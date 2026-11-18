package domain

import (
	"errors"
	"time"
)

// OutboxStatus represents the lifecycle of an outbox message
type OutboxStatus string

const (
	OutboxStatusPending    OutboxStatus = "PENDING"
	OutboxStatusProcessing OutboxStatus = "PROCESSING"
	OutboxStatusPublished  OutboxStatus = "PUBLISHED"
	OutboxStatusFailed     OutboxStatus = "FAILED"
)

var (
	ErrInvalidOutboxEvent = errors.New("event_id and site_id are mandatory for outbox")
	ErrEmptyPayload       = errors.New("outbox payload cannot be empty")
)

// OutboxRecord represents an event in the transactional outbox queue
type OutboxRecord struct {
	ID             int64        `json:"id"`
	EventID        string       `json:"event_id"`
	SiteID         string       `json:"site_id"`
	Payload        []byte       `json:"payload"`
	IsFirePriority bool         `json:"is_fire_priority"`
	Status         OutboxStatus `json:"status"`
	LockedUntil    *time.Time   `json:"locked_until,omitempty"`
	RetryCount     int          `json:"retry_count"`
	CreatedAtUTC   time.Time    `json:"created_at_utc"`
	PublishedAtUTC *time.Time   `json:"published_at_utc,omitempty"`
}

// NewOutboxRecord creates a pending outbox record
func NewOutboxRecord(eventID, siteID string, payload []byte, isFirePriority bool) (*OutboxRecord, error) {
	if eventID == "" || siteID == "" {
		return nil, ErrInvalidOutboxEvent
	}
	if len(payload) == 0 {
		return nil, ErrEmptyPayload
	}

	return &OutboxRecord{
		EventID:        eventID,
		SiteID:         siteID,
		Payload:        payload,
		IsFirePriority: isFirePriority,
		Status:         OutboxStatusPending,
		CreatedAtUTC:   time.Now().UTC(),
	}, nil
}
