package grpcserver

import (
	"context"
	"log"
	"strings"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/grpcserver/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// Server implements pb.EdgeIngestionServiceServer
type Server struct {
	pb.UnimplementedEdgeIngestionServiceServer
	eventService    *application.EventService
	cameraService   *application.CameraService
	sharedSecret    string
	onEventIngested func()
}

// NewServer initializes gRPC ingestion server
func NewServer(
	eventService *application.EventService,
	cameraService *application.CameraService,
	sharedSecret string,
	onEventIngested ...func(),
) *Server {
	var onIngest func()
	if len(onEventIngested) > 0 {
		onIngest = onEventIngested[0]
	}
	return &Server{
		eventService:    eventService,
		cameraService:   cameraService,
		sharedSecret:    sharedSecret,
		onEventIngested: onIngest,
	}
}

// SubmitEvent handles detection ingestion from Python AI worker
// Enforces: ZERO RAW FRAMES OVER gRPC (Anti-Failure Law 5) & Pre-shared HMAC/Bearer Auth
func (s *Server) SubmitEvent(ctx context.Context, req *pb.SubmitEventRequest) (*pb.SubmitEventResponse, error) {
	if err := s.verifyAuth(ctx); err != nil {
		return nil, err
	}

	// Validate Anti-Failure Law 5: Zero Raw Frames
	if req.GetSnapshotRelPath() == "" {
		return nil, status.Errorf(codes.InvalidArgument, "snapshot_rel_path is mandatory (zero raw frames policy)")
	}

	occurredAt := time.UnixMilli(req.GetOccurredAtUtcMs()).UTC()
	if req.GetOccurredAtUtcMs() == 0 {
		occurredAt = time.Now().UTC()
	}

	var bboxes []domain.BoundingBox
	for _, b := range req.GetBboxes() {
		if b != nil {
			bboxes = append(bboxes, domain.BoundingBox{
				X1:         b.GetX1(),
				Y1:         b.GetY1(),
				X2:         b.GetX2(),
				Y2:         b.GetY2(),
				Label:      b.GetLabel(),
				Confidence: b.GetConfidence(),
				TrackID:    b.GetTrackId(),
			})
		}
	}

	severity := domain.IncidentSeverity(req.GetSeverity())
	switch severity {
	case domain.SeverityInfo, domain.SeverityWarning, domain.SeverityCritical, domain.SeverityCriticalFire:
		// Valid
	default:
		severity = domain.SeverityWarning
	}

	_, isDuplicate, err := s.eventService.HandleIncomingDetection(
		ctx,
		req.GetEventId(),
		req.GetSiteId(),
		req.GetCameraId(),
		req.GetZoneId(),
		req.GetEventType(),
		severity,
		occurredAt,
		req.GetModelId(),
		req.GetModelVersion(),
		req.GetConfidence(),
		bboxes,
		req.GetSnapshotRelPath(),
	)
	if err != nil {
		log.Printf("[ERROR] Ingestion failed for event %s: %v", req.GetEventId(), err)
		return nil, status.Errorf(codes.Internal, "failed to persist incident: %v", err)
	}

	if isDuplicate {
		log.Printf("[WARN] Duplicate event %s ignored for site %s / camera %s",
			req.GetEventId(), req.GetSiteId(), req.GetCameraId())
		return &pb.SubmitEventResponse{
			Accepted:      true,
			Duplicate:     true,
			StatusMessage: "Duplicate event detected: already ingested and queued",
		}, nil
	}

	log.Printf("[INFO] Ingested safety event %s [%s] for site %s / camera %s",
		req.GetEventId(), req.GetSeverity(), req.GetSiteId(), req.GetCameraId())

	if s.onEventIngested != nil {
		s.onEventIngested()
	}

	return &pb.SubmitEventResponse{
		Accepted:      true,
		Duplicate:     false,
		StatusMessage: "Incident accepted and queued to transactional outbox",
	}, nil
}

// SendHeartbeat handles periodic stream telemetry from Python AI worker
func (s *Server) SendHeartbeat(ctx context.Context, req *pb.HeartbeatRequest) (*pb.HeartbeatResponse, error) {
	if err := s.verifyAuth(ctx); err != nil {
		return nil, err
	}

	var telemetry []application.StreamTelemetry
	for _, st := range req.GetCameraStreams() {
		if st != nil {
			telemetry = append(telemetry, application.StreamTelemetry{
				CameraID:       st.GetCameraId(),
				Online:         st.GetOnline(),
				FPSDecoded:     st.GetFpsDecoded(),
				DroppedFrames:  st.GetDroppedFrames(),
				LastFrameUTCMs: st.GetLastFrameUtcMs(),
			})
		}
	}

	if err := s.cameraService.RecordWorkerHeartbeat(ctx, req.GetWorkerId(), req.GetSiteId(), telemetry); err != nil {
		log.Printf("[WARN] Error processing worker heartbeat: %v", err)
	}

	return &pb.HeartbeatResponse{Ok: true}, nil
}

func (s *Server) verifyAuth(ctx context.Context) error {
	if s.sharedSecret == "" {
		return nil // No auth configured (local dev fallback)
	}

	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return status.Errorf(codes.Unauthenticated, "missing gRPC metadata")
	}

	authHeaders := md.Get("authorization")
	if len(authHeaders) == 0 {
		// Also accept x-api-key or shared-token
		tokens := md.Get("x-shared-token")
		if len(tokens) > 0 && tokens[0] == s.sharedSecret {
			return nil
		}
		return status.Errorf(codes.Unauthenticated, "missing authorization token")
	}

	token := strings.TrimPrefix(authHeaders[0], "Bearer ")
	if token != s.sharedSecret {
		return status.Errorf(codes.PermissionDenied, "invalid authentication secret")
	}

	return nil
}

// Register registers the ingestion server with the gRPC service registrar
func Register(s grpc.ServiceRegistrar, srv *Server) {
	pb.RegisterEdgeIngestionServiceServer(s, srv)
}
