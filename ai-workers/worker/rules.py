"""
Shawaf AI — Spatial Rules Engine
Deterministic ray-casting point-in-polygon evaluation for industrial safety zones.
Complies with ADR-011 and ADR-012 edge rule specifications.
"""

from typing import List, Tuple, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class ZoneDefinition:
    id: str
    camera_id: str
    name: str
    zone_type: str  # INTRUSION, RESTRICTED_ACCESS, LOITERING
    severity: str   # SEV1, SEV2, SEV3
    polygon: List[Tuple[float, float]]  # [(x, y), ...] normalized 0.0 - 1.0


def point_in_polygon(point: Tuple[float, float], polygon: List[Tuple[float, float]]) -> bool:
    """
    Ray-casting algorithm (Jordan Curve Theorem).
    Returns True if point (x, y) is strictly or boundary-inside the polygon.
    """
    x, y = point
    n = len(polygon)
    if n < 3:
        return False

    inside = False
    p1x, p1y = polygon[0]
    for i in range(1, n + 1):
        p2x, p2y = polygon[i % n]
        if y > min(p1y, p2y):
            if y <= max(p1y, p2y):
                if x <= max(p1x, p2x):
                    if p1y != p2y:
                        x_inters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                    if p1x == p2x or x <= x_inters:
                        inside = not inside
        p1x, p1y = p2x, p2y

    return inside


def get_foot_point(bbox: Tuple[float, float, float, float]) -> Tuple[float, float]:
    """
    Computes bottom-center foot contact point from bounding box [x1, y1, x2, y2].
    This represents ground-plane position for industrial floor-marked safety zones.
    """
    x1, y1, x2, y2 = bbox
    cx = (x1 + x2) / 2.0
    cy = y2
    return (cx, cy)


class RuleEvaluator:
    """
    Evaluates tracking bounding boxes against active safety zones.
    """

    def __init__(self, zones: List[ZoneDefinition]):
        self.zones = zones

    def evaluate(
        self,
        track_id: int,
        bbox: Tuple[float, float, float, float],
        camera_id: str,
        frame_width: int,
        frame_height: int,
    ) -> List[Dict[str, Any]]:
        """
        Evaluates a detected object against all safety zones for a camera.
        Returns list of rule violation events.
        """
        violations = []
        foot_x, foot_y = get_foot_point(bbox)

        # Normalize foot coordinates to [0.0, 1.0]
        norm_x = foot_x / float(frame_width)
        norm_y = foot_y / float(frame_height)
        norm_point = (norm_x, norm_y)

        for zone in self.zones:
            if zone.camera_id != camera_id:
                continue

            if point_in_polygon(norm_point, zone.polygon):
                violations.append({
                    "zone_id": zone.id,
                    "zone_name": zone.name,
                    "zone_type": zone.zone_type,
                    "severity": zone.severity,
                    "track_id": track_id,
                    "foot_point_norm": [norm_x, norm_y],
                    "bbox": list(bbox),
                })

        return violations
