"""
Shawaf AI — Video Analytics Pipeline Pattern
Sequentially processes frames through:
Decoder -> BaseDetector (Strategy) -> Tracker -> IndustrialRuleEngine -> EdgeIngestionClient
"""

from typing import List, Dict, Any, Optional
import numpy as np

from .detector import BaseDetector
from .tracker import CentroidTracker
from .rules import IndustrialRuleEngine
from .grpc_client import EdgeIngestionClient


class VideoAnalyticsPipeline:
    """Pipeline pattern orchestrating detection, tracking, rule evaluation, and event dispatch."""

    def __init__(
        self,
        site_id: str,
        camera_id: str,
        detector: BaseDetector,
        tracker: CentroidTracker,
        rule_engine: IndustrialRuleEngine,
        client: EdgeIngestionClient,
    ):
        self.site_id = site_id
        self.camera_id = camera_id
        self.detector = detector
        self.tracker = tracker
        self.rule_engine = rule_engine
        self.client = client

    def process_frame(
        self,
        frame_idx: int,
        timestamp: float,
        frame: np.ndarray,
        zones_config: Optional[List[Dict[str, Any]]] = None,
    ) -> List[Dict[str, Any]]:
        """
        Executes a complete single-frame pipeline cycle.
        """
        # Stage 1: Detector Strategy
        detections, latency_ms = self.detector.detect(frame)

        # Stage 2: Tracker Stage
        tracked_objects = self.tracker.update(detections)

        # Stage 3: Rule Evaluation Stage
        events = self.rule_engine.evaluate(
            frame_idx=frame_idx,
            timestamp=timestamp,
            detections=detections,
            tracked_objects=tracked_objects,
            zones=zones_config,
        )

        # Stage 4: Event Dispatch Stage
        for event in events:
            event["site_id"] = self.site_id
            event["camera_id"] = self.camera_id
            event["inference_latency_ms"] = latency_ms
            self.client.submit_event(event)

        return events
