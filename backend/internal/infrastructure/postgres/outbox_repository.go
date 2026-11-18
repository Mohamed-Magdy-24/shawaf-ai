package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/lib/pq"
)

// OutboxRepository implements application.OutboxRepository using PostgreSQL 16
// Employs FOR UPDATE SKIP LOCKED and lease expiration reaper for bulletproof delivery
type OutboxRepository struct {
	db *DB
}

// NewOutboxRepository creates an outbox repository adapter
func NewOutboxRepository(db *DB) *OutboxRepository {
	return &OutboxRepository{db: db}
}

// Enqueue inserts a new event into the transactional outbox
func (r *OutboxRepository) Enqueue(
	ctx context.Context,
	siteID, eventID string,
	payload []byte,
	isFirePriority bool,
) error {
	return r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			INSERT INTO outbox (
				event_id, site_id, payload, is_fire_priority, status, created_at_utc
			) VALUES ($1, $2, $3, $4, 'PENDING', $5)
		`
		_, err := tx.ExecContext(ctx, query, eventID, siteID, payload, isFirePriority, time.Now().UTC())
		if err != nil {
			return fmt.Errorf("failed to enqueue outbox row: %w", err)
		}
		return nil
	})
}

// FetchAndLockPending claims up to `limit` pending outbox records
// Uses secure stored procedure claim_pending_outbox (SECURITY DEFINER)
// preventing broad cross-tenant table access
func (r *OutboxRepository) FetchAndLockPending(
	ctx context.Context,
	limit int,
	lockDuration time.Duration,
) ([]*domain.OutboxRecord, error) {
	if limit <= 0 {
		limit = 50
	}
	if lockDuration <= 0 {
		lockDuration = 30 * time.Second
	}

	var records []*domain.OutboxRecord
	durationInterval := fmt.Sprintf("%d seconds", int(lockDuration.Seconds()))

	// Try secure stored procedure first (SECURITY DEFINER, least privilege)
	query := `
		SELECT id, event_id, site_id, payload, is_fire_priority, status, retry_count, created_at_utc
		FROM claim_pending_outbox($1, $2::interval)
	`
	rows, err := r.db.QueryContext(ctx, query, limit, durationInterval)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var rec domain.OutboxRecord
			var statusStr string

			if err := rows.Scan(
				&rec.ID, &rec.EventID, &rec.SiteID, &rec.Payload,
				&rec.IsFirePriority, &statusStr, &rec.RetryCount, &rec.CreatedAtUTC,
			); err != nil {
				return nil, fmt.Errorf("failed to scan outbox row: %w", err)
			}

			rec.Status = domain.OutboxStatus(statusStr)
			lockedUntil := time.Now().UTC().Add(lockDuration)
			rec.LockedUntil = &lockedUntil
			records = append(records, &rec)
		}
		if err := rows.Err(); err != nil {
			return nil, err
		}
		return records, nil
	}

	// Fallback to direct transaction without tenant bypass
	tx, txErr := r.db.BeginTx(ctx, nil)
	if txErr != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", txErr)
	}
	defer tx.Rollback()

	selectQuery := `
		SELECT id, event_id, site_id, payload, is_fire_priority, status, retry_count, created_at_utc
		FROM outbox
		WHERE status = 'PENDING'
		ORDER BY is_fire_priority DESC, id ASC
		LIMIT $1
		FOR UPDATE SKIP LOCKED
	`

	rows, err = tx.QueryContext(ctx, selectQuery, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to query pending outbox: %w", err)
	}
	defer rows.Close()

	var ids []int64
	for rows.Next() {
		var rec domain.OutboxRecord
		var statusStr string

		if err := rows.Scan(
			&rec.ID, &rec.EventID, &rec.SiteID, &rec.Payload,
			&rec.IsFirePriority, &statusStr, &rec.RetryCount, &rec.CreatedAtUTC,
		); err != nil {
			return nil, fmt.Errorf("failed to scan outbox row: %w", err)
		}

		rec.Status = domain.OutboxStatus(statusStr)
		ids = append(ids, rec.ID)
		records = append(records, &rec)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	if len(ids) == 0 {
		return nil, nil
	}

	lockedUntil := time.Now().UTC().Add(lockDuration)
	updateQuery := `
		UPDATE outbox
		SET status = 'PROCESSING', locked_until = $1
		WHERE id = ANY($2)
	`

	_, err = tx.ExecContext(ctx, updateQuery, lockedUntil, pq.Array(ids))
	if err != nil {
		return nil, fmt.Errorf("failed to mark outbox rows as PROCESSING: %w", err)
	}

	for _, rec := range records {
		rec.Status = domain.OutboxStatusProcessing
		rec.LockedUntil = &lockedUntil
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit outbox batch: %w", err)
	}

	return records, nil
}

// MarkPublished marks an outbox record as successfully delivered
func (r *OutboxRepository) MarkPublished(ctx context.Context, id int64) error {
	// Try secure stored procedure first
	var success bool
	err := r.db.QueryRowContext(ctx, "SELECT mark_outbox_published($1)", id).Scan(&success)
	if err == nil {
		return nil
	}

	// Fallback direct SQL without app.site_id bypass
	query := `
		UPDATE outbox
		SET status = 'PUBLISHED', published_at_utc = $1, locked_until = NULL
		WHERE id = $2
	`
	_, err = r.db.ExecContext(ctx, query, time.Now().UTC(), id)
	if err != nil {
		return fmt.Errorf("failed to mark outbox row as PUBLISHED: %w", err)
	}
	return nil
}

// ReapExpiredLeases recovers orphaned PROCESSING records whose leases expired
// Guaranteed recovery on edge daemon restart after crash/SIGKILL
func (r *OutboxRepository) ReapExpiredLeases(ctx context.Context) (int64, error) {
	var reaped int64
	err := r.db.QueryRowContext(ctx, "SELECT reap_expired_outbox_leases()").Scan(&reaped)
	if err == nil {
		return reaped, nil
	}

	// Fallback direct SQL
	query := `
		UPDATE outbox
		SET status = 'PENDING', locked_until = NULL, retry_count = retry_count + 1
		WHERE status = 'PROCESSING' AND locked_until < $1
	`
	res, err := r.db.ExecContext(ctx, query, time.Now().UTC())
	if err != nil {
		return 0, fmt.Errorf("failed to execute lease reaper query: %w", err)
	}
	reaped, err = res.RowsAffected()
	return reaped, err
}
