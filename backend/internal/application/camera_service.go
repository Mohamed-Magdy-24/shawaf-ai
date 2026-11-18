package application

import (
	"context"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// StreamTelemetry contains decoded stream stats from Python worker heartbeat
type StreamTelemetry struct {
	CameraID       string
	Online         bool
	FPSDecoded     float64
	DroppedFrames  uint64
	LastFrameUTCMs int64
}

// CameraService manages camera metadata and stream health monitoring
type CameraService struct {
	repo   CameraRepository
	events *EventService
}

// NewCameraService creates a camera application service
func NewCameraService(repo CameraRepository, events *EventService) *CameraService {
	return &CameraService{
		repo:   repo,
		events: events,
	}
}

// GetCamera retrieves camera details
func (s *CameraService) GetCamera(ctx context.Context, siteID, cameraID string) (*domain.Camera, error) {
	if siteID == "" || cameraID == "" {
		return nil, domain.ErrInvalidCameraID
	}
	return s.repo.GetByID(ctx, siteID, cameraID)
}

// ListCameras lists all cameras for a site
func (s *CameraService) ListCameras(ctx context.Context, siteID string) ([]*domain.Camera, error) {
	if siteID == "" {
		return nil, domain.ErrInvalidSiteID
	}
	return s.repo.List(ctx, siteID)
}

// RecordWorkerHeartbeat processes camera stream telemetry from an AI worker
// Triggers NFR-OBS-002 "Coverage Lost" alert if a stream went offline or is dead
func (s *CameraService) RecordWorkerHeartbeat(
	ctx context.Context,
	workerID, siteID string,
	telemetry []StreamTelemetry,
) error {
	now := time.Now().UTC()
	for _, stream := range telemetry {
		// Update stream telemetry in repository
		if err := s.repo.UpdateTelemetry(
			ctx, siteID, stream.CameraID,
			stream.Online, stream.FPSDecoded, stream.DroppedFrames, now,
		); err != nil {
			// Telemetry persistence failure logged but loop continues
			fmt.Printf("[WARN] Failed to update telemetry for camera %s/%s: %v\n", siteID, stream.CameraID, err)
		}

		// NFR-OBS-002: Coverage Lost check
		if !stream.Online {
			eventID := fmt.Sprintf("cov_lost_%s_%s_%d", siteID, stream.CameraID, now.Unix()/60)
			_, _, _ = s.events.HandleIncomingDetection(
				ctx,
				eventID,
				siteID,
				stream.CameraID,
				"",
				"camera.coverage.lost",
				domain.SeverityCritical,
				now,
				"health-telemetry-watcher",
				"v1.0",
				1.0,
				nil,
				"",
			)
		}
	}
	return nil
}
