package httpapi

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/crypto"
)

var (
	loginLimiter = NewRateLimiter(5, 10)
)

// UserClaims defines JWT access token structure
type UserClaims struct {
	UserID    string   `json:"user_id"`
	SiteIDs   []string `json:"site_ids"`
	Role      string   `json:"role"`
	FullName  string   `json:"full_name"`
	TokenType string   `json:"token_type,omitempty"`
	jwt.RegisteredClaims
}

func (s *Server) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	clientIP := strings.Split(r.RemoteAddr, ":")[0]
	if !loginLimiter.allow(clientIP) {
		s.writeError(w, http.StatusTooManyRequests, "RATE_LIMITED", "too many login attempts; retry in 60 seconds", nil)
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

	if s.db == nil {
		http.Error(w, `{"error":"database unavailable"}`, http.StatusServiceUnavailable)
		return
	}

	var userID, role, passwordHash string
	var siteID sql.NullString

	query := `SELECT id, password_hash, role, site_id FROM users WHERE username = $1`
	err := s.db.QueryRowContext(r.Context(), query, req.Username).Scan(&userID, &passwordHash, &role, &siteID)
	if err != nil {
		s.LogAuditAction(r.Context(), "", "", "LOGIN_FAILURE", "users", map[string]interface{}{"username": req.Username, "ip": clientIP, "reason": "user_not_found"})
		http.Error(w, `{"error":"invalid credentials"}`, http.StatusUnauthorized)
		return
	}

	valid, vErr := crypto.VerifyPassword(req.Password, passwordHash)
	if vErr != nil || !valid {
		s.LogAuditAction(r.Context(), "", userID, "LOGIN_FAILURE", "users", map[string]interface{}{"username": req.Username, "ip": clientIP, "reason": "bad_password"})
		http.Error(w, `{"error":"invalid credentials"}`, http.StatusUnauthorized)
		return
	}

	allowedSites := []string{
		"11111111-1111-1111-1111-111111111111",
		"22222222-2222-2222-2222-222222222222",
	}
	if siteID.Valid && siteID.String != "" {
		allowedSites = []string{siteID.String}
	}

	// Short-lived Access Token (15 minutes)
	accessClaims := &UserClaims{
		UserID:    userID,
		SiteIDs:   allowedSites,
		Role:      role,
		FullName:  req.Username,
		TokenType: "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   userID,
		},
	}
	accessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(s.jwtSecret)
	if err != nil {
		http.Error(w, `{"error":"failed to generate access token"}`, http.StatusInternalServerError)
		return
	}

	// Refresh Token (7 days rotation)
	refreshClaims := &UserClaims{
		UserID:    userID,
		TokenType: "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   userID,
		},
	}
	refreshToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(s.jwtSecret)
	if err != nil {
		http.Error(w, `{"error":"failed to generate refresh token"}`, http.StatusInternalServerError)
		return
	}

	s.LogAuditAction(r.Context(), siteID.String, userID, "LOGIN_SUCCESS", "users", map[string]interface{}{"username": req.Username, "role": role, "ip": clientIP})

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"data": map[string]interface{}{
			"token":         accessToken,
			"refresh_token": refreshToken,
			"user_id":       userID,
			"full_name":     req.Username,
			"role":          role,
			"site_ids":      allowedSites,
			"expires_in":    900,
		},
		"token":         accessToken,
		"refresh_token": refreshToken,
		"user_id":       userID,
		"full_name":     req.Username,
		"role":          role,
		"site_ids":      allowedSites,
		"expires_in":    900,
	})
}

func (s *Server) handleRefreshToken(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		RefreshToken string `json:"refresh_token"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		http.Error(w, `{"error":"invalid refresh token payload"}`, http.StatusBadRequest)
		return
	}

	claims := &UserClaims{}
	token, err := jwt.ParseWithClaims(req.RefreshToken, claims, func(t *jwt.Token) (interface{}, error) {
		return s.jwtSecret, nil
	})
	if err != nil || !token.Valid || claims.TokenType != "refresh" {
		http.Error(w, `{"error":"invalid or expired refresh token"}`, http.StatusUnauthorized)
		return
	}

	var role string
	var siteID sql.NullString
	var username string
	query := `SELECT username, role, site_id FROM users WHERE id = $1`
	if err := s.db.QueryRowContext(r.Context(), query, claims.UserID).Scan(&username, &role, &siteID); err != nil {
		http.Error(w, `{"error":"user not found"}`, http.StatusUnauthorized)
		return
	}

	allowedSites := []string{
		"11111111-1111-1111-1111-111111111111",
		"22222222-2222-2222-2222-222222222222",
	}
	if siteID.Valid && siteID.String != "" {
		allowedSites = []string{siteID.String}
	}

	newAccessClaims := &UserClaims{
		UserID:    claims.UserID,
		SiteIDs:   allowedSites,
		Role:      role,
		FullName:  username,
		TokenType: "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   claims.UserID,
		},
	}
	newAccessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, newAccessClaims).SignedString(s.jwtSecret)
	if err != nil {
		http.Error(w, `{"error":"failed to generate access token"}`, http.StatusInternalServerError)
		return
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"token":      newAccessToken,
		"expires_in": 900,
	})
}

func (s *Server) handleWSTicket(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		s.writeError(w, http.StatusMethodNotAllowed, "METHOD_NOT_ALLOWED", "method not allowed", nil)
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
		if siteID != "" {
			if err := s.AuthorizeSiteAccess(r, siteID); err != nil {
				s.writeError(w, http.StatusForbidden, "FORBIDDEN", err.Error(), nil)
				return
			}
		}
	}

	ticket := s.wsHub.CreateTicket(siteID, userID)
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"data": map[string]interface{}{
			"ticket":     ticket,
			"expires_in": 30,
		},
		"ticket":     ticket,
		"expires_in": 30,
	})
}
