import sys
import uuid
import time
import logging
from pathlib import Path
from typing import List, Optional, Tuple

import grpc

# Ensure worker/pb is in python path
_pb_dir = str(Path(__file__).resolve().parent / "pb")
if _pb_dir not in sys.path:
    sys.path.insert(0, _pb_dir)

from surveillance.v1 import events_pb2, events_pb2_grpc
from worker.inference import Detection
from worker.ppe_detector import PPEViolation
from worker.decoder import CameraStreamHealthData

logger = logging.getLogger(__name__)

class EdgeIngestionClient:
    """
    gRPC Client for EdgeIngestionService per ADR-012.
    Dispatches lightweight event metadata and telemetry to Go edged daemon.
    Zero raw frames sent across gRPC boundary.
    """

    def __init__(self, target: str, shared_secret_token: str = ""):
        self.target = target
        self.shared_secret_token = shared_secret_token
        self.channel: Optional[grpc.Channel] = None
        self.stub: Optional[events_pb2_grpc.EdgeIngestionServiceStub] = None
        self._connect()

    def _connect(self):
        """Establishes gRPC insecure channel with keepalive options."""
        options = [
            ('grpc.max_receive_message_length', 16 * 1024 * 1024),
            ('grpc.max_send_message_length', 16 * 1024 * 1024),
            ('grpc.keepalive_time_ms', 10000),
            ('grpc.keepalive_timeout_ms', 5000),
            ('grpc.keepalive_permit_without_calls', True),
        ]
        self.channel = grpc.insecure_channel(self.target, options=options)
        self.stub = events_pb2_grpc.EdgeIngestionServiceStub(self.channel)
        logger.info("Connected gRPC EdgeIngestionClient to %s", self.target)

    def _get_metadata(self) -> List[Tuple[str, str]]:
        metadata = []
        if self.shared_secret_token:
            metadata.append(('authorization', f"Bearer {self.shared_secret_token}"))
            metadata.append(('x-shared-secret', self.shared_secret_token))
        return metadata

    def submit_event(self, request: events_pb2.SubmitEventRequest, timeout: float = 5.0) -> events_pb2.SubmitEventResponse:
        """Transmits an AI detection event to Go edged daemon."""
        if not self.stub:
            raise RuntimeError("gRPC client is not initialized.")
        try:
            response = self.stub.SubmitEvent(
                request,
                metadata=self._get_metadata(),
                timeout=timeout
            )
            return response
        except grpc.RpcError as e:
            logger.error("gRPC SubmitEvent RPC failed [%s]: %s", e.code(), e.details())
            raise

    def send_heartbeat(
        self,
        worker_id: str,
        site_id: str,
        streams: List[CameraStreamHealthData],
        timeout: float = 3.0
    ) -> bool:
        """Sends periodic heartbeat with camera stream health telemetry."""
        if not self.stub:
            return False

        camera_stream_msgs = []
        for s in streams:
            camera_stream_msgs.append(
                events_pb2.CameraStreamHealth(
                    camera_id=s.camera_id,
                    online=s.online,
                    fps_decoded=s.fps_decoded,
                    dropped_frames=s.dropped_frames,
                    last_frame_utc_ms=s.last_frame_utc_ms
                )
            )

        req = events_pb2.HeartbeatRequest(
            worker_id=worker_id,
            site_id=site_id,
            timestamp_utc_ms=int(time.time() * 1000),
            camera_streams=camera_stream_msgs
        )

        try:
            resp = self.stub.SendHeartbeat(
                req,
                metadata=self._get_metadata(),
                timeout=timeout
            )
            return resp.ok
        except grpc.RpcError as e:
            logger.warning("Heartbeat transmission failed [%s]: %s", e.code(), e.details())
            return False

    def close(self):
        if self.channel:
            self.channel.close()
            self.channel = None
            self.stub = None

def build_bounding_boxes(detections: List[Detection]) -> List[events_pb2.BoundingBox]:
    """Converts internal Detection list to protobuf BoundingBox list."""
    bboxes = []
    for d in detections:
        bboxes.append(
            events_pb2.BoundingBox(
                x1=float(d.x1),
                y1=float(d.y1),
                x2=float(d.x2),
                y2=float(d.y2),
                label=d.label,
                confidence=float(d.confidence),
                track_id=int(d.track_id)
            )
        )
    return bboxes

def create_intrusion_event_request(
    site_id: str,
    camera_id: str,
    zone_id: str,
    intruders: List[Detection],
    snapshot_rel_path: str,
    occurred_at_ms: Optional[int] = None,
    event_id: Optional[str] = None
) -> events_pb2.SubmitEventRequest:
    """Builds a validated SubmitEventRequest for restricted zone breach (FR-AI-001)."""
    now_ms = occurred_at_ms or int(time.time() * 1000)
    # Generate deterministic UUIDv5 idempotency key if not provided
    if not event_id:
        key_name = f"{site_id}:{camera_id}:{zone_id}:{now_ms}"
        event_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, key_name))

    max_conf = max((d.confidence for d in intruders), default=0.90)

    return events_pb2.SubmitEventRequest(
        schema_version="1.0.0",
        event_id=event_id,
        site_id=site_id,
        camera_id=camera_id,
        zone_id=zone_id,
        event_type="restricted_zone.entry.detected",
        severity="CRITICAL",
        occurred_at_utc_ms=now_ms,
        received_at_utc_ms=now_ms,
        model_id="yolox-s",
        model_version="1.0.0",
        rule_id="FR-AI-001",
        rule_version="1.0.0",
        confidence=float(max_conf),
        bboxes=build_bounding_boxes(intruders),
        snapshot_rel_path=snapshot_rel_path,
        subject_status="UNKNOWN_PERSON"
    )

def create_ppe_violation_event_request(
    site_id: str,
    camera_id: str,
    zone_id: str,
    violation: PPEViolation,
    snapshot_rel_path: str,
    occurred_at_ms: Optional[int] = None,
    event_id: Optional[str] = None
) -> events_pb2.SubmitEventRequest:
    """Builds a validated SubmitEventRequest for PPE violation (FR-AI-002)."""
    now_ms = occurred_at_ms or int(time.time() * 1000)
    if not event_id:
        key_name = f"{site_id}:{camera_id}:{zone_id}:{violation.violation_type}:{now_ms}"
        event_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, key_name))

    all_dets = [violation.person] + violation.associated_equipment

    return events_pb2.SubmitEventRequest(
        schema_version="1.0.0",
        event_id=event_id,
        site_id=site_id,
        camera_id=camera_id,
        zone_id=zone_id,
        event_type=f"safety.{violation.violation_type}",
        severity="WARNING",
        occurred_at_utc_ms=now_ms,
        received_at_utc_ms=now_ms,
        model_id="yolox-ppe",
        model_version="1.0.0",
        rule_id="FR-AI-002",
        rule_version="1.0.0",
        confidence=float(violation.person.confidence),
        bboxes=build_bounding_boxes(all_dets),
        snapshot_rel_path=snapshot_rel_path,
        subject_status="UNKNOWN_PERSON"
    )
