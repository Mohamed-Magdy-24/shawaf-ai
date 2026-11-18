import os
import time
import logging
import threading
from typing import List, Dict, Optional, Tuple

import numpy as np

from worker.config import WorkerConfig
from worker.decoder import RTSPStreamDecoder, CameraStreamHealthData
from worker.sampler import MultiRateFrameSampler
from worker.inference import ONNXDetector, Detection
from worker.rules import (
    IntrusionRuleEvaluator,
    generate_relative_snapshot_path,
    save_evidence_snapshot,
)
from worker.ppe_detector import PPEComplianceDetector, PPEViolation
from worker.grpc_client import (
    EdgeIngestionClient,
    create_intrusion_event_request,
    create_ppe_violation_event_request,
)

logger = logging.getLogger(__name__)

class CameraPipeline:
    """
    Individual camera inference pipeline.
    Combines direct video decoding, multi-rate frame sampling, ONNX inference,
    intrusion & PPE rule evaluation, snapshot persistence, and gRPC event emission.
    """

    def __init__(
        self,
        camera_id: str,
        rtsp_url: str,
        zone_id: str,
        restricted_polygon: List[Tuple[float, float]],
        config: WorkerConfig,
        detector: ONNXDetector,
        grpc_client: Optional[EdgeIngestionClient] = None,
        ppe_detector: Optional[PPEComplianceDetector] = None
    ):
        self.camera_id = camera_id
        self.rtsp_url = rtsp_url
        self.zone_id = zone_id
        self.restricted_polygon = restricted_polygon
        self.config = config
        self.detector = detector
        self.grpc_client = grpc_client

        # Decoders & Samplers
        self.decoder = RTSPStreamDecoder(
            camera_id=camera_id,
            rtsp_url=rtsp_url,
            ffmpeg_bin=config.ffmpeg_bin
        )
        self.sampler = MultiRateFrameSampler({
            "intrusion": config.sample_rate_fps,     # 2.0 FPS
            "ppe": config.ppe_sample_rate_fps,       # 0.5 FPS
        })

        # Rule Evaluators
        self.intrusion_evaluator = IntrusionRuleEvaluator(
            site_id=config.site_id,
            camera_id=camera_id,
            zone_id=zone_id,
            polygon=restricted_polygon,
            cooldown_sec=config.cooldown_sec
        )

        self.ppe_compliance = ppe_detector or PPEComplianceDetector(
            site_id=config.site_id,
            camera_id=camera_id,
            cooldown_sec=config.cooldown_sec
        )

        self._running = False
        self._thread: Optional[threading.Thread] = None

    def start(self):
        """Starts stream decoder and processing thread."""
        self._running = True
        self.decoder.start()
        self._thread = threading.Thread(target=self._run_loop, daemon=True, name=f"pipe-{self.camera_id}")
        self._thread.start()
        logger.info("Camera pipeline started for [%s]", self.camera_id)

    def process_frame(self, frame: np.ndarray, timestamp_ms: int, now_mono: Optional[float] = None) -> List[str]:
        """
        Processes a single frame through multi-rate samplers and safety rules.
        Returns list of generated event IDs (useful for testing and monitoring).
        """
        if now_mono is None:
            now_mono = time.monotonic()

        generated_events: List[str] = []
        cached_detections: Optional[List[Detection]] = None

        # 1. Intrusion Detection Rule (FR-AI-001 @ 2.0 FPS)
        if self.sampler.should_sample("intrusion", now_mono):
            if cached_detections is None:
                cached_detections = self.detector.detect(frame)

            intruders = self.intrusion_evaluator.evaluate(cached_detections, now_mono)
            if intruders:
                event_id = None
                rel_path = generate_relative_snapshot_path(self.config.site_id, "placeholder")
                # Temp event_id to generate final path
                temp_req = create_intrusion_event_request(
                    site_id=self.config.site_id,
                    camera_id=self.camera_id,
                    zone_id=self.zone_id,
                    intruders=intruders,
                    snapshot_rel_path="",
                    occurred_at_ms=timestamp_ms
                )
                event_id = temp_req.event_id
                rel_path = generate_relative_snapshot_path(self.config.site_id, event_id)

                # Persist evidence snapshot
                save_evidence_snapshot(
                    image_bgr=frame,
                    base_dir=self.config.snapshot_base_dir,
                    rel_path=rel_path,
                    detections=intruders,
                    polygon=self.restricted_polygon
                )

                req = create_intrusion_event_request(
                    site_id=self.config.site_id,
                    camera_id=self.camera_id,
                    zone_id=self.zone_id,
                    intruders=intruders,
                    snapshot_rel_path=rel_path,
                    occurred_at_ms=timestamp_ms,
                    event_id=event_id
                )

                if self.grpc_client:
                    try:
                        self.grpc_client.submit_event(req)
                        logger.info("Submitted intrusion alert [%s] for zone %s", event_id, self.zone_id)
                    except Exception as e:
                        logger.error("Failed to transmit intrusion event: %s", e)

                generated_events.append(event_id)

        # 2. PPE Compliance Rule (FR-AI-002 @ 0.5 FPS)
        if self.sampler.should_sample("ppe", now_mono):
            if cached_detections is None:
                cached_detections = self.detector.detect(frame)

            violations = self.ppe_compliance.evaluate(cached_detections, now_mono)
            for v in violations:
                temp_req = create_ppe_violation_event_request(
                    site_id=self.config.site_id,
                    camera_id=self.camera_id,
                    zone_id=self.zone_id,
                    violation=v,
                    snapshot_rel_path="",
                    occurred_at_ms=timestamp_ms
                )
                event_id = temp_req.event_id
                rel_path = generate_relative_snapshot_path(self.config.site_id, event_id)

                # Persist evidence snapshot
                all_dets = [v.person] + v.associated_equipment
                save_evidence_snapshot(
                    image_bgr=frame,
                    base_dir=self.config.snapshot_base_dir,
                    rel_path=rel_path,
                    detections=all_dets
                )

                req = create_ppe_violation_event_request(
                    site_id=self.config.site_id,
                    camera_id=self.camera_id,
                    zone_id=self.zone_id,
                    violation=v,
                    snapshot_rel_path=rel_path,
                    occurred_at_ms=timestamp_ms,
                    event_id=event_id
                )

                if self.grpc_client:
                    try:
                        self.grpc_client.submit_event(req)
                        logger.info("Submitted PPE alert [%s] type=%s", event_id, v.violation_type)
                    except Exception as e:
                        logger.error("Failed to transmit PPE event: %s", e)

                generated_events.append(event_id)

        return generated_events

    def _run_loop(self):
        while self._running:
            item = self.decoder.get_latest_frame(timeout=0.2)
            if item is None:
                continue

            frame, timestamp_ms = item
            try:
                self.process_frame(frame, timestamp_ms)
            except Exception as e:
                logger.error("Error processing frame for camera %s: %s", self.camera_id, e)

    def get_health(self) -> CameraStreamHealthData:
        return self.decoder.get_health()

    def stop(self):
        self._running = False
        self.decoder.stop()
        if self._thread and self._thread.is_alive():
            self._thread.join(timeout=2)
        logger.info("Camera pipeline stopped for [%s]", self.camera_id)


class AIWorkerSupervisor:
    """
    Supervises multiple CameraPipelines and dispatches periodic gRPC health heartbeats.
    """

    def __init__(self, config: WorkerConfig, detector: ONNXDetector, grpc_client: Optional[EdgeIngestionClient] = None):
        self.config = config
        self.detector = detector
        self.grpc_client = grpc_client
        self.pipelines: Dict[str, CameraPipeline] = {}
        self._running = False
        self._heartbeat_thread: Optional[threading.Thread] = None

    def add_camera_pipeline(
        self,
        camera_id: str,
        rtsp_url: str,
        zone_id: str,
        polygon: List[Tuple[float, float]]
    ) -> CameraPipeline:
        pipe = CameraPipeline(
            camera_id=camera_id,
            rtsp_url=rtsp_url,
            zone_id=zone_id,
            restricted_polygon=polygon,
            config=self.config,
            detector=self.detector,
            grpc_client=self.grpc_client
        )
        self.pipelines[camera_id] = pipe
        return pipe

    def start(self):
        self._running = True
        for pipe in self.pipelines.values():
            pipe.start()

        if self.grpc_client:
            self._heartbeat_thread = threading.Thread(target=self._heartbeat_loop, daemon=True, name="heartbeat-supervisor")
            self._heartbeat_thread.start()

        logger.info("AIWorkerSupervisor started with %d camera pipelines.", len(self.pipelines))

    def _heartbeat_loop(self):
        while self._running:
            health_list = [p.get_health() for p in self.pipelines.values()]
            if self.grpc_client:
                self.grpc_client.send_heartbeat(
                    worker_id=self.config.worker_id,
                    site_id=self.config.site_id,
                    streams=health_list
                )
            time.sleep(self.config.heartbeat_interval_sec)

    def stop(self):
        self._running = False
        for pipe in self.pipelines.values():
            pipe.stop()
        if self._heartbeat_thread and self._heartbeat_thread.is_alive():
            self._heartbeat_thread.join(timeout=2)
        if self.grpc_client:
            self.grpc_client.close()
        logger.info("AIWorkerSupervisor shutdown complete.")
