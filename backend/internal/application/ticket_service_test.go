package application

import (
	"testing"
	"time"
)

func TestTicketService_SingleUseAndSiteIsolation(t *testing.T) {
	svc := NewTicketService()

	// 1. Issue Ticket for site_bnf
	ticket, err := svc.IssueTicket("site_bnf", "op_john", 5*time.Second)
	if err != nil {
		t.Fatalf("failed to issue ticket: %v", err)
	}
	if len(ticket) != 32 { // 16 bytes hex-encoded = 32 chars
		t.Fatalf("expected 32 character hex ticket, got %d chars: %s", len(ticket), ticket)
	}

	// 2. Attempt redemption for wrong site (site_rnf)
	_, err = svc.ConsumeTicket(ticket, "site_rnf")
	if err != ErrTicketSiteMismatch {
		t.Fatalf("expected ErrTicketSiteMismatch, got %v", err)
	}

	// 3. Re-attempt: Since the ticket was consumed, it must now be deleted immediately (single-use guarantee)
	_, err = svc.ConsumeTicket(ticket, "site_bnf")
	if err != ErrInvalidTicket {
		t.Fatalf("expected ErrInvalidTicket on already consumed ticket, got %v", err)
	}

	// 4. Issue and successfully consume
	validTicket, _ := svc.IssueTicket("site_bnf", "op_sarah", 5*time.Second)
	userID, err := svc.ConsumeTicket(validTicket, "site_bnf")
	if err != nil {
		t.Fatalf("expected valid consumption, got %v", err)
	}
	if userID != "op_sarah" {
		t.Fatalf("expected op_sarah, got %s", userID)
	}

	// 5. Subsequent consumption must fail
	_, err = svc.ConsumeTicket(validTicket, "site_bnf")
	if err != ErrInvalidTicket {
		t.Fatalf("expected ErrInvalidTicket on second consume, got %v", err)
	}
}

func TestTicketService_Expiration(t *testing.T) {
	svc := NewTicketService()

	// Issue with sub-millisecond TTL
	ticket, err := svc.IssueTicket("site_bnf", "op_fast", 1*time.Millisecond)
	if err != nil {
		t.Fatalf("failed to issue ticket: %v", err)
	}

	time.Sleep(10 * time.Millisecond)

	_, err = svc.ConsumeTicket(ticket, "site_bnf")
	if err != ErrInvalidTicket {
		t.Fatalf("expected ErrInvalidTicket for expired ticket, got %v", err)
	}
}
