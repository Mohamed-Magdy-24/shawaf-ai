package ports

import (
	"context"
	"errors"
)

// ErrFeatureBlockedByGovernance is strictly returned when unapproved hardware/data access is attempted.
var ErrFeatureBlockedByGovernance = errors.New("503 FEATURE_BLOCKED_BY_GOVERNANCE: direct factory ZKTeco/SQL Server contact and biometric processing are strictly prohibited under OWNER_AUTHORIZATION_LOCAL_DEV.md pending SPK-01, SPK-04, and DEC-06 approvals")

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
