package ports

import (
	"context"
	"errors"
	"time"
)

var (
	ErrFeatureBlockedByGovernance = errors.New("503 FEATURE_BLOCKED_BY_GOVERNANCE: direct factory ZKTeco/SQL Server contact and biometric processing are strictly prohibited under OWNER_AUTHORIZATION_LOCAL_DEV.md pending SPK-01, SPK-04, and DEC-06 approvals")
	ErrEmployeeNotFound           = errors.New("identity: employee record not found")
)

// Employee represents an enrolled industrial employee under multi-site tenant isolation
type Employee struct {
	SiteID       string    `json:"site_id"`
	EmployeeID   string    `json:"employee_id"`
	FullName     string    `json:"full_name"`
	Department   string    `json:"department"`
	PhotoRelPath string    `json:"photo_rel_path,omitempty"`
	SourceType   string    `json:"source_type"` // MANUAL_UPLOAD, CSV_IMPORT, ZKTECO_SYNC, SQLSERVER_SYNC
	IsActive     bool      `json:"is_active"`
	CreatedAt    time.Time `json:"created_at,omitempty"`
}

// EmployeePresenceRecord represents the real-time "Who & Where" presence state
type EmployeePresenceRecord struct {
	SiteID     string    `json:"site_id"`
	EmployeeID string    `json:"employee_id"`
	FullName   string    `json:"full_name"`
	Department string    `json:"department"`
	CameraID   string    `json:"camera_id"`
	ZoneID     string    `json:"zone_id,omitempty"`
	Confidence float32   `json:"confidence"`
	LastSeenAt time.Time `json:"last_seen_at"`
}

// EmployeeEmbeddingRecord represents a 512-d L2-normalized float32 face embedding
type EmployeeEmbeddingRecord struct {
	SiteID             string    `json:"site_id"`
	EmployeeID         string    `json:"employee_id"`
	FullName           string    `json:"full_name"`
	ModelVersion       string    `json:"model_version"`
	EmbeddingFp32Bytes []byte    `json:"-"`
	PhotoSHA256        string    `json:"photo_sha256"`
	CreatedAt          time.Time `json:"created_at,omitempty"`
}

// EmployeeRegistryPort defines the primary domain contract for employee identity and presence
type EmployeeRegistryPort interface {
	RegisterEmployee(ctx context.Context, emp *Employee, embeddingBytes []byte, photoSHA256 string) error
	GetEmployees(ctx context.Context, siteID string) ([]*Employee, error)
	GetEmployee(ctx context.Context, siteID, employeeID string) (*Employee, error)
	GetEmployeePresence(ctx context.Context, siteID string) ([]*EmployeePresenceRecord, error)
	GetEmployeeEmbeddings(ctx context.Context, siteID string) ([]*EmployeeEmbeddingRecord, error)
}

// EmployeeIdentity represents an employee record synchronized from read-only attendance databases
type EmployeeIdentity struct {
	SiteID     string `json:"site_id"`
	EmployeeID string `json:"employee_id"`
	FullName   string `json:"full_name"`
	Department string `json:"department"`
	IsActive   bool   `json:"is_active"`
}

// BiometricFacePhoto represents verified RGB facial imagery obtained via official terminal export APIs
type BiometricFacePhoto struct {
	EmployeeID string `json:"employee_id"`
	PhotoBytes []byte `json:"-"`
	SHA256     string `json:"sha256"`
	MimeType   string `json:"mime_type"`
}

// AttendanceEmployeeReader defines the domain contract for reading employees from read-only staging views (SPK-04)
type AttendanceEmployeeReader interface {
	ReadEmployees(ctx context.Context, siteID string) ([]*EmployeeIdentity, error)
	GetEmployee(ctx context.Context, siteID, employeeID string) (*EmployeeIdentity, error)
}

// BiometricPhotoFetcher defines the domain contract for retrieving official employee RGB reference photos (SPK-01)
type BiometricPhotoFetcher interface {
	FetchVerifiedFacePhoto(ctx context.Context, siteID, employeeID string) (*BiometricFacePhoto, error)
}
