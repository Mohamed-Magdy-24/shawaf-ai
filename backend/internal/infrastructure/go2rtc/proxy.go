package go2rtc

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

// SDPProxyClient proxies WebRTC SDP offer/answers to the internal, unexposed go2rtc sidecar
// Enforces Zero-Trust boundary (Step 4.2 / 4.5) - port 1984 is completely blocked from external clients
type SDPProxyClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewSDPProxyClient initializes client pointing to internal go2rtc sidecar
func NewSDPProxyClient(baseURL string) *SDPProxyClient {
	if baseURL == "" {
		baseURL = "http://go2rtc:1984"
	}
	return &SDPProxyClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// ExchangeSDP sends client WebRTC SDP offer to go2rtc and returns the synthesized SDP answer
func (c *SDPProxyClient) ExchangeSDP(ctx context.Context, cameraID string, sdpOffer []byte) ([]byte, error) {
	if len(sdpOffer) == 0 {
		return nil, fmt.Errorf("empty SDP offer provided")
	}

	targetURL := fmt.Sprintf("%s/api/webrtc?src=%s", c.baseURL, url.QueryEscape(cameraID))

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, targetURL, bytes.NewReader(sdpOffer))
	if err != nil {
		return nil, fmt.Errorf("failed to create go2rtc request: %w", err)
	}
	req.Header.Set("Content-Type", "application/sdp")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("go2rtc sidecar connection error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("go2rtc returned HTTP %d: %s", resp.StatusCode, string(body))
	}

	sdpAnswer, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read go2rtc SDP answer: %w", err)
	}

	return sdpAnswer, nil
}
