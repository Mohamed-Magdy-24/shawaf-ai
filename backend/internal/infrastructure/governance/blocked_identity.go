package governance

import (
	"context"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

// BlockedIdentityAdapter implements AttendanceEmployeeReader and BiometricPhotoFetcher
// by strictly enforcing OWNER_AUTHORIZATION_LOCAL_DEV.md governance boundaries.
type BlockedIdentityAdapter struct{}

func NewBlockedIdentityAdapter() *BlockedIdentityAdapter {
	return &BlockedIdentityAdapter{}
}

func (b *BlockedIdentityAdapter) ReadEmployees(ctx context.Context, siteID string) ([]*ports.EmployeeIdentity, error) {
	return nil, ports.ErrFeatureBlockedByGovernance
}

func (b *BlockedIdentityAdapter) GetEmployee(ctx context.Context, siteID, employeeID string) (*ports.EmployeeIdentity, error) {
	return nil, ports.ErrFeatureBlockedByGovernance
}

func (b *BlockedIdentityAdapter) FetchVerifiedFacePhoto(ctx context.Context, siteID, employeeID string) (*ports.BiometricFacePhoto, error) {
	return nil, ports.ErrFeatureBlockedByGovernance
}
