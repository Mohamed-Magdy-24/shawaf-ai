package go2rtc

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

type StreamGateway struct {
	baseURL    string
	httpClient *http.Client
}

func NewStreamGateway(baseURL string) *StreamGateway {
	return &StreamGateway{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 4 * time.Second,
		},
	}
}

// RegisterLiveStream dynamically injects an RTSP sub-stream into go2rtc without restarting the container
func (g *StreamGateway) RegisterLiveStream(ctx context.Context, streamName, rtspURL string) error {
	endpoint := fmt.Sprintf("%s/api/streams?name=%s&src=%s",
		g.baseURL,
		url.QueryEscape(streamName),
		url.QueryEscape(rtspURL),
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodPut, endpoint, nil)
	if err != nil {
		return fmt.Errorf("go2rtc: failed to build stream registration request: %w", err)
	}

	resp, err := g.httpClient.Do(req)
	if err != nil {
		// In local simulation where go2rtc may not have reached healthy state yet, log and return error
		return fmt.Errorf("go2rtc: registration call failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return fmt.Errorf("go2rtc: registration returned non-200 status %d", resp.StatusCode)
	}

	return nil
}

// DeregisterLiveStream removes a stream from go2rtc
func (g *StreamGateway) DeregisterLiveStream(ctx context.Context, streamName string) error {
	endpoint := fmt.Sprintf("%s/api/streams?name=%s", g.baseURL, url.QueryEscape(streamName))
	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, endpoint, nil)
	if err != nil {
		return err
	}

	resp, err := g.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	return nil
}

// Ensure StreamGateway implements ports.StreamGatewayPort
var _ ports.StreamGatewayPort = (*StreamGateway)(nil)
