package postgres

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// CameraRepository implements application.CameraRepository using PostgreSQL 16
type CameraRepository struct {
	db *DB
}

// NewCameraRepository creates a camera repository adapter
func NewCameraRepository(db *DB) *CameraRepository {
	return &CameraRepository{db: db}
}

// GetByID retrieves a single camera by ID scoped to its site
func (r *CameraRepository) GetByID(ctx context.Context, siteID, cameraID string) (*domain.Camera, error) {
	var cam domain.Camera
	var zoneID sql.NullString
	var lastHeartbeat sql.NullTime

	err := r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT 
				id, site_id, name, rtsp_main_url, rtsp_sub_url, zone_id,
				status, fps_decoded, dropped_frames, last_heartbeat, created_at_utc
			FROM cameras
			WHERE id = $1 AND site_id = $2
		`

		row := tx.QueryRowContext(ctx, query, cameraID, siteID)
		err := row.Scan(
			&cam.ID, &cam.SiteID, &cam.Name, &cam.RTSPMainURL, &cam.RTSPSubURL,
			&zoneID, &cam.Status, &cam.FPSDecoded, &cam.DroppedFrames,
			&lastHeartbeat, &cam.CreatedAtUTC,
		)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return fmt.Errorf("camera not found: %s", cameraID)
			}
			return fmt.Errorf("failed to query camera: %w", err)
		}

		if zoneID.Valid {
			cam.ZoneID = zoneID.String
		}
		if lastHeartbeat.Valid {
			cam.LastHeartbeat = lastHeartbeat.Time
		}

		return nil
	})

	if err != nil {
		return nil, err
	}
	return &cam, nil
}

// List lists all cameras for a site
func (r *CameraRepository) List(ctx context.Context, siteID string) ([]*domain.Camera, error) {
	var cameras []*domain.Camera

	err := r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT 
				id, site_id, name, rtsp_main_url, rtsp_sub_url, zone_id,
				status, fps_decoded, dropped_frames, last_heartbeat, created_at_utc
			FROM cameras
			WHERE site_id = $1
			ORDER BY id ASC
		`

		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return fmt.Errorf("failed to query cameras: %w", err)
		}
		defer rows.Close()

		for rows.Next() {
			var cam domain.Camera
			var zoneID sql.NullString
			var lastHeartbeat sql.NullTime

			if err := rows.Scan(
				&cam.ID, &cam.SiteID, &cam.Name, &cam.RTSPMainURL, &cam.RTSPSubURL,
				&zoneID, &cam.Status, &cam.FPSDecoded, &cam.DroppedFrames,
				&lastHeartbeat, &cam.CreatedAtUTC,
			); err != nil {
				return fmt.Errorf("failed to scan camera row: %w", err)
			}

			if zoneID.Valid {
				cam.ZoneID = zoneID.String
			}
			if lastHeartbeat.Valid {
				cam.LastHeartbeat = lastHeartbeat.Time
			}

			cameras = append(cameras, &cam)
		}
		return rows.Err()
	})

	if err != nil {
		return nil, err
	}
	return cameras, nil
}

// UpdateTelemetry updates live stream stats from Python worker heartbeat
func (r *CameraRepository) UpdateTelemetry(
	ctx context.Context,
	siteID, cameraID string,
	online bool,
	fps float64,
	dropped uint64,
	lastHeartbeat time.Time,
) error {
	return r.db.WithTenantTx(ctx, siteID, func(tx *sql.Tx) error {
		status := domain.CameraStatusOnline
		if !online {
			status = domain.CameraStatusOffline
		}

		query := `
			UPDATE cameras SET
				status = $1,
				fps_decoded = $2,
				dropped_frames = $3,
				last_heartbeat = $4
			WHERE id = $5 AND site_id = $6
		`

		_, err := tx.ExecContext(ctx, query, string(status), fps, dropped, lastHeartbeat, cameraID, siteID)
		if err != nil {
			return fmt.Errorf("failed to update camera telemetry: %w", err)
		}
		return nil
	})
}
