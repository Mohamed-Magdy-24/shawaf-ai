package domain

import (
	"errors"
	"time"
)

// Clean Architecture: Domain layer has zero external framework or database dependencies.

type Severity string

const (
	SeverityInfo         Severity = "INFO"
	SeverityWarning      Severity = "WARNING"
	SeverityCritical     Severity = "CRITICAL"
	SeverityCriticalFire Severity = "CRITICAL_FIRE"
)

type EventState string

const (
	StateNew          EventState = "NEW"
	StateAcknowledged EventState = "ACKNOWLEDGED"
	StateResolved     EventState = "RESOLVED"
	StateDismissed    EventState = "DISMISSED"
)

var (
	ErrInvalidSiteID    = errors.New("domain: invalid or missing site_id")
	ErrInvalidCameraID  = errors.New("domain: invalid or missing camera_id")
	ErrInvalidEventID   = errors.New("domain: invalid or missing event_id")
	ErrInvalidState     = errors.New("domain: invalid event transition state")
	ErrDismissReasonReq = errors.New("domain: dismissal requires a valid reason")
)

type Event struct {
	EventID         string     `json:"event_id"`
	SiteID          string     `json:"site_id"`
	CameraID        string     `json:"camera_id"`
	ZoneID          string     `json:"zone_id,omitempty"`
	EventType       string     `json:"event_type"`
	Severity        Severity   `json:"severity"`
	OccurredAt      time.Time  `json:"occurred_at"`
	ReceivedAt      time.Time  `json:"received_at"`
	ModelID         string     `json:"model_id"`
	ModelVersion    string     `json:"model_version"`
	RuleID          string     `json:"rule_id"`
	RuleVersion     string     `json:"rule_version"`
	Confidence      float32    `json:"confidence"`
	SnapshotRelPath string     `json:"snapshot_rel_path"`
	SubjectStatus   string     `json:"subject_status"`
	State           EventState `json:"state"`
	DismissedReason string     `json:"dismissed_reason,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

func (e *Event) Validate() error {
	if e.EventID == "" {
		return ErrInvalidEventID
	}
	if e.SiteID == "" {
		return ErrInvalidSiteID
	}
	if e.CameraID == "" {
		return ErrInvalidCameraID
	}
	return nil
}

func (e *Event) TransitionTo(newState EventState, reason string) error {
	switch newState {
	case StateAcknowledged:
		if e.State != StateNew {
			return ErrInvalidState
		}
		e.State = StateAcknowledged
	case StateResolved:
		if e.State != StateAcknowledged && e.State != StateNew {
			return ErrInvalidState
		}
		e.State = StateResolved
	case StateDismissed:
		if reason == "" {
			return ErrDismissReasonReq
		}
		e.State = StateDismissed
		e.DismissedReason = reason
	default:
		return ErrInvalidState
	}
	return nil
}

type Camera struct {
	SiteID     string    `json:"site_id"`
	CameraID   string    `json:"camera_id"`
	Name       string    `json:"name"`
	RTSPURL    string    `json:"rtsp_sub_url"`
	Status     string    `json:"status"`
	CreatedAt  time.Time `json:"created_at"`
}

type Zone struct {
	SiteID          string    `json:"site_id"`
	ZoneID          string    `json:"zone_id"`
	CameraID        string    `json:"camera_id"`
	Name            string    `json:"name"`
	PolygonGeoJSON  string    `json:"polygon_geojson"`
	RiskType        string    `json:"risk_type"`
	ScheduleCron    string    `json:"schedule_cron"`
	CreatedAt       time.Time `json:"created_at"`
}

type CameraHealth struct {
	SiteID          string    `json:"site_id"`
	CameraID        string    `json:"camera_id"`
	Online          bool      `json:"online"`
	FPSDecoded      float64   `json:"fps_decoded"`
	DroppedFrames   uint64    `json:"dropped_frames"`
	LastHeartbeatAt time.Time `json:"last_heartbeat_at"`
}

type OutboxItem struct {
	ID                 int64     `json:"id"`
	EventID            string    `json:"event_id"`
	SiteID             string    `json:"site_id"`
	Priority           string    `json:"priority"`
	DestinationChannel string    `json:"destination_channel"`
	PayloadJSON        string    `json:"payload_json"`
	Status             string    `json:"status"`
	Attempts           int       `json:"attempts"`
	NextAttemptAt      time.Time `json:"next_attempt_at"`
	LockedUntil        *time.Time `json:"locked_until,omitempty"`
	IdempotencyKey     string    `json:"idempotency_key"`
	CreatedAt          time.Time `json:"created_at"`
}
