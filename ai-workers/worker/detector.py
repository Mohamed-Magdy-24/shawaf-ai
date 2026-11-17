"""
Shawaf AI — Object Detection Strategy & Factory (OOP)
Defines Strategy interface BaseDetector, concrete OnnxDetector, and Factory DetectorFactory.
"""

from abc import ABC, abstractmethod
import time
from typing import List, Tuple
import cv2
import numpy as np
import onnxruntime as ort


class BaseDetector(ABC):
    """Strategy interface for deep learning detection models."""

    @abstractmethod
    def detect(self, frame: np.ndarray) -> Tuple[List[Tuple[float, float, float, float, float, int]], float]:
        """
        Runs object detection on frame.
        Returns:
            detections: List of [x1, y1, x2, y2, confidence, class_id] in original frame coordinates
            latency_ms: Inference time in milliseconds
        """
        pass


class OnnxDetector(BaseDetector):
    """Concrete Strategy: ONNX Runtime detection engine."""

    def __init__(self, model_path: str, conf_threshold: float = 0.45):
        self.model_path = model_path
        self.conf_threshold = conf_threshold

        opts = ort.SessionOptions()
        opts.intra_op_num_threads = 4
        opts.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

        # Prefer CPUExecutionProvider for local dev and deterministic benchmarks
        providers = ['CPUExecutionProvider']
        if 'CUDAExecutionProvider' in ort.get_available_providers():
            providers.insert(0, 'CUDAExecutionProvider')

        self.session = ort.InferenceSession(model_path, sess_options=opts, providers=providers)
        self.input_name = self.session.get_inputs()[0].name
        self.output_name = self.session.get_outputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape  # [1, 3, 416, 416]
        self.target_h = self.input_shape[2]
        self.target_w = self.input_shape[3]
        print(f"[Detector] Loaded {model_path} on {self.session.get_providers()[0]}")

    def detect(self, frame: np.ndarray) -> Tuple[List[Tuple[float, float, float, float, float, int]], float]:
        orig_h, orig_w = frame.shape[:2]

        # Preprocessing: BGR -> RGB, Resize, Normalize 0-1, HWC -> CHW, Add Batch
        img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        resized = cv2.resize(img_rgb, (self.target_w, self.target_h), interpolation=cv2.INTER_LINEAR)
        blob = resized.astype(np.float32) / 255.0
        blob = np.transpose(blob, (2, 0, 1))
        blob = np.expand_dims(blob, axis=0)

        t0 = time.perf_counter()
        outputs = self.session.run([self.output_name], {self.input_name: blob})
        t1 = time.perf_counter()
        latency_ms = (t1 - t0) * 1000.0

        raw_dets = outputs[0][0]  # Shape [10, 6]
        detections = []

        scale_x = orig_w / float(self.target_w)
        scale_y = orig_h / float(self.target_h)

        for det in raw_dets:
            x1, y1, x2, y2, score, class_id = det
            if score >= self.conf_threshold:
                orig_x1 = max(0.0, float(x1 * scale_x))
                orig_y1 = max(0.0, float(y1 * scale_y))
                orig_x2 = min(float(orig_w), float(x2 * scale_x))
                orig_y2 = min(float(orig_h), float(y2 * scale_y))
                detections.append((orig_x1, orig_y1, orig_x2, orig_y2, float(score), int(class_id)))

        return detections, latency_ms


class DetectorFactory:
    """Factory Pattern for creating object detection strategies."""

    @staticmethod
    def create(detector_type: str = "onnx", model_path: str = "", conf_threshold: float = 0.45) -> BaseDetector:
        if detector_type.lower() == "onnx":
            return OnnxDetector(model_path=model_path, conf_threshold=conf_threshold)
        raise ValueError(f"Unknown detector type: {detector_type}")
