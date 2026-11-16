"""
Shawaf AI — Edge AI Worker Daemon
Pipeline: Stream Decoding -> ONNX Detection -> Object Tracking -> Spatial Safety Rules -> Event Ingestion
Zero raw video crossing network boundary.
"""

import sys
import time
import signal
import os
from typing import Dict, Tuple

from worker.config import load_config
from worker.decoder import StreamDecoder
from worker.detector import OnnxDetector
from worker.tracker import MultiObjectTracker
from worker.rules import ZoneDefinition, RuleEvaluator
from worker.grpc_client import EdgeIngestionClient


def main():
    config = load_config()
    print("=================================================================")
    print("   SHAWAF AI (شوف AI) — Computer Vision Safety Worker")
    print(f"   Worker ID: {config.worker_id} | Site ID: {config.site_id}")
    print("=================================================================")

    # Initialize Safety Zones (calibrated with seed database)
    zones = [
        ZoneDefinition(
            id="bnf_zone_restricted_01",
            camera_id="bnf_cam_01",
            name="Loading Dock Danger Perimeter",
            zone_type="RESTRICTED_AREA",
            severity="SEV1",
            polygon=[(0.40, 0.35), (0.85, 0.35), (0.85, 0.90), (0.40, 0.90)],
        ),
        ZoneDefinition(
            id="bnf_zone_crane_01",
            camera_id="bnf_cam_02",
            name="Overhead Crane Safety Boundary",
            zone_type="CRANE_TRAVEL",
            severity="SEV1",
            polygon=[(0.20, 0.20), (0.70, 0.20), (0.70, 0.75), (0.20, 0.75)],
        ),
    ]

    # Resolve paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    model_path = os.path.join(base_dir, config.model_path)
    if not os.path.exists(model_path):
        model_path = os.path.join(base_dir, "data", "models", "cleanroom_yolox_nano_fp32.onnx")

    video_src = config.camera_sources[0]
    if not os.path.isabs(video_src) and not video_src.startswith("rtsp://"):
        video_src = os.path.join(base_dir, video_src)

    detector = OnnxDetector(model_path, conf_threshold=config.confidence_threshold)
    tracker = MultiObjectTracker(iou_threshold=config.iou_threshold)
    evaluator = RuleEvaluator(zones)
    client = EdgeIngestionClient(
        grpc_target=config.edge_grpc_url,
        http_base_url=config.edge_http_url,
        shared_token=config.shared_token,
        worker_id=config.worker_id
    )

    camera_id = config.camera_id
    decoder = StreamDecoder(video_src, camera_id=camera_id, maxlen=config.decode_queue_maxlen)
    decoder.start()

    # Track alert debounce { (track_id, zone_id): last_alert_time }
    alert_debounce: Dict[Tuple[int, str], float] = {}
    last_heartbeat = time.time()
    running = True

    def sig_handler(sig, frame):
        nonlocal running
        print("\n[Worker] Stopping AI worker...")
        running = False

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    print(f"[Worker] Pipeline active. Processing stream from {video_src}...")

    try:
        while running:
            item = decoder.get_latest_frame()
            if item is None:
                time.sleep(0.01)
                continue

            frame, frame_time = item
            orig_h, orig_w = frame.shape[:2]

            # 1. Detection
            detections, lat_ms = detector.detect(frame)

            # 2. Tracking
            confirmed_tracks = tracker.update(detections)

            # 3. Spatial Rules Evaluation
            now = time.time()
            for track in confirmed_tracks:
                violations = evaluator.evaluate(track.track_id, track.bbox, camera_id, orig_w, orig_h)
                for v in violations:
                    key = (v["track_id"], v["zone_id"])
                    last_time = alert_debounce.get(key, 0.0)

                    # Debounce: alert once every 5 seconds per track per zone
                    if now - last_time >= 5.0:
                        alert_debounce[key] = now
                        print(f"[ALERT] Violation detected! Zone: {v['zone_name']} | Track: #{track.track_id} | Severity: {v['severity']}")

                        event_data = {
                            "site_id": config.site_id,
                            "camera_id": camera_id,
                            "zone_id": v["zone_id"],
                            "event_type": f"ZONE_{v['zone_type']}",
                            "severity": v["severity"],
                            "confidence": track.score,
                            "track_id": track.track_id,
                            "bbox": list(track.bbox),
                            "payload": {
                                "foot_point": v["foot_point_norm"],
                                "zone_name": v["zone_name"],
                                "inference_lat_ms": round(lat_ms, 2),
                            }
                        }
                        client.submit_event(event_data)

            # 4. Periodic Heartbeat (NFR-OBS-002 watchdog compliance)
            if now - last_heartbeat >= config.heartbeat_interval_sec:
                last_heartbeat = now
                ok = client.send_heartbeat(
                    site_id=config.site_id,
                    camera_id=camera_id,
                    fps=round(decoder.fps, 1),
                    drops=decoder.dropped_frames,
                    latency_ms=round(lat_ms, 2)
                )
                print(f"[Heartbeat] bnf_cam_01 heartbeat dispatched: ok={ok}")

    finally:
        decoder.stop()
        print("[Worker] AI worker terminated cleanly.")


if __name__ == "__main__":
    main()
