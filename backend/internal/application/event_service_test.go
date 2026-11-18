package application

import (
	"context"
	"testing"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

type mockIncidentRepo struct {
	saved    map[string]*domain.SafetyIncident
	active   []*domain.SafetyIncident
	updateFn func(inc *domain.SafetyIncident) error
	outbox   *mockOutboxRepo
}

func (m *mockIncidentRepo) Save(ctx context.Context, incident *domain.SafetyIncident) error {
	if m.saved == nil {
		m.saved = make(map[string]*domain.SafetyIncident)
	}
	m.saved[incident.ID] = incident
	return nil
}

func (m *mockIncidentRepo) SaveWithOutbox(ctx context.Context, incident *domain.SafetyIncident, payload []byte, isFirePriority bool) (bool, error) {
	if m.saved == nil {
		m.saved = make(map[string]*domain.SafetyIncident)
	}
	if _, exists := m.saved[incident.ID]; exists {
		return false, nil // Duplicate detected
	}
	m.saved[incident.ID] = incident
	if m.outbox != nil {
		_ = m.outbox.Enqueue(ctx, incident.SiteID, incident.ID, payload, isFirePriority)
	}
	return true, nil
}

func (m *mockIncidentRepo) GetByID(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error) {
	if inc, ok := m.saved[id]; ok && inc.SiteID == siteID {
		return inc, nil
	}
	return nil, domain.ErrInvalidSiteID
}

func (m *mockIncidentRepo) ListActive(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error) {
	return m.active, nil
}

func (m *mockIncidentRepo) Update(ctx context.Context, incident *domain.SafetyIncident) error {
	if m.updateFn != nil {
		return m.updateFn(incident)
	}
	return nil
}

type mockOutboxRepo struct {
	enqueued []struct {
		siteID   string
		eventID  string
		payload  []byte
		isFire   bool
	}
}

func (m *mockOutboxRepo) Enqueue(ctx context.Context, siteID, eventID string, payload []byte, isFirePriority bool) error {
	m.enqueued = append(m.enqueued, struct {
		siteID  string
		eventID string
		payload []byte
		isFire  bool
	}{siteID, eventID, payload, isFirePriority})
	return nil
}

func (m *mockOutboxRepo) FetchAndLockPending(ctx context.Context, limit int, lockDuration time.Duration) ([]*domain.OutboxRecord, error) {
	return nil, nil
}

func (m *mockOutboxRepo) MarkPublished(ctx context.Context, id int64) error {
	return nil
}

func (m *mockOutboxRepo) ReapExpiredLeases(ctx context.Context) (int64, error) {
	return 0, nil
}

type mockCameraRepo struct{}

func (m *mockCameraRepo) GetByID(ctx context.Context, siteID, cameraID string) (*domain.Camera, error) {
	return &domain.Camera{ID: cameraID, SiteID: siteID, Name: "Test Cam", Status: domain.CameraStatusOnline}, nil
}

func (m *mockCameraRepo) List(ctx context.Context, siteID string) ([]*domain.Camera, error) {
	return nil, nil
}

func (m *mockCameraRepo) UpdateTelemetry(ctx context.Context, siteID, cameraID string, online bool, fps float64, dropped uint64, lastHeartbeat time.Time) error {
	return nil
}

func TestEventService_HandleIncomingDetection_OutboxRouting(t *testing.T) {
	ctx := context.Background()
	outboxRepo := &mockOutboxRepo{}
	incidentRepo := &mockIncidentRepo{outbox: outboxRepo}
	cameraRepo := &mockCameraRepo{}

	svc := NewEventService(incidentRepo, outboxRepo, cameraRepo)

	// 1. Ingest normal warning event
	now := time.Now().UTC()
	inc, isDup, err := svc.HandleIncomingDetection(
		ctx,
		"evt-100", "site_bnf", "camera_01", "zone_gate",
		"restricted_zone.entry.detected",
		domain.SeverityWarning,
		now,
		"yolox", "1.0",
		0.92,
		[]domain.BoundingBox{{X1: 0, Y1: 0, X2: 100, Y2: 100, Label: "PERSON", Confidence: 0.92}},
		"site_bnf/2026/11/18/evt-100.jpg",
	)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if isDup {
		t.Fatalf("expected isDup=false on fresh event")
	}

	if inc.ID != "evt-100" || inc.Status != domain.StatusNew {
		t.Fatalf("incident not created properly: %+v", inc)
	}

	if len(outboxRepo.enqueued) != 1 {
		t.Fatalf("expected 1 outbox message, got %d", len(outboxRepo.enqueued))
	}
	if outboxRepo.enqueued[0].isFire {
		t.Fatalf("expected isFire=false for warning event")
	}

	// 2. Ingest duplicate event -> MUST NOT enqueue a duplicate outbox message
	_, isDup2, err := svc.HandleIncomingDetection(
		ctx,
		"evt-100", "site_bnf", "camera_01", "zone_gate",
		"restricted_zone.entry.detected",
		domain.SeverityWarning,
		now,
		"yolox", "1.0",
		0.92,
		nil,
		"site_bnf/2026/11/18/evt-100.jpg",
	)
	if err != nil {
		t.Fatalf("unexpected error on duplicate event: %v", err)
	}
	if !isDup2 {
		t.Fatalf("expected isDup=true on duplicate event")
	}
	if len(outboxRepo.enqueued) != 1 {
		t.Fatalf("duplicate event must not enqueue duplicate outbox message! got %d", len(outboxRepo.enqueued))
	}

	// 3. Ingest CRITICAL_FIRE event -> MUST set isFirePriority = true for fast-path routing
	fireInc, isDup3, err := svc.HandleIncomingDetection(
		ctx,
		"evt-fire-1", "site_bnf", "camera_02", "zone_warehouse",
		"fire.smoke.detected",
		domain.SeverityCriticalFire,
		now,
		"fire-detector", "1.0",
		0.99,
		nil,
		"site_bnf/2026/11/18/evt-fire-1.jpg",
	)
	if err != nil {
		t.Fatalf("unexpected error on fire event: %v", err)
	}
	if isDup3 {
		t.Fatalf("expected isDup=false for fire event")
	}
	if err != nil {
		t.Fatalf("unexpected error on fire event: %v", err)
	}
	if fireInc.Severity != domain.SeverityCriticalFire {
		t.Fatalf("expected SeverityCriticalFire, got %s", fireInc.Severity)
	}

	if len(outboxRepo.enqueued) != 2 {
		t.Fatalf("expected 2 outbox messages, got %d", len(outboxRepo.enqueued))
	}
	if !outboxRepo.enqueued[1].isFire {
		t.Fatalf("expected isFire=true for critical fire alert")
	}
}
