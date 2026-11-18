package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/ws"
)

type dummyIncidentRepo struct {
	incidents map[string]*domain.SafetyIncident
}

func newDummyIncidentRepo() *dummyIncidentRepo {
	return &dummyIncidentRepo{incidents: make(map[string]*domain.SafetyIncident)}
}

func (d *dummyIncidentRepo) Save(ctx context.Context, inc *domain.SafetyIncident) error {
	d.incidents[inc.ID] = inc
	return nil
}
func (d *dummyIncidentRepo) SaveWithOutbox(ctx context.Context, inc *domain.SafetyIncident, payload []byte, isFirePriority bool) (bool, error) {
	if _, exists := d.incidents[inc.ID]; exists {
		return false, nil // duplicate
	}
	d.incidents[inc.ID] = inc
	return true, nil
}
func (d *dummyIncidentRepo) GetByID(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error) {
	if inc, ok := d.incidents[id]; ok && inc.SiteID == siteID {
		return inc, nil
	}
	return nil, domain.ErrInvalidSiteID
}
func (d *dummyIncidentRepo) ListActive(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error) {
	var list []*domain.SafetyIncident
	for _, inc := range d.incidents {
		if inc.SiteID == siteID && (inc.Status == domain.StatusNew || inc.Status == domain.StatusAcknowledged) {
			list = append(list, inc)
		}
	}
	return list, nil
}
func (d *dummyIncidentRepo) Update(ctx context.Context, inc *domain.SafetyIncident) error {
	d.incidents[inc.ID] = inc
	return nil
}

type dummyOutboxRepo struct{}

func (d *dummyOutboxRepo) Enqueue(ctx context.Context, siteID, eventID string, payload []byte, isFirePriority bool) error {
	return nil
}
func (d *dummyOutboxRepo) FetchAndLockPending(ctx context.Context, limit int, lockDuration time.Duration) ([]*domain.OutboxRecord, error) {
	return nil, nil
}
func (d *dummyOutboxRepo) MarkPublished(ctx context.Context, id int64) error {
	return nil
}
func (d *dummyOutboxRepo) ReapExpiredLeases(ctx context.Context) (int64, error) {
	return 0, nil
}

type dummyCameraRepo struct {
	cameras map[string]*domain.Camera
}

func newDummyCameraRepo() *dummyCameraRepo {
	r := &dummyCameraRepo{cameras: make(map[string]*domain.Camera)}
	r.cameras["cam_01"] = &domain.Camera{
		ID:          "cam_01",
		SiteID:      "site_bnf",
		Name:        "Gate Camera",
		RTSPMainURL: "rtsp://mediamtx:8554/bnf/camera01",
		Status:      domain.CameraStatusOnline,
	}
	return r
}
func (d *dummyCameraRepo) GetByID(ctx context.Context, siteID, cameraID string) (*domain.Camera, error) {
	if cam, ok := d.cameras[cameraID]; ok && cam.SiteID == siteID {
		return cam, nil
	}
	return nil, domain.ErrInvalidCameraID
}
func (d *dummyCameraRepo) List(ctx context.Context, siteID string) ([]*domain.Camera, error) {
	var list []*domain.Camera
	for _, cam := range d.cameras {
		if cam.SiteID == siteID {
			list = append(list, cam)
		}
	}
	return list, nil
}
func (d *dummyCameraRepo) UpdateTelemetry(ctx context.Context, siteID, cameraID string, online bool, fps float64, dropped uint64, lastHeartbeat time.Time) error {
	return nil
}

func setupTestServer(t *testing.T, snapDir string) (*http.ServeMux, *dummyIncidentRepo, *application.TicketService, *Handler, *Authenticator) {
	incRepo := newDummyIncidentRepo()
	outboxRepo := &dummyOutboxRepo{}
	camRepo := newDummyCameraRepo()

	events := application.NewEventService(incRepo, outboxRepo, camRepo)
	cameras := application.NewCameraService(camRepo, events)
	tickets := application.NewTicketService()
	hub := ws.NewHub()
	proxy := go2rtc.NewSDPProxyClient("http://127.0.0.1:9999") // dummy target
	auth := NewAuthenticator("test_secret")

	handler := NewHandler(events, cameras, tickets, hub, proxy, snapDir, auth)
	mux := http.NewServeMux()
	handler.RegisterRoutes(mux)

	return mux, incRepo, tickets, handler, auth
}

func TestHandler_Healthz(t *testing.T) {
	mux, _, _, _, _ := setupTestServer(t, "")

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to decode json: %v", err)
	}
	if resp["status"] != "HEALTHY" {
		t.Fatalf("expected HEALTHY, got %v", resp["status"])
	}
}

func TestHandler_Authentication_And_Authorization_Boundaries(t *testing.T) {
	mux, _, _, _, auth := setupTestServer(t, "")

	// 1. Unauthenticated request -> 401 Unauthorized
	req := httptest.NewRequest(http.MethodGet, "/api/v1/sites/site_bnf/cameras", nil)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for unauthenticated request, got %d", rec.Code)
	}

	// 2. Invalid token -> 401 Unauthorized
	req = httptest.NewRequest(http.MethodGet, "/api/v1/sites/site_bnf/cameras", nil)
	req.Header.Set("Authorization", "Bearer invalid_garbage_token")
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for invalid token, got %d", rec.Code)
	}

	// 3. Expired token -> 401 Unauthorized
	expiredToken, _ := auth.GenerateSignedToken(&Principal{
		UserID:       "op_expired",
		Role:         "operator",
		AllowedSites: []string{"site_bnf"},
		ExpiresAt:    time.Now().UTC().Add(-1 * time.Hour),
	})
	req = httptest.NewRequest(http.MethodGet, "/api/v1/sites/site_bnf/cameras", nil)
	req.Header.Set("Authorization", "Bearer "+expiredToken)
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for expired token, got %d", rec.Code)
	}

	// 4. Cross-tenant attempt: site_bnf user trying site_rnf -> 403 Forbidden
	bnfToken, _ := auth.GenerateSignedToken(&Principal{
		UserID:       "op_bnf",
		Role:         "operator",
		AllowedSites: []string{"site_bnf"},
		ExpiresAt:    time.Now().UTC().Add(1 * time.Hour),
	})
	req = httptest.NewRequest(http.MethodGet, "/api/v1/sites/site_rnf/cameras", nil)
	req.Header.Set("Authorization", "Bearer "+bnfToken)
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusForbidden {
		t.Fatalf("expected 403 for cross-tenant access, got %d", rec.Code)
	}

	// 5. Authorized site_bnf request -> 200 OK
	req = httptest.NewRequest(http.MethodGet, "/api/v1/sites/site_bnf/cameras", nil)
	req.Header.Set("Authorization", "Bearer "+bnfToken)
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200 for authorized tenant request, got %d", rec.Code)
	}
}

func TestHandler_IssueWSTicket(t *testing.T) {
	mux, _, tickets, _, auth := setupTestServer(t, "")

	bnfToken, _ := auth.GenerateSignedToken(&Principal{
		UserID:       "operator_patrol",
		Role:         "operator",
		AllowedSites: []string{"site_bnf"},
		ExpiresAt:    time.Now().UTC().Add(1 * time.Hour),
	})

	// Client sends spoofed user_id in body -> server must IGNORE it and use operator_patrol from token!
	reqBody := []byte(`{"user_id":"spoofed_hacker_id"}`)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/sites/site_bnf/ws-ticket", bytes.NewReader(reqBody))
	req.Header.Set("Authorization", "Bearer "+bnfToken)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
	}

	var resp issueTicketResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to decode ticket response: %v", err)
	}

	if resp.Ticket == "" || resp.ExpiresInSeconds != 15 || resp.SiteID != "site_bnf" {
		t.Fatalf("unexpected ticket response: %+v", resp)
	}

	// Verify ticket is strictly bound to the authenticated principal operator_patrol
	userID, err := tickets.ConsumeTicket(resp.Ticket, "site_bnf")
	if err != nil {
		t.Fatalf("expected ticket to be valid, got %v", err)
	}
	if userID != "operator_patrol" {
		t.Fatalf("expected principal operator_patrol (spoofed body ignored), got %s", userID)
	}
}

func TestHandler_IncidentLifecycle(t *testing.T) {
	mux, incRepo, _, _, auth := setupTestServer(t, "")

	bnfToken, _ := auth.GenerateSignedToken(&Principal{
		UserID:       "op_floor_1",
		Role:         "operator",
		AllowedSites: []string{"site_bnf"},
		ExpiresAt:    time.Now().UTC().Add(1 * time.Hour),
	})

	// Seed incident
	now := time.Now().UTC()
	inc, _ := domain.NewSafetyIncident("evt-lifecycle-1", "site_bnf", "cam_01", "zone_gate", "entry.detected", domain.SeverityWarning, now, "yolox", "1.0", 0.9, nil, "snap.jpg")
	_ = incRepo.Save(context.Background(), inc)

	// 1. Acknowledge
	ackBody := []byte(`{}`)
	ackReq := httptest.NewRequest(http.MethodPost, "/api/v1/sites/site_bnf/incidents/evt-lifecycle-1/acknowledge", bytes.NewReader(ackBody))
	ackReq.Header.Set("Authorization", "Bearer "+bnfToken)
	ackRec := httptest.NewRecorder()
	mux.ServeHTTP(ackRec, ackReq)

	if ackRec.Code != http.StatusOK {
		t.Fatalf("expected 200 on acknowledge, got %d: %s", ackRec.Code, ackRec.Body.String())
	}

	// 2. Dismiss with missing reason -> MUST FAIL with 400
	disReq := httptest.NewRequest(http.MethodPost, "/api/v1/sites/site_bnf/incidents/evt-lifecycle-1/dismiss", bytes.NewReader([]byte(`{}`)))
	disReq.Header.Set("Authorization", "Bearer "+bnfToken)
	disRec := httptest.NewRecorder()
	mux.ServeHTTP(disRec, disReq)

	if disRec.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 when dismissal reason is missing, got %d", disRec.Code)
	}

	// 3. Resolve
	resBody := []byte(`{}`)
	resReq := httptest.NewRequest(http.MethodPost, "/api/v1/sites/site_bnf/incidents/evt-lifecycle-1/resolve", bytes.NewReader(resBody))
	resReq.Header.Set("Authorization", "Bearer "+bnfToken)
	resRec := httptest.NewRecorder()
	mux.ServeHTTP(resRec, resReq)

	if resRec.Code != http.StatusOK {
		t.Fatalf("expected 200 on resolve, got %d: %s", resRec.Code, resRec.Body.String())
	}
}

func TestHandler_SnapshotTraversalProtection(t *testing.T) {
	tmpDir := t.TempDir()
	// Write a safe snapshot inside tmpDir
	safeFile := filepath.Join(tmpDir, "site_bnf", "test.jpg")
	_ = os.MkdirAll(filepath.Dir(safeFile), 0755)
	_ = os.WriteFile(safeFile, []byte("fake_jpeg_data"), 0644)

	mux, _, _, handler, _ := setupTestServer(t, tmpDir)

	// Safe request -> 200
	req := httptest.NewRequest(http.MethodGet, "/snapshots/site_bnf/test.jpg", nil)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200 for safe snapshot, got %d", rec.Code)
	}

	// Traversal attempt -> 403 Forbidden
	travReq := httptest.NewRequest(http.MethodGet, "/snapshots/../secret.txt", nil)
	travRec := httptest.NewRecorder()
	handler.handleSnapshotFile(travRec, travReq)
	if travRec.Code != http.StatusForbidden {
		t.Fatalf("expected 403 for path traversal, got %d", travRec.Code)
	}
}
