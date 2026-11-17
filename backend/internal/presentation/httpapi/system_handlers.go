package httpapi

import (
	"fmt"
	"net/http"
	"sync"
	"time"
)

var (
	healthDbMu     sync.RWMutex
	lastHealthTime time.Time
	lastDbStatus   = "UP"
)

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	healthDbMu.RLock()
	dbStatus := lastDbStatus
	needCheck := time.Since(lastHealthTime) > 1*time.Second
	healthDbMu.RUnlock()

	if needCheck {
		healthDbMu.Lock()
		if time.Since(lastHealthTime) > 1*time.Second {
			if s.db == nil || s.db.Ping() != nil {
				lastDbStatus = "DOWN"
			} else {
				lastDbStatus = "UP"
			}
			lastHealthTime = time.Now()
		}
		dbStatus = lastDbStatus
		healthDbMu.Unlock()
	}

	resp := map[string]interface{}{
		"status":     "SERVING",
		"system":     "Shawaf AI Edge Platform (edged)",
		"uptime_sec": time.Since(s.startTime).Seconds(),
		"components": map[string]string{
			"postgres": dbStatus,
			"outbox":   "ACTIVE",
			"watchdog": "ACTIVE",
		},
	}
	s.writeJSON(w, http.StatusOK, resp)
}

func (s *Server) handleMetrics(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; version=0.0.4")
	uptime := time.Since(s.startTime).Seconds()
	metrics := fmt.Sprintf(
		"# HELP edged_uptime_seconds Total daemon uptime in seconds\n"+
			"# TYPE edged_uptime_seconds counter\n"+
			"edged_uptime_seconds %.1f\n"+
			"# HELP edged_system_status Daemon operational status (1 = healthy)\n"+
			"# TYPE edged_system_status gauge\n"+
			"edged_system_status 1\n",
		uptime,
	)
	_, _ = w.Write([]byte(metrics))
}
