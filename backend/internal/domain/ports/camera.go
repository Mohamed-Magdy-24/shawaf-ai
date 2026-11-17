package ports

import (
	"context"
	"errors"
	"fmt"
	"net/url"
	"regexp"
	"strings"
	"time"
)

var (
	ErrInvalidRTSPURL = errors.New("camera: invalid rtsp url; must begin with rtsp:// or rtsps://")
	ErrCameraNotFound = errors.New("camera: camera not found")
	ErrNVRNotFound    = errors.New("nvr: nvr not found")
)

var rtspRegex = regexp.MustCompile(`^rtsps?://`)
var credScrubber = regexp.MustCompile(`^(rtsps?://)[^@]+@`)

// NVR represents an on-premise Network Video Recorder
type NVR struct {
	SiteID            string    `json:"site_id"`
	NVRID             string    `json:"nvr_id"`
	Name              string    `json:"name"`
	Vendor            string    `json:"vendor"` // HIKVISION, DAHUA, TIANDY, GENERIC
	HostIP            string    `json:"host_ip"`
	Port              int       `json:"port"`
	Username          string    `json:"username"`
	EncryptedPassword string    `json:"-"` // Never expose over API
	Status            string    `json:"status"`
	CreatedAt         time.Time `json:"created_at,omitempty"`
}

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

// BuildVendorRTSPURL constructs the vendor-specific RTSP sub-stream URL
func BuildVendorRTSPURL(vendor, hostIP string, port int, channel int, username, password, customPath string) string {
	if port <= 0 {
		port = 554
	}
	if channel <= 0 {
		channel = 1
	}

	userPart := ""
	if username != "" {
		if password != "" {
			userPart = fmt.Sprintf("%s:%s@", url.QueryEscape(username), url.QueryEscape(password))
		} else {
			userPart = fmt.Sprintf("%s@", url.QueryEscape(username))
		}
	}

	vendorUpper := strings.ToUpper(vendor)
	switch vendorUpper {
	case "HIKVISION":
		// Hikvision RTSP: /Streaming/Channels/{channel}02 is sub-stream; {channel}01 is main
		return fmt.Sprintf("rtsp://%s%s:%d/Streaming/Channels/%d02", userPart, hostIP, port, channel)
	case "DAHUA":
		// Dahua RTSP: /cam/realmonitor?channel={channel}&subtype=1 (subtype 1 is sub-stream)
		return fmt.Sprintf("rtsp://%s%s:%d/cam/realmonitor?channel=%d&subtype=1", userPart, hostIP, port, channel)
	case "TIANDY":
		// Tiandy RTSP: /video2 is sub-stream
		return fmt.Sprintf("rtsp://%s%s:%d/video2", userPart, hostIP, port)
	default:
		// Generic
		path := customPath
		if path == "" {
			path = fmt.Sprintf("live/ch%d", channel)
		}
		path = strings.TrimPrefix(path, "/")
		return fmt.Sprintf("rtsp://%s%s:%d/%s", userPart, hostIP, port, path)
	}
}

// CameraRegistryPort defines the primary domain contract for camera inventory management
type CameraRegistryPort interface {
	RegisterCamera(ctx context.Context, cam *Camera) error
	GetCameras(ctx context.Context, siteID string) ([]*Camera, error)
	GetCamera(ctx context.Context, siteID, cameraID string) (*Camera, error)
}

// NVRRegistryPort defines the contract for NVR appliance management
type NVRRegistryPort interface {
	RegisterNVR(ctx context.Context, nvr *NVR) error
	GetNVRs(ctx context.Context, siteID string) ([]*NVR, error)
	GetNVR(ctx context.Context, siteID, nvrID string) (*NVR, error)
}

// StreamGatewayPort defines the primary domain contract for dynamic WebRTC stream registration in go2rtc
type StreamGatewayPort interface {
	RegisterLiveStream(ctx context.Context, streamName, rtspURL string) error
	DeregisterLiveStream(ctx context.Context, streamName string) error
}
