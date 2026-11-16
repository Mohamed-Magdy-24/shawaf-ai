package application

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// CoverageWatchdog monitors camera heartbeats and triggers NFR-OBS-002 operational alerts
type CoverageWatchdog struct {
	db             *sql.DB
	repo           domain.EventRepository
	timeoutSec     float64
	tickerInterval time.Duration
	stopCh         chan struct{}
}

// NewCoverageWatchdog creates an operational health monitor
func NewCoverageWatchdog(db *sql.DB, repo domain.EventRepository, timeoutSec float64) *CoverageWatchdog {
	if timeoutSec <= 0 {
		timeoutSec = 15.0
	}
	return &CoverageWatchdog{
		db:             db,
		repo:           repo,
		timeoutSec:     timeoutSec,
		tickerInterval: 3 * time.Second,
		stopCh:         make(chan struct{}),
	}
}

// Start begins periodic health evaluation across all sites
func (w *CoverageWatchdog) Start(ctx context.Context) {
	ticker := time.NewTicker(w.tickerInterval)
	go func() {
		defer ticker.Stop()
		log.Printf("[CoverageWatchdog] Started. Health check interval: %v, timeout: %.1fs", w.tickerInterval, w.timeoutSec)
		for {
			select {
			case <-ctx.Done():
				return
			case <-w.stopCh:
				return
			case <-ticker.C:
				if err := w.scanStaleCameras(ctx); err != nil {
					log.Printf("[CoverageWatchdog] Scan error: %v", err)
				}
			}
		}
	}()
}

// Stop gracefully terminates the watchdog
func (w *CoverageWatchdog) Stop() {
	close(w.stopCh)
}

// scanStaleCameras iterates through active sites and evaluates health within each site's RLS boundary
func (w *CoverageWatchdog) scanStaleCameras(ctx context.Context) error {
	threshold := time.Now().UTC().Add(-time.Duration(w.timeoutSec * float64(time.Second)))

	siteRows, err := w.db.QueryContext(ctx, `SELECT id FROM sites WHERE is_active = true`)
	if err != nil {
		return fmt.Errorf("failed to query active sites: %w", err)
	}
	defer siteRows.Close()

	var siteIDs []string
	for siteRows.Next() {
		var id string
		if err := siteRows.Scan(&id); err == nil {
			siteIDs = append(siteIDs, id)
		}
	}

	for _, siteID := range siteIDs {
		w.scanStaleCamerasForSite(ctx, siteID, threshold)
	}

	return nil
}

func (w *CoverageWatchdog) scanStaleCamerasForSite(ctx context.Context, siteID string, threshold time.Time) {
	tx, err := w.db.BeginTx(ctx, nil)
	if err != nil {
		return
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, "SELECT set_config('app.site_id', $1, true)", siteID); err != nil {
		log.Printf("[CoverageWatchdog] set_config error for site %s: %v", siteID, err)
		return
	}

	query := `
		SELECT c.camera_id, c.name, h.last_heartbeat_at
		FROM cameras c
		JOIN camera_health h ON c.site_id = h.site_id AND c.camera_id = h.camera_id
		WHERE h.online = true AND (h.last_heartbeat_at IS NULL OR h.last_heartbeat_at < $1)
	`
	rows, err := tx.QueryContext(ctx, query, threshold)
	if err != nil {
		return
	}
	defer rows.Close()

	type StaleCam struct {
		CameraID      string
		Name          string
		LastHeartbeat *time.Time
	}

	var staleList []StaleCam
	for rows.Next() {
		var s StaleCam
		if err := rows.Scan(&s.CameraID, &s.Name, &s.LastHeartbeat); err != nil {
			log.Printf("[CoverageWatchdog] Row scan error: %v", err)
			continue
		}
		staleList = append(staleList, s)
	}
	rows.Close()

	for _, cam := range staleList {
		log.Printf("[CoverageWatchdog] NFR-OBS-002 ALERT: Camera %s at site %s missed heartbeat (>%.1fs). Marking offline and raising COVERAGE_LOST.",
			cam.CameraID, siteID, w.timeoutSec)

		// 1. Mark camera offline within site boundary
		_, _ = tx.ExecContext(ctx, `
			UPDATE camera_health
			SET online = false
			WHERE site_id = $1 AND camera_id = $2
		`, siteID, cam.CameraID)

		// 2. Raise NFR-OBS-002 operational event
		event := &domain.Event{
			EventID:         uuid.New().String(),
			SiteID:          siteID,
			CameraID:        cam.CameraID,
			ZoneID:          "",
			EventType:       "COVERAGE_LOST",
			Severity:        domain.SeverityCritical,
			OccurredAt:      time.Now().UTC(),
			ReceivedAt:      time.Now().UTC(),
			ModelID:         "watchdog_nfr_obs_002",
			ModelVersion:    "v1.0",
			RuleID:          "NFR-OBS-002",
			RuleVersion:     "v1.0",
			Confidence:      1.0,
			SnapshotRelPath: "",
			SubjectStatus:   "COVERAGE_LOST",
			State:           domain.StateNew,
			CreatedAt:       time.Now().UTC(),
		}

		if err := w.repo.InsertEvent(ctx, event); err != nil {
			log.Printf("[CoverageWatchdog] Failed to record coverage lost event for %s: %v", cam.CameraID, err)
		}
	}

	_ = tx.Commit()
}
