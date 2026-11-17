package httpapi

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// UserClaims defines JWT token structure
type UserClaims struct {
	UserID   string   `json:"user_id"`
	SiteIDs  []string `json:"site_ids"`
	Role     string   `json:"role"`
	FullName string   `json:"full_name"`
	jwt.RegisteredClaims
}

func (s *Server) authMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			http.Error(w, `{"error":"unauthorized: missing or invalid Authorization header"}`, http.StatusUnauthorized)
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims := &UserClaims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			return s.jwtSecret, nil
		})

		if err != nil || !token.Valid {
			http.Error(w, `{"error":"unauthorized: token invalid or expired"}`, http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), "user_claims", claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	}
}

func (s *Server) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
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

	var userID, role string
	var siteID sql.NullString

	query := `SELECT id, role, site_id FROM users WHERE username = $1`
	err := s.db.QueryRowContext(r.Context(), query, req.Username).Scan(&userID, &role, &siteID)
	if err != nil {
		// Fallback for admin credentials if users not seeded yet
		if (req.Username == "admin_corp" || req.Username == "admin") && (req.Password == "AdminPassword123!" || req.Password == "admin123") {
			userID = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
			role = "senior_management"
		} else {
			http.Error(w, `{"error":"invalid credentials"}`, http.StatusUnauthorized)
			return
		}
	}

	allowedSites := []string{
		"11111111-1111-1111-1111-111111111111",
		"22222222-2222-2222-2222-222222222222",
	}
	if siteID.Valid && siteID.String != "" {
		allowedSites = []string{siteID.String}
	}

	claims := &UserClaims{
		UserID:   userID,
		SiteIDs:  allowedSites,
		Role:     role,
		FullName: req.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(8 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(s.jwtSecret)
	if err != nil {
		http.Error(w, `{"error":"failed to generate token"}`, http.StatusInternalServerError)
		return
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"token":      tokenString,
		"user_id":    userID,
		"full_name":  req.Username,
		"role":       role,
		"site_ids":   allowedSites,
		"expires_in": 28800,
	})
}

func (s *Server) handleWSTicket(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
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
	}

	ticket := s.wsHub.CreateTicket(siteID, userID)
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"ticket":     ticket,
		"expires_in": 30,
	})
}
