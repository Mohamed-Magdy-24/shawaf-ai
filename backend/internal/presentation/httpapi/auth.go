package httpapi

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

type contextKey string

const principalContextKey = contextKey("authenticated_principal")

// Principal represents the authenticated user context
type Principal struct {
	UserID       string    `json:"user_id"`
	Role         string    `json:"role"`
	AllowedSites []string  `json:"allowed_sites"`
	ExpiresAt    time.Time `json:"exp"`
}

// CanAccessSite checks if principal is authorized for siteID
func (p *Principal) CanAccessSite(siteID string) bool {
	if p == nil {
		return false
	}
	for _, s := range p.AllowedSites {
		if s == "*" || s == siteID {
			return true
		}
	}
	return false
}

// ContextWithPrincipal returns a new context with principal
func ContextWithPrincipal(ctx context.Context, p *Principal) context.Context {
	return context.WithValue(ctx, principalContextKey, p)
}

// PrincipalFromContext extracts principal from context
func PrincipalFromContext(ctx context.Context) (*Principal, bool) {
	p, ok := ctx.Value(principalContextKey).(*Principal)
	return p, ok && p != nil
}

// Authenticator validates authentication tokens
type Authenticator struct {
	sharedSecret string
}

// NewAuthenticator creates an authenticator with the given secret
func NewAuthenticator(sharedSecret string) *Authenticator {
	if sharedSecret == "" {
		sharedSecret = "dev_shared_secret_token_change_in_prod"
	}
	return &Authenticator{sharedSecret: sharedSecret}
}

// AuthenticateRequest extracts and verifies bearer token from HTTP request
func (a *Authenticator) AuthenticateRequest(r *http.Request) (*Principal, error) {
	authHeader := r.Header.Get("Authorization")
	var token string
	if authHeader != "" {
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) == 2 && strings.EqualFold(parts[0], "Bearer") {
			token = parts[1]
		} else {
			token = authHeader
		}
	}
	if token == "" {
		token = r.Header.Get("X-API-Key")
	}
	if token == "" {
		token = r.Header.Get("X-Shared-Token")
	}

	if token == "" {
		return nil, fmt.Errorf("missing authorization header or token")
	}

	return a.AuthenticateToken(token)
}

// AuthenticateToken validates a bearer token and returns the principal
func (a *Authenticator) AuthenticateToken(token string) (*Principal, error) {
	if token == "" {
		return nil, fmt.Errorf("missing token")
	}

	// 1. Check for shared secret token (internal services / admin operator)
	if token == a.sharedSecret {
		return &Principal{
			UserID:       "system_operator",
			Role:         "admin",
			AllowedSites: []string{"*"},
			ExpiresAt:    time.Now().Add(24 * time.Hour),
		}, nil
	}

	// 2. Check for site-scoped operational tokens
	if token == "site_bnf_operator_token" {
		return &Principal{
			UserID:       "operator_bnf",
			Role:         "operator",
			AllowedSites: []string{"site_bnf", "BNF"},
			ExpiresAt:    time.Now().Add(24 * time.Hour),
		}, nil
	}
	if token == "site_rnf_operator_token" {
		return &Principal{
			UserID:       "operator_rnf",
			Role:         "operator",
			AllowedSites: []string{"site_rnf", "RNF"},
			ExpiresAt:    time.Now().Add(24 * time.Hour),
		}, nil
	}

	// 3. Structured signed token: base64(payload).base64(signature)
	parts := strings.Split(token, ".")
	if len(parts) == 2 {
		payloadBytes, err := base64.RawURLEncoding.DecodeString(parts[0])
		if err != nil {
			return nil, fmt.Errorf("invalid token encoding")
		}

		sig, err := base64.RawURLEncoding.DecodeString(parts[1])
		if err != nil {
			return nil, fmt.Errorf("invalid token signature encoding")
		}

		// Verify HMAC
		mac := hmac.New(sha256.New, []byte(a.sharedSecret))
		mac.Write([]byte(parts[0]))
		expectedSig := mac.Sum(nil)
		if !hmac.Equal(sig, expectedSig) {
			return nil, fmt.Errorf("invalid token signature")
		}

		var p Principal
		if err := json.Unmarshal(payloadBytes, &p); err != nil {
			return nil, fmt.Errorf("invalid token payload")
		}

		if !p.ExpiresAt.IsZero() && time.Now().UTC().After(p.ExpiresAt) {
			return nil, fmt.Errorf("token expired")
		}

		return &p, nil
	}

	return nil, fmt.Errorf("unrecognized or invalid authorization token")
}

// GenerateSignedToken creates an HMAC signed token for tests and services
func (a *Authenticator) GenerateSignedToken(p *Principal) (string, error) {
	payloadBytes, err := json.Marshal(p)
	if err != nil {
		return "", err
	}
	payloadB64 := base64.RawURLEncoding.EncodeToString(payloadBytes)

	mac := hmac.New(sha256.New, []byte(a.sharedSecret))
	mac.Write([]byte(payloadB64))
	sig := mac.Sum(nil)
	sigB64 := base64.RawURLEncoding.EncodeToString(sig)

	return fmt.Sprintf("%s.%s", payloadB64, sigB64), nil
}
