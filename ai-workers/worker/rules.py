import os
import uuid
import time
from datetime import datetime, timezone
from typing import List, Tuple, Optional, Dict
import numpy as np

from worker.inference import Detection

def point_in_polygon(point: Tuple[float, float], polygon: List[Tuple[float, float]]) -> bool:
    """Ray casting algorithm to determine if a 2D point is strictly inside a polygon."""
    x, y = point
    n = len(polygon)
    if n < 3:
        return False
    inside = False

    p1x, p1y = polygon[0]
    for i in range(n + 1):
        p2x, p2y = polygon[i % n]
        if y > min(p1y, p2y):
            if y <= max(p1y, p2y):
                if x <= max(p1x, p2x):
                    if p1y != p2y:
                        xinters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                    if p1x == p2x or x <= xinters:
                        inside = not inside
        p1x, p1y = p2x, p2y

    return inside

def check_bbox_intrusion(bbox: Tuple[float, float, float, float], polygon: List[Tuple[float, float]]) -> bool:
    """
    Evaluates if the bottom-center (footpoint) of an object bounding box enters restricted zone polygon.
    bbox: (x1, y1, x2, y2)
    """
    x1, y1, x2, y2 = bbox
    footpoint = ((x1 + x2) / 2.0, y2)
    return point_in_polygon(footpoint, polygon)

def generate_relative_snapshot_path(site_id: str, event_id: str, dt: Optional[datetime] = None) -> str:
    """Generates snapshot relative path strictly matching '<site_id>/<yyyy>/<mm>/<dd>/<event_id>.jpg'."""
    if dt is None:
        dt = datetime.now(timezone.utc)
    return f"{site_id}/{dt.year:04d}/{dt.month:02d}/{dt.day:02d}/{event_id}.jpg"

def save_evidence_snapshot(
    image_bgr: np.ndarray,
    base_dir: str,
    rel_path: str,
    detections: Optional[List[Detection]] = None,
    polygon: Optional[List[Tuple[float, float]]] = None
) -> str:
    """
    Annotates and saves evidence JPEG snapshot to disk under base_dir / rel_path.
    Returns the absolute path of saved image.
    """
    import cv2  # Lazy import to ensure portability across environments without opencv
    full_path = os.path.normpath(os.path.join(base_dir, rel_path))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)

    annotated = image_bgr.copy()

    # Draw restricted zone polygon in Red
    if polygon and len(polygon) >= 3:
        pts = np.array(polygon, np.int32).reshape((-1, 1, 2))
        cv2.polylines(annotated, [pts], isClosed=True, color=(0, 0, 255), thickness=2)

    # Draw bounding boxes
    if detections:
        for d in detections:
            x1, y1, x2, y2 = int(d.x1), int(d.y1), int(d.x2), int(d.y2)
            color = (0, 0, 255) if "person" in d.label.lower() else (0, 255, 0)
            cv2.rectangle(annotated, (x1, y1), (x2, y2), color, 2)
            label_text = f"{d.label} {d.confidence:.2f}"
            cv2.putText(annotated, label_text, (x1, max(15, y1 - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

            # Draw footpoint
            fx, fy = int((d.x1 + d.x2) / 2.0), int(d.y2)
            cv2.circle(annotated, (fx, fy), 4, (0, 0, 255), -1)

    # Encode and save JPEG
    cv2.imwrite(full_path, annotated, [int(cv2.IMWRITE_JPEG_QUALITY), 85])
    return full_path

class IntrusionRuleEvaluator:
    """
    Evaluator for Restricted Area Intrusion Rule (FR-AI-001).
    Evaluates detected persons against configured polygon zones with debouncing.
    """

    def __init__(self, site_id: str, camera_id: str, zone_id: str, polygon: List[Tuple[float, float]], cooldown_sec: float = 5.0):
        self.site_id = site_id
        self.camera_id = camera_id
        self.zone_id = zone_id
        self.polygon = polygon
        self.cooldown_sec = cooldown_sec
        self.last_alert_time: float = 0.0

    def evaluate(self, detections: List[Detection], now_mono: Optional[float] = None) -> List[Detection]:
        """
        Filters detections for persons breaching the restricted polygon.
        Returns list of intruding detections if outside cooldown window, else empty list.
        """
        if now_mono is None:
            now_mono = time.monotonic()

        intruders = []
        for d in detections:
            # Check person label or class
            if "person" in d.label.lower():
                if check_bbox_intrusion((d.x1, d.y1, d.x2, d.y2), self.polygon):
                    intruders.append(d)

        if not intruders:
            return []

        # Check cooldown debounce window
        if (now_mono - self.last_alert_time) >= self.cooldown_sec:
            self.last_alert_time = now_mono
            return intruders

        return []
