package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

type alertCacheEntry struct {
	alerts    []*domain.Event
	timestamp time.Time
}

var (
	alertCacheMu sync.RWMutex
	alertCache   = make(map[string]alertCacheEntry)
)

// InvalidateAlertCache purges cached inbox alerts for a site
func InvalidateAlertCache(siteID string) {
	alertCacheMu.Lock()
	delete(alertCache, siteID)
	alertCacheMu.Unlock()
}

func (s *Server) handleEvents(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		http.Error(w, `{"error":"site_id parameter required"}`, http.StatusBadRequest)
		return
	}

	events, err := s.repo.GetEvents(r.Context(), siteID, 50, 0)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"events": events})
}

func (s *Server) handleAlertsInbox(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		http.Error(w, `{"error":"site_id parameter required"}`, http.StatusBadRequest)
		return
	}

	alertCacheMu.RLock()
	if cached, ok := alertCache[siteID]; ok && time.Since(cached.timestamp) < 500*time.Millisecond {
		alertCacheMu.RUnlock()
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"alerts": cached.alerts})
		return
	}
	alertCacheMu.RUnlock()

	events, err := s.repo.GetEvents(r.Context(), siteID, 100, 0)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}

	var activeAlerts []*domain.Event
	for _, e := range events {
		if e.State == domain.StateNew || e.State == domain.StateAcknowledged {
			activeAlerts = append(activeAlerts, e)
		}
	}
	if activeAlerts == nil {
		activeAlerts = []*domain.Event{}
	}

	alertCacheMu.Lock()
	alertCache[siteID] = alertCacheEntry{alerts: activeAlerts, timestamp: time.Now()}
	alertCacheMu.Unlock()

	s.writeJSON(w, http.StatusOK, map[string]interface{}{"alerts": activeAlerts})
}

func (s *Server) handleAlertAction(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		SiteID     string `json:"site_id"`
		EventID    string `json:"event_id"`
		Action     string `json:"action"` // ACKNOWLEDGE, DISMISS, RESOLVE, ESCALATE
		Note       string `json:"note"`
		OccurredAt string `json:"occurred_at,omitempty"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
		return
	}

	// FR-ALT-008: Rejection rule: DISMISS strictly requires a reason
	if req.Action == "DISMISS" && strings.TrimSpace(req.Note) == "" {
		http.Error(w, `{"error":"FR-ALT-008 violation: dismissal strictly requires a valid reason"}`, http.StatusBadRequest)
		return
	}

	var targetState domain.EventState
	switch req.Action {
	case "ACKNOWLEDGE":
		targetState = domain.StateAcknowledged
	case "RESOLVE":
		targetState = domain.StateResolved
	case "DISMISS":
		targetState = domain.StateDismissed
	case "ESCALATE":
		targetState = domain.StateAcknowledged
	default:
		http.Error(w, `{"error":"invalid action; expected ACKNOWLEDGE, RESOLVE, or DISMISS"}`, http.StatusBadRequest)
		return
	}

	claims, _ := r.Context().Value("user_claims").(*UserClaims)
	userID := "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
	if claims != nil {
		userID = claims.UserID
	}

	occurredAt := time.Now().UTC()
	if req.OccurredAt != "" {
		if t, err := time.Parse(time.RFC3339, req.OccurredAt); err == nil {
			occurredAt = t
		}
	}

	if s.repo != nil {
		_ = s.repo.UpdateEventState(r.Context(), req.SiteID, req.EventID, occurredAt, targetState, req.Note, userID)
	}

	InvalidateAlertCache(req.SiteID)

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":      true,
		"event_id":     req.EventID,
		"new_state":    string(targetState),
		"action_taken": req.Action,
	})
}
