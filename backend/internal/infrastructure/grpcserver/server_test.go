package grpcserver

import (
	"context"
	"testing"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/grpcserver/pb"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type mockIncRepo struct {
	saved *domain.SafetyIncident
}

func (m *mockIncRepo) Save(ctx context.Context, inc *domain.SafetyIncident) error {
	m.saved = inc
	return nil
}
func (m *mockIncRepo) SaveWithOutbox(ctx context.Context, inc *domain.SafetyIncident, payload []byte, isFirePriority bool) (bool, error) {
	if m.saved != nil && m.saved.ID == inc.ID {
		return false, nil // duplicate
	}
	m.saved = inc
	return true, nil
}
func (m *mockIncRepo) GetByID(ctx context.Context, siteID, id string) (*domain.SafetyIncident, error) {
	return nil, nil
}
func (m *mockIncRepo) ListActive(ctx context.Context, siteID string) ([]*domain.SafetyIncident, error) {
	return nil, nil
}
func (m *mockIncRepo) Update(ctx context.Context, inc *domain.SafetyIncident) error {
	return nil
}

type mockOutbox struct{}

func (m *mockOutbox) Enqueue(ctx context.Context, siteID, eventID string, payload []byte, isFirePriority bool) error {
	return nil
}
func (m *mockOutbox) FetchAndLockPending(ctx context.Context, limit int, lockDuration time.Duration) ([]*domain.OutboxRecord, error) {
	return nil, nil
}
func (m *mockOutbox) MarkPublished(ctx context.Context, id int64) error {
	return nil
}
func (m *mockOutbox) ReapExpiredLeases(ctx context.Context) (int64, error) {
	return 0, nil
}

type mockCamRepo struct {
	updatedCamera string
	online        bool
}

func (m *mockCamRepo) GetByID(ctx context.Context, siteID, cameraID string) (*domain.Camera, error) {
	return nil, nil
}
func (m *mockCamRepo) List(ctx context.Context, siteID string) ([]*domain.Camera, error) {
	return nil, nil
}
func (m *mockCamRepo) UpdateTelemetry(ctx context.Context, siteID, cameraID string, online bool, fps float64, dropped uint64, lastHeartbeat time.Time) error {
	m.updatedCamera = cameraID
	m.online = online
	return nil
}

func TestServer_SubmitEvent_AuthAndZeroRawFrames(t *testing.T) {
	incRepo := &mockIncRepo{}
	outboxRepo := &mockOutbox{}
	camRepo := &mockCamRepo{}

	events := application.NewEventService(incRepo, outboxRepo, camRepo)
	cameras := application.NewCameraService(camRepo, events)
	server := NewServer(events, cameras, "secret_123")

	// 1. Missing Auth Metadata -> codes.Unauthenticated
	req := &pb.SubmitEventRequest{
		EventId:         "evt-1",
		SiteId:          "site_bnf",
		CameraId:        "cam-1",
		EventType:       "entry.detected",
		Severity:        "WARNING",
		SnapshotRelPath: "site_bnf/2026/11/18/evt-1.jpg",
	}
	_, err := server.SubmitEvent(context.Background(), req)
	if status.Code(err) != codes.Unauthenticated {
		t.Fatalf("expected Unauthenticated, got %v", err)
	}

	// 2. Wrong Auth Secret -> codes.PermissionDenied
	badCtx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer wrong_secret"))
	_, err = server.SubmitEvent(badCtx, req)
	if status.Code(err) != codes.PermissionDenied {
		t.Fatalf("expected PermissionDenied, got %v", err)
	}

	// 3. Valid Auth but Missing Snapshot Path (Anti-Failure Law 5 violation: zero raw frames)
	validCtx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer secret_123"))
	badPathReq := &pb.SubmitEventRequest{
		EventId:         "evt-1",
		SiteId:          "site_bnf",
		CameraId:        "cam-1",
		EventType:       "entry.detected",
		Severity:        "WARNING",
		SnapshotRelPath: "", // Empty path violates policy
	}
	_, err = server.SubmitEvent(validCtx, badPathReq)
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("expected InvalidArgument for empty snapshot path, got %v", err)
	}

	// 4. Fully Valid Ingestion Request
	resp, err := server.SubmitEvent(validCtx, req)
	if err != nil {
		t.Fatalf("expected success, got %v", err)
	}
	if !resp.Accepted {
		t.Fatalf("expected Accepted=true, got %+v", resp)
	}
	if incRepo.saved == nil || incRepo.saved.ID != "evt-1" {
		t.Fatalf("incident was not persisted to repository: %+v", incRepo.saved)
	}
}

func TestServer_SendHeartbeat(t *testing.T) {
	incRepo := &mockIncRepo{}
	outboxRepo := &mockOutbox{}
	camRepo := &mockCamRepo{}

	events := application.NewEventService(incRepo, outboxRepo, camRepo)
	cameras := application.NewCameraService(camRepo, events)
	server := NewServer(events, cameras, "secret_123")

	validCtx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer secret_123"))
	hbReq := &pb.HeartbeatRequest{
		WorkerId:       "worker-py-1",
		SiteId:         "site_bnf",
		TimestampUtcMs: time.Now().UnixMilli(),
		CameraStreams: []*pb.CameraStreamHealth{
			{
				CameraId:       "cam_gate",
				Online:         true,
				FpsDecoded:     15.0,
				DroppedFrames:  0,
				LastFrameUtcMs: time.Now().UnixMilli(),
			},
		},
	}

	resp, err := server.SendHeartbeat(validCtx, hbReq)
	if err != nil {
		t.Fatalf("heartbeat failed: %v", err)
	}
	if !resp.Ok {
		t.Fatalf("expected Ok=true, got %+v", resp)
	}
	if camRepo.updatedCamera != "cam_gate" || !camRepo.online {
		t.Fatalf("camera telemetry not updated: camera=%s online=%v", camRepo.updatedCamera, camRepo.online)
	}
}
