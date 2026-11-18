package application

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"sync"
	"time"
)

var (
	ErrInvalidTicket       = errors.New("invalid or expired websocket ticket")
	ErrTicketSiteMismatch  = errors.New("ticket was issued for a different site")
	ErrTicketTTLTooLong    = errors.New("ticket TTL exceeds maximum permissible duration")
)

type ticketEntry struct {
	SiteID    string
	UserID    string
	ExpiresAt time.Time
}

// TicketService provides cryptographically random single-use ticket auth for WebSockets
// Eliminates token query-string leakage in proxy logs and browser history (VULN-08)
type TicketService struct {
	mu      sync.Mutex
	tickets map[string]ticketEntry
}

// NewTicketService initializes the ticket service
func NewTicketService() *TicketService {
	ts := &TicketService{
		tickets: make(map[string]ticketEntry),
	}

	// Background routine for sweeping expired tickets
	go func() {
		ticker := time.NewTicker(30 * time.Second)
		for range ticker.C {
			ts.purgeExpired()
		}
	}()

	return ts
}

// IssueTicket generates a random 128-bit single-use ticket with 15s default TTL
func (s *TicketService) IssueTicket(siteID, userID string, ttl time.Duration) (string, error) {
	if ttl <= 0 {
		ttl = 15 * time.Second
	}
	if ttl > 60*time.Second {
		return "", ErrTicketTTLTooLong
	}

	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	ticket := hex.EncodeToString(b)

	s.mu.Lock()
	defer s.mu.Unlock()

	s.tickets[ticket] = ticketEntry{
		SiteID:    siteID,
		UserID:    userID,
		ExpiresAt: time.Now().UTC().Add(ttl),
	}

	return ticket, nil
}

// ConsumeTicket validates and immediately invalidates the ticket upon handshake
func (s *TicketService) ConsumeTicket(ticket, expectedSiteID string) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	entry, exists := s.tickets[ticket]
	if !exists {
		return "", ErrInvalidTicket
	}

	// Always delete ticket immediately on access (single-use guarantee)
	delete(s.tickets, ticket)

	if time.Now().UTC().After(entry.ExpiresAt) {
		return "", ErrInvalidTicket
	}

	if expectedSiteID != "" && entry.SiteID != expectedSiteID {
		return "", ErrTicketSiteMismatch
	}

	return entry.UserID, nil
}

func (s *TicketService) purgeExpired() {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now().UTC()
	for ticket, entry := range s.tickets {
		if now.After(entry.ExpiresAt) {
			delete(s.tickets, ticket)
		}
	}
}
