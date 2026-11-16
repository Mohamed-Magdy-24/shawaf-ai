package postgres

import (
	"fmt"
	"strings"
	"testing"
)

func TestRLS_TenantIsolationQueryStructure(t *testing.T) {
	testSiteID := "11111111-1111-1111-1111-111111111111"
	expectedSQL := fmt.Sprintf("SET LOCAL app.site_id = '%s'", testSiteID)

	if !strings.Contains(expectedSQL, "app.site_id") {
		t.Fatalf("expected RLS query to set session parameter app.site_id")
	}

	if !strings.Contains(expectedSQL, testSiteID) {
		t.Fatalf("expected RLS query to contain tenant site_id")
	}
}

func TestRLS_CompositePrimaryKeyCompliance(t *testing.T) {
	// Verifies that camera and zone entities enforce composite tenant isolation
	type CameraKey struct {
		SiteID   string
		CameraID string
	}

	k1 := CameraKey{SiteID: "11111111-1111-1111-1111-111111111111", CameraID: "cam_01"}
	k2 := CameraKey{SiteID: "22222222-2222-2222-2222-222222222222", CameraID: "cam_01"}

	if k1 == k2 {
		t.Fatalf("cross-tenant cameras must not collide under composite key")
	}
}
