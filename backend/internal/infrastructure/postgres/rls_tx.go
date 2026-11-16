package postgres

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
	_ "github.com/lib/pq"
)

type DB struct {
	pool *sql.DB
}

func NewDB(dsn string) (*DB, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("postgres open error: %w", err)
	}
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(15 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("postgres ping error: %w", err)
	}
	return &DB{pool: db}, nil
}

func (d *DB) Close() error {
	return d.pool.Close()
}

// WithSiteTx executes a transaction bounded to a specific tenant site_id.
// It sets the session setting 'app.site_id' locally, which PostgreSQL Row-Level Security policies enforce.
func (d *DB) WithSiteTx(ctx context.Context, siteID string, fn func(tx *sql.Tx) error) error {
	tx, err := d.pool.BeginTx(ctx, &sql.TxOptions{Isolation: sql.LevelReadCommitted})
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback()

	// Enforce tenant boundary in RLS
	setQuery := fmt.Sprintf("SET LOCAL app.site_id = '%s'", siteID)
	if _, err := tx.ExecContext(ctx, setQuery); err != nil {
		return fmt.Errorf("set site_id RLS context: %w", err)
	}

	if err := fn(tx); err != nil {
		return err
	}
	return tx.Commit()
}

// InsertEvent inserts an event into the partitioned table and enqueues an outbox row atomically.
func (d *DB) InsertEvent(ctx context.Context, event *domain.Event) error {
	return d.WithSiteTx(ctx, event.SiteID, func(tx *sql.Tx) error {
		// 1. Insert into partitioned events table
		eventQuery := `
			INSERT INTO events (
				event_id, site_id, camera_id, zone_id, event_type, severity,
				occurred_at, received_at, model_id, model_version, rule_id, rule_version,
				confidence, snapshot_rel_path, subject_status, state
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
			ON CONFLICT (event_id, site_id, occurred_at) DO NOTHING`

		_, err := tx.ExecContext(ctx, eventQuery,
			event.EventID, event.SiteID, event.CameraID, event.ZoneID, event.EventType, string(event.Severity),
			event.OccurredAt, event.ReceivedAt, event.ModelID, event.ModelVersion, event.RuleID, event.RuleVersion,
			event.Confidence, event.SnapshotRelPath, event.SubjectStatus, string(event.State),
		)
		if err != nil {
			return fmt.Errorf("insert event: %w", err)
		}

		// 2. Enqueue in Transactional Outbox (ADR-013)
		payload, err := json.Marshal(event)
		if err != nil {
			return fmt.Errorf("marshal outbox payload: %w", err)
		}

		priority := "NORMAL"
		if event.Severity == domain.SeverityCriticalFire {
			priority = "CRITICAL_FIRE"
		} else if event.Severity == domain.SeverityCritical {
			priority = "CRITICAL"
		}

		idempotencyKey := fmt.Sprintf("%s:%s", event.SiteID, event.EventID)

		outboxQuery := `
			INSERT INTO outbox (
				event_id, site_id, priority, destination_channel, payload_json, idempotency_key
			) VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (idempotency_key) DO NOTHING`

		_, err = tx.ExecContext(ctx, outboxQuery,
			event.EventID, event.SiteID, priority, "WEBSOCKET", payload, idempotencyKey,
		)
		if err != nil {
			return fmt.Errorf("insert outbox: %w", err)
		}

		// If fire, trigger immediate unthrottled LISTEN/NOTIFY
		if priority == "CRITICAL_FIRE" {
			notifyQuery := fmt.Sprintf("NOTIFY outbox_fire, '%s'", idempotencyKey)
			_, _ = tx.ExecContext(ctx, notifyQuery)
		}
		return nil
	})
}

func (d *DB) GetEvents(ctx context.Context, siteID string, limit int, offset int) ([]*domain.Event, error) {
	var events []*domain.Event
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT event_id, site_id, camera_id, COALESCE(zone_id, ''), event_type, severity,
			       occurred_at, received_at, model_id, model_version, rule_id, rule_version,
			       confidence, snapshot_rel_path, subject_status, state, COALESCE(dismissed_reason, ''), created_at
			FROM events
			ORDER BY occurred_at DESC
			LIMIT $1 OFFSET $2`

		rows, err := tx.QueryContext(ctx, query, limit, offset)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var e domain.Event
			var sev, st string
			if err := rows.Scan(
				&e.EventID, &e.SiteID, &e.CameraID, &e.ZoneID, &e.EventType, &sev,
				&e.OccurredAt, &e.ReceivedAt, &e.ModelID, &e.ModelVersion, &e.RuleID, &e.RuleVersion,
				&e.Confidence, &e.SnapshotRelPath, &e.SubjectStatus, &st, &e.DismissedReason, &e.CreatedAt,
			); err != nil {
				return err
			}
			e.Severity = domain.Severity(sev)
			e.State = domain.EventState(st)
			events = append(events, &e)
		}
		return nil
	})
	return events, err
}

func (d *DB) UpdateEventState(ctx context.Context, siteID, eventID string, occurredAt time.Time, newState domain.EventState, reason, userID string) error {
	return d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			UPDATE events
			SET state = $1, dismissed_reason = $2
			WHERE event_id = $3 AND site_id = $4 AND occurred_at = $5`

		res, err := tx.ExecContext(ctx, query, string(newState), reason, eventID, siteID, occurredAt)
		if err != nil {
			return err
		}
		rows, _ := res.RowsAffected()
		if rows == 0 {
			return sql.ErrNoRows
		}

		// Log in incident_actions
		actionQuery := `
			INSERT INTO incident_actions (event_id, site_id, user_id, action_type, note)
			VALUES ($1, $2, $3, $4, $5)`
		_, err = tx.ExecContext(ctx, actionQuery, eventID, siteID, userID, string(newState), reason)
		return err
	})
}

func (d *DB) UpdateCameraHealth(ctx context.Context, siteID, cameraID string, online bool, fps float64, drops uint64) error {
	return d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			INSERT INTO camera_health (site_id, camera_id, online, fps_decoded, dropped_frames, last_heartbeat_at)
			VALUES ($1, $2, $3, $4, $5, NOW())
			ON CONFLICT (site_id, camera_id) DO UPDATE SET
				online = EXCLUDED.online,
				fps_decoded = EXCLUDED.fps_decoded,
				dropped_frames = EXCLUDED.dropped_frames,
				last_heartbeat_at = NOW()`
		_, err := tx.ExecContext(ctx, query, siteID, cameraID, online, fps, drops)
		return err
	})
}
