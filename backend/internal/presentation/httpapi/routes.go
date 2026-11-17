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

		switch subResource {
		case "ws-ticket":
			s.authMiddleware(s.handleWSTicket)(w, r)
			return
		case "cameras":
			if subSubResource == "test-connection" {
				s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
					s.handleCameraTestConnection(w, r, siteID)
				})(w, r)
				return
			}
			if r.Method == http.MethodPost {
				s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
					s.handleRegisterSiteCamera(w, r, siteID)
				})(w, r)
				return
			}
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleGetSiteCameras(w, r, siteID)
			})(w, r)
			return
		case "active-streams":
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteActiveStreams(w, r, siteID)
			})(w, r)
			return
		case "nvrs":
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteNVRs(w, r, siteID)
			})(w, r)
			return
		case "employees":
			if subSubResource == "import" {
				s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
					s.handleSiteEmployeesImport(w, r, siteID)
				})(w, r)
				return
			}
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteEmployees(w, r, siteID)
			})(w, r)
			return
		case "presence":
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleSitePresence(w, r, siteID)
			})(w, r)
			return
		case "embeddings":
			s.authMiddleware(func(w http.ResponseWriter, r *http.Request) {
				s.handleSiteEmbeddings(w, r, siteID)
			})(w, r)
			return
		}
	}
	http.NotFound(w, r)
}
