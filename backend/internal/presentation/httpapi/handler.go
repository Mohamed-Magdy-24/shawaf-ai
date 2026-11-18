package httpapi

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/ws"
)

// Handler coordinates REST and WebSocket presentation endpoints
type Handler struct {
	events        *application.EventService
	cameras       *application.CameraService
	tickets       *application.TicketService
	wsHub         *ws.Hub
	sdpProxy      *go2rtc.SDPProxyClient
	snapshotDir   string
	authenticator *Authenticator
}

// NewHandler creates a new HTTP API handler
func NewHandler(
	events *application.EventService,
	cameras *application.CameraService,
	tickets *application.TicketService,
	wsHub *ws.Hub,
	sdpProxy *go2rtc.SDPProxyClient,
	snapshotDir string,
	authenticator ...*Authenticator,
) *Handler {
	if snapshotDir == "" {
		snapshotDir = "/var/lib/surveillance/snapshots"
	}
	var auth *Authenticator
	if len(authenticator) > 0 && authenticator[0] != nil {
		auth = authenticator[0]
	} else {
		auth = NewAuthenticator("")
	}
	return &Handler{
		events:        events,
		cameras:       cameras,
		tickets:       tickets,
		wsHub:         wsHub,
		sdpProxy:      sdpProxy,
		snapshotDir:   snapshotDir,
		authenticator: auth,
	}
}

// RegisterRoutes registers all REST and WebSocket API routes on a ServeMux
func (h *Handler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/healthz", h.handleHealthz)
	mux.HandleFunc("/api/v1/sites/", h.handleSitesRouter)
	mux.HandleFunc("/snapshots/", h.handleSnapshotFile)
}

func (h *Handler) handleHealthz(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"status":        "HEALTHY",
		"timestamp_utc": time.Now().UTC().Format(time.RFC3339),
		"service":       "edged",
	})
}

// handleSitesRouter routes /api/v1/sites/{site_id}/... requests
func (h *Handler) handleSitesRouter(w http.ResponseWriter, r *http.Request) {
	// Path pattern: /api/v1/sites/{site_id}/[resource]/[sub-path]
	trimmed := strings.TrimPrefix(r.URL.Path, "/api/v1/sites/")
	parts := strings.Split(trimmed, "/")
	if len(parts) == 0 || parts[0] == "" {
		http.Error(w, "missing site_id in URL", http.StatusBadRequest)
		return
	}

	siteID := parts[0]
	if len(parts) == 1 {
		http.NotFound(w, r)
		return
	}

	resource := parts[1]

	// WebSocket streaming endpoint authenticates via single-use ticket in query string
	if resource == "ws-events" && r.Method == http.MethodGet {
		h.handleWSEvents(w, r, siteID)
		return
	}

	// All other REST routes require bearer token authentication & site authorization
	principal, err := h.authenticator.AuthenticateRequest(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{
			"error": fmt.Sprintf("unauthorized: %v", err),
		})
		return
	}

	// Enforce site-level authorization (tenant boundary)
	if !principal.CanAccessSite(siteID) {
		writeJSON(w, http.StatusForbidden, map[string]string{
			"error": fmt.Sprintf("forbidden: user %s has no access to site %s", principal.UserID, siteID),
		})
		return
	}

	// Inject authenticated principal into request context
	r = r.WithContext(ContextWithPrincipal(r.Context(), principal))

	switch resource {
	case "ws-ticket":
		if r.Method == http.MethodPost {
			h.handleIssueWSTicket(w, r, siteID, principal)
			return
		}
	case "cameras":
		h.handleCameras(w, r, siteID, parts[2:])
		return
	case "incidents":
		h.handleIncidents(w, r, siteID, parts[2:], principal)
		return
	}

	http.NotFound(w, r)
}

// ---------------------------------------------------------------------------
// 1. Single-Use WebSocket Ticket Handlers (VULN-08 Mitigation)
// ---------------------------------------------------------------------------

type issueTicketResponse struct {
	Ticket           string `json:"ticket"`
	ExpiresInSeconds int    `json:"expires_in_seconds"`
	SiteID           string `json:"site_id"`
}

func (h *Handler) handleIssueWSTicket(w http.ResponseWriter, r *http.Request, siteID string, principal *Principal) {
	// Derive identity strictly from authenticated principal (VULN-08 mitigation & zero spoofing)
	if principal == nil || principal.UserID == "" {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "authenticated principal missing valid user identity"})
		return
	}
	userID := principal.UserID

	ticket, err := h.tickets.IssueTicket(siteID, userID, 15*time.Second)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}

	writeJSON(w, http.StatusOK, issueTicketResponse{
		Ticket:           ticket,
		ExpiresInSeconds: 15,
		SiteID:           siteID,
	})
}

func (h *Handler) handleWSEvents(w http.ResponseWriter, r *http.Request, siteID string) {
	ticket := r.URL.Query().Get("ticket")
	if ticket == "" {
		http.Error(w, "missing mandatory single-use ticket in query param", http.StatusUnauthorized)
		return
	}

	userID, err := h.tickets.ConsumeTicket(ticket, siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf("ticket authentication rejected: %v", err), http.StatusForbidden)
		return
	}

	conn, err := ws.Upgrade(w, r)
	if err != nil {
		log.Printf("[ERROR] WebSocket upgrade failed: %v", err)
		return
	}

	h.wsHub.RegisterClient(conn, siteID, userID)
}

// ---------------------------------------------------------------------------
// 2. Zero-Trust go2rtc WebRTC SDP Proxy Handlers (Step 4.2 / 4.5)
// ---------------------------------------------------------------------------

func (h *Handler) handleCameras(w http.ResponseWriter, r *http.Request, siteID string, subParts []string) {
	if len(subParts) == 0 {
		// GET /api/v1/sites/{site_id}/cameras
		if r.Method == http.MethodGet {
			cams, err := h.cameras.ListCameras(r.Context(), siteID)
			if err != nil {
				writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
				return
			}
			writeJSON(w, http.StatusOK, cams)
			return
		}
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	cameraID := subParts[0]
	if len(subParts) == 1 {
		// GET /api/v1/sites/{site_id}/cameras/{camera_id}
		if r.Method == http.MethodGet {
			cam, err := h.cameras.GetCamera(r.Context(), siteID, cameraID)
			if err != nil {
				writeJSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
				return
			}
			writeJSON(w, http.StatusOK, cam)
			return
		}
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if len(subParts) == 2 && subParts[1] == "webrtc" {
		// POST /api/v1/sites/{site_id}/cameras/{camera_id}/webrtc
		if r.Method == http.MethodPost {
			h.handleWebRTCSDPExchange(w, r, siteID, cameraID)
			return
		}
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	http.NotFound(w, r)
}

func (h *Handler) handleWebRTCSDPExchange(w http.ResponseWriter, r *http.Request, siteID, cameraID string) {
	// Read SDP offer body
	body, err := io.ReadAll(r.Body)
	if err != nil || len(body) == 0 {
		http.Error(w, "missing SDP offer in request body", http.StatusBadRequest)
		return
	}

	// Verify camera exists for site
	if _, err := h.cameras.GetCamera(r.Context(), siteID, cameraID); err != nil {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": fmt.Sprintf("camera %s not found for site %s", cameraID, siteID)})
		return
	}

	// Proxy SDP offer to internal go2rtc sidecar (port 1984)
	sdpAnswer, err := h.sdpProxy.ExchangeSDP(r.Context(), cameraID, body)
	if err != nil {
		log.Printf("[ERROR] go2rtc WebRTC SDP proxy failed for %s/%s: %v", siteID, cameraID, err)
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": fmt.Sprintf("WebRTC signaling proxy error: %v", err)})
		return
	}

	w.Header().Set("Content-Type", "application/sdp")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(sdpAnswer)
}

// ---------------------------------------------------------------------------
// 3. Incident State Machine Endpoints (FR-ALT-008: NEW -> ACK -> RESOLVED|DISMISSED)
// ---------------------------------------------------------------------------

func (h *Handler) handleIncidents(w http.ResponseWriter, r *http.Request, siteID string, subParts []string, principal *Principal) {
	if len(subParts) == 0 {
		// GET /api/v1/sites/{site_id}/incidents
		if r.Method == http.MethodGet {
			incidents, err := h.events.ListActiveIncidents(r.Context(), siteID)
			if err != nil {
				writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
				return
			}
			writeJSON(w, http.StatusOK, incidents)
			return
		}
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	incidentID := subParts[0]
	if len(subParts) == 1 {
		// GET /api/v1/sites/{site_id}/incidents/{id}
		if r.Method == http.MethodGet {
			inc, err := h.events.GetIncident(r.Context(), siteID, incidentID)
			if err != nil {
				writeJSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
				return
			}
			writeJSON(w, http.StatusOK, inc)
			return
		}
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	action := subParts[1]
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var reqBody struct {
		Reason string `json:"reason"`
	}
	_ = json.NewDecoder(r.Body).Decode(&reqBody)

	// Operator identity is strictly derived from the authenticated principal (zero client-side spoofing)
	if principal == nil || principal.UserID == "" {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "authenticated principal missing valid operator identity"})
		return
	}
	operatorID := principal.UserID

	switch action {
	case "acknowledge":
		inc, err := h.events.AcknowledgeIncident(r.Context(), siteID, incidentID, operatorID)
		if err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		writeJSON(w, http.StatusOK, inc)
	case "resolve":
		inc, err := h.events.ResolveIncident(r.Context(), siteID, incidentID, operatorID)
		if err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		writeJSON(w, http.StatusOK, inc)
	case "dismiss":
		if reqBody.Reason == "" {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "dismissal reason is mandatory"})
			return
		}
		inc, err := h.events.DismissIncident(r.Context(), siteID, incidentID, operatorID, reqBody.Reason)
		if err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		writeJSON(w, http.StatusOK, inc)
	default:
		http.NotFound(w, r)
	}
}

// ---------------------------------------------------------------------------
// 4. Snapshot File Server (Site-Jailed)
// ---------------------------------------------------------------------------

func (h *Handler) handleSnapshotFile(w http.ResponseWriter, r *http.Request) {
	relPath := strings.TrimPrefix(r.URL.Path, "/snapshots/")
	cleanRel := filepath.Clean(relPath)

	// Prevent directory traversal attacks
	if strings.Contains(cleanRel, "..") || filepath.IsAbs(cleanRel) {
		http.Error(w, "invalid path traversal attempted", http.StatusForbidden)
		return
	}

	// Extract site ID from the first path segment (<site_id>/<yyyy>/<mm>/<dd>/<event_id>.jpg or <site_id>/<filename>)
	slashPath := filepath.ToSlash(cleanRel)
	parts := strings.Split(slashPath, "/")
	if len(parts) < 1 || parts[0] == "" {
		http.Error(w, "invalid snapshot path: missing site identifier", http.StatusBadRequest)
		return
	}
	siteID := parts[0]

	// Verify authentication and site authorization for snapshot access
	principal, err := h.authenticator.AuthenticateRequest(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{
			"error": fmt.Sprintf("unauthorized snapshot access: %v", err),
		})
		return
	}

	if !principal.CanAccessSite(siteID) {
		writeJSON(w, http.StatusForbidden, map[string]string{
			"error": fmt.Sprintf("forbidden: user %s has no access to site %s snapshots", principal.UserID, siteID),
		})
		return
	}

	fullPath := filepath.Join(h.snapshotDir, cleanRel)
	if _, err := os.Stat(fullPath); os.IsNotExist(err) {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "image/jpeg")
	w.Header().Set("Cache-Control", "private, max-age=86400")
	http.ServeFile(w, r, fullPath)
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}
