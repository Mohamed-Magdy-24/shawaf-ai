import time
from typing import Dict, Optional

class MultiRateFrameSampler:
    """
    Multi-rate frame sampler for AI computer vision workloads.
    Controls evaluation frequency per detection pipeline:
    - Intrusion detection (FR-AI-001): 2.0 FPS (500 ms)
    - PPE compliance detection (FR-AI-002): 0.5 FPS (2000 ms)
    - Fall detection: 2.0 FPS (500 ms)
    - Smoke/Fire anomaly: 1.0 FPS (1000 ms)
    Uses monotonic clock to remain immune to wall-clock time jumps and drift.
    """

    def __init__(self, default_rates: Optional[Dict[str, float]] = None):
        self._rates: Dict[str, float] = default_rates or {
            "intrusion": 2.0,
            "ppe": 0.5,
            "fall": 2.0,
            "fire": 1.0,
        }
        self._last_sample_mono: Dict[str, float] = {}
        self._samples_count: Dict[str, int] = {}

    def set_rate(self, task_name: str, fps: float):
        """Sets or updates sampling rate in frames per second for a specific task."""
        if fps <= 0:
            raise ValueError(f"Sampling rate must be positive: {fps}")
        self._rates[task_name] = fps

    def get_rate(self, task_name: str) -> float:
        """Returns the configured sampling rate for a task."""
        return self._rates.get(task_name, 2.0)

    def should_sample(self, task_name: str, now_mono: Optional[float] = None) -> bool:
        """
        Determines whether the given task is due for sampling at current monotonic time.
        If due, updates the last sample timestamp and returns True.
        """
        if now_mono is None:
            now_mono = time.monotonic()

        fps = self._rates.get(task_name, 2.0)
        min_interval = 1.0 / fps

        if task_name not in self._last_sample_mono:
            self._last_sample_mono[task_name] = now_mono
            self._samples_count[task_name] = self._samples_count.get(task_name, 0) + 1
            return True

        last_time = self._last_sample_mono[task_name]
        if (now_mono - last_time) >= min_interval:
            self._last_sample_mono[task_name] = now_mono
            self._samples_count[task_name] = self._samples_count.get(task_name, 0) + 1
            return True
        return False

    def time_until_next_sample(self, task_name: str, now_mono: Optional[float] = None) -> float:
        """Returns seconds remaining until task is due for next evaluation."""
        if now_mono is None:
            now_mono = time.monotonic()
        fps = self._rates.get(task_name, 2.0)
        min_interval = 1.0 / fps
        last_time = self._last_sample_mono.get(task_name, 0.0)
        elapsed = now_mono - last_time
        remaining = min_interval - elapsed
        return max(0.0, remaining)

    def get_sample_count(self, task_name: str) -> int:
        return self._samples_count.get(task_name, 0)
