import sys
import unittest
from pathlib import Path

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.inference import Detection
from worker.ppe_detector import (
    PPEComplianceDetector,
    calculate_overlap_ratio
)

class TestPPEComplianceDetector(unittest.TestCase):
    def setUp(self):
        self.detector = PPEComplianceDetector(
            site_id="BNF",
            camera_id="cam-01",
            require_helmet=True,
            require_vest=True,
            cooldown_sec=5.0
        )

    def test_overlap_ratio(self):
        box1 = (10.0, 10.0, 20.0, 20.0)  # Area = 100
        box2 = (10.0, 10.0, 30.0, 30.0)  # Contains box1
        self.assertAlmostEqual(calculate_overlap_ratio(box1, box2), 1.0)

        box_disjoint = (50.0, 50.0, 60.0, 60.0)
        self.assertAlmostEqual(calculate_overlap_ratio(box1, box_disjoint), 0.0)

    def test_fully_compliant_worker(self):
        # Person at x1=100, y1=100, x2=200, y2=300 (height=200, width=100)
        person = Detection(100.0, 100.0, 200.0, 300.0, "person", 0.95, 0)
        # Helmet in head region (y: 100 to 170)
        helmet = Detection(120.0, 105.0, 180.0, 140.0, "hard_hat", 0.90, 1)
        # Vest in torso region (y: 130 to 250)
        vest = Detection(110.0, 140.0, 190.0, 240.0, "safety_vest", 0.88, 2)

        violations = self.detector.evaluate([person, helmet, vest], now_mono=10.0)
        self.assertEqual(len(violations), 0)

    def test_missing_helmet_violation(self):
        person = Detection(100.0, 100.0, 200.0, 300.0, "person", 0.95, 0)
        vest = Detection(110.0, 140.0, 190.0, 240.0, "safety_vest", 0.88, 2)

        violations = self.detector.evaluate([person, vest], now_mono=20.0)
        self.assertEqual(len(violations), 1)
        self.assertTrue(violations[0].missing_helmet)
        self.assertFalse(violations[0].missing_vest)
        self.assertEqual(violations[0].violation_type, "ppe.missing.helmet")

    def test_missing_vest_violation(self):
        person = Detection(100.0, 100.0, 200.0, 300.0, "person", 0.95, 0)
        helmet = Detection(120.0, 105.0, 180.0, 140.0, "hard_hat", 0.90, 1)

        violations = self.detector.evaluate([person, helmet], now_mono=30.0)
        self.assertEqual(len(violations), 1)
        self.assertFalse(violations[0].missing_helmet)
        self.assertTrue(violations[0].missing_vest)
        self.assertEqual(violations[0].violation_type, "ppe.missing.vest")

    def test_missing_both_violation(self):
        person = Detection(100.0, 100.0, 200.0, 300.0, "person", 0.95, 0)

        violations = self.detector.evaluate([person], now_mono=40.0)
        self.assertEqual(len(violations), 1)
        self.assertTrue(violations[0].missing_helmet)
        self.assertTrue(violations[0].missing_vest)
        self.assertEqual(violations[0].violation_type, "ppe.missing.both")

    def test_cooldown_debounce(self):
        person = Detection(100.0, 100.0, 200.0, 300.0, "person", 0.95, 0)
        v1 = self.detector.evaluate([person], now_mono=50.0)
        self.assertEqual(len(v1), 1)

        # Within 5s cooldown
        v2 = self.detector.evaluate([person], now_mono=52.0)
        self.assertEqual(len(v2), 0)

        # After cooldown
        v3 = self.detector.evaluate([person], now_mono=56.0)
        self.assertEqual(len(v3), 1)

if __name__ == '__main__':
    unittest.main()
