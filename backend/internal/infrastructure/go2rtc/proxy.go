package go2rtc

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

// Proxy handles Zero-Trust SDP exchange between authorized clients and internal go2rtc sidecar
type Proxy struct {
	go2rtcURL  string
	httpClient *http.Client
}

// NewProxy initializes the go2rtc SDP proxy
func NewProxy(go2rtcURL string) *Proxy {
	if go2rtcURL == "" {
		go2rtcURL = os.Getenv("GO2RTC_INTERNAL_URL")
	}
	return &Proxy{
		go2rtcURL: go2rtcURL,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// ExchangeSDP proxies the client's WebRTC SDP offer to go2rtc and returns the SDP answer
func (p *Proxy) ExchangeSDP(ctx context.Context, siteID, cameraID, clientSDP string) (string, error) {
	if clientSDP == "" {
		return "", fmt.Errorf("SDP offer cannot be empty")
	}

	// go2rtc stream identifier convention: site_{siteID}_cam_{cameraID}
	streamName := fmt.Sprintf("site_%s_cam_%s", siteID, cameraID)
	targetURL := fmt.Sprintf("%s/api/webrtc?src=%s", p.go2rtcURL, streamName)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, targetURL, bytes.NewBufferString(clientSDP))
	if err != nil {
		return "", fmt.Errorf("failed to create go2rtc proxy request: %w", err)
	}
	req.Header.Set("Content-Type", "application/sdp")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("go2rtc sidecar unreachable at %s: %w", targetURL, err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read go2rtc SDP response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("go2rtc returned status %d: %s", resp.StatusCode, string(body))
	}

	return string(body), nil
}
