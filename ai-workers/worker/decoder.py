"""
Shawaf AI — Resilient Video Decoder
Supports RTSP streams and synthetic MP4 sources.
Implements bounded frame queue (maxlen=2) to prevent latency buildup.
Counts dropped frames and measures decoding FPS.
"""

import time
import threading
from collections import deque
from typing import Optional, Tuple
import cv2
import numpy as np


class StreamDecoder:
    def __init__(self, source_url: str, camera_id: str, maxlen: int = 2):
        self.source_url = source_url
        self.camera_id = camera_id
        self.maxlen = maxlen
        self.queue = deque(maxlen=maxlen)
        self.lock = threading.Lock()
        self.running = False
        self.thread: Optional[threading.Thread] = None

        self.dropped_frames = 0
        self.total_frames = 0
        self.fps = 0.0
        self.last_frame_time = 0.0
        self.frame_width = 0
        self.frame_height = 0

    def start(self):
        self.running = True
        self.thread = threading.Thread(target=self._decode_loop, daemon=True)
        self.thread.start()

    def stop(self):
        self.running = False
        if self.thread and self.thread.is_alive():
            self.thread.join(timeout=2.0)

    def _decode_loop(self):
        cap = cv2.VideoCapture(self.source_url)
        if not cap.isOpened():
            print(f"[Decoder] Error: Cannot open video source: {self.source_url}")
            return

        self.frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        print(f"[Decoder] Connected to camera {self.camera_id} ({self.frame_width}x{self.frame_height})")

        frame_count = 0
        start_time = time.time()

        while self.running:
            ret, frame = cap.read()
            if not ret:
                # If synthetic video reaches EOF, rewind and loop
                if not self.source_url.startswith("rtsp://"):
                    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                    continue
                else:
                    time.sleep(0.1)
                    continue

            now = time.time()
            self.total_frames += 1
            frame_count += 1

            if now - start_time >= 1.0:
                self.fps = frame_count / (now - start_time)
                frame_count = 0
                start_time = now

            with self.lock:
                if len(self.queue) >= self.maxlen:
                    self.dropped_frames += 1
                self.queue.append((frame, now))
                self.last_frame_time = now

        cap.release()

    def get_latest_frame(self) -> Optional[Tuple[np.ndarray, float]]:
        with self.lock:
            if not self.queue:
                return None
            return self.queue.pop()
