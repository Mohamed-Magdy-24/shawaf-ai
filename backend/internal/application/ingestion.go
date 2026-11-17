package application

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// SubmitEventRequest encapsulates incoming detection events from edge AI workers
type SubmitEventRequest struct {
	EventID         string          `json:"event_id,omitempty"`
	SiteID          string          `json:"site_id"`
	CameraID        string          `json:"camera_id"`
	ZoneID          string          `json:"zone_id,omitempty"`
	EventType       string          `json:"event_type"`
	Severity        domain.Severity `json:"severity"`
	OccurredAt      time.Time       `json:"occurred_at"`
	ModelID         string          `json:"model_id,omitempty"`
	ModelVersion    string          `json:"model_version,omitempty"`
	RuleID          string          `json:"rule_id,omitempty"`
	RuleVersion     string          `json:"rule_version,omitempty"`
	Confidence      float32         `json:"confidence"`
	SnapshotRelPath string          `json:"snapshot_rel_path,omitempty"`
	SubjectStatus   string          `json:"subject_status,omitempty"`
	EmployeeID      string          `json:"employee_id,omitempty"`
	EmployeeName    string          `json:"employee_name,omitempty"`
	BBox            []float64       `json:"bbox,omitempty"`
	Payload         interface{}     `json:"payload,omitempty"`
}

// IngestionService coordinates secure event processing and outbox emission
type IngestionService struct {
	repo domain.EventRepository
}

// NewIngestionService initializes the ingestion service
func NewIngestionService(repo domain.EventRepository) *IngestionService {
	return &IngestionService{
		repo: repo,
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

	eventID := req.EventID
	if eventID == "" {
		eventID = uuid.New().String()
	}

	modelID := req.ModelID
	if modelID == "" {
		modelID = "cleanroom_yolox_nano_fp32"
	}
	modelVersion := req.ModelVersion
	if modelVersion == "" {
		modelVersion = "v1.0"
	}
	ruleID := req.RuleID
	if ruleID == "" {
		ruleID = "spatial_polygon_v1"
	}
	ruleVersion := req.RuleVersion
	if ruleVersion == "" {
		ruleVersion = "v1.0"
	}
	subjectStatus := req.SubjectStatus
	if subjectStatus == "" {
		subjectStatus = "UNKNOWN"
	}

	event := &domain.Event{
		EventID:         eventID,
		SiteID:          req.SiteID,
		CameraID:        req.CameraID,
		ZoneID:          req.ZoneID,
		EventType:       req.EventType,
		Severity:        req.Severity,
		OccurredAt:      req.OccurredAt,
		ReceivedAt:      time.Now().UTC(),
		ModelID:         modelID,
		ModelVersion:    modelVersion,
		RuleID:          ruleID,
		RuleVersion:     ruleVersion,
		Confidence:      req.Confidence,
		SnapshotRelPath: req.SnapshotRelPath,
		SubjectStatus:   subjectStatus,
		EmployeeID:      req.EmployeeID,
		EmployeeName:    req.EmployeeName,
		State:           domain.StateNew,
		CreatedAt:       time.Now().UTC(),
	}

	if err := s.repo.InsertEvent(ctx, event); err != nil {
		return nil, err
	}

	return event, nil
}

// RecordHeartbeat updates camera health and active stream status under tenant RLS
func (s *IngestionService) RecordHeartbeat(ctx context.Context, siteID, cameraID string, fps float64, drops int64, latencyMs float64) error {
	if siteID == "" || cameraID == "" {
		return errors.New("site_id and camera_id required")
	}

	var d uint64
	if drops > 0 {
		d = uint64(drops)
	}

	return s.repo.UpdateCameraHealth(ctx, siteID, cameraID, true, fps, d)
}
