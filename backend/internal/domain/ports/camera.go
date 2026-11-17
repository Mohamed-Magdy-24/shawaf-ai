package ports

import (
	"context"
	"errors"
	"regexp"
)

var (
	ErrInvalidRTSPURL = errors.New("camera: invalid rtsp url; must begin with rtsp:// or rtsps://")
	ErrCameraNotFound = errors.New("camera: camera not found")
)

var rtspRegex = regexp.MustCompile(`^rtsps?://`)
var credScrubber = regexp.MustCompile(`^(rtsps?://)[^@]+@`)

// Camera represents an on-premise industrial IP camera or NVR sub-stream
type Camera struct {
	SiteID    string   `json:"site_id"`
	CameraID  string   `json:"camera_id"`
	NVRID     string   `json:"nvr_id,omitempty"`
	Name      string   `json:"name"`
	RTSPURL   string   `json:"rtsp_sub_url"` // Scrubbed in JSON output
	ONVIFHost string   `json:"onvif_host,omitempty"`
	TargetFPS int      `json:"fps_target"`
	Zones     []string `json:"zones,omitempty"`
	Status    string   `json:"status"`
}

// SanitizeRTSPURL removes credentials from the RTSP connection string to prevent leaks
func SanitizeRTSPURL(rawURL string) string {
	if credScrubber.MatchString(rawURL) {
		return credScrubber.ReplaceAllString(rawURL, "${1}***:***@")
	}
	return rawURL
}

// ValidateRTSPURL checks whether the URL conforms to RTSP / RTSPS standards
func ValidateRTSPURL(rawURL string) bool {
	return rtspRegex.MatchString(rawURL)
}

// CameraRegistryPort defines the primary domain contract for camera inventory management
type CameraRegistryPort interface {
	RegisterCamera(ctx context.Context, cam *Camera) error
	GetCameras(ctx context.Context, siteID string) ([]*Camera, error)
	GetCamera(ctx context.Context, siteID, cameraID string) (*Camera, error)
}

// StreamGatewayPort defines the primary domain contract for dynamic WebRTC stream registration in go2rtc
type StreamGatewayPort interface {
	RegisterLiveStream(ctx context.Context, streamName, rtspURL string) error
	DeregisterLiveStream(ctx context.Context, streamName string) error
}
