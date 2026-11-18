package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// IncidentRepository defines the persistence port for incidents
type IncidentRepository interface {
	Save(ctx context.Context, incident *domain.SafetyIncident) error
	SaveWithOutbox(ctx context.Context, incident *domain.SafetyIncident, payload []byte, isFirePriority bool) (bool, error)
	GetByID(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error)
	ListActive(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error)
	Update(ctx context.Context, incident *domain.SafetyIncident) error
}

// OutboxRepository defines the transactional outbox queue port
type OutboxRepository interface {
	Enqueue(ctx context.Context, siteID, eventID string, payload []byte, isFirePriority bool) error
	FetchAndLockPending(ctx context.Context, limit int, lockDuration time.Duration) ([]*domain.OutboxRecord, error)
	MarkPublished(ctx context.Context, id int64) error
	ReapExpiredLeases(ctx context.Context) (int64, error)
}

// CameraRepository defines the persistence port for camera fleet & telemetry
type CameraRepository interface {
	GetByID(ctx context.Context, siteID, cameraID string) (*domain.Camera, error)
	List(ctx context.Context, siteID string) ([]*domain.Camera, error)
	UpdateTelemetry(ctx context.Context, siteID, cameraID string, online bool, fps float64, dropped uint64, lastHeartbeat time.Time) error
}

// OutboxBroadcaster defines the outbound notification port (e.g. WebSocket Hub)
type OutboxBroadcaster interface {
	Broadcast(siteID string, payload []byte) error
}

// EventService orchestrates safety incident lifecycle and outbox publishing
type EventService struct {
	repo      IncidentRepository
	outbox    OutboxRepository
	cameraRepo CameraRepository
}

// NewEventService initializes application service
func NewEventService(repo IncidentRepository, outbox OutboxRepository, cameraRepo CameraRepository) *EventService {
	return &EventService{
		repo:       repo,
		outbox:     outbox,
		cameraRepo: cameraRepo,
	}
}

// HandleIncomingDetection ingests, creates, and atomically queues a safety event
// Returns (*domain.SafetyIncident, isDuplicate, error)
func (s *EventService) HandleIncomingDetection(
	ctx context.Context,
	id, siteID, cameraID, zoneID, eventType string,
	severity domain.IncidentSeverity,
	occurredAt time.Time,
	modelID, modelVersion string,
	confidence float32,
	bboxes []domain.BoundingBox,
	snapshotPath string,
) (*domain.SafetyIncident, bool, error) {
	incident, err := domain.NewSafetyIncident(
		id, siteID, cameraID, zoneID, eventType,
		severity, occurredAt, modelID, modelVersion,
		confidence, bboxes, snapshotPath,
	)
	if err != nil {
		return nil, false, fmt.Errorf("domain validation failed: %w", err)
	}

	isFirePriority := severity == domain.SeverityCriticalFire
	payloadData := map[string]interface{}{
		"id":                incident.ID,
		"event_id":          incident.ID,
		"site_id":           incident.SiteID,
		"camera_id":         incident.CameraID,
		"camera_name":       incident.CameraID,
		"zone_id":           incident.ZoneID,
		"event_type":        incident.EventType,
		"severity":          incident.Severity,
		"status":            incident.Status,
		"occurred_at_utc":   incident.OccurredAtUTC.Format(time.RFC3339),
		"confidence":        incident.Confidence,
		"bboxes":            incident.BBoxes,
		"snapshot_rel_path": incident.SnapshotRelPath,
	}
	payloadBytes, err := json.Marshal(payloadData)
	if err != nil {
		return nil, false, fmt.Errorf("failed to marshal outbox payload: %w", err)
	}

	// Atomically persist safety incident and outbox row in a single database transaction
	isNew, err := s.repo.SaveWithOutbox(ctx, incident, payloadBytes, isFirePriority)
	if err != nil {
		return nil, false, fmt.Errorf("failed to atomically persist incident and outbox: %w", err)
	}

	isDuplicate := !isNew
	return incident, isDuplicate, nil
}

// GetIncident retrieves a specific incident enforcing site tenant boundary
func (s *EventService) GetIncident(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error) {
	if siteID == "" || id == "" {
		return nil, domain.ErrInvalidSiteID
	}
	return s.repo.GetByID(ctx, siteID, id)
}

// ListActiveIncidents lists active incidents for a site
func (s *EventService) ListActiveIncidents(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error) {
	if siteID == "" {
		return nil, domain.ErrInvalidSiteID
	}
	return s.repo.ListActive(ctx, siteID)
}

// AcknowledgeIncident transitions state to ACKNOWLEDGED per FR-ALT-008
func (s *EventService) AcknowledgeIncident(ctx context.Context, siteID, id, operatorID string) (*domain.SafetyIncident, error) {
	incident, err := s.repo.GetByID(ctx, siteID, id)
	if err != nil {
		return nil, err
	}
	if err := incident.Acknowledge(operatorID); err != nil {
		return nil, err
	}
	if err := s.repo.Update(ctx, incident); err != nil {
		return nil, err
	}
	return incident, nil
}

// ResolveIncident transitions state to RESOLVED per FR-ALT-008
func (s *EventService) ResolveIncident(ctx context.Context, siteID, id, operatorID string) (*domain.SafetyIncident, error) {
	incident, err := s.repo.GetByID(ctx, siteID, id)
	if err != nil {
		return nil, err
	}
	if err := incident.Resolve(operatorID); err != nil {
		return nil, err
	}
	if err := s.repo.Update(ctx, incident); err != nil {
		return nil, err
	}
	return incident, nil
}

// DismissIncident transitions state to DISMISSED with mandatory reason per FR-ALT-008
func (s *EventService) DismissIncident(ctx context.Context, siteID, id, operatorID, reason string) (*domain.SafetyIncident, error) {
	incident, err := s.repo.GetByID(ctx, siteID, id)
	if err != nil {
		return nil, err
	}
	if err := incident.Dismiss(operatorID, reason); err != nil {
		return nil, err
	}
	if err := s.repo.Update(ctx, incident); err != nil {
		return nil, err
	}
	return incident, nil
}
