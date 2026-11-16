"""
Shawaf AI — Worker Configuration Module
Loads environment variables with fallback defaults for local development and Docker orchestration.
"""

import os
from dataclasses import dataclass, field
from typing import List


@dataclass
class WorkerConfig:
    site_id: str = os.getenv("SITE_ID", "11111111-1111-1111-1111-111111111111")
    worker_id: str = os.getenv("WORKER_ID", "worker-bnf-ai-01")
    edge_grpc_url: str = os.getenv("EDGED_GRPC_ADDR", os.getenv("EDGE_GRPC_URL", "localhost:50051"))
    edge_http_url: str = os.getenv("EDGED_HTTP_ADDR", os.getenv("EDGE_HTTP_URL", "http://localhost:8080"))
    shared_token: str = os.getenv("EDGED_WORKER_SHARED_TOKEN", "local_dev_worker_grpc_shared_secret_token_03")
    camera_id: str = os.getenv("CAMERA_ID", "bnf_cam_01")
    rtsp_base: str = os.getenv("MEDIAMTX_RTSP_BASE", "rtsp://mediamtx:8554")
    model_path: str = os.getenv("ONNX_MODEL_PATH", os.getenv("MODEL_PATH", "data/models/cleanroom_yolox_nano_fp32.onnx"))
    confidence_threshold: float = float(os.getenv("CONFIDENCE_THRESHOLD", "0.45"))
    iou_threshold: float = float(os.getenv("IOU_THRESHOLD", "0.50"))
    heartbeat_interval_sec: float = float(os.getenv("HEARTBEAT_INTERVAL_SEC", "3.0"))
    decode_queue_maxlen: int = int(os.getenv("DECODE_QUEUE_MAXLEN", "2"))
    camera_sources: List[str] = field(default_factory=lambda: [
        os.getenv("CAMERA_SOURCE", f"{os.getenv('MEDIAMTX_RTSP_BASE', 'rtsp://mediamtx:8554')}/{os.getenv('CAMERA_ID', 'bnf_cam_01')}")
    ])


def load_config() -> WorkerConfig:
    return WorkerConfig()
