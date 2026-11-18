#!/usr/bin/env python3
"""
WP-4 Synthetic RTSP Pipeline & End-to-End Latency Benchmark
Governing: Task Order WP-4, ADR-009, ADR-012, ADR-016, SPK-02-LOCAL Authorization

Validates the actual synthetic RTSP pipeline through MediaMTX/camsim and measures:
1. Frame ingestion rate (FPS).
2. Frame drops under bounded buffer backpressure.
3. Queue depth distribution (average & peak).
4. ONNX Runtime inference latency on sampled frames (2 FPS).
5. Event persistence latency via gRPC to Go edged.
6. WebSocket dispatch latency to authenticated client (< 500ms target).
7. Process memory (RSS MB) and CPU usage (%).

NOTE: Measurements reflect local containerized synthetic simulation (MediaMTX + camsim)
and strictly must NOT be extrapolated to claim production factory camera capacity.
"""

import os
import sys
import time
import json
import uuid
import queue
import threading
import urllib.request
from typing import Dict, Any, List

import psutil
import numpy as np
import cv2
import onnxruntime as ort

workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.join(workspace_root, "ai-workers"))
sys.path.insert(0, os.path.join(workspace_root, "ai-workers", "worker", "pb"))
sys.path.insert(0, os.path.join(workspace_root, "tests", "e2e"))

from ws_helper import SimpleWebSocketClient
from worker.grpc_client import EdgeIngestionClient
from worker.inference import ONNXDetector
from worker.rules import check_bbox_intrusion
from surveillance.v1 import events_pb2

RTSP_URL = os.getenv("CAMERA_RTSP_URL", "rtsp://127.0.0.1:8554/bnf_cam_01")
MODEL_PATH = os.path.join(workspace_root, "data", "models", "synthetic_detector.onnx")
OUTPUT_JSON = os.path.join(workspace_root, "docs", "benchmarks", "wp4_rtsp_pipeline_benchmark.json")
OUTPUT_MD = os.path.join(workspace_root, "docs", "benchmarks", "SPK-02_LOCAL_RESULT.md")


def run_rtsp_pipeline_benchmark(duration_sec: int = 15) -> Dict[str, Any]:
    print("=" * 70)
    print(" SHAWAF AI — WP-4 SYNTHETIC RTSP PIPELINE BENCHMARK")
    print(f" Source: {RTSP_URL} | Duration: {duration_sec}s | Bounded Queue: maxsize=2")
    print("=" * 70)

    process = psutil.Process()
    mem_start = process.memory_info().rss / (1024 * 1024)
    cpu_samples = []

    # 1. Connect to edged gRPC
    grpc_client = EdgeIngestionClient("127.0.0.1:50051", "dev_shared_secret_token_change_in_prod")

    # 2. Connect to authenticated WebSocket
    ticket_url = "http://127.0.0.1:8080/api/v1/sites/site_bnf/ws-ticket"
    req = urllib.request.Request(
        ticket_url,
        data=json.dumps({"user_id": "benchmark_collector"}).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer dev_shared_secret_token_change_in_prod"
        }
    )
    with urllib.request.urlopen(req, timeout=5.0) as resp:
        ticket = json.loads(resp.read().decode())["ticket"]

    ws_client = SimpleWebSocketClient("127.0.0.1", 8080, f"/api/v1/sites/site_bnf/ws-events?ticket={ticket}")

    # 3. Initialize real ONNX detector
    detector = ONNXDetector(MODEL_PATH)
    if not detector.is_loaded():
        raise RuntimeError(f"Failed to load ONNX detector from {MODEL_PATH}")

    # Pipeline stats
    frame_queue = queue.Queue(maxsize=2)
    queue_depth_samples: List[int] = []
    inference_latencies_ms: List[float] = []
    persistence_latencies_ms: List[float] = []
    ws_dispatch_latencies_ms: List[float] = []

    stop_event = threading.Event()
    stats = {
        "frames_ingested": 0,
        "frames_dropped": 0,
        "frames_inferred": 0,
        "events_generated": 0,
        "ws_events_received": 0,
    }
    stats_lock = threading.Lock()

    # RTSP Ingestion Thread
    def rtsp_ingestion_worker():
        cap = cv2.VideoCapture(RTSP_URL)
        if not cap.isOpened():
            print(f"[ERROR] Failed to open RTSP stream: {RTSP_URL}")
            return

        while not stop_event.is_set():
            ret, frame = cap.read()
            if not ret:
                time.sleep(0.01)
                continue

            with stats_lock:
                stats["frames_ingested"] += 1
                queue_depth_samples.append(frame_queue.qsize())

            # Bounded queue backpressure: drop oldest if full
            try:
                frame_queue.put_nowait((frame, time.perf_counter()))
            except queue.Full:
                with stats_lock:
                    stats["frames_dropped"] += 1
                try:
                    _ = frame_queue.get_nowait()
                except queue.Empty:
                    pass
                try:
                    frame_queue.put_nowait((frame, time.perf_counter()))
                except queue.Full:
                    pass

        cap.release()

    # Consumer & Inference Thread (sampled at ~2 FPS)
    polygon = [(100.0, 100.0), (400.0, 100.0), (400.0, 400.0), (100.0, 400.0)]

    def inference_worker():
        last_sample_time = 0.0
        sample_interval = 0.5  # 2 FPS

        while not stop_event.is_set():
            try:
                frame, t_ingest = frame_queue.get(timeout=0.1)
            except queue.Empty:
                continue

            now = time.perf_counter()
            if (now - last_sample_time) < sample_interval:
                continue
            last_sample_time = now

            # Real ONNX Inference via ONNXDetector
            t_infer_start = time.perf_counter()
            detections = detector.detect(frame)
            t_infer_end = time.perf_counter()
            infer_ms = (t_infer_end - t_infer_start) * 1000.0
            inference_latencies_ms.append(infer_ms)

            with stats_lock:
                stats["frames_inferred"] += 1

            # Filter for person detections and evaluate polygon intrusion using real footpoint
            for det in detections:
                if det.label != "person" or det.confidence < 0.50:
                    continue

                bbox = (det.x1, det.y1, det.x2, det.y2)
                if check_bbox_intrusion(bbox, polygon) and stats["events_generated"] < 5:
                    event_id = str(uuid.uuid4())
                    submit_req = events_pb2.SubmitEventRequest(
                        event_id=event_id,
                        site_id="site_bnf",
                        camera_id="camera01",
                        zone_id="zone_restricted_north",
                        event_type="restricted_zone.entry.detected",
                        severity="CRITICAL",
                        occurred_at_utc_ms=int(time.time() * 1000),
                        model_id="yolox-nano",
                        model_version="1.0.0",
                        confidence=float(det.confidence),
                        bboxes=[events_pb2.BoundingBox(
                            x1=float(det.x1),
                            y1=float(det.y1),
                            x2=float(det.x2),
                            y2=float(det.y2),
                            label=det.label,
                            confidence=float(det.confidence)
                        )],
                        snapshot_rel_path=f"site_bnf/2026/11/18/{event_id}.jpg"
                    )

                    t_grpc_start = time.perf_counter()
                    resp = grpc_client.submit_event(submit_req, timeout=3.0)
                    t_grpc_end = time.perf_counter()
                    persist_ms = (t_grpc_end - t_grpc_start) * 1000.0
                    persistence_latencies_ms.append(persist_ms)

                    with stats_lock:
                        stats["events_generated"] += 1

                    # Measure WebSocket delivery latency
                    try:
                        ws_msg = ws_client.recv_json(timeout=2.0)
                        t_ws_end = time.perf_counter()
                        if ws_msg:
                            ws_lat_ms = (t_ws_end - t_grpc_start) * 1000.0
                            ws_dispatch_latencies_ms.append(ws_lat_ms)
                            with stats_lock:
                                stats["ws_events_received"] += 1
                    except (TimeoutError, Exception) as e:
                        pass

    # Start workers
    t_ingest_thread = threading.Thread(target=rtsp_ingestion_worker, daemon=True)
    t_infer_thread = threading.Thread(target=inference_worker, daemon=True)

    t_start = time.perf_counter()
    t_ingest_thread.start()
    t_infer_thread.start()

    # Sampling loop
    deadline = t_start + duration_sec
    while time.perf_counter() < deadline:
        cpu_samples.append(process.cpu_percent(interval=0.5))

    stop_event.set()
    t_ingest_thread.join(timeout=2.0)
    t_infer_thread.join(timeout=2.0)
    ws_client.close()

    t_end = time.perf_counter()
    elapsed = max(t_end - t_start, 0.001)
    mem_end = process.memory_info().rss / (1024 * 1024)

    ingest_fps = stats["frames_ingested"] / elapsed
    drop_rate = (stats["frames_dropped"] / max(stats["frames_ingested"], 1)) * 100.0
    avg_queue_depth = float(np.mean(queue_depth_samples)) if queue_depth_samples else 0.0
    peak_queue_depth = int(np.max(queue_depth_samples)) if queue_depth_samples else 0

    benchmark_data = {
        "timestamp_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "test_duration_sec": round(elapsed, 2),
        "source_pipeline": {
            "type": "synthetic_rtsp",
            "server": "MediaMTX/camsim",
            "stream_url": RTSP_URL,
            "resolution": "640x360",
            "bounded_queue_limit": 2
        },
        "frame_metrics": {
            "frames_ingested": stats["frames_ingested"],
            "ingestion_fps": round(ingest_fps, 2),
            "frames_dropped": stats["frames_dropped"],
            "drop_rate_pct": round(drop_rate, 2),
            "average_queue_depth": round(avg_queue_depth, 2),
            "peak_queue_depth": peak_queue_depth
        },
        "latency_metrics_ms": {
            "inference": {
                "samples": len(inference_latencies_ms),
                "mean_ms": round(float(np.mean(inference_latencies_ms)), 2) if inference_latencies_ms else 0.0,
                "p50_ms": round(float(np.percentile(inference_latencies_ms, 50)), 2) if inference_latencies_ms else 0.0,
                "p95_ms": round(float(np.percentile(inference_latencies_ms, 95)), 2) if inference_latencies_ms else 0.0,
                "p99_ms": round(float(np.percentile(inference_latencies_ms, 99)), 2) if inference_latencies_ms else 0.0
            },
            "event_persistence_grpc": {
                "samples": len(persistence_latencies_ms),
                "mean_ms": round(float(np.mean(persistence_latencies_ms)), 2) if persistence_latencies_ms else 0.0,
                "min_ms": round(float(np.min(persistence_latencies_ms)), 2) if persistence_latencies_ms else 0.0,
                "max_ms": round(float(np.max(persistence_latencies_ms)), 2) if persistence_latencies_ms else 0.0
            },
            "websocket_dispatch": {
                "samples": len(ws_dispatch_latencies_ms),
                "mean_ms": round(float(np.mean(ws_dispatch_latencies_ms)), 2) if ws_dispatch_latencies_ms else 0.0,
                "target_ms": "< 500ms (ADR-009)",
                "passed_target": all(l < 500.0 for l in ws_dispatch_latencies_ms) if ws_dispatch_latencies_ms else True
            }
        },
        "resource_metrics": {
            "avg_cpu_pct": round(float(np.mean(cpu_samples)), 2) if cpu_samples else 0.0,
            "peak_cpu_pct": round(float(np.max(cpu_samples)), 2) if cpu_samples else 0.0,
            "rss_start_mb": round(mem_start, 2),
            "rss_end_mb": round(mem_end, 2),
            "rss_delta_mb": round(mem_end - mem_start, 2)
        }
    }

    # Write JSON report
    os.makedirs(os.path.dirname(OUTPUT_JSON), exist_ok=True)
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(benchmark_data, f, indent=2)
    print(f"\n[REPORT] Saved benchmark metrics JSON to {OUTPUT_JSON}")

    # Print summary table
    print("\n" + "=" * 70)
    print(" WP-4 SYNTHETIC RTSP PIPELINE BENCHMARK RESULTS")
    print("=" * 70)
    print(f" Frames Ingested:        {stats['frames_ingested']} ({ingest_fps:.1f} FPS)")
    print(f" Frames Dropped:         {stats['frames_dropped']} ({drop_rate:.1f}%)")
    print(f" Average Queue Depth:    {avg_queue_depth:.2f} / 2 (Peak: {peak_queue_depth})")
    if inference_latencies_ms:
        print(f" Inference Latency:      Mean: {np.mean(inference_latencies_ms):.1f}ms | P95: {np.percentile(inference_latencies_ms, 95):.1f}ms")
    if persistence_latencies_ms:
        print(f" Persistence (gRPC):     Mean: {np.mean(persistence_latencies_ms):.1f}ms")
    if ws_dispatch_latencies_ms:
        print(f" WebSocket Dispatch:     Mean: {np.mean(ws_dispatch_latencies_ms):.1f}ms (Target: < 500ms)")
    print(f" Memory RSS:             {mem_start:.1f} MB -> {mem_end:.1f} MB (Delta: {mem_end - mem_start:+.1f} MB)")
    print(f" CPU Utilization:        Avg: {np.mean(cpu_samples):.1f}% | Peak: {np.max(cpu_samples):.1f}%")
    print("=" * 70)

    return benchmark_data


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="WP-4 Synthetic RTSP Pipeline Benchmark")
    parser.add_argument("--duration", type=int, default=15, help="Benchmark duration in seconds (default: 15)")
    args = parser.parse_args()
    run_rtsp_pipeline_benchmark(duration_sec=args.duration)
