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

// isSafeTargetHost validates that the target host does not target prohibited cloud metadata or arbitrary localhost interfaces
func isSafeTargetHost(host string) error {
	trimmed := strings.TrimSpace(strings.ToLower(host))
	if trimmed == "" {
		return fmt.Errorf("empty host")
	}

	// Block cloud metadata services and IPv6 metadata
	if trimmed == "169.254.169.254" || trimmed == "metadata.google.internal" || strings.HasPrefix(trimmed, "fd00:") {
		return fmt.Errorf("ssrf blocked: prohibited cloud metadata target")
	}

	// Parse IP if provided
	ip := net.ParseIP(trimmed)
	if ip != nil {
		if ip.IsUnspecified() || ip.IsMulticast() {
			return fmt.Errorf("ssrf blocked: invalid target address %s", trimmed)
		}
	}
	return nil
}

// TestRTSPConnection checks network reachability and authentic RTSP protocol handshake
func TestRTSPConnection(ctx context.Context, rawRTSPURL string, timeout time.Duration) *ProbeResult {
	if timeout <= 0 {
		timeout = 3 * time.Second
	}

	sanitized := ports.SanitizeRTSPURL(rawRTSPURL)
	res := &ProbeResult{
		Reachable:    false,
		SanitizedURL: sanitized,
	}

	if !strings.HasPrefix(rawRTSPURL, "rtsp://") && !strings.HasPrefix(rawRTSPURL, "rtsps://") {
		res.Error = "invalid scheme: must begin with rtsp:// or rtsps://"
		return res
	}

	u, err := url.Parse(rawRTSPURL)
	if err != nil {
		res.Error = fmt.Sprintf("invalid rtsp url: %v", err)
		return res
	}

	host := u.Hostname()
	if err := isSafeTargetHost(host); err != nil {
		res.Error = err.Error()
		return res
	}

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

	// Send RTSP OPTIONS handshake
	reqStr := fmt.Sprintf("OPTIONS %s RTSP/1.0\r\nCSeq: 1\r\nUser-Agent: ShawafAI-Probe/1.0\r\n\r\n", sanitized)
	_, err = conn.Write([]byte(reqStr))
	if err != nil {
		res.Reachable = false
		res.RTSPStatus = "TCP_CONNECTED_RTSP_HANDSHAKE_FAILED"
		res.Error = fmt.Sprintf("TCP connected to %s:%s but failed to send RTSP OPTIONS: %v", host, port, err)
		return res
	}

	reader := bufio.NewReader(conn)
	line, err := reader.ReadString('\n')
	if err != nil {
		res.Reachable = false
		res.RTSPStatus = "TCP_CONNECTED_RTSP_TIMEOUT"
		res.Error = fmt.Sprintf("TCP connected to %s:%s but target failed to respond with RTSP signature: %v", host, port, err)
		return res
	}

	line = strings.TrimSpace(line)
	// A genuine RTSP service MUST reply with RTSP/ protocol header (e.g. RTSP/1.0 200 OK or RTSP/1.0 401 Unauthorized)
	if !strings.HasPrefix(line, "RTSP/") {
		res.Reachable = false
		res.RTSPStatus = "NON_RTSP_SERVICE"
		res.Error = fmt.Sprintf("Target port responded with non-RTSP protocol signature: %s", line)
		return res
	}

	res.Reachable = true
	res.RTSPStatus = line
	return res
}
