package domain

import "time"

// SiteIdentifier represents an isolated factory installation
type SiteIdentifier string

const (
	SiteBNF SiteIdentifier = "BNF" // Beni Suef
	SiteRNF SiteIdentifier = "RNF" // Sadat City
)

// CameraStatus represents stream reachability
type CameraStatus string

const (
	CameraStatusOnline  CameraStatus = "ONLINE"
	CameraStatusOffline CameraStatus = "OFFLINE"
	CameraStatusDegraded CameraStatus = "DEGRADED"
)

// Camera represents an IP camera registered to a factory site
type Camera struct {
	ID             string       `json:"id"`
	SiteID         string       `json:"site_id"`
	Name           string       `json:"name"`
	RTSPMainURL    string       `json:"-"` // Credential protected, never serialized to client
	RTSPSubURL     string       `json:"-"`
	ZoneID         string       `json:"zone_id"`
	Status         CameraStatus `json:"status"`
	FPSDecoded     float64      `json:"fps_decoded"`
	DroppedFrames  uint64       `json:"dropped_frames"`
	LastHeartbeat  time.Time    `json:"last_heartbeat"`
	CreatedAtUTC   time.Time    `json:"created_at_utc"`
}

// Point represents a 2D coordinate for polygon zones
type Point struct {
	X float32 `json:"x"`
	Y float32 `json:"y"`
}

// DetectionZone represents a configured physical area (e.g., restricted perimeter)
type DetectionZone struct {
	ID          string    `json:"id"`
	SiteID      string    `json:"site_id"`
	CameraID    string    `json:"camera_id"`
	Name        string    `json:"name"`
	Polygon     []Point   `json:"polygon"`
	RuleType    string    `json:"rule_type"` // e.g. "RESTRICTED_ENTRY", "PPE_REQUIRED"
	IsActive    bool      `json:"is_active"`
	CreatedAtUTC time.Time `json:"created_at_utc"`
}
