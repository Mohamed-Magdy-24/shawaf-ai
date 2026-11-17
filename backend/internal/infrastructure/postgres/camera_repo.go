package postgres

import (
	"context"
	"database/sql"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/lib/pq"
)

func (d *DB) RegisterCamera(ctx context.Context, cam *ports.Camera) error {
	return d.WithSiteTx(ctx, cam.SiteID, func(tx *sql.Tx) error {
		query := `
			INSERT INTO cameras (site_id, camera_id, nvr_id, name, rtsp_sub_url, onvif_host, fps_target, zones, status)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			ON CONFLICT (site_id, camera_id) DO UPDATE SET
				name = EXCLUDED.name,
				nvr_id = EXCLUDED.nvr_id,
				rtsp_sub_url = EXCLUDED.rtsp_sub_url,
				onvif_host = EXCLUDED.onvif_host,
				fps_target = EXCLUDED.fps_target,
				zones = EXCLUDED.zones,
				status = EXCLUDED.status`

		var nvrID, onvifHost *string
		if cam.NVRID != "" {
			nvrID = &cam.NVRID
		}
		if cam.ONVIFHost != "" {
			onvifHost = &cam.ONVIFHost
		}
		status := cam.Status
		if status == "" {
			status = "ACTIVE"
		}
		targetFPS := cam.TargetFPS
		if targetFPS <= 0 {
			targetFPS = 15
		}

		_, err := tx.ExecContext(ctx, query,
			cam.SiteID, cam.CameraID, nvrID, cam.Name, cam.RTSPURL, onvifHost, targetFPS, pq.Array(cam.Zones), status,
		)
		return err
	})
}

func (d *DB) GetCameras(ctx context.Context, siteID string) ([]*ports.Camera, error) {
	var cameras []*ports.Camera
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, camera_id, COALESCE(nvr_id, ''), name, rtsp_sub_url, COALESCE(onvif_host, ''), COALESCE(fps_target, 15), COALESCE(zones, '{}'), status
			FROM cameras
			WHERE site_id = $1
			ORDER BY camera_id ASC`
		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var c ports.Camera
			var zones pq.StringArray
			if err := rows.Scan(&c.SiteID, &c.CameraID, &c.NVRID, &c.Name, &c.RTSPURL, &c.ONVIFHost, &c.TargetFPS, &zones, &c.Status); err != nil {
				return err
			}
			c.Zones = []string(zones)
			c.RTSPURL = ports.SanitizeRTSPURL(c.RTSPURL)
			cameras = append(cameras, &c)
		}
		return rows.Err()
	})
	return cameras, err
}

func (d *DB) GetCamera(ctx context.Context, siteID, cameraID string) (*ports.Camera, error) {
	var c ports.Camera
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, camera_id, COALESCE(nvr_id, ''), name, rtsp_sub_url, COALESCE(onvif_host, ''), COALESCE(fps_target, 15), COALESCE(zones, '{}'), status
			FROM cameras
			WHERE site_id = $1 AND camera_id = $2`
		var zones pq.StringArray
		err := tx.QueryRowContext(ctx, query, siteID, cameraID).Scan(
			&c.SiteID, &c.CameraID, &c.NVRID, &c.Name, &c.RTSPURL, &c.ONVIFHost, &c.TargetFPS, &zones, &c.Status,
		)
		if err != nil {
			if err == sql.ErrNoRows {
				return ports.ErrCameraNotFound
			}
			return err
		}
		c.Zones = []string(zones)
		c.RTSPURL = ports.SanitizeRTSPURL(c.RTSPURL)
		return nil
	})
	if err != nil {
		return nil, err
	}
	return &c, nil
}

// Ensure DB implements ports.CameraRegistryPort
var _ ports.CameraRegistryPort = (*DB)(nil)
