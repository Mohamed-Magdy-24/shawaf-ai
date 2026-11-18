import os
import sys
import time
import signal
import logging
import argparse
from pathlib import Path

# Add worker package to path
_pkg_root = str(Path(__file__).resolve().parent.parent)
if _pkg_root not in sys.path:
    sys.path.insert(0, _pkg_root)

from worker.config import WorkerConfig, scrub_credentials
from worker.inference import ONNXDetector
from worker.grpc_client import EdgeIngestionClient
from worker.pipeline import AIWorkerSupervisor

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s'
)
logger = logging.getLogger("ai-worker")

def parse_polygon(poly_str: str):
    """Parses comma-separated polygon string: 'x1,y1;x2,y2;x3,y3;x4,y4'."""
    points = []
    for pair in poly_str.split(";"):
        pair = pair.strip()
        if not pair:
            continue
        parts = pair.split(",")
        if len(parts) == 2:
            points.append((float(parts[0].strip()), float(parts[1].strip())))
    return points

def main():
    parser = argparse.ArgumentParser(description="Industrial AI Surveillance Computer Vision Worker")
    parser.add_argument("--site-id", default=None, help="Site UUID or code (e.g. BNF)")
    parser.add_argument("--worker-id", default=None, help="Worker ID")
    parser.add_argument("--grpc-target", default=None, help="Edged gRPC target endpoint (host:port)")
    parser.add_argument("--model-path", default=None, help="Path to ONNX object detection model")
    parser.add_argument("--rtsp-url", default=None, help="RTSP sub-stream URL for single-camera mode")
    parser.add_argument("--camera-id", default="cam-01", help="Camera ID")
    parser.add_argument("--zone-id", default="zone-restricted-01", help="Zone ID")
    parser.add_argument("--polygon", default="100,100;300,100;300,300;100,300", help="Restricted polygon")

    args = parser.parse_args()

    cfg = WorkerConfig()
    if args.site_id:
        cfg.site_id = args.site_id
    if args.worker_id:
        cfg.worker_id = args.worker_id
    if args.grpc_target:
        cfg.edged_grpc_target = args.grpc_target
    if args.model_path:
        cfg.model_path = args.model_path

    # Fallback to local synthetic detector if model path not set or missing
    if not cfg.model_path or not os.path.exists(cfg.model_path):
        candidate_synth = str(Path(_pkg_root).parent / "data" / "models" / "synthetic_detector.onnx")
        if os.path.exists(candidate_synth):
            cfg.model_path = candidate_synth

    logger.info("==================================================")
    logger.info(" Starting Industrial AI Worker [%s]", cfg.worker_id)
    logger.info(" Site ID: %s | Target gRPC: %s", cfg.site_id, cfg.edged_grpc_target)
    logger.info(" Sampling: Intrusion=%.1f FPS | PPE=%.1f FPS", cfg.sample_rate_fps, cfg.ppe_sample_rate_fps)
    logger.info(" Model Path: %s", cfg.model_path)
    logger.info("==================================================")

    # Initialize ONNX detector (ADR-016: Zero PyTorch)
    detector = ONNXDetector(
        model_path=cfg.model_path,
        conf_threshold=cfg.confidence_threshold
    )

    # Initialize gRPC Client
    grpc_client = None
    try:
        grpc_client = EdgeIngestionClient(
            target=cfg.edged_grpc_target,
            shared_secret_token=cfg.shared_secret_token
        )
    except Exception as e:
        logger.warning("Could not pre-connect gRPC client to %s: %s", cfg.edged_grpc_target, e)

    supervisor = AIWorkerSupervisor(config=cfg, detector=detector, grpc_client=grpc_client)

    # Register camera pipeline if RTSP URL provided
    rtsp_url = args.rtsp_url or os.getenv("CAMERA_RTSP_URL")
    if rtsp_url:
        poly = parse_polygon(args.polygon)
        supervisor.add_camera_pipeline(
            camera_id=args.camera_id,
            rtsp_url=rtsp_url,
            zone_id=args.zone_id,
            polygon=poly
        )

    # Graceful shutdown handling
    def shutdown_signal(sig, frame):
        logger.info("Received termination signal (%s). Shutting down supervisor...", sig)
        supervisor.stop()
        sys.exit(0)

    signal.signal(signal.SIGINT, shutdown_signal)
    signal.signal(signal.SIGTERM, shutdown_signal)

    supervisor.start()

    try:
        while True:
            time.sleep(1.0)
    except KeyboardInterrupt:
        shutdown_signal(signal.SIGINT, None)

if __name__ == "__main__":
    main()
