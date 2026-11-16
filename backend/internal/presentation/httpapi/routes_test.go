package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
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
