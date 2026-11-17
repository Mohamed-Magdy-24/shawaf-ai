package httpapi

import (
	"database/sql"
	"encoding/json"
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
