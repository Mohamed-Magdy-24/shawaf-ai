package application

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// CoverageWatchdog monitors camera heartbeats and triggers NFR-OBS-002 operational alerts
type CoverageWatchdog struct {
	txManager      domain.TxManager
	repo           domain.EventRepository
	db             *sql.DB
	timeoutSec     float64
	tickerInterval time.Duration
	stopCh         chan struct{}
}

// NewCoverageWatchdog creates an operational health monitor
func NewCoverageWatchdog(db *sql.DB, txManager domain.TxManager, repo domain.EventRepository, timeoutSec float64) *CoverageWatchdog {
	if timeoutSec <= 0 {
		timeoutSec = 15.0
	}
	return &CoverageWatchdog{
		db:             db,
		txManager:      txManager,
		repo:           repo,
		timeoutSec:     timeoutSec,
		tickerInterval: 5 * time.Second,
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

// scanStaleCameras queries cameras with last_heartbeat older than timeout and status != COVERAGE_LOST
func (w *CoverageWatchdog) scanStaleCameras(ctx context.Context) error {
	threshold := time.Now().UTC().Add(-time.Duration(w.timeoutSec * float64(time.Second)))

	// Query across all sites directly using system/runtime connection
	query := `
		SELECT site_id, camera_id, name, status, last_heartbeat
		FROM camera_health
		WHERE status = 'STREAMING' AND (last_heartbeat IS NULL OR last_heartbeat < $1)
	`
	rows, err := w.db.QueryContext(ctx, query, threshold)
	if err != nil {
		return fmt.Errorf("failed to query stale cameras: %w", err)
	}
	defer rows.Close()

	type StaleCam struct {
		SiteID        string
		CameraID      string
		Name          string
		Status        string
		LastHeartbeat *time.Time
	}

	var staleList []StaleCam
	for rows.Next() {
		var s StaleCam
		if err := rows.Scan(&s.SiteID, &s.CameraID, &s.Name, &s.Status, &s.LastHeartbeat); err != nil {
			log.Printf("[CoverageWatchdog] Row scan error: %v", err)
			continue
		}
		staleList = append(staleList, s)
	}

	for _, cam := range staleList {
		log.Printf("[CoverageWatchdog] ALERT: Camera %s at site %s exceeded timeout (last heartbeat: %v). Transitioning to COVERAGE_LOST.",
			cam.CameraID, cam.SiteID, cam.LastHeartbeat)

		err := w.txManager.WithSiteTx(ctx, cam.SiteID, func(tx *sql.Tx) error {
			// 1. Update camera status
			_, err := tx.ExecContext(ctx, `
				UPDATE camera_health
				SET status = 'COVERAGE_LOST', updated_at = NOW()
				WHERE site_id = $1 AND camera_id = $2
			`, cam.SiteID, cam.CameraID)
			if err != nil {
				return err
			}

			// 2. Raise NFR-OBS-002 operational event
			meta, _ := json.Marshal(map[string]interface{}{
				"reason":           "Heartbeat missing > 15s",
				"last_heartbeat":   cam.LastHeartbeat,
				"timeout_seconds": w.timeoutSec,
			})

			event := &domain.Event{
				ID:         uuid.New().String(),
				SiteID:     cam.SiteID,
				CameraID:   cam.CameraID,
				ZoneID:     "",
				EventType:  "CAMERA_COVERAGE_LOST",
				Severity:   domain.Sev2,
				State:      domain.StateNew,
				Confidence: 1.0,
				OccurredAt: time.Now().UTC(),
				CreatedAt:  time.Now().UTC(),
				Metadata:   meta,
			}

			if err := w.repo.InsertEvent(ctx, tx, event); err != nil {
				return err
			}

			// 3. Emit Outbox notification
			outboxPayload, _ := json.Marshal(event)
			outboxItem := &domain.OutboxItem{
				ID:        uuid.New().String(),
				SiteID:    cam.SiteID,
				Topic:     "camera.coverage_lost",
				Payload:   outboxPayload,
				CreatedAt: time.Now().UTC(),
			}

			return s_repo_insertOutbox(ctx, tx, w.repo, outboxItem)
		})

		if err != nil {
			log.Printf("[CoverageWatchdog] Failed to transition camera %s to COVERAGE_LOST: %v", cam.CameraID, err)
		}
	}

	return nil
}

func s_repo_insertOutbox(ctx context.Context, tx *sql.Tx, repo domain.EventRepository, item *domain.OutboxItem) error {
	return repo.InsertOutbox(ctx, tx, item)
}
