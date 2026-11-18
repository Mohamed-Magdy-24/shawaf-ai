import os
import sys
import unittest
import tempfile
from pathlib import Path
import numpy as np

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.config import WorkerConfig
from worker.inference import ONNXDetector
from worker.pipeline import CameraPipeline

class TestCameraPipeline(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.config = WorkerConfig()
        self.config.snapshot_base_dir = self.tmp_dir.name
        self.config.cooldown_sec = 0.0  # Disable cooldown for immediate evaluation in tests

        # Resolve synthetic detector model
        test_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.abspath(os.path.join(test_dir, "..", "..", "data", "models", "synthetic_detector.onnx"))
        self.detector = ONNXDetector(model_path)

        # Polygon containing the synthetic detection footpoint (200, 120)
        self.polygon = [(100.0, 50.0), (300.0, 50.0), (300.0, 200.0), (100.0, 200.0)]

        self.pipeline = CameraPipeline(
            camera_id="cam-test-01",
            rtsp_url="rtsp://127.0.0.1:8554/live",
            zone_id="zone-restricted-01",
            restricted_polygon=self.polygon,
            config=self.config,
            detector=self.detector,
            grpc_client=None  # Offline test mode
        )

    def tearDown(self):
        self.tmp_dir.cleanup()

    def test_pipeline_frame_processing_generates_snapshot_and_events(self):
        dummy_frame = np.zeros((360, 640, 3), dtype=np.uint8)
        now_ms = 1731945000000

        event_ids = self.pipeline.process_frame(dummy_frame, timestamp_ms=now_ms, now_mono=1.0)
        self.assertGreaterEqual(len(event_ids), 1)

        # Check evidence snapshot was saved to disk
        site_dir = os.path.join(self.tmp_dir.name, self.config.site_id)
        self.assertTrue(os.path.exists(site_dir))

        # Walk tmp_dir and verify .jpg files exist
        saved_snapshots = []
        for root, _, files in os.walk(self.tmp_dir.name):
            for f in files:
                if f.endswith(".jpg"):
                    saved_snapshots.append(os.path.join(root, f))

        self.assertGreaterEqual(len(saved_snapshots), 1)
        for s in saved_snapshots:
            self.assertGreater(os.path.getsize(s), 0)

if __name__ == '__main__':
    unittest.main()
