package application

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// SubmitEventRequest encapsulates incoming detection events from edge AI workers
type SubmitEventRequest struct {
	SiteID     string          `json:"site_id"`
	CameraID   string          `json:"camera_id"`
	ZoneID     string          `json:"zone_id"`
	EventType  string          `json:"event_type"`
	Severity   domain.Severity `json:"severity"`
	Confidence float64         `json:"confidence"`
	TrackID    int64           `json:"track_id"`
	BBox       []float64       `json:"bbox"` // [x1, y1, x2, y2]
	OccurredAt time.Time       `json:"occurred_at"`
	Payload    json.RawMessage `json:"payload,omitempty"`
}

// IngestionService coordinates secure event processing, RLS validation, and outbox emission
type IngestionService struct {
	txManager domain.TxManager
	repo      domain.EventRepository
}

// NewIngestionService initializes the ingestion service
func NewIngestionService(txManager domain.TxManager, repo domain.EventRepository) *IngestionService {
	return &IngestionService{
		txManager: txManager,
		repo:      repo,
	}
}

// SubmitEvent processes an edge event within an RLS-isolated transaction
func (s *IngestionService) SubmitEvent(ctx context.Context, req *SubmitEventRequest) (*domain.Event, error) {
	if req.SiteID == "" || req.CameraID == "" {
		return nil, errors.New("site_id and camera_id are mandatory")
	}
	if req.OccurredAt.IsZero() {
		req.OccurredAt = time.Now().UTC()
	}

	eventID := uuid.New().String()
	event := &domain.Event{
		ID:         eventID,
		SiteID:     req.SiteID,
		CameraID:   req.CameraID,
		ZoneID:     req.ZoneID,
		EventType:  req.EventType,
		Severity:   req.Severity,
		State:      domain.StateNew,
		Confidence: req.Confidence,
		TrackID:    req.TrackID,
		OccurredAt: req.OccurredAt,
		CreatedAt:  time.Now().UTC(),
		Metadata:   req.Payload,
	}

	// Payload formatting if empty
	if len(event.Metadata) == 0 {
		meta, _ := json.Marshal(map[string]interface{}{
			"bbox": req.BBox,
		})
		event.Metadata = meta
	}

	// Atomically insert event and outbox item under tenant RLS transaction
	err := s.txManager.WithSiteTx(ctx, req.SiteID, func(tx *sql.Tx) error {
		if err := s.repo.InsertEvent(ctx, tx, event); err != nil {
			return fmt.Errorf("failed to insert event: %w", err)
		}

		outboxPayload, err := json.Marshal(event)
		if err != nil {
			return fmt.Errorf("failed to marshal outbox payload: %w", err)
		}

		outboxItem := &domain.OutboxItem{
			ID:        uuid.New().String(),
			SiteID:    req.SiteID,
			Topic:     "event.created",
			Payload:   outboxPayload,
			CreatedAt: time.Now().UTC(),
		}

		if err := s.repo.InsertOutbox(ctx, tx, outboxItem); err != nil {
			return fmt.Errorf("failed to insert outbox item: %w", err)
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	return event, nil
}

// RecordHeartbeat updates camera health and active stream status under tenant RLS
func (s *IngestionService) RecordHeartbeat(ctx context.Context, siteID, cameraID string, fps float64, drops int64, latencyMs float64) error {
	if siteID == "" || cameraID == "" {
		return errors.New("site_id and camera_id required")
	}

	health := &domain.CameraHealth{
		SiteID:             siteID,
		CameraID:           cameraID,
		Status:             domain.StatusStreaming,
		LastHeartbeat:      time.Now().UTC(),
		ConsecutiveDrops:   drops,
		InferenceLatencyMs: latencyMs,
		FPS:                fps,
	}

	return s.txManager.WithSiteTx(ctx, siteID, func(tx *sql.Tx) error {
		return s.repo.UpdateCameraHealth(ctx, tx, health)
	})
}
