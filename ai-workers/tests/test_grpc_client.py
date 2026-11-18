import sys
import uuid
import unittest
from pathlib import Path

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.inference import Detection
from worker.ppe_detector import PPEViolation
from worker.grpc_client import (
    create_intrusion_event_request,
    create_ppe_violation_event_request,
    build_bounding_boxes
)

class TestGRPCClientEventBuilders(unittest.TestCase):
    def setUp(self):
        self.site_id = "BNF"
        self.camera_id = "cam-zone-01"
        self.zone_id = "zone-restricted-alpha"

    def test_build_bounding_boxes(self):
        dets = [
            Detection(10.0, 20.0, 30.0, 40.0, "person", 0.95, 0, track_id=42),
            Detection(15.0, 22.0, 25.0, 35.0, "hard_hat", 0.88, 1, track_id=43)
        ]
        bboxes = build_bounding_boxes(dets)
        self.assertEqual(len(bboxes), 2)
        self.assertEqual(bboxes[0].label, "person")
        self.assertAlmostEqual(bboxes[0].confidence, 0.95, places=2)
        self.assertEqual(bboxes[0].track_id, 42)

    def test_create_intrusion_event_request(self):
        intruders = [
            Detection(100.0, 100.0, 150.0, 200.0, "person", 0.92, 0)
        ]
        rel_path = "BNF/2026/11/18/evt-001.jpg"
        now_ms = 1731940000000

        req = create_intrusion_event_request(
            site_id=self.site_id,
            camera_id=self.camera_id,
            zone_id=self.zone_id,
            intruders=intruders,
            snapshot_rel_path=rel_path,
            occurred_at_ms=now_ms
        )

        self.assertEqual(req.schema_version, "1.0.0")
        self.assertEqual(req.site_id, self.site_id)
        self.assertEqual(req.camera_id, self.camera_id)
        self.assertEqual(req.zone_id, self.zone_id)
        self.assertEqual(req.event_type, "restricted_zone.entry.detected")
        self.assertEqual(req.severity, "CRITICAL")
        self.assertEqual(req.rule_id, "FR-AI-001")
        self.assertEqual(req.snapshot_rel_path, rel_path)
        self.assertEqual(req.subject_status, "UNKNOWN_PERSON")
        self.assertEqual(len(req.bboxes), 1)

        # Idempotency key must be valid UUIDv5 string
        parsed_uuid = uuid.UUID(req.event_id)
        self.assertEqual(parsed_uuid.version, 5)

    def test_create_ppe_violation_event_request(self):
        person = Detection(100.0, 100.0, 150.0, 250.0, "person", 0.91, 0)
        vest = Detection(105.0, 140.0, 145.0, 200.0, "safety_vest", 0.85, 2)
        violation = PPEViolation(
            person=person,
            missing_helmet=True,
            missing_vest=False,
            associated_equipment=[vest]
        )
        rel_path = "BNF/2026/11/18/evt-ppe-002.jpg"
        now_ms = 1731940005000

        req = create_ppe_violation_event_request(
            site_id=self.site_id,
            camera_id=self.camera_id,
            zone_id=self.zone_id,
            violation=violation,
            snapshot_rel_path=rel_path,
            occurred_at_ms=now_ms
        )

        self.assertEqual(req.schema_version, "1.0.0")
        self.assertEqual(req.event_type, "safety.ppe.missing.helmet")
        self.assertEqual(req.severity, "WARNING")
        self.assertEqual(req.rule_id, "FR-AI-002")
        self.assertEqual(len(req.bboxes), 2)  # Person + Vest

if __name__ == '__main__':
    unittest.main()
