package domain

import (
	"errors"
	"time"
)

// Standard domain errors
var (
	ErrInvalidSiteID          = errors.New("site_id is mandatory and must not be empty")
	ErrInvalidCameraID        = errors.New("camera_id is mandatory")
	ErrInvalidSeverity        = errors.New("severity must be INFO, WARNING, CRITICAL, or CRITICAL_FIRE")
	ErrDismissalReasonRequired = errors.New("dismissal reason is mandatory when dismissing an incident")
	ErrInvalidStateTransition = errors.New("invalid incident state transition")
)

// IncidentSeverity represents safety severity levels
type IncidentSeverity string

const (
	SeverityInfo         IncidentSeverity = "INFO"
	SeverityWarning      IncidentSeverity = "WARNING"
	SeverityCritical     IncidentSeverity = "CRITICAL"
	SeverityCriticalFire IncidentSeverity = "CRITICAL_FIRE"
)

// IncidentStatus represents the FR-ALT-008 minimal workflow state
type IncidentStatus string

const (
	StatusNew          IncidentStatus = "NEW"
	StatusAcknowledged IncidentStatus = "ACKNOWLEDGED"
	StatusResolved     IncidentStatus = "RESOLVED"
	StatusDismissed    IncidentStatus = "DISMISSED"
)

// BoundingBox represents an object detection bounding box
type BoundingBox struct {
	X1         float32 `json:"x1"`
	Y1         float32 `json:"y1"`
	X2         float32 `json:"x2"`
	Y2         float32 `json:"y2"`
	Label      string  `json:"label"`
	Confidence float32 `json:"confidence"`
	TrackID    int64   `json:"track_id,omitempty"`
}

// SafetyIncident represents an industrial surveillance incident domain aggregate
type SafetyIncident struct {
	ID               string           `json:"id"`
	SiteID           string           `json:"site_id"`
	CameraID         string           `json:"camera_id"`
	ZoneID           string           `json:"zone_id"`
	EventType        string           `json:"event_type"`
	Severity         IncidentSeverity `json:"severity"`
	Status           IncidentStatus   `json:"status"`
	OccurredAtUTC    time.Time        `json:"occurred_at_utc"`
	ModelID          string           `json:"model_id"`
	ModelVersion     string           `json:"model_version"`
	Confidence       float32          `json:"confidence"`
	BBoxes           []BoundingBox    `json:"bboxes"`
	SnapshotRelPath  string           `json:"snapshot_rel_path"`
	AcknowledgedBy   string           `json:"acknowledged_by,omitempty"`
	AcknowledgedAt   *time.Time       `json:"acknowledged_at,omitempty"`
	ResolvedBy       string           `json:"resolved_by,omitempty"`
	ResolvedAt       *time.Time       `json:"resolved_at,omitempty"`
	DismissalReason  string           `json:"dismissal_reason,omitempty"`
	CreatedAtUTC     time.Time        `json:"created_at_utc"`
}

// NewSafetyIncident validates and creates a new incident in NEW state
func NewSafetyIncident(
	id, siteID, cameraID, zoneID, eventType string,
	severity IncidentSeverity,
	occurredAt time.Time,
	modelID, modelVersion string,
	confidence float32,
	bboxes []BoundingBox,
	snapshotPath string,
) (*SafetyIncident, error) {
	if siteID == "" {
		return nil, ErrInvalidSiteID
	}
	if cameraID == "" {
		return nil, ErrInvalidCameraID
	}
	switch severity {
	case SeverityInfo, SeverityWarning, SeverityCritical, SeverityCriticalFire:
		// Valid
	default:
		return nil, ErrInvalidSeverity
	}

	return &SafetyIncident{
		ID:              id,
		SiteID:          siteID,
		CameraID:        cameraID,
		ZoneID:          zoneID,
		EventType:       eventType,
		Severity:        severity,
		Status:          StatusNew,
		OccurredAtUTC:   occurredAt,
		ModelID:         modelID,
		ModelVersion:    modelVersion,
		Confidence:      confidence,
		BBoxes:          bboxes,
		SnapshotRelPath: snapshotPath,
		CreatedAtUTC:    time.Now().UTC(),
	}, nil
}

// Acknowledge transitions incident from NEW to ACKNOWLEDGED per FR-ALT-008
func (i *SafetyIncident) Acknowledge(operatorID string) error {
	if i.Status != StatusNew {
		return ErrInvalidStateTransition
	}
	now := time.Now().UTC()
	i.Status = StatusAcknowledged
	i.AcknowledgedBy = operatorID
	i.AcknowledgedAt = &now
	return nil
}

// Resolve transitions incident from ACKNOWLEDGED to RESOLVED per FR-ALT-008
func (i *SafetyIncident) Resolve(operatorID string) error {
	if i.Status != StatusAcknowledged && i.Status != StatusNew {
		return ErrInvalidStateTransition
	}
	now := time.Now().UTC()
	i.Status = StatusResolved
	i.ResolvedBy = operatorID
	i.ResolvedAt = &now
	return nil
}

// Dismiss transitions incident to DISMISSED with a mandatory reason per FR-ALT-008
func (i *SafetyIncident) Dismiss(operatorID, reason string) error {
	if reason == "" {
		return ErrDismissalReasonRequired
	}
	now := time.Now().UTC()
	i.Status = StatusDismissed
	i.ResolvedBy = operatorID
	i.ResolvedAt = &now
	i.DismissalReason = reason
	return nil
}
