import time
import logging
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass

from worker.inference import Detection

logger = logging.getLogger(__name__)

@dataclass
class PPEViolation:
    person: Detection
    missing_helmet: bool
    missing_vest: bool
    associated_equipment: List[Detection]

    @property
    def violation_type(self) -> str:
        if self.missing_helmet and self.missing_vest:
            return "ppe.missing.both"
        elif self.missing_helmet:
            return "ppe.missing.helmet"
        elif self.missing_vest:
            return "ppe.missing.vest"
        return "ppe.compliant"

def calculate_overlap_ratio(inner_box: Tuple[float, float, float, float], outer_box: Tuple[float, float, float, float]) -> float:
    """Calculates intersection area over inner box area."""
    ix1, iy1, ix2, iy2 = inner_box
    ox1, oy1, ox2, oy2 = outer_box

    inter_x1 = max(ix1, ox1)
    inter_y1 = max(iy1, oy1)
    inter_x2 = min(ix2, ox2)
    inter_y2 = min(iy2, oy2)

    inter_w = max(0.0, inter_x2 - inter_x1)
    inter_h = max(0.0, inter_y2 - inter_y1)
    inter_area = inter_w * inter_h

    inner_area = max(1.0, (ix2 - ix1) * (iy2 - iy1))
    return inter_area / inner_area

class PPEComplianceDetector:
    """
    PPE Safety Compliance Detector (FR-AI-002).
    Evaluates helmet and safety vest compliance for detected workers.
    Generates violation events if required PPE is missing.
    """

    def __init__(
        self,
        site_id: str,
        camera_id: str,
        require_helmet: bool = True,
        require_vest: bool = True,
        cooldown_sec: float = 5.0
    ):
        self.site_id = site_id
        self.camera_id = camera_id
        self.require_helmet = require_helmet
        self.require_vest = require_vest
        self.cooldown_sec = cooldown_sec
        self.last_alert_time: float = 0.0

    def evaluate(self, detections: List[Detection], now_mono: Optional[float] = None) -> List[PPEViolation]:
        """
        Analyzes detections in a frame to associate persons with PPE equipment.
        Returns list of PPEViolation records for non-compliant persons.
        """
        if now_mono is None:
            now_mono = time.monotonic()

        persons: List[Detection] = []
        helmets: List[Detection] = []
        vests: List[Detection] = []
        no_helmets: List[Detection] = []
        no_vests: List[Detection] = []

        for d in detections:
            lbl = d.label.lower()
            if "person" in lbl:
                persons.append(d)
            elif "no_hard_hat" in lbl or "no_helmet" in lbl:
                no_helmets.append(d)
            elif "hard_hat" in lbl or "helmet" in lbl:
                helmets.append(d)
            elif "no_safety_vest" in lbl or "no_vest" in lbl:
                no_vests.append(d)
            elif "safety_vest" in lbl or "vest" in lbl:
                vests.append(d)

        violations: List[PPEViolation] = []

        for p in persons:
            p_box = (p.x1, p.y1, p.x2, p.y2)
            ph = p.height
            pw = p.width

            # Head region: top 35% of person bounding box
            head_box = (p.x1, p.y1, p.x2, p.y1 + ph * 0.35)
            # Torso region: 15% to 75% of person bounding box
            torso_box = (p.x1, p.y1 + ph * 0.15, p.x2, p.y1 + ph * 0.75)

            # Check explicit negative detections first
            explicit_no_helmet = any(
                calculate_overlap_ratio((nh.x1, nh.y1, nh.x2, nh.y2), head_box) > 0.3 for nh in no_helmets
            )
            explicit_no_vest = any(
                calculate_overlap_ratio((nv.x1, nv.y1, nv.x2, nv.y2), torso_box) > 0.3 for nv in no_vests
            )

            # Check positive equipment detections
            has_helmet = not explicit_no_helmet and any(
                calculate_overlap_ratio((h.x1, h.y1, h.x2, h.y2), head_box) > 0.3 for h in helmets
            )
            has_vest = not explicit_no_vest and any(
                calculate_overlap_ratio((v.x1, v.y1, v.x2, v.y2), torso_box) > 0.3 for v in vests
            )

            missing_helmet = self.require_helmet and (explicit_no_helmet or not has_helmet)
            missing_vest = self.require_vest and (explicit_no_vest or not has_vest)

            if missing_helmet or missing_vest:
                associated = [h for h in helmets if calculate_overlap_ratio((h.x1, h.y1, h.x2, h.y2), head_box) > 0.3]
                associated.extend([v for v in vests if calculate_overlap_ratio((v.x1, v.y1, v.x2, v.y2), torso_box) > 0.3])
                violations.append(PPEViolation(
                    person=p,
                    missing_helmet=missing_helmet,
                    missing_vest=missing_vest,
                    associated_equipment=associated
                ))

        if not violations:
            return []

        # Check cooldown debounce window
        if (now_mono - self.last_alert_time) >= self.cooldown_sec:
            self.last_alert_time = now_mono
            return violations

        return []
