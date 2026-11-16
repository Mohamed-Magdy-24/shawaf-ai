"""
Shawaf AI — Deterministic Object Tracker
Implements lightweight ByteTrack/IoU association with temporal smoothing.
Prevents duplicate alert oscillations by maintaining persistent track IDs across frames.
"""

from typing import List, Tuple, Dict, Any, Optional
import numpy as np


def compute_iou(boxA: Tuple[float, float, float, float], boxB: Tuple[float, float, float, float]) -> float:
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])

    interArea = max(0.0, xB - xA) * max(0.0, yB - yA)
    boxAArea = max(0.0, boxA[2] - boxA[0]) * max(0.0, boxA[3] - boxA[1])
    boxBArea = max(0.0, boxB[2] - boxB[0]) * max(0.0, boxB[3] - boxB[1])

    denom = boxAArea + boxBArea - interArea
    if denom <= 0.0:
        return 0.0
    return interArea / denom


class Track:
    def __init__(self, track_id: int, bbox: Tuple[float, float, float, float], score: float, class_id: int):
        self.track_id = track_id
        self.bbox = bbox  # [x1, y1, x2, y2]
        self.score = score
        self.class_id = class_id
        self.hits = 1
        self.age = 1
        self.time_since_update = 0
        self.confirmed = False

    def predict(self):
        self.age += 1
        self.time_since_update += 1

    def update(self, bbox: Tuple[float, float, float, float], score: float):
        # Exponential smoothing on bounding box
        alpha = 0.7
        self.bbox = (
            alpha * bbox[0] + (1 - alpha) * self.bbox[0],
            alpha * bbox[1] + (1 - alpha) * self.bbox[1],
            alpha * bbox[2] + (1 - alpha) * self.bbox[2],
            alpha * bbox[3] + (1 - alpha) * self.bbox[3],
        )
        self.score = score
        self.hits += 1
        self.time_since_update = 0
        if self.hits >= 2:
            self.confirmed = True


class MultiObjectTracker:
    def __init__(self, iou_threshold: float = 0.3, max_age: int = 30):
        self.iou_threshold = iou_threshold
        self.max_age = max_age
        self.next_id = 1
        self.tracks: List[Track] = []

    def update(self, detections: List[Tuple[float, float, float, float, float, int]]) -> List[Track]:
        """
        detections: List of [x1, y1, x2, y2, score, class_id]
        Returns list of active confirmed tracks.
        """
        for t in self.tracks:
            t.predict()

        matched_tracks = set()
        matched_dets = set()

        if len(self.tracks) > 0 and len(detections) > 0:
            iou_matrix = np.zeros((len(self.tracks), len(detections)), dtype=np.float32)
            for i, t in enumerate(self.tracks):
                for j, d in enumerate(detections):
                    det_box = (d[0], d[1], d[2], d[3])
                    iou_matrix[i, j] = compute_iou(t.bbox, det_box)

            # Greedy matching in descending order of IoU
            indices = np.dstack(np.unravel_index(np.argsort(-iou_matrix.ravel()), iou_matrix.shape))[0]
            for i, j in indices:
                if i in matched_tracks or j in matched_dets:
                    continue
                if iou_matrix[i, j] >= self.iou_threshold:
                    matched_tracks.add(i)
                    matched_dets.add(j)
                    d = detections[j]
                    self.tracks[i].update((d[0], d[1], d[2], d[3]), d[4])

        # Create new tracks for unmatched detections
        for j, d in enumerate(detections):
            if j not in matched_dets:
                new_track = Track(
                    track_id=self.next_id,
                    bbox=(d[0], d[1], d[2], d[3]),
                    score=d[4],
                    class_id=int(d[5]),
                )
                self.next_id += 1
                self.tracks.append(new_track)

        # Drop tracks exceeding max_age
        self.tracks = [t for t in self.tracks if t.time_since_update <= self.max_age]

        # Return confirmed tracks
        return [t for t in self.tracks if t.confirmed and t.time_since_update == 0]
