package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/crypto"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/network"
)

func (s *Server) handleCameras(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		http.Error(w, `{"error":"site_id parameter required"}`, http.StatusBadRequest)
		return
	}

	query := `
		SELECT c.camera_id, c.site_id, c.name, c.rtsp_sub_url, c.status,
		       COALESCE(h.online, false) AS online,
		       COALESCE(h.fps_decoded, 0.0) AS fps_decoded,
		       h.last_heartbeat_at
		FROM cameras c
		LEFT JOIN camera_health h ON c.site_id = h.site_id AND c.camera_id = h.camera_id
		WHERE c.site_id = $1
		ORDER BY c.name
	`
	rows, err := s.db.QueryContext(r.Context(), query, siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var cameras []map[string]interface{}
	for rows.Next() {
		var cid, sid, name, rtsp, status string
		var online bool
		var fps float64
		var lastHb *time.Time
		if err := rows.Scan(&cid, &sid, &name, &rtsp, &status, &online, &fps, &lastHb); err == nil {
			healthStatus := "DISCONNECTED"
			if online {
				healthStatus = "STREAMING"
			} else if status == "COVERAGE_LOST" {
				healthStatus = "COVERAGE_LOST"
			}

			cameras = append(cameras, map[string]interface{}{
				"id":             cid,
				"site_id":        sid,
				"name":           name,
				"fps_target":     15,
				"is_active":      status == "ACTIVE",
				"health_status":  healthStatus,
				"current_fps":    fps,
				"last_heartbeat": lastHb,
			})
		}
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"cameras": cameras})
}

func (s *Server) handleGetSiteCameras(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.cameraPort != nil {
		cameras, err := s.cameraPort.GetCameras(r.Context(), siteID)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		if cameras == nil {
			cameras = []*ports.Camera{}
		}
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"cameras": cameras})
		return
	}
	q := r.URL.Query()
	q.Set("site_id", siteID)
	r.URL.RawQuery = q.Encode()
	s.handleCameras(w, r)
}

func (s *Server) handleRegisterSiteCamera(w http.ResponseWriter, r *http.Request, siteID string) {
	claimsVal := r.Context().Value("user_claims")
	if claimsVal == nil {
		http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
		return
	}
	claims := claimsVal.(*UserClaims)

	// RBAC check: only security_manager and senior_management (or admin)
	if claims.Role != "security_manager" && claims.Role != "senior_management" && claims.Role != "admin" {
		http.Error(w, `{"error":"forbidden: insufficient role to register cameras"}`, http.StatusForbidden)
		return
	}

	// Site tenant boundary check
	if claims.Role != "senior_management" && claims.Role != "admin" {
		allowed := false
		for _, sID := range claims.SiteIDs {
			if sID == siteID {
				allowed = true
				break
			}
		}
		if !allowed {
			http.Error(w, `{"error":"forbidden: cross-site camera registration prohibited"}`, http.StatusForbidden)
			return
		}
	}

	var req struct {
		CameraID   string   `json:"camera_id"`
		ID         string   `json:"id"`
		NVRID      string   `json:"nvr_id"`
		Name       string   `json:"name"`
		Vendor     string   `json:"vendor"`
		HostIP     string   `json:"host_ip"`
		Port       int      `json:"port"`
		Channel    int      `json:"channel"`
		Username   string   `json:"username"`
		Password   string   `json:"password"`
		CustomPath string   `json:"custom_path"`
		RTSPURL    string   `json:"rtsp_url"`
		RTSPSub    string   `json:"rtsp_sub_url"`
		ONVIFHost  string   `json:"onvif_host"`
		TargetFPS  int      `json:"fps_target"`
		Zones      []string `json:"zones"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid camera payload"}`, http.StatusBadRequest)
		return
	}

	camID := req.CameraID
	if camID == "" {
		camID = req.ID
	}
	if camID == "" && req.Name != "" {
		slug := strings.ToLower(strings.ReplaceAll(req.Name, " ", "_"))
		camID = fmt.Sprintf("cam_%s", slug)
	}

	rtspURL := req.RTSPURL
	if rtspURL == "" {
		rtspURL = req.RTSPSub
	}
	if rtspURL == "" && req.HostIP != "" {
		rtspURL = ports.BuildVendorRTSPURL(req.Vendor, req.HostIP, req.Port, req.Channel, req.Username, req.Password, req.CustomPath)
	}

	if camID == "" || req.Name == "" {
		http.Error(w, `{"error":"camera name is required"}`, http.StatusBadRequest)
		return
	}

	if !ports.ValidateRTSPURL(rtspURL) {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, ports.ErrInvalidRTSPURL), http.StatusBadRequest)
		return
	}

	cam := &ports.Camera{
		SiteID:    siteID,
		CameraID:  camID,
		NVRID:     req.NVRID,
		Name:      req.Name,
		RTSPURL:   rtspURL,
		ONVIFHost: req.ONVIFHost,
		TargetFPS: req.TargetFPS,
		Zones:     req.Zones,
		Status:    "ACTIVE",
	}

	if s.cameraPort != nil {
		if err := s.cameraPort.RegisterCamera(r.Context(), cam); err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to register camera: %v"}`, err), http.StatusInternalServerError)
			return
		}
	}

	if s.streamGateway != nil {
		_ = s.streamGateway.RegisterLiveStream(r.Context(), cam.CameraID, cam.RTSPURL)
	}

	sanitized := *cam
	sanitized.RTSPURL = ports.SanitizeRTSPURL(cam.RTSPURL)
	s.writeJSON(w, http.StatusCreated, map[string]interface{}{
		"ok":     true,
		"camera": sanitized,
	})
}

func (s *Server) handleCameraTestConnection(w http.ResponseWriter, r *http.Request, siteID string) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		RTSPURL    string `json:"rtsp_url"`
		Vendor     string `json:"vendor"`
		HostIP     string `json:"host_ip"`
		Port       int    `json:"port"`
		Channel    int    `json:"channel"`
		Username   string `json:"username"`
		Password   string `json:"password"`
		CustomPath string `json:"custom_path"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid test payload"}`, http.StatusBadRequest)
		return
	}

	targetURL := req.RTSPURL
	if targetURL == "" && req.HostIP != "" {
		targetURL = ports.BuildVendorRTSPURL(req.Vendor, req.HostIP, req.Port, req.Channel, req.Username, req.Password, req.CustomPath)
	}

	if targetURL == "" || !ports.ValidateRTSPURL(targetURL) {
		http.Error(w, `{"error":"invalid or missing rtsp url"}`, http.StatusBadRequest)
		return
	}

	probeRes := network.TestRTSPConnection(r.Context(), targetURL, 3*time.Second)
	s.writeJSON(w, http.StatusOK, probeRes)
}

func (s *Server) handleSiteActiveStreams(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.cameraPort == nil {
		http.Error(w, `{"error":"camera registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	cameras, err := s.cameraPort.GetCameras(r.Context(), siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	type ActiveStream struct {
		CameraID  string   `json:"camera_id"`
		Name      string   `json:"name"`
		StreamURL string   `json:"stream_url"`
		FPSTarget int      `json:"fps_target"`
		Zones     []string `json:"zones"`
		Status    string   `json:"status"`
	}
	var streams []ActiveStream
	for _, c := range cameras {
		if c.Status == "ACTIVE" {
			streams = append(streams, ActiveStream{
				CameraID:  c.CameraID,
				Name:      c.Name,
				StreamURL: c.RTSPURL,
				FPSTarget: c.TargetFPS,
				Zones:     c.Zones,
				Status:    c.Status,
			})
		}
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"site_id": siteID,
		"streams": streams,
	})
}

func (s *Server) handleSiteNVRs(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.nvrPort == nil {
		http.Error(w, `{"error":"nvr registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}

	if r.Method == http.MethodGet {
		nvrs, err := s.nvrPort.GetNVRs(r.Context(), siteID)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		if nvrs == nil {
			nvrs = []*ports.NVR{}
		}
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"nvrs": nvrs})
		return
	}

	if r.Method == http.MethodPost {
		var req struct {
			NVRID    string `json:"nvr_id"`
			Name     string `json:"name"`
			Vendor   string `json:"vendor"`
			HostIP   string `json:"host_ip"`
			Port     int    `json:"port"`
			Username string `json:"username"`
			Password string `json:"password"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, `{"error":"invalid nvr payload"}`, http.StatusBadRequest)
			return
		}

		if req.NVRID == "" {
			req.NVRID = fmt.Sprintf("nvr_%d", time.Now().UnixNano()%10000)
		}
		if req.Name == "" {
			req.Name = req.NVRID
		}

		encPass, err := crypto.Encrypt(req.Password, s.encryptionKey)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"encryption error: %v"}`, err), http.StatusInternalServerError)
			return
		}

		nvr := &ports.NVR{
			SiteID:            siteID,
			NVRID:             req.NVRID,
			Name:              req.Name,
			Vendor:            req.Vendor,
			HostIP:            req.HostIP,
			Port:              req.Port,
			Username:          req.Username,
			EncryptedPassword: encPass,
			Status:            "ACTIVE",
		}

		if err := s.nvrPort.RegisterNVR(r.Context(), nvr); err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to register nvr: %v"}`, err), http.StatusInternalServerError)
			return
		}

		s.writeJSON(w, http.StatusCreated, map[string]interface{}{
			"ok":  true,
			"nvr": nvr,
		})
		return
	}

	http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
}

func (s *Server) handleWebRTCSDP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	claims, _ := r.Context().Value("user_claims").(*UserClaims)
	if claims == nil {
		http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
		return
	}

	// D-011 Role check: Only security_manager and senior_management may access live video
	if claims.Role != "security_manager" && claims.Role != "senior_management" && claims.Role != "ADMIN" {
		http.Error(w, `{"error":"forbidden: D-011 role policy denies live video access to factory_operator"}`, http.StatusForbidden)
		return
	}

	var req struct {
		SiteID   string `json:"site_id"`
		CameraID string `json:"camera_id"`
		SDP      string `json:"sdp"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
		return
	}

	// Verify user has access to this site
	hasSite := false
	for _, sid := range claims.SiteIDs {
		if sid == req.SiteID {
			hasSite = true
			break
		}
	}
	if !hasSite && claims.Role != "senior_management" {
		http.Error(w, `{"error":"forbidden: user not authorized for requested site"}`, http.StatusForbidden)
		return
	}

	answerSDP, err := s.go2rtcProxy.ExchangeSDP(r.Context(), req.SiteID, req.CameraID, req.SDP)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"webrtc exchange failed: %v"}`, err), http.StatusBadGateway)
		return
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"sdp": answerSDP,
	})
}
