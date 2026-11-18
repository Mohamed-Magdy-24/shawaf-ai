import os
import sys
import unittest
from pathlib import Path
from datetime import datetime, timezone

# Ensure worker package is in sys.path
_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.rules import (
    point_in_polygon,
    check_bbox_intrusion,
    generate_relative_snapshot_path,
    IntrusionRuleEvaluator
)
from worker.inference import Detection

class TestSafetyRules(unittest.TestCase):
    def setUp(self):
        # A square polygon from (100, 100) to (300, 300)
        self.polygon = [(100.0, 100.0), (300.0, 100.0), (300.0, 300.0), (100.0, 300.0)]

    def test_point_inside_polygon(self):
        self.assertTrue(point_in_polygon((200.0, 200.0), self.polygon))
        self.assertTrue(point_in_polygon((150.0, 150.0), self.polygon))

    def test_point_outside_polygon(self):
        self.assertFalse(point_in_polygon((50.0, 50.0), self.polygon))
        self.assertFalse(point_in_polygon((400.0, 200.0), self.polygon))
        self.assertFalse(point_in_polygon((200.0, 350.0), self.polygon))

    def test_bbox_footpoint_intrusion(self):
        # Bbox: x1=180, y1=150, x2=220, y2=250 -> footpoint=(200, 250) inside
        bbox_inside = (180.0, 150.0, 220.0, 250.0)
        self.assertTrue(check_bbox_intrusion(bbox_inside, self.polygon))

        # Bbox: x1=10, y1=10, x2=50, y2=80 -> footpoint=(30, 80) outside
        bbox_outside = (10.0, 10.0, 50.0, 80.0)
        self.assertFalse(check_bbox_intrusion(bbox_outside, self.polygon))

    def test_relative_snapshot_path_format(self):
        dt = datetime(2026, 11, 18, 14, 0, 0, tzinfo=timezone.utc)
        path = generate_relative_snapshot_path("BNF", "evt-uuid-1234", dt)
        self.assertEqual(path, "BNF/2026/11/18/evt-uuid-1234.jpg")

    def test_intrusion_rule_evaluator_and_cooldown(self):
        evaluator = IntrusionRuleEvaluator("BNF", "cam-01", "zone-01", self.polygon, cooldown_sec=5.0)

        det_inside = Detection(
            x1=180.0, y1=150.0, x2=220.0, y2=250.0,
            label="person", confidence=0.95, class_id=0
        )
        det_outside = Detection(
            x1=10.0, y1=10.0, x2=50.0, y2=80.0,
            label="person", confidence=0.90, class_id=0
        )

        # First evaluation at t=10.0: should trigger alert
        intruders = evaluator.evaluate([det_inside, det_outside], now_mono=10.0)
        self.assertEqual(len(intruders), 1)
        self.assertEqual(intruders[0].confidence, 0.95)

        # Second evaluation at t=12.0 (< cooldown 5.0s): should be debounced
        intruders_debounced = evaluator.evaluate([det_inside], now_mono=12.0)
        self.assertEqual(len(intruders_debounced), 0)

        # Third evaluation at t=16.0 (>= cooldown 5.0s): should trigger again
        intruders_next = evaluator.evaluate([det_inside], now_mono=16.0)
        self.assertEqual(len(intruders_next), 1)

if __name__ == '__main__':
    unittest.main()
