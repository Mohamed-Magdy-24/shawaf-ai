"""
Shawaf AI — Edge Ingestion Client (Genuine Protobuf gRPC + Resilient Fallback)
Transmits structured safety events and camera stream heartbeats to edged daemon.
Zero raw video crossing network boundary (ADR-012).
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error
from typing import Dict, Any, Optional

import grpc

# Ensure worker/pb is importable
pb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pb")
if pb_dir not in sys.path:
    sys.path.insert(0, pb_dir)

try:
    from surveillance.v1 import events_pb2, events_pb2_grpc
    HAS_GRPC_STUBS = True
except ImportError:
    HAS_GRPC_STUBS = False


class EdgeIngestionClient:
    def __init__(
        self,
        grpc_target: str = "localhost:50051",
        http_base_url: str = "http://localhost:8080",
        shared_token: str = "local_dev_worker_grpc_shared_secret_token_03",
        worker_id: str = "worker-bnf-ai-01"
    ):
        self.grpc_target = grpc_target
        self.http_base_url = http_base_url.rstrip("/")
        self.shared_token = shared_token
        self.worker_id = worker_id

        self.channel: Optional[grpc.Channel] = None
        self.stub: Optional[events_pb2_grpc.EdgeIngestionServiceStub] = None

        if HAS_GRPC_STUBS:
            try:
                self.channel = grpc.insecure_channel(self.grpc_target)
                self.stub = events_pb2_grpc.EdgeIngestionServiceStub(self.channel)
            except Exception as e:
                print(f"[gRPC Client] Channel init warning: {e}")

    def submit_event(self, event_data: Dict[str, Any]) -> bool:
        """
        Submits structured event via gRPC; falls back to HTTP REST gateway if gRPC unavailable.
        """
        # Try gRPC first if stubs available
        if self.stub:
            try:
                metadata = (("x-worker-token", self.shared_token),)
                occurred_ms = int(event_data.get("occurred_at_utc_ms", time.time() * 1000))

                req = events_pb2.SubmitEventRequest(
                    schema_version="1.0.0",
                    event_id=event_data.get("event_id", ""),
                    site_id=event_data.get("site_id", ""),
                    camera_id=event_data.get("camera_id", ""),
                    zone_id=event_data.get("zone_id", ""),
                    event_type=event_data.get("event_type", "INTRUSION"),
                    severity=event_data.get("severity", "CRITICAL"),
                    occurred_at_utc_ms=occurred_ms,
                    received_at_utc_ms=int(time.time() * 1000),
                    model_id=event_data.get("model_id", "cleanroom_yolox_nano_fp32"),
                    model_version=event_data.get("model_version", "v1.0"),
                    rule_id=event_data.get("rule_id", "spatial_polygon_v1"),
                    rule_version=event_data.get("rule_version", "v1.0"),
                    confidence=float(event_data.get("confidence", 0.95)),
                    snapshot_rel_path=event_data.get("snapshot_rel_path", ""),
                    subject_status=event_data.get("subject_status", "VIOLATION"),
                )
                # If stubs have employee_id/employee_name attributes, set them:
                if hasattr(req, "employee_id") and "employee_id" in event_data:
                    req.employee_id = event_data["employee_id"]
                if hasattr(req, "employee_name") and "employee_name" in event_data:
                    req.employee_name = event_data["employee_name"]

                resp = self.stub.SubmitEvent(req, metadata=metadata, timeout=3.0)
                if resp.accepted:
                    return True
            except Exception as e:
                # Fallback to HTTP
                pass

        # Fallback HTTP REST Gateway
        return self._submit_http(event_data)

    def send_heartbeat(self, site_id: str, camera_id: str, fps: float, drops: int, latency_ms: float) -> bool:
        """
        Sends stream health heartbeat via gRPC; falls back to HTTP.
        """
        if self.stub:
            try:
                metadata = (("x-worker-token", self.shared_token),)
                stream_health = events_pb2.CameraStreamHealth(
                    camera_id=camera_id,
                    online=True,
                    fps_decoded=float(fps),
                    dropped_frames=int(drops),
                    last_frame_utc_ms=int(time.time() * 1000),
                )
                req = events_pb2.HeartbeatRequest(
                    worker_id=self.worker_id,
                    site_id=site_id,
                    timestamp_utc_ms=int(time.time() * 1000),
                    camera_streams=[stream_health],
                )
                resp = self.stub.SendHeartbeat(req, metadata=metadata, timeout=2.0)
                if resp.ok:
                    return True
            except Exception:
                pass

        # Fallback HTTP
        return self._heartbeat_http(site_id, camera_id, fps, drops, latency_ms)

    def _submit_http(self, event_data: Dict[str, Any]) -> bool:
        url = f"{self.http_base_url}/api/v1/edge/events"
        payload = json.dumps(event_data).encode("utf-8")
        req = urllib.request.Request(
            url,
            data=payload,
            headers={"Content-Type": "application/json", "x-worker-token": self.shared_token},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=3.0) as resp:
                return resp.status in (200, 201)
        except Exception:
            return False

    def _heartbeat_http(self, site_id: str, camera_id: str, fps: float, drops: int, latency_ms: float) -> bool:
        url = f"{self.http_base_url}/api/v1/edge/heartbeat"
        payload = json.dumps({
            "site_id": site_id,
            "camera_id": camera_id,
            "fps": fps,
            "drops": drops,
            "latency_ms": latency_ms,
        }).encode("utf-8")
        req = urllib.request.Request(
            url,
            data=payload,
            headers={"Content-Type": "application/json", "x-worker-token": self.shared_token},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=2.0) as resp:
                return resp.status == 200
        except Exception:
            return False
