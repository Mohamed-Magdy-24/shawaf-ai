import subprocess
import threading
import time
import logging
import queue
import shutil
from typing import List, Optional, Tuple
import numpy as np

from worker.config import scrub_credentials, validate_rtsp_url

logger = logging.getLogger(__name__)

class CameraStreamHealthData:
    def __init__(self, camera_id: str):
        self.camera_id = camera_id
        self.online = False
        self.fps_decoded = 0.0
        self.dropped_frames = 0
        self.last_frame_utc_ms = 0

class RTSPStreamDecoder:
    """
    RTSP stream decoder using FFmpeg subprocess per ADR-012 and Anti-Failure Law 9.
    Maintains a bounded latest-frame queue (maxsize 1-2) and telemetry for drops/FPS.
    """

    def __init__(
        self,
        camera_id: str,
        rtsp_url: str,
        width: int = 640,
        height: int = 360,
        ffmpeg_bin: str = "ffmpeg",
        max_queue_size: int = 2
    ):
        if not validate_rtsp_url(rtsp_url):
            raise ValueError(f"Invalid RTSP URL format: {scrub_credentials(rtsp_url)}")
        self.camera_id = camera_id
        self.rtsp_url = rtsp_url
        self.width = width
        self.height = height
        self.frame_size = width * height * 3
        self.ffmpeg_bin = ffmpeg_bin
        self.max_queue_size = max_queue_size

        self.process: Optional[subprocess.Popen] = None
        self._frame_queue: queue.Queue = queue.Queue(maxsize=max_queue_size)
        self._running = False
        self._thread: Optional[threading.Thread] = None

        # Health & Telemetry
        self.health = CameraStreamHealthData(camera_id)
        self._lock = threading.Lock()
        self._frames_decoded_counter = 0
        self._last_fps_calc_time = time.monotonic()

    def build_ffmpeg_cmd(self) -> List[str]:
        """Constructs argument list for FFmpeg (shell=False mandatory)."""
        bin_path = shutil.which(self.ffmpeg_bin) or self.ffmpeg_bin
        return [
            bin_path,
            "-loglevel", "error",
            "-rtsp_transport", "tcp",
            "-i", self.rtsp_url,
            "-f", "image2pipe",
            "-pix_fmt", "bgr24",
            "-vcodec", "rawvideo",
            "-"
        ]

    def start(self):
        """Starts background frame reader loop."""
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._reader_loop, daemon=True, name=f"decoder-{self.camera_id}")
        self._thread.start()
        logger.info("Decoder started for camera %s (RTSP: %s)", self.camera_id, scrub_credentials(self.rtsp_url))

    def _spawn_process(self) -> subprocess.Popen:
        cmd = self.build_ffmpeg_cmd()
        safe_log = scrub_credentials(" ".join(cmd))
        logger.debug("Spawning FFmpeg subprocess: %s", safe_log)
        return subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=False,
            bufsize=10**7
        )

    def _reader_loop(self):
        reconnect_delay = 1.0
        while self._running:
            try:
                self.process = self._spawn_process()
                with self._lock:
                    self.health.online = True
                reconnect_delay = 1.0

                while self._running and self.process and self.process.poll() is None:
                    raw_frame = self.process.stdout.read(self.frame_size)
                    if not raw_frame or len(raw_frame) < self.frame_size:
                        logger.warning("Incomplete frame received for camera %s, reconnecting...", self.camera_id)
                        break

                    frame = np.frombuffer(raw_frame, dtype=np.uint8).reshape((self.height, self.width, 3))
                    now_ms = int(time.time() * 1000)

                    # Bounded latest-frame queue: drop older frame if full
                    try:
                        self._frame_queue.put_nowait((frame, now_ms))
                    except queue.Full:
                        try:
                            _ = self._frame_queue.get_nowait()
                            with self._lock:
                                self.health.dropped_frames += 1
                        except queue.Empty:
                            pass
                        self._frame_queue.put_nowait((frame, now_ms))

                    # Update telemetry
                    with self._lock:
                        self.health.last_frame_utc_ms = now_ms
                        self._frames_decoded_counter += 1
                        now_mono = time.monotonic()
                        elapsed = now_mono - self._last_fps_calc_time
                        if elapsed >= 1.0:
                            self.health.fps_decoded = round(self._frames_decoded_counter / elapsed, 2)
                            self._frames_decoded_counter = 0
                            self._last_fps_calc_time = now_mono

            except FileNotFoundError:
                logger.error("FFmpeg binary '%s' not found on system path.", self.ffmpeg_bin)
                with self._lock:
                    self.health.online = False
                time.sleep(5.0)
            except Exception as e:
                logger.error("Error in decoder loop for %s: %s", self.camera_id, scrub_credentials(str(e)))
                with self._lock:
                    self.health.online = False
            finally:
                self._terminate_process()

            if self._running:
                logger.info("Attempting reconnection for camera %s in %.1fs...", self.camera_id, reconnect_delay)
                time.sleep(reconnect_delay)
                reconnect_delay = min(reconnect_delay * 2, 30.0)

    def get_latest_frame(self, timeout: float = 0.5) -> Optional[Tuple[np.ndarray, int]]:
        """Retrieves the latest available frame and timestamp (ms) from the queue."""
        try:
            return self._frame_queue.get(timeout=timeout)
        except queue.Empty:
            return None

    def get_health(self) -> CameraStreamHealthData:
        """Returns snapshot of current stream health metrics."""
        with self._lock:
            # Check for coverage lost / stream freeze
            now_ms = int(time.time() * 1000)
            if self.health.online and self.health.last_frame_utc_ms > 0:
                if (now_ms - self.health.last_frame_utc_ms) > 15000:  # 15s freeze
                    self.health.online = False

            data = CameraStreamHealthData(self.camera_id)
            data.online = self.health.online
            data.fps_decoded = self.health.fps_decoded
            data.dropped_frames = self.health.dropped_frames
            data.last_frame_utc_ms = self.health.last_frame_utc_ms
            return data

    def _terminate_process(self):
        if self.process:
            try:
                self.process.terminate()
                self.process.wait(timeout=2)
            except Exception:
                try:
                    self.process.kill()
                except Exception:
                    pass
            self.process = None

    def stop(self):
        """Stops the decoder and worker thread."""
        self._running = False
        self._terminate_process()
        if self._thread and self._thread.is_alive():
            self._thread.join(timeout=3)
        with self._lock:
            self.health.online = False
        logger.info("Decoder stopped for camera %s", self.camera_id)
