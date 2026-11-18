import os
import sys
import unittest
from pathlib import Path
import numpy as np

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.inference import ONNXDetector, Detection

class TestONNXInference(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Resolve synthetic detector model
        test_dir = os.path.dirname(os.path.abspath(__file__))
        cls.model_path = os.path.abspath(os.path.join(test_dir, "..", "..", "data", "models", "synthetic_detector.onnx"))

    def test_detector_initialization(self):
        if not os.path.exists(self.model_path):
            self.skipTest(f"Synthetic model not found at {self.model_path}")

        detector = ONNXDetector(self.model_path)
        self.assertTrue(detector.is_loaded())
        self.assertIn("CPUExecutionProvider", detector.session.get_providers())

    def test_preprocessing_shape_and_range(self):
        detector = ONNXDetector(self.model_path)
        dummy_bgr = np.zeros((360, 640, 3), dtype=np.uint8)
        tensor, ratio, pad = detector.preprocess(dummy_bgr)

        self.assertEqual(tensor.shape, (1, 3, 640, 640))
        self.assertEqual(tensor.dtype, np.float32)
        self.assertGreaterEqual(tensor.min(), 0.0)
        self.assertLessEqual(tensor.max(), 1.0)
        self.assertAlmostEqual(ratio, 1.0, places=2)

    def test_end_to_end_synthetic_detection(self):
        if not os.path.exists(self.model_path):
            self.skipTest(f"Synthetic model not found at {self.model_path}")

        detector = ONNXDetector(self.model_path)
        dummy_bgr = np.zeros((360, 640, 3), dtype=np.uint8)
        detections = detector.detect(dummy_bgr)

        self.assertGreaterEqual(len(detections), 1)
        labels = [d.label for d in detections]
        self.assertIn("person", labels)

        person_det = next(d for d in detections if d.label == "person")
        self.assertGreater(person_det.confidence, 0.8)
        self.assertGreater(person_det.footpoint[1], 50.0)

if __name__ == '__main__':
    unittest.main()
