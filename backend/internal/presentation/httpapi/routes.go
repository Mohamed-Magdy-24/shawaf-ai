package httpapi

import (
	"net/http"
	"strings"
)

// RegisterRoutes registers all REST and WebSocket routes
func (s *Server) RegisterRoutes(mux *http.ServeMux) {
	// Operational & Observability
	mux.HandleFunc("/healthz", s.handleHealthz)
	mux.HandleFunc("/metrics", s.handleMetrics)

	// Auth
	mux.HandleFunc("/api/v1/auth/login", s.handleLogin)
	mux.HandleFunc("/api/v1/auth/refresh", s.handleRefreshToken)

	// Sites, Cameras, Zones
	mux.HandleFunc("/api/v1/sites", s.authMiddleware(s.handleSites))
	mux.HandleFunc("/api/v1/cameras", s.authMiddleware(s.handleCameras))
	mux.HandleFunc("/api/v1/zones", s.authMiddleware(s.handleZones))

	// Events & Alerts Inbox
	mux.HandleFunc("/api/v1/events", s.authMiddleware(s.handleEvents))
	mux.HandleFunc("/api/v1/alerts/inbox", s.authMiddleware(s.handleAlertsInbox))
	mux.HandleFunc("/api/v1/alerts/actions", s.authMiddleware(s.handleAlertAction))

	// WebRTC Zero-Trust SDP Proxy
	mux.HandleFunc("/api/v1/webrtc/sdp", s.authMiddleware(s.handleWebRTCSDP))

	// WebSocket single-use ticket and connection
	mux.HandleFunc("/api/v1/ws-ticket", s.authMiddleware(s.handleWSTicket))
	mux.HandleFunc("/api/v1/sites/", s.handleSiteSubRoutes)
	mux.HandleFunc("/api/v1/ws", s.wsHub.HandleWS)

	// Edge Worker Ingestion (HTTP Gateway fallback)
	mux.HandleFunc("/api/v1/edge/events", s.handleEdgeSubmitEvent)
	mux.HandleFunc("/api/v1/edge/heartbeat", s.handleEdgeHeartbeat)
}

func (s *Server) handleSiteSubRoutes(w http.ResponseWriter, r *http.Request) {
	// Path format: /api/v1/sites/{site_id}/...
	parts := strings.Split(strings.Trim(r.URL.Path, "/"), "/")
	if len(parts) >= 4 {
		siteID := parts[3]
		subResource := ""
		if len(parts) >= 5 {
			subResource = parts[4]
		}
		subSubResource := ""
		if len(parts) >= 6 {
			subSubResource = parts[5]
		}

		// Helper to wrap sub-routes with authentication and site-level tenant authorization
		withSiteAuth := func(next func(http.ResponseWriter, *http.Request)) http.HandlerFunc {
			return s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				if err := s.AuthorizeSiteAccess(r, siteID); err != nil {
					s.writeError(w, http.StatusForbidden, "FORBIDDEN", err.Error(), nil)
					return
				}
				next(w, r)
			})
		}

		switch subResource {
		case "ws-ticket":
			withSiteAuth(s.handleWSTicket)(w, r)
			return
		case "cameras":
			if subSubResource == "test-connection" {
				withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
					s.handleCameraTestConnection(w, r, siteID)
				})(w, r)
				return
			}
			if r.Method == http.MethodPost {
				withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
					s.handleRegisterSiteCamera(w, r, siteID)
				})(w, r)
				return
			}
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				s.handleGetSiteCameras(w, r, siteID)
			})(w, r)
			return
		case "active-streams":
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteActiveStreams(w, r, siteID)
			})(w, r)
			return
		case "nvrs":
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteNVRs(w, r, siteID)
			})(w, r)
			return
		case "employees":
			if subSubResource == "import" {
				withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
					s.handleSiteEmployeesImport(w, r, siteID)
				})(w, r)
				return
			}
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteEmployees(w, r, siteID)
			})(w, r)
			return
		case "presence":
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				s.handleSitePresence(w, r, siteID)
			})(w, r)
			return
		case "alerts":
			// Supports both /sites/{id}/alerts and /sites/{id}/alerts/inbox
			if subSubResource == "inbox" || subSubResource == "" {
				withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
					q := r.URL.Query()
					q.Set("site_id", siteID)
					r.URL.RawQuery = q.Encode()
					s.handleAlertsInbox(w, r)
				})(w, r)
				return
			}
			// Supports /sites/{id}/alerts/{event_id}/actions
			if len(parts) >= 7 && parts[6] == "actions" {
				withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
					q := r.URL.Query()
					q.Set("site_id", siteID)
					q.Set("event_id", subSubResource)
					r.URL.RawQuery = q.Encode()
					s.handleAlertAction(w, r)
				})(w, r)
				return
			}
		case "embeddings":
			// Biometric embeddings export strictly restricted to senior management
			withSiteAuth(func(w http.ResponseWriter, r *http.Request) {
				claims, _ := r.Context().Value("user_claims").(*UserClaims)
				if claims == nil || (claims.Role != "senior_management" && claims.Role != "corp_admin") {
					s.writeError(w, http.StatusForbidden, "FORBIDDEN", "biometric embedding export restricted to senior management", nil)
					return
				}
				s.handleSiteEmbeddings(w, r, siteID)
			})(w, r)
			return
		}
	}
	http.NotFound(w, r)
}
