import os
import logging
from dataclasses import dataclass
from typing import List, Tuple, Optional
import numpy as np
import cv2
import onnxruntime as ort

logger = logging.getLogger(__name__)

@dataclass
class Detection:
    x1: float
    y1: float
    x2: float
    y2: float
    label: str
    confidence: float
    class_id: int
    track_id: int = -1

    @property
    def footpoint(self) -> Tuple[float, float]:
        """Returns bottom-center coordinates of the bounding box."""
        return ((self.x1 + self.x2) / 2.0, self.y2)

    @property
    def center(self) -> Tuple[float, float]:
        """Returns center coordinates of the bounding box."""
        return ((self.x1 + self.x2) / 2.0, (self.y1 + self.y2) / 2.0)

    @property
    def width(self) -> float:
        return max(0.0, self.x2 - self.x1)

    @property
    def height(self) -> float:
        return max(0.0, self.y2 - self.y1)

    @property
    def area(self) -> float:
        return self.width * self.height


class ONNXDetector:
    """
    ONNX Runtime computer vision inference engine per ADR-016 (zero PyTorch).
    Executes standard ONNX object detection graphs with CPU baseline and optional CUDA acceleration.
    """

    def __init__(
        self,
        model_path: str,
        labels: Optional[List[str]] = None,
        conf_threshold: float = 0.50,
        iou_threshold: float = 0.45,
        input_size: Tuple[int, int] = (640, 640)
    ):
        self.model_path = model_path
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold
        self.input_width, self.input_height = input_size

        self.labels = labels or [
            "person", "hard_hat", "safety_vest", "no_hard_hat", "no_safety_vest", "machinery"
        ]

        self.session: Optional[ort.InferenceSession] = None
        self.input_name: Optional[str] = None
        self.output_names: List[str] = []
        self._init_session()

    def _init_session(self):
        """Initializes ONNX Runtime session with provider fallback (CUDA -> CPU)."""
        if not os.path.isfile(self.model_path):
            logger.warning("Model file not found at '%s'. Detector operating in offline synthetic mode.", self.model_path)
            return

        available_providers = ort.get_available_providers()
        # Prefer CUDA if present per ADR-016, otherwise CPU baseline
        providers = []
        if "CUDAExecutionProvider" in available_providers:
            providers.append("CUDAExecutionProvider")
        providers.append("CPUExecutionProvider")

        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

        try:
            self.session = ort.InferenceSession(self.model_path, sess_options=sess_options, providers=providers)
            active_provider = self.session.get_providers()[0]
            logger.info("ONNX Runtime session initialized for '%s' using provider: %s", self.model_path, active_provider)

            self.input_name = self.session.get_inputs()[0].name
            self.output_names = [out.name for out in self.session.get_outputs()]
        except Exception as e:
            logger.error("Failed to initialize ONNX session for %s: %s", self.model_path, e)
            raise

    def is_loaded(self) -> bool:
        return self.session is not None

    def preprocess(self, img_bgr: np.ndarray) -> Tuple[np.ndarray, float, Tuple[int, int]]:
        """
        Preprocesses image for ONNX detection:
        Letterbox padding to maintain aspect ratio, BGR->RGB, scale to [0, 1], NCHW float32.
        """
        orig_h, orig_w = img_bgr.shape[:2]
        r = min(self.input_width / orig_w, self.input_height / orig_h)
        new_w = int(round(orig_w * r))
        new_h = int(round(orig_h * r))
        pad_x = (self.input_width - new_w) // 2
        pad_y = (self.input_height - new_h) // 2

        if (orig_w, orig_h) != (new_w, new_h):
            resized = cv2.resize(img_bgr, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
        else:
            resized = img_bgr

        # Create padded canvas (grey 114)
        canvas = np.full((self.input_height, self.input_width, 3), 114, dtype=np.uint8)
        canvas[pad_y:pad_y + new_h, pad_x:pad_x + new_w] = resized

        # BGR to RGB, normalize, transpose to (1, 3, H, W)
        rgb = cv2.cvtColor(canvas, cv2.COLOR_BGR2RGB)
        tensor = rgb.astype(np.float32) / 255.0
        tensor = np.transpose(tensor, (2, 0, 1))
        tensor = np.expand_dims(tensor, axis=0)

        return tensor, r, (pad_x, pad_y)

    def postprocess(
        self,
        outputs: List[np.ndarray],
        ratio: float,
        pad: Tuple[int, int],
        orig_shape: Tuple[int, int]
    ) -> List[Detection]:
        """
        Parses raw model outputs, applies NMS, and scales bounding boxes back to original coordinates.
        Supports standard output formats:
        - (1, num_anchors, 4 + num_classes) or (1, 4 + num_classes, num_anchors)
        - (N, 6): [x1, y1, x2, y2, conf, class_id]
        """
        orig_h, orig_w = orig_shape
        pad_x, pad_y = pad
        detections: List[Detection] = []

        if not outputs:
            return detections

        out = outputs[0]
        if out.ndim == 3:
            # Check if classes are on axis 1 (e.g., shape (1, 84, 8400))
            if out.shape[1] < out.shape[2] and out.shape[1] <= (4 + len(self.labels)):
                out = np.transpose(out[0], (1, 0))  # Now (num_anchors, 4 + num_classes)
            else:
                out = out[0]

        boxes = []
        confidences = []
        class_ids = []

        for row in out:
            if len(row) < 5:
                continue

            # Case A: Format [x1, y1, x2, y2, conf, class_id]
            if len(row) == 6:
                x1, y1, x2, y2, conf, cls_id = row
                if conf < self.conf_threshold:
                    continue
                cls_id = int(cls_id)
            else:
                # Case B: Format [cx, cy, w, h, obj_conf, class_probs...] or [cx, cy, w, h, class_probs...]
                cx, cy, w, h = row[0:4]
                if len(row) > 4:
                    scores = row[4:]
                    # Check if there's separate obj_conf
                    if len(scores) > len(self.labels):
                        obj_conf = scores[0]
                        class_probs = scores[1:]
                        score_arr = obj_conf * class_probs
                    else:
                        score_arr = scores

                    cls_id = int(np.argmax(score_arr))
                    conf = float(score_arr[cls_id])
                else:
                    conf = 0.0
                    cls_id = 0

                if conf < self.conf_threshold:
                    continue

                x1 = cx - w / 2.0
                y1 = cy - h / 2.0
                x2 = cx + w / 2.0
                y2 = cy + h / 2.0

            # Unpad and scale back to original frame
            box_x1 = max(0.0, min(orig_w, (x1 - pad_x) / ratio))
            box_y1 = max(0.0, min(orig_h, (y1 - pad_y) / ratio))
            box_x2 = max(0.0, min(orig_w, (x2 - pad_x) / ratio))
            box_y2 = max(0.0, min(orig_h, (y2 - pad_y) / ratio))

            bw = box_x2 - box_x1
            bh = box_y2 - box_y1
            if bw <= 1 or bh <= 1:
                continue

            boxes.append([int(box_x1), int(box_y1), int(bw), int(bh)])
            confidences.append(float(conf))
            class_ids.append(cls_id)

        if not boxes:
            return detections

        indices = cv2.dnn.NMSBoxes(boxes, confidences, self.conf_threshold, self.iou_threshold)
        if len(indices) > 0:
            for i in indices.flatten():
                bx, by, bw, bh = boxes[i]
                cid = class_ids[i]
                label = self.labels[cid] if cid < len(self.labels) else f"class_{cid}"
                detections.append(Detection(
                    x1=float(bx),
                    y1=float(by),
                    x2=float(bx + bw),
                    y2=float(by + bh),
                    label=label,
                    confidence=confidences[i],
                    class_id=cid
                ))

        return detections

    def detect(self, img_bgr: np.ndarray) -> List[Detection]:
        """Runs full end-to-end detection pipeline on input BGR frame."""
        if not self.is_loaded():
            return []

        orig_shape = img_bgr.shape[:2]
        tensor, ratio, pad = self.preprocess(img_bgr)
        outputs = self.session.run(self.output_names, {self.input_name: tensor})
        return self.postprocess(outputs, ratio, pad, orig_shape)
