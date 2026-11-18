package application

import (
	"context"
	"fmt"
	"time"
)

// OutboxService manages outbox message dispatch and lease expiration recovery
type OutboxService struct {
	outbox      OutboxRepository
	broadcaster OutboxBroadcaster
}

// NewOutboxService initializes the outbox application service
func NewOutboxService(outbox OutboxRepository, broadcaster OutboxBroadcaster) *OutboxService {
	return &OutboxService{
		outbox:      outbox,
		broadcaster: broadcaster,
	}
}

// DispatchPending polls and delivers pending outbox records
// Employs SKIP LOCKED to prevent duplicate concurrent worker processing
func (s *OutboxService) DispatchPending(ctx context.Context, batchSize int, lockDuration time.Duration) (int, error) {
	records, err := s.outbox.FetchAndLockPending(ctx, batchSize, lockDuration)
	if err != nil {
		return 0, fmt.Errorf("failed to fetch pending outbox records: %w", err)
	}

	dispatched := 0
	for _, rec := range records {
		if s.broadcaster != nil {
			if err := s.broadcaster.Broadcast(rec.SiteID, rec.Payload); err != nil {
				fmt.Printf("[WARN] Failed to broadcast outbox record %d: %v\n", rec.ID, err)
				// Even if broadcast fails to some clients, mark published or let retry handle it
			}
		}

		if err := s.outbox.MarkPublished(ctx, rec.ID); err != nil {
			fmt.Printf("[ERROR] Failed to mark outbox record %d as published: %v\n", rec.ID, err)
			continue
		}
		dispatched++
	}

	return dispatched, nil
}

// ReapExpiredLeases recovers orphaned PROCESSING records whose locks expired
// Ensures zero lost alerts if edged crashes or is SIGKILLed mid-flight
func (s *OutboxService) ReapExpiredLeases(ctx context.Context) (int64, error) {
	reapedCount, err := s.outbox.ReapExpiredLeases(ctx)
	if err != nil {
		return 0, fmt.Errorf("failed to reap expired outbox leases: %w", err)
	}
	if reapedCount > 0 {
		fmt.Printf("[INFO] Lease reaper recovered %d orphaned outbox records back to PENDING\n", reapedCount)
	}
	return reapedCount, nil
}
