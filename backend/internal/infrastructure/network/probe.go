package network

import (
	"bufio"
	"context"
	"fmt"
	"net"
	"net/url"
	"strings"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

// ProbeResult holds the connection test result
type ProbeResult struct {
	Reachable    bool    `json:"reachable"`
	SanitizedURL string  `json:"sanitized_url"`
	LatencyMs    float64 `json:"latency_ms"`
	RTSPStatus   string  `json:"rtsp_status,omitempty"`
	Error        string  `json:"error,omitempty"`
}

// TestRTSPConnection checks network reachability and RTSP handshake
func TestRTSPConnection(ctx context.Context, rawRTSPURL string, timeout time.Duration) *ProbeResult {
	if timeout <= 0 {
		timeout = 3 * time.Second
	}

	sanitized := ports.SanitizeRTSPURL(rawRTSPURL)
	res := &ProbeResult{
		Reachable:    false,
		SanitizedURL: sanitized,
	}

	u, err := url.Parse(rawRTSPURL)
	if err != nil {
		res.Error = fmt.Sprintf("invalid rtsp url: %v", err)
		return res
	}

	host := u.Hostname()
	port := u.Port()
	if port == "" {
		port = "554"
	}
	targetAddr := net.JoinHostPort(host, port)

	start := time.Now()
	var d net.Dialer
	conn, err := d.DialContext(ctx, "tcp", targetAddr)
	if err != nil {
		res.LatencyMs = float64(time.Since(start).Milliseconds())
		res.Error = fmt.Sprintf("tcp connection failed to %s:%s: %v", host, port, err)
		return res
	}
	defer conn.Close()

	res.LatencyMs = float64(time.Since(start).Milliseconds())
	_ = conn.SetDeadline(time.Now().Add(timeout))

	// Send RTSP OPTIONS
	reqStr := fmt.Sprintf("OPTIONS %s RTSP/1.0\r\nCSeq: 1\r\nUser-Agent: ShawafAI-Probe/1.0\r\n\r\n", sanitized)
	_, err = conn.Write([]byte(reqStr))
	if err != nil {
		// TCP succeeded, so host is reachable even if RTSP handshake timed out
		res.Reachable = true
		res.RTSPStatus = "TCP_OPEN_RTSP_TIMEOUT"
		return res
	}

	reader := bufio.NewReader(conn)
	line, err := reader.ReadString('\n')
	if err != nil {
		res.Reachable = true
		res.RTSPStatus = "TCP_OPEN"
		return res
	}

	line = strings.TrimSpace(line)
	res.Reachable = true
	res.RTSPStatus = line
	return res
}
