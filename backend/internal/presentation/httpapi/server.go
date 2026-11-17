package httpapi

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/governance"
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
		jwtSecret = os.Getenv("EDGED_JWT_SECRET")
	}
	encKey := os.Getenv("EDGED_ENCRYPTION_KEY")
	evDir := os.Getenv("EDGED_EVIDENCE_DIR")
	if evDir == "" {
		evDir = "/var/lib/surveillance/evidence"
	}
	s := &Server{
		db:            db,
		repo:          repo,
		ingestionSvc:  ingestionSvc,
		go2rtcProxy:   go2rtcProxy,
		wsHub:         wsHub,
		jwtSecret:     []byte(jwtSecret),
		encryptionKey: encKey,
		evidenceDir:   evDir,
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

func (s *Server) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

// writeData writes a single entity response according to the canonical contract: { "data": { ... } }
func (s *Server) writeData(w http.ResponseWriter, status int, data interface{}) {
	s.writeJSON(w, status, map[string]interface{}{
		"data": data,
	})
}

// writeDataList writes a collection response according to the canonical contract: { "data": [ ... ], "meta": { ... } }
// For maximum backward-compatibility with existing integration tests, it also embeds the resourceKey if provided.
func (s *Server) writeDataList(w http.ResponseWriter, status int, resourceKey string, data interface{}, meta map[string]interface{}) {
	if meta == nil {
		meta = map[string]interface{}{}
	}
	resp := map[string]interface{}{
		"data": data,
		"meta": meta,
	}
	if resourceKey != "" {
		resp[resourceKey] = data
	}
	s.writeJSON(w, status, resp)
}

// writeError writes a structured error response according to the canonical contract:
// { "error": { "code": "...", "message": "...", "details": { ... } } }
func (s *Server) writeError(w http.ResponseWriter, status int, code, message string, details map[string]interface{}) {
	if details == nil {
		details = map[string]interface{}{}
	}
	s.writeJSON(w, status, map[string]interface{}{
		"error": map[string]interface{}{
			"code":    code,
			"message": message,
			"details": details,
		},
	})
}

// LogAuditAction records administrative operations into the immutable platform audit_logs table
func (s *Server) LogAuditAction(ctx context.Context, siteID, userID, action, resource string, details map[string]interface{}) {
	if s.db == nil {
		return
	}
	detailsJSON, _ := json.Marshal(details)
	query := `
		INSERT INTO audit_logs (site_id, user_id, action, resource, details_json, created_at)
		VALUES ($1, $2, $3, $4, $5, NOW())`

	var sID, uID *string
	if siteID != "" {
		sID = &siteID
	}
	if userID != "" && userID != "anonymous" {
		uID = &userID
	}

	if _, err := s.db.ExecContext(ctx, query, sID, uID, action, resource, detailsJSON); err != nil {
		log.Printf("[Audit] Warning: Failed to record audit log: %v", err)
	}
}
