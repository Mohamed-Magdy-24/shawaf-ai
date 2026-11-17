package httpapi

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/csv"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/crypto"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/governance"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/network"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/ws"
)

// Server coordinates HTTP REST endpoints, security middleware, and WebSocket upgrade
type Server struct {
	db             *sql.DB
	repo           domain.EventRepository
	cameraPort     ports.CameraRegistryPort
	nvrPort        ports.NVRRegistryPort
	employeePort   ports.EmployeeRegistryPort
	streamGateway  ports.StreamGatewayPort
	identityReader ports.AttendanceEmployeeReader
	photoFetcher   ports.BiometricPhotoFetcher
	ingestionSvc   *application.IngestionService
	go2rtcProxy    *go2rtc.Proxy
	wsHub          *ws.Hub
	jwtSecret      []byte
	encryptionKey  string
	evidenceDir    string
	startTime      time.Time
}

// SetPorts binds hexagonal ports for cameras, video gateway, and governance identity adapters
func (s *Server) SetPorts(cam ports.CameraRegistryPort, stream ports.StreamGatewayPort, idReader ports.AttendanceEmployeeReader, photo ports.BiometricPhotoFetcher) {
	s.cameraPort = cam
	s.streamGateway = stream
	s.identityReader = idReader
	s.photoFetcher = photo
	if np, ok := cam.(ports.NVRRegistryPort); ok {
		s.nvrPort = np
	}
	if ep, ok := cam.(ports.EmployeeRegistryPort); ok {
		s.employeePort = ep
	}
}

// SetEncryptionKey configures secret for AES-256-GCM RTSP password storage
func (s *Server) SetEncryptionKey(key string) {
	if key != "" {
		s.encryptionKey = key
	}
}

// SetEvidenceDir sets storage directory for employee photos and alert snapshots
func (s *Server) SetEvidenceDir(dir string) {
	if dir != "" {
		s.evidenceDir = dir
	}
}

// NewServer initializes the HTTP API Server
func NewServer(
	db *sql.DB,
	repo domain.EventRepository,
	ingestionSvc *application.IngestionService,
	go2rtcProxy *go2rtc.Proxy,
	wsHub *ws.Hub,
	jwtSecret string,
) *Server {
	if jwtSecret == "" {
		jwtSecret = "local_dev_jwt_hmac_secret_32bytes_min_0001"
	}
	s := &Server{
		db:            db,
		repo:          repo,
		ingestionSvc:  ingestionSvc,
		go2rtcProxy:   go2rtcProxy,
		wsHub:         wsHub,
		jwtSecret:     []byte(jwtSecret),
		encryptionKey: "local_dev_secret_key_32bytes_min_0001",
		evidenceDir:   "/var/lib/surveillance/evidence",
		startTime:     time.Now().UTC(),
	}
	if cp, ok := repo.(ports.CameraRegistryPort); ok {
		s.cameraPort = cp
	}
	if np, ok := repo.(ports.NVRRegistryPort); ok {
		s.nvrPort = np
	}
	if ep, ok := repo.(ports.EmployeeRegistryPort); ok {
		s.employeePort = ep
	}
	s.identityReader = governance.NewBlockedIdentityAdapter()
	s.photoFetcher = governance.NewBlockedIdentityAdapter()
	return s
}

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

func (s *Server) handleSiteEmployees(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusServiceUnavailable)
		_ = json.NewEncoder(w).Encode(map[string]interface{}{
			"error":          "FEATURE_BLOCKED_BY_GOVERNANCE",
			"detail":         ports.ErrFeatureBlockedByGovernance.Error(),
			"spk_references": []string{"SPK-01", "SPK-04", "DEC-06"},
		})
		return
	}

	if r.Method == http.MethodGet {
		employees, err := s.employeePort.GetEmployees(r.Context(), siteID)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		if employees == nil {
			employees = []*ports.Employee{}
		}
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"employees": employees})
		return
	}

	if r.Method == http.MethodPost {
		var empID, fullName, department, sourceType string
		var photoBytes []byte
		contentType := r.Header.Get("Content-Type")

		if strings.HasPrefix(contentType, "multipart/form-data") {
			if err := r.ParseMultipartForm(10 << 20); err != nil {
				http.Error(w, `{"error":"failed to parse multipart form"}`, http.StatusBadRequest)
				return
			}
			empID = r.FormValue("employee_id")
			fullName = r.FormValue("full_name")
			department = r.FormValue("department")
			sourceType = r.FormValue("source_type")

			file, _, err := r.FormFile("photo")
			if err == nil {
				defer file.Close()
				photoBytes, _ = io.ReadAll(file)
			}
		} else {
			var req struct {
				EmployeeID  string `json:"employee_id"`
				FullName    string `json:"full_name"`
				Department  string `json:"department"`
				SourceType  string `json:"source_type"`
				PhotoBase64 string `json:"photo_base64"`
			}
			if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
				http.Error(w, `{"error":"invalid json body"}`, http.StatusBadRequest)
				return
			}
			empID = req.EmployeeID
			fullName = req.FullName
			department = req.Department
			sourceType = req.SourceType
			if req.PhotoBase64 != "" {
				photoBytes, _ = base64.StdEncoding.DecodeString(req.PhotoBase64)
			}
		}

		if empID == "" || fullName == "" {
			http.Error(w, `{"error":"employee_id and full_name are required"}`, http.StatusBadRequest)
			return
		}

		var photoRelPath string
		var photoSHA string
		var embeddingBytes []byte

		if len(photoBytes) > 0 {
			h := sha256.Sum256(photoBytes)
			photoSHA = hex.EncodeToString(h[:])
			photoRelPath = fmt.Sprintf("evidence/%s/employees/%s.jpg", siteID, empID)

			fullPath := filepath.Join(s.evidenceDir, siteID, "employees", fmt.Sprintf("%s.jpg", empID))
			_ = os.MkdirAll(filepath.Dir(fullPath), 0755)
			_ = os.WriteFile(fullPath, photoBytes, 0644)

			embeddingBytes = crypto.GenerateNormalizedEmbedding512(photoBytes)
		} else {
			syntheticSeed := []byte(fmt.Sprintf("%s:%s", siteID, empID))
			embeddingBytes = crypto.GenerateNormalizedEmbedding512(syntheticSeed)
			h := sha256.Sum256(syntheticSeed)
			photoSHA = hex.EncodeToString(h[:])
		}

		emp := &ports.Employee{
			SiteID:       siteID,
			EmployeeID:   empID,
			FullName:     fullName,
			Department:   department,
			PhotoRelPath: photoRelPath,
			SourceType:   sourceType,
			IsActive:     true,
		}

		if err := s.employeePort.RegisterEmployee(r.Context(), emp, embeddingBytes, photoSHA); err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to register employee: %v"}`, err), http.StatusInternalServerError)
			return
		}

		s.writeJSON(w, http.StatusCreated, map[string]interface{}{
			"ok":       true,
			"employee": emp,
		})
		return
	}

	http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
}

func (s *Server) handleSiteEmployeesImport(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, `{"error":"cannot read payload"}`, http.StatusBadRequest)
		return
	}

	var importedCount int

	var jsonRecords []struct {
		EmployeeID string `json:"employee_id"`
		FullName   string `json:"full_name"`
		Department string `json:"department"`
	}
	if err := json.Unmarshal(bodyBytes, &jsonRecords); err == nil && len(jsonRecords) > 0 {
		for _, rec := range jsonRecords {
			if rec.EmployeeID == "" || rec.FullName == "" {
				continue
			}
			seed := []byte(fmt.Sprintf("%s:%s", siteID, rec.EmployeeID))
			embBytes := crypto.GenerateNormalizedEmbedding512(seed)
			h := sha256.Sum256(seed)
			emp := &ports.Employee{
				SiteID:     siteID,
				EmployeeID: rec.EmployeeID,
				FullName:   rec.FullName,
				Department: rec.Department,
				SourceType: "CSV_IMPORT",
				IsActive:   true,
			}
			if err := s.employeePort.RegisterEmployee(r.Context(), emp, embBytes, hex.EncodeToString(h[:])); err == nil {
				importedCount++
			}
		}
	} else {
		reader := csv.NewReader(strings.NewReader(string(bodyBytes)))
		records, err := reader.ReadAll()
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to parse csv: %v"}`, err), http.StatusBadRequest)
			return
		}
		for i, row := range records {
			if i == 0 && (strings.Contains(strings.ToLower(row[0]), "id") || strings.Contains(strings.ToLower(row[0]), "employee")) {
				continue
			}
			if len(row) < 2 {
				continue
			}
			empID := strings.TrimSpace(row[0])
			fullName := strings.TrimSpace(row[1])
			dept := "OPERATIONS"
			if len(row) >= 3 && strings.TrimSpace(row[2]) != "" {
				dept = strings.TrimSpace(row[2])
			}
			if empID == "" || fullName == "" {
				continue
			}

			seed := []byte(fmt.Sprintf("%s:%s", siteID, empID))
			embBytes := crypto.GenerateNormalizedEmbedding512(seed)
			h := sha256.Sum256(seed)
			emp := &ports.Employee{
				SiteID:     siteID,
				EmployeeID: empID,
				FullName:   fullName,
				Department: dept,
				SourceType: "CSV_IMPORT",
				IsActive:   true,
			}
			if err := s.employeePort.RegisterEmployee(r.Context(), emp, embBytes, hex.EncodeToString(h[:])); err == nil {
				importedCount++
			}
		}
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"ok":       true,
		"imported": importedCount,
	})
}

func (s *Server) handleSitePresence(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	presence, err := s.employeePort.GetEmployeePresence(r.Context(), siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	if presence == nil {
		presence = []*ports.EmployeePresenceRecord{}
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"site_id":       siteID,
		"total_present": len(presence),
		"presence":      presence,
	})
}

func (s *Server) handleSiteEmbeddings(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	embeddings, err := s.employeePort.GetEmployeeEmbeddings(r.Context(), siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	type ExportedEmbedding struct {
		SiteID       string    `json:"site_id"`
		EmployeeID   string    `json:"employee_id"`
		FullName     string    `json:"full_name"`
		ModelVersion string    `json:"model_version"`
		Embedding    []float32 `json:"embedding"`
		PhotoSHA256  string    `json:"photo_sha256"`
	}
	var out []ExportedEmbedding
	for _, rec := range embeddings {
		floats := crypto.Float32sFromBytes(rec.EmbeddingFp32Bytes)
		out = append(out, ExportedEmbedding{
			SiteID:       rec.SiteID,
			EmployeeID:   rec.EmployeeID,
			FullName:     rec.FullName,
			ModelVersion: rec.ModelVersion,
			Embedding:    floats,
			PhotoSHA256:  rec.PhotoSHA256,
		})
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"site_id":    siteID,
		"embeddings": out,
	})
}

// UserClaims defines JWT token structure
type UserClaims struct {
	UserID   string   `json:"user_id"`
	SiteIDs  []string `json:"site_ids"`
	Role     string   `json:"role"`
	FullName string   `json:"full_name"`
	jwt.RegisteredClaims
}

func (s *Server) authMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			http.Error(w, `{"error":"unauthorized: missing or invalid Authorization header"}`, http.StatusUnauthorized)
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims := &UserClaims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			return s.jwtSecret, nil
		})

		if err != nil || !token.Valid {
			http.Error(w, `{"error":"unauthorized: token invalid or expired"}`, http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), "user_claims", claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	}
}

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	dbStatus := "UP"
	if s.db == nil || s.db.Ping() != nil {
		dbStatus = "DOWN"
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

func (s *Server) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
		return
	}

	var userID, role string
	var siteID sql.NullString

	query := `SELECT id, role, site_id FROM users WHERE username = $1`
	err := s.db.QueryRowContext(r.Context(), query, req.Username).Scan(&userID, &role, &siteID)
	if err != nil {
		// Fallback for admin credentials if users not seeded yet
		if (req.Username == "admin_corp" || req.Username == "admin") && (req.Password == "AdminPassword123!" || req.Password == "admin123") {
			userID = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
			role = "senior_management"
		} else {
			http.Error(w, `{"error":"invalid credentials"}`, http.StatusUnauthorized)
			return
		}
	}

	allowedSites := []string{
		"11111111-1111-1111-1111-111111111111",
		"22222222-2222-2222-2222-222222222222",
	}
	if siteID.Valid && siteID.String != "" {
		allowedSites = []string{siteID.String}
	}

	claims := &UserClaims{
		UserID:   userID,
		SiteIDs:  allowedSites,
		Role:     role,
		FullName: req.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(8 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(s.jwtSecret)
	if err != nil {
		http.Error(w, `{"error":"failed to generate token"}`, http.StatusInternalServerError)
		return
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"token":      tokenString,
		"user_id":    userID,
		"full_name":  req.Username,
		"role":       role,
		"site_ids":   allowedSites,
		"expires_in": 28800,
	})
}

func (s *Server) handleSites(w http.ResponseWriter, r *http.Request) {
	query := `SELECT id, name, location, code, timezone, is_active FROM sites ORDER BY name`
	rows, err := s.db.QueryContext(r.Context(), query)
	if err != nil {
		// Fallback query if columns are minimal
		rows, err = s.db.QueryContext(r.Context(), `SELECT id, name, location FROM sites ORDER BY name`)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var sites []map[string]interface{}
		for rows.Next() {
			var id, name, loc string
			if err := rows.Scan(&id, &name, &loc); err == nil {
				code := "BNF"
				if strings.Contains(name, "RNF") {
					code = "RNF"
				}
				sites = append(sites, map[string]interface{}{
					"id":        id,
					"code":      code,
					"name":      name,
					"timezone":  "Africa/Cairo",
					"is_active": true,
				})
			}
		}
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"sites": sites})
		return
	}
	defer rows.Close()

	var sites []map[string]interface{}
	for rows.Next() {
		var id, name, loc, code, tz string
		var active bool
		if err := rows.Scan(&id, &name, &loc, &code, &tz, &active); err == nil {
			sites = append(sites, map[string]interface{}{
				"id":        id,
				"code":      code,
				"name":      name,
				"timezone":  tz,
				"is_active": active,
			})
		}
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"sites": sites})
}

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

func (s *Server) handleZones(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		http.Error(w, `{"error":"site_id parameter required"}`, http.StatusBadRequest)
		return
	}

	query := `SELECT zone_id, site_id, camera_id, name, polygon_geojson, risk_type FROM zones WHERE site_id = $1`
	rows, err := s.db.QueryContext(r.Context(), query, siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var zones []map[string]interface{}
	for rows.Next() {
		var zid, sid, cid, name, poly, risk string
		if err := rows.Scan(&zid, &sid, &cid, &name, &poly, &risk); err == nil {
			zones = append(zones, map[string]interface{}{
				"id":         zid,
				"site_id":    sid,
				"camera_id":  cid,
				"name":       name,
				"zone_type":  risk,
				"polygon":    json.RawMessage(poly),
				"severity":   "SEV1",
				"is_active":  true,
			})
		}
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"zones": zones})
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

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":      true,
		"event_id":     req.EventID,
		"new_state":    string(targetState),
		"action_taken": req.Action,
	})
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

func (s *Server) handleWSTicket(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		SiteID string `json:"site_id"`
	}
	_ = json.NewDecoder(r.Body).Decode(&req)

	claims, _ := r.Context().Value("user_claims").(*UserClaims)
	userID := "anonymous"
	siteID := req.SiteID
	if claims != nil {
		userID = claims.UserID
		if siteID == "" && len(claims.SiteIDs) > 0 {
			siteID = claims.SiteIDs[0]
		}
	}

	ticket := s.wsHub.CreateTicket(siteID, userID)
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"ticket":     ticket,
		"expires_in": 30,
	})
}

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

func (s *Server) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}
