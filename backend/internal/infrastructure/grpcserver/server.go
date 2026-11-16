package grpcserver

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// IngestionServer implements the edge ingestion gRPC server
type IngestionServer struct {
	ingestionSvc *application.IngestionService
	grpcServer   *grpc.Server
	listenAddr   string
}

// NewIngestionServer creates a new gRPC ingestion server
func NewIngestionServer(listenAddr string, ingestionSvc *application.IngestionService) *IngestionServer {
	if listenAddr == "" {
		listenAddr = ":50051"
	}
	return &IngestionServer{
		ingestionSvc: ingestionSvc,
		listenAddr:   listenAddr,
	}
}

// Raw gRPC request representation matching proto/surveillance/v1/events.proto
type WireSubmitEventRequest struct {
	SchemaVersion   string  `json:"schema_version"`
	EventID         string  `json:"event_id"`
	SiteID          string  `json:"site_id"`
	CameraID        string  `json:"camera_id"`
	ZoneID          string  `json:"zone_id"`
	EventType       string  `json:"event_type"`
	Severity        string  `json:"severity"`
	OccurredAtUtcMs int64   `json:"occurred_at_utc_ms"`
	ReceivedAtUtcMs int64   `json:"received_at_utc_ms"`
	ModelID         string  `json:"model_id"`
	ModelVersion    string  `json:"model_version"`
	RuleID          string  `json:"rule_id"`
	RuleVersion     string  `json:"rule_version"`
	Confidence      float32 `json:"confidence"`
	SnapshotRelPath string  `json:"snapshot_rel_path"`
	SubjectStatus   string  `json:"subject_status"`
}

type WireSubmitEventResponse struct {
	Accepted      bool   `json:"accepted"`
	Duplicate     bool   `json:"duplicate"`
	StatusMessage string `json:"status_message"`
}

type WireCameraStreamHealth struct {
	CameraID       string  `json:"camera_id"`
	Online         bool    `json:"online"`
	FPSDecoded     float64 `json:"fps_decoded"`
	DroppedFrames  uint64  `json:"dropped_frames"`
	LastFrameUtcMs int64   `json:"last_frame_utc_ms"`
}

type WireHeartbeatRequest struct {
	WorkerID       string                   `json:"worker_id"`
	SiteID         string                   `json:"site_id"`
	TimestampUtcMs int64                    `json:"timestamp_utc_ms"`
	CameraStreams  []WireCameraStreamHealth `json:"camera_streams"`
}

type WireHeartbeatResponse struct {
	OK bool `json:"ok"`
}

// ProcessSubmitEvent handles structured event ingestion from edge AI workers
func (s *IngestionServer) ProcessSubmitEvent(ctx context.Context, req *WireSubmitEventRequest) (*WireSubmitEventResponse, error) {
	if req.SiteID == "" || req.CameraID == "" {
		return nil, status.Error(codes.InvalidArgument, "site_id and camera_id required")
	}

	occurredAt := time.UnixMilli(req.OccurredAtUtcMs).UTC()
	if req.OccurredAtUtcMs == 0 {
		occurredAt = time.Now().UTC()
	}

	metaMap := map[string]interface{}{
		"model_id":          req.ModelID,
		"model_version":     req.ModelVersion,
		"rule_id":           req.RuleID,
		"rule_version":      req.RuleVersion,
		"snapshot_rel_path": req.SnapshotRelPath,
		"subject_status":    req.SubjectStatus,
	}
	metaBytes, _ := json.Marshal(metaMap)

	appReq := &application.SubmitEventRequest{
		SiteID:     req.SiteID,
		CameraID:   req.CameraID,
		ZoneID:     req.ZoneID,
		EventType:  req.EventType,
		Severity:   domain.Severity(req.Severity),
		Confidence: float64(req.Confidence),
		OccurredAt: occurredAt,
		Payload:    metaBytes,
	}

	_, err := s.ingestionSvc.SubmitEvent(ctx, appReq)
	if err != nil {
		log.Printf("[gRPC Server] Ingestion rejected: %v", err)
		return &WireSubmitEventResponse{
			Accepted:      false,
			Duplicate:     false,
			StatusMessage: err.Error(),
		}, nil
	}

	return &WireSubmitEventResponse{
		Accepted:      true,
		Duplicate:     false,
		StatusMessage: "Accepted",
	}, nil
}

// ProcessHeartbeat updates camera health records from worker stream monitoring
func (s *IngestionServer) ProcessHeartbeat(ctx context.Context, req *WireHeartbeatRequest) (*WireHeartbeatResponse, error) {
	for _, stream := range req.CameraStreams {
		_ = s.ingestionSvc.RecordHeartbeat(
			ctx,
			req.SiteID,
			stream.CameraID,
			stream.FPSDecoded,
			int64(stream.DroppedFrames),
			0.0,
		)
	}
	return &WireHeartbeatResponse{OK: true}, nil
}

// Start begins listening on the configured TCP address
func (s *IngestionServer) Start() error {
	lis, err := net.Listen("tcp", s.listenAddr)
	if err != nil {
		return fmt.Errorf("failed to listen on %s: %w", s.listenAddr, err)
	}

	s.grpcServer = grpc.NewServer()
	log.Printf("[gRPC Server] Listening on %s", s.listenAddr)

	go func() {
		if err := s.grpcServer.Serve(lis); err != nil && err != grpc.ErrServerStopped {
			log.Printf("[gRPC Server] Error: %v", err)
		}
	}()

	return nil
}

// Stop gracefully shuts down the gRPC server
func (s *IngestionServer) Stop() {
	if s.grpcServer != nil {
		s.grpcServer.GracefulStop()
	}
}
