package postgres

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// IncidentRepository implements application.IncidentRepository using PostgreSQL 16
type IncidentRepository struct {
	db *DB
}

// NewIncidentRepository creates an incident repository adapter
func NewIncidentRepository(db *DB) *IncidentRepository {
	return &IncidentRepository{db: db}
}

// Save persists a new safety incident with tenant RLS enforcement
func (r *IncidentRepository) Save(ctx context.Context, incident *domain.SafetyIncident) error {
	return r.db.WithTenantTx(ctx, incident.SiteID, func(tx *sql.Tx) error {
		bboxesJSON, err := json.Marshal(incident.BBoxes)
		if err != nil {
			return fmt.Errorf("failed to marshal bboxes: %w", err)
		}

		query := `
			INSERT INTO events (
				id, site_id, camera_id, zone_id, event_type, severity,
				status, occurred_at_utc, model_id, model_version,
				confidence, bboxes, snapshot_rel_path, created_at_utc
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
			ON CONFLICT (site_id, id) DO NOTHING
		`

		_, err = tx.ExecContext(
			ctx, query,
			incident.ID, incident.SiteID, incident.CameraID, incident.ZoneID,
			string(incident.EventType), string(incident.Severity), string(incident.Status),
			incident.OccurredAtUTC, incident.ModelID, incident.ModelVersion,
			incident.Confidence, bboxesJSON, incident.SnapshotRelPath, incident.CreatedAtUTC,
		)
		if err != nil {
			return fmt.Errorf("failed to insert incident: %w", err)
		}
		return nil
	})
}

// GetByID retrieves a single incident by ID within a site boundary
func (r *IncidentRepository) GetByID(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error) {
	var incident domain.SafetyIncident
	var bboxesJSON []byte
	var severityStr, statusStr string
	var ackBy, resBy, disReason sql.NullString
	var ackAt, resAt *time.Time

	err := r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT 
				id, site_id, camera_id, zone_id, event_type, severity,
				status, occurred_at_utc, model_id, model_version,
				confidence, bboxes, snapshot_rel_path, acknowledged_by,
				acknowledged_at_utc, resolved_by, resolved_at_utc,
				dismissal_reason, created_at_utc
			FROM events
			WHERE id = $1 AND site_id = $2
		`

		row := tx.QueryRowContext(ctx, query, id, siteID)
		err := row.Scan(
			&incident.ID, &incident.SiteID, &incident.CameraID, &incident.ZoneID,
			&incident.EventType, &severityStr, &statusStr, &incident.OccurredAtUTC,
			&incident.ModelID, &incident.ModelVersion, &incident.Confidence,
			&bboxesJSON, &incident.SnapshotRelPath, &ackBy, &ackAt,
			&resBy, &resAt, &disReason, &incident.CreatedAtUTC,
		)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return fmt.Errorf("incident not found: %s", id)
			}
			return fmt.Errorf("failed to query incident: %w", err)
		}

		incident.Severity = domain.IncidentSeverity(severityStr)
		incident.Status = domain.IncidentStatus(statusStr)
		if ackBy.Valid {
			incident.AcknowledgedBy = ackBy.String
			incident.AcknowledgedAt = ackAt
		}
		if resBy.Valid {
			incident.ResolvedBy = resBy.String
			incident.ResolvedAt = resAt
		}
		if disReason.Valid {
			incident.DismissalReason = disReason.String
		}

		if len(bboxesJSON) > 0 {
			if err := json.Unmarshal(bboxesJSON, &incident.BBoxes); err != nil {
				return fmt.Errorf("failed to unmarshal bboxes: %w", err)
			}
		}

		return nil
	})

	if err != nil {
		return nil, err
	}
	return &incident, nil
}

// ListActive lists all non-resolved/non-dismissed incidents for a site
func (r *IncidentRepository) ListActive(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error) {
	var incidents []*domain.SafetyIncident

	err := r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT 
				id, site_id, camera_id, zone_id, event_type, severity,
				status, occurred_at_utc, model_id, model_version,
				confidence, bboxes, snapshot_rel_path, acknowledged_by,
				acknowledged_at_utc, resolved_by, resolved_at_utc,
				dismissal_reason, created_at_utc
			FROM events
			WHERE site_id = $1 AND status IN ('NEW', 'ACKNOWLEDGED')
			ORDER BY occurred_at_utc DESC
			LIMIT 100
		`

		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return fmt.Errorf("failed to query active incidents: %w", err)
		}
		defer rows.Close()

		for rows.Next() {
			var inc domain.SafetyIncident
			var bboxesJSON []byte
			var severityStr, statusStr string
			var ackBy, resBy, disReason sql.NullString
			var ackAt, resAt *time.Time

			if err := rows.Scan(
				&inc.ID, &inc.SiteID, &inc.CameraID, &inc.ZoneID,
				&inc.EventType, &severityStr, &statusStr, &inc.OccurredAtUTC,
				&inc.ModelID, &inc.ModelVersion, &inc.Confidence,
				&bboxesJSON, &inc.SnapshotRelPath, &ackBy, &ackAt,
				&resBy, &resAt, &disReason, &inc.CreatedAtUTC,
			); err != nil {
				return fmt.Errorf("failed to scan incident row: %w", err)
			}

			inc.Severity = domain.IncidentSeverity(severityStr)
			inc.Status = domain.IncidentStatus(statusStr)
			if ackBy.Valid {
				inc.AcknowledgedBy = ackBy.String
				inc.AcknowledgedAt = ackAt
			}
			if resBy.Valid {
				inc.ResolvedBy = resBy.String
				inc.ResolvedAt = resAt
			}
			if disReason.Valid {
				inc.DismissalReason = disReason.String
			}
			if len(bboxesJSON) > 0 {
				_ = json.Unmarshal(bboxesJSON, &inc.BBoxes)
			}

			incidents = append(incidents, &inc)
		}
		return rows.Err()
	})

	if err != nil {
		return nil, err
	}
	return incidents, nil
}

// Update saves state transitions (ACKNOWLEDGE, RESOLVE, DISMISS)
func (r *IncidentRepository) Update(ctx context.Context, incident *domain.SafetyIncident) error {
	return r.db.WithTenantTx(ctx, incident.SiteID, func(tx *sql.Tx) error {
		query := `
			UPDATE events SET
				status = $1,
				acknowledged_by = $2,
				acknowledged_at_utc = $3,
				resolved_by = $4,
				resolved_at_utc = $5,
				dismissal_reason = $6
			WHERE id = $7 AND site_id = $8
		`

		var ackBy, resBy, disReason sql.NullString
		if incident.AcknowledgedBy != "" {
			ackBy = sql.NullString{String: incident.AcknowledgedBy, Valid: true}
		}
		if incident.ResolvedBy != "" {
			resBy = sql.NullString{String: incident.ResolvedBy, Valid: true}
		}
		if incident.DismissalReason != "" {
			disReason = sql.NullString{String: incident.DismissalReason, Valid: true}
		}

		res, err := tx.ExecContext(
			ctx, query,
			string(incident.Status), ackBy, incident.AcknowledgedAt,
			resBy, incident.ResolvedAt, disReason,
			incident.ID, incident.SiteID,
		)
		if err != nil {
			return fmt.Errorf("failed to update incident: %w", err)
		}

		rows, err := res.RowsAffected()
		if err != nil {
			return err
		}
		if rows == 0 {
			return fmt.Errorf("incident not found for update: %s", incident.ID)
		}

		return nil
	})
}
