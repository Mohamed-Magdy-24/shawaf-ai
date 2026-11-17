package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

func TestHandleHealthz(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")
	mux := http.NewServeMux()
	server.RegisterRoutes(mux)

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected HTTP 200, got %d", rec.Code)
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}

	if resp["status"] != "SERVING" {
		t.Fatalf("expected status SERVING, got %v", resp["status"])
	}
}

func TestHandleAlertAction_FR_ALT_008_Violation(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")

	// Payload with DISMISS and empty note
	payload := map[string]string{
		"site_id":  "11111111-1111-1111-1111-111111111111",
		"event_id": "evt-001",
		"action":   "DISMISS",
		"note":     "   ", // empty / whitespace only
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/alerts/actions", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	// Attach user claims to context
	claims := &UserClaims{
		UserID:   "user-01",
		FullName: "sec_mgr",
		Role:     "security_manager",
		SiteIDs:  []string{"11111111-1111-1111-1111-111111111111"},
	}
	ctx := context.WithValue(req.Context(), "user_claims", claims)
	req = req.WithContext(ctx)

	rec := httptest.NewRecorder()
	server.handleAlertAction(rec, req)

	// Expect HTTP 400 Bad Request
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("expected HTTP 400 on FR-ALT-008 violation, got %d. Body: %s", rec.Code, rec.Body.String())
	}

	if !bytes.Contains(rec.Body.Bytes(), []byte("FR-ALT-008 violation")) {
		t.Fatalf("expected response to mention 'FR-ALT-008 violation', got: %s", rec.Body.String())
	}
}

func TestHandleWebRTCSDP_D011_OperatorDenied(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")

	payload := map[string]string{
		"site_id":   "11111111-1111-1111-1111-111111111111",
		"camera_id": "bnf_cam_01",
		"sdp":       "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\n",
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/webrtc/sdp", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	// Claims for factory_operator (Forbidden per D-011)
	claims := &UserClaims{
		UserID:   "op-01",
		FullName: "operator_bnf",
		Role:     "factory_operator",
		SiteIDs:  []string{"11111111-1111-1111-1111-111111111111"},
	}
	ctx := context.WithValue(req.Context(), "user_claims", claims)
	req = req.WithContext(ctx)

	rec := httptest.NewRecorder()
	server.handleWebRTCSDP(rec, req)

	// Expect HTTP 403 Forbidden
	if rec.Code != http.StatusForbidden {
		t.Fatalf("expected HTTP 403 Forbidden per D-011, got %d. Body: %s", rec.Code, rec.Body.String())
	}

	if !bytes.Contains(rec.Body.Bytes(), []byte("D-011 role policy denies live video access")) {
		t.Fatalf("expected D-011 rejection message, got: %s", rec.Body.String())
	}
}

func TestAuthMiddleware_Unauthorized(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")
	mux := http.NewServeMux()
	server.RegisterRoutes(mux)

	// Request without Authorization header
	req := httptest.NewRequest(http.MethodGet, "/api/v1/sites", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected HTTP 401 Unauthorized for missing token, got %d", rec.Code)
	}
}

func TestJWT_SigningAndValidation(t *testing.T) {
	secret := []byte("test_jwt_secret_32bytes_min_1234")

	claims := &UserClaims{
		UserID:   "user-test-123",
		FullName: "sec_mgr_bnf",
		Role:     "security_manager",
		SiteIDs:  []string{"11111111-1111-1111-1111-111111111111"},
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(1 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   "user-test-123",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString(secret)
	if err != nil {
		t.Fatalf("failed to sign token: %v", err)
	}

	// Verify token
	parsedClaims := &UserClaims{}
	parsedToken, err := jwt.ParseWithClaims(tokenStr, parsedClaims, func(t *jwt.Token) (interface{}, error) {
		return secret, nil
	})
	if err != nil || !parsedToken.Valid {
		t.Fatalf("token validation failed: %v", err)
	}

	if parsedClaims.Role != "security_manager" {
		t.Fatalf("expected role security_manager, got %s", parsedClaims.Role)
	}
}

type mockCameraRepo struct {
	registered []*ports.Camera
}

func (m *mockCameraRepo) RegisterCamera(ctx context.Context, cam *ports.Camera) error {
	m.registered = append(m.registered, cam)
	return nil
}

func (m *mockCameraRepo) GetCameras(ctx context.Context, siteID string) ([]*ports.Camera, error) {
	var res []*ports.Camera
	for _, c := range m.registered {
		if c.SiteID == siteID {
			res = append(res, c)
		}
	}
	return res, nil
}

func (m *mockCameraRepo) GetCamera(ctx context.Context, siteID, cameraID string) (*ports.Camera, error) {
	for _, c := range m.registered {
		if c.SiteID == siteID && c.CameraID == cameraID {
			return c, nil
		}
	}
	return nil, ports.ErrCameraNotFound
}

func TestHandleRegisterSiteCamera_RBAC_Denied(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")
	mockRepo := &mockCameraRepo{}
	server.SetPorts(mockRepo, nil, nil, nil)

	payload := map[string]interface{}{
		"camera_id":    "test_cam_01",
		"name":         "Test Cam",
		"rtsp_sub_url": "rtsp://192.168.1.50/sub",
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/sites/11111111-1111-1111-1111-111111111111/cameras", bytes.NewReader(body))
	claims := &UserClaims{
		UserID:  "op-1",
		Role:    "factory_operator",
		SiteIDs: []string{"11111111-1111-1111-1111-111111111111"},
	}
	req = req.WithContext(context.WithValue(req.Context(), "user_claims", claims))

	rec := httptest.NewRecorder()
	server.handleRegisterSiteCamera(rec, req, "11111111-1111-1111-1111-111111111111")

	if rec.Code != http.StatusForbidden {
		t.Fatalf("expected HTTP 403 Forbidden for operator, got %d", rec.Code)
	}
}

func TestHandleRegisterSiteCamera_InvalidRTSP(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")
	mockRepo := &mockCameraRepo{}
	server.SetPorts(mockRepo, nil, nil, nil)

	payload := map[string]interface{}{
		"camera_id":    "test_cam_01",
		"name":         "Test Cam",
		"rtsp_sub_url": "http://invalid-stream/video.mp4",
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/sites/11111111-1111-1111-1111-111111111111/cameras", bytes.NewReader(body))
	claims := &UserClaims{
		UserID:  "mgr-1",
		Role:    "security_manager",
		SiteIDs: []string{"11111111-1111-1111-1111-111111111111"},
	}
	req = req.WithContext(context.WithValue(req.Context(), "user_claims", claims))

	rec := httptest.NewRecorder()
	server.handleRegisterSiteCamera(rec, req, "11111111-1111-1111-1111-111111111111")

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("expected HTTP 400 Bad Request on invalid RTSP URL, got %d", rec.Code)
	}
}

func TestHandleRegisterSiteCamera_Success_Sanitized(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")
	mockRepo := &mockCameraRepo{}
	server.SetPorts(mockRepo, nil, nil, nil)

	payload := map[string]interface{}{
		"camera_id":    "bnf_cam_new",
		"name":         "BNF Perimeter Gate 3",
		"rtsp_sub_url": "rtsp://admin:secret123@10.0.1.20:554/live/sub",
		"fps_target":   15,
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/sites/11111111-1111-1111-1111-111111111111/cameras", bytes.NewReader(body))
	claims := &UserClaims{
		UserID:  "mgr-1",
		Role:    "security_manager",
		SiteIDs: []string{"11111111-1111-1111-1111-111111111111"},
	}
	req = req.WithContext(context.WithValue(req.Context(), "user_claims", claims))

	rec := httptest.NewRecorder()
	server.handleRegisterSiteCamera(rec, req, "11111111-1111-1111-1111-111111111111")

	if rec.Code != http.StatusCreated {
		t.Fatalf("expected HTTP 201 Created, got %d. Body: %s", rec.Code, rec.Body.String())
	}

	var resp struct {
		OK     bool         `json:"ok"`
		Camera ports.Camera `json:"camera"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}

	// Verify RTSP URL is sanitized and credentials are scrubbed
	if strings.Contains(resp.Camera.RTSPURL, "secret123") {
		t.Fatalf("SECURITY VIOLATION: credentials leaked in camera response: %s", resp.Camera.RTSPURL)
	}
	if !strings.Contains(resp.Camera.RTSPURL, "***:***@") {
		t.Fatalf("expected credentials to be replaced with '***:***@', got: %s", resp.Camera.RTSPURL)
	}
}

func TestHandleSiteEmployees_503_BlockedByGovernance(t *testing.T) {
	server := NewServer(nil, nil, nil, nil, nil, "test_jwt_secret_32bytes_min_1234")

	req := httptest.NewRequest(http.MethodGet, "/api/v1/sites/11111111-1111-1111-1111-111111111111/employees", nil)
	rec := httptest.NewRecorder()
	server.handleSiteEmployees(rec, req, "11111111-1111-1111-1111-111111111111")

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected HTTP 503 Service Unavailable, got %d", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "FEATURE_BLOCKED_BY_GOVERNANCE") {
		t.Fatalf("expected response to declare FEATURE_BLOCKED_BY_GOVERNANCE, got: %s", rec.Body.String())
	}
}
