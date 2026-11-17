package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/industrial-ai/surveillance/backend/internal/application"
)

func (s *Server) handleEdgeSubmitEvent(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req application.SubmitEventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
		return
	}

	event, err := s.ingestionSvc.SubmitEvent(r.Context(), &req)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}

	_ = s.wsHub.BroadcastEvent(event.SiteID, event)
	s.writeJSON(w, http.StatusCreated, event)
}

func (s *Server) handleEdgeHeartbeat(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		SiteID    string  `json:"site_id"`
		CameraID  string  `json:"camera_id"`
		FPS       float64 `json:"fps"`
		Drops     int64   `json:"drops"`
		LatencyMs float64 `json:"latency_ms"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
		return
	}

	err := s.ingestionSvc.RecordHeartbeat(r.Context(), req.SiteID, req.CameraID, req.FPS, req.Drops, req.LatencyMs)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}

	s.writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}
