package postgres

import (
	"context"
	"database/sql"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/lib/pq"
)

// -----------------------------------------------------------------------------
// Cameras
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// NVRs
// -----------------------------------------------------------------------------

func (d *DB) RegisterNVR(ctx context.Context, nvr *ports.NVR) error {
	return d.WithSiteTx(ctx, nvr.SiteID, func(tx *sql.Tx) error {
		query := `
			INSERT INTO nvrs (site_id, nvr_id, name, vendor, host_ip, port, username, encrypted_password, status)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			ON CONFLICT (site_id, nvr_id) DO UPDATE SET
				name = EXCLUDED.name,
				vendor = EXCLUDED.vendor,
				host_ip = EXCLUDED.host_ip,
				port = EXCLUDED.port,
				username = EXCLUDED.username,
				encrypted_password = EXCLUDED.encrypted_password,
				status = EXCLUDED.status`

		port := nvr.Port
		if port <= 0 {
			port = 554
		}
		status := nvr.Status
		if status == "" {
			status = "ACTIVE"
		}
		vendor := nvr.Vendor
		if vendor == "" {
			vendor = "GENERIC"
		}

		_, err := tx.ExecContext(ctx, query,
			nvr.SiteID, nvr.NVRID, nvr.Name, vendor, nvr.HostIP, port, nvr.Username, nvr.EncryptedPassword, status,
		)
		return err
	})
}

func (d *DB) GetNVRs(ctx context.Context, siteID string) ([]*ports.NVR, error) {
	var nvrs []*ports.NVR
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, nvr_id, name, vendor, host_ip, port, username, encrypted_password, status, created_at
			FROM nvrs
			WHERE site_id = $1
			ORDER BY nvr_id ASC`
		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var n ports.NVR
			if err := rows.Scan(&n.SiteID, &n.NVRID, &n.Name, &n.Vendor, &n.HostIP, &n.Port, &n.Username, &n.EncryptedPassword, &n.Status, &n.CreatedAt); err != nil {
				return err
			}
			nvrs = append(nvrs, &n)
		}
		return rows.Err()
	})
	return nvrs, err
}

func (d *DB) GetNVR(ctx context.Context, siteID, nvrID string) (*ports.NVR, error) {
	var n ports.NVR
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, nvr_id, name, vendor, host_ip, port, username, encrypted_password, status, created_at
			FROM nvrs
			WHERE site_id = $1 AND nvr_id = $2`
		err := tx.QueryRowContext(ctx, query, siteID, nvrID).Scan(
			&n.SiteID, &n.NVRID, &n.Name, &n.Vendor, &n.HostIP, &n.Port, &n.Username, &n.EncryptedPassword, &n.Status, &n.CreatedAt,
		)
		if err != nil {
			if err == sql.ErrNoRows {
				return ports.ErrNVRNotFound
			}
			return err
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return &n, nil
}

// -----------------------------------------------------------------------------
// Employees & Presence
// -----------------------------------------------------------------------------

func (d *DB) RegisterEmployee(ctx context.Context, emp *ports.Employee, embeddingBytes []byte, photoSHA256 string) error {
	return d.WithSiteTx(ctx, emp.SiteID, func(tx *sql.Tx) error {
		// 1. Upsert employee
		empQuery := `
			INSERT INTO employees (site_id, employee_id, full_name, department, photo_rel_path, source_type, is_active)
			VALUES ($1, $2, $3, $4, $5, $6, $7)
			ON CONFLICT (site_id, employee_id) DO UPDATE SET
				full_name = EXCLUDED.full_name,
				department = EXCLUDED.department,
				photo_rel_path = COALESCE(EXCLUDED.photo_rel_path, employees.photo_rel_path),
				source_type = EXCLUDED.source_type,
				is_active = EXCLUDED.is_active`

		sourceType := emp.SourceType
		if sourceType == "" {
			sourceType = "MANUAL_UPLOAD"
		}
		dept := emp.Department
		if dept == "" {
			dept = "OPERATIONS"
		}

		var photoPath *string
		if emp.PhotoRelPath != "" {
			photoPath = &emp.PhotoRelPath
		}

		_, err := tx.ExecContext(ctx, empQuery,
			emp.SiteID, emp.EmployeeID, emp.FullName, dept, photoPath, sourceType, emp.IsActive,
		)
		if err != nil {
			return err
		}

		// 2. Insert embedding if provided
		if len(embeddingBytes) > 0 {
			embedQuery := `
				INSERT INTO employee_embeddings (site_id, employee_id, model_version, embedding_fp32_bytes, photo_sha256)
				VALUES ($1, $2, $3, $4, $5)
				ON CONFLICT (site_id, employee_id, model_version) DO UPDATE SET
					embedding_fp32_bytes = EXCLUDED.embedding_fp32_bytes,
					photo_sha256 = EXCLUDED.photo_sha256,
					created_at = NOW()`
			_, err = tx.ExecContext(ctx, embedQuery, emp.SiteID, emp.EmployeeID, "mobilefacenet-v1", embeddingBytes, photoSHA256)
			if err != nil {
				return err
			}
		}

		return nil
	})
}

func (d *DB) GetEmployees(ctx context.Context, siteID string) ([]*ports.Employee, error) {
	var employees []*ports.Employee
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, employee_id, full_name, department, COALESCE(photo_rel_path, ''), source_type, is_active, created_at
			FROM employees
			WHERE site_id = $1
			ORDER BY full_name ASC`
		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var e ports.Employee
			if err := rows.Scan(&e.SiteID, &e.EmployeeID, &e.FullName, &e.Department, &e.PhotoRelPath, &e.SourceType, &e.IsActive, &e.CreatedAt); err != nil {
				return err
			}
			employees = append(employees, &e)
		}
		return rows.Err()
	})
	return employees, err
}

func (d *DB) GetEmployee(ctx context.Context, siteID, employeeID string) (*ports.Employee, error) {
	var e ports.Employee
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT site_id, employee_id, full_name, department, COALESCE(photo_rel_path, ''), source_type, is_active, created_at
			FROM employees
			WHERE site_id = $1 AND employee_id = $2`
		err := tx.QueryRowContext(ctx, query, siteID, employeeID).Scan(
			&e.SiteID, &e.EmployeeID, &e.FullName, &e.Department, &e.PhotoRelPath, &e.SourceType, &e.IsActive, &e.CreatedAt,
		)
		if err != nil {
			if err == sql.ErrNoRows {
				return ports.ErrEmployeeNotFound
			}
			return err
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return &e, nil
}

func (d *DB) GetEmployeePresence(ctx context.Context, siteID string) ([]*ports.EmployeePresenceRecord, error) {
	var presence []*ports.EmployeePresenceRecord
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT p.site_id, p.employee_id, e.full_name, e.department, p.camera_id, COALESCE(p.zone_id, ''), p.confidence, p.last_seen_at
			FROM employee_presence p
			JOIN employees e ON e.site_id = p.site_id AND e.employee_id = p.employee_id
			WHERE p.site_id = $1
			ORDER BY p.last_seen_at DESC`
		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var pr ports.EmployeePresenceRecord
			if err := rows.Scan(&pr.SiteID, &pr.EmployeeID, &pr.FullName, &pr.Department, &pr.CameraID, &pr.ZoneID, &pr.Confidence, &pr.LastSeenAt); err != nil {
				return err
			}
			presence = append(presence, &pr)
		}
		return rows.Err()
	})
	return presence, err
}

func (d *DB) GetEmployeeEmbeddings(ctx context.Context, siteID string) ([]*ports.EmployeeEmbeddingRecord, error) {
	var embeddings []*ports.EmployeeEmbeddingRecord
	err := d.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		query := `
			SELECT emb.site_id, emb.employee_id, e.full_name, emb.model_version, emb.embedding_fp32_bytes, emb.photo_sha256, emb.created_at
			FROM employee_embeddings emb
			JOIN employees e ON e.site_id = emb.site_id AND e.employee_id = emb.employee_id
			WHERE emb.site_id = $1
			ORDER BY emb.employee_id ASC`
		rows, err := tx.QueryContext(ctx, query, siteID)
		if err != nil {
			return err
		}
		defer rows.Close()

		for rows.Next() {
			var rec ports.EmployeeEmbeddingRecord
			if err := rows.Scan(&rec.SiteID, &rec.EmployeeID, &rec.FullName, &rec.ModelVersion, &rec.EmbeddingFp32Bytes, &rec.PhotoSHA256, &rec.CreatedAt); err != nil {
				return err
			}
			embeddings = append(embeddings, &rec)
		}
		return rows.Err()
	})
	return embeddings, err
}

// Interface assertions
var _ ports.CameraRegistryPort = (*DB)(nil)
var _ ports.NVRRegistryPort = (*DB)(nil)
var _ ports.EmployeeRegistryPort = (*DB)(nil)
