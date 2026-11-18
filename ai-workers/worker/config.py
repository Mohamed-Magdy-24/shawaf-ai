import os
import re
from pathlib import Path
from pydantic import BaseModel, Field

class WorkerConfig(BaseModel):
    site_id: str = Field(default_factory=lambda: os.getenv("SITE_ID", "BNF"))
    worker_id: str = Field(default_factory=lambda: os.getenv("WORKER_ID", "worker-bnf-01"))
    edged_grpc_target: str = Field(default_factory=lambda: os.getenv("EDGED_GRPC_TARGET", "127.0.0.1:50051"))
    shared_secret_token: str = Field(default_factory=lambda: os.getenv("SHARED_SECRET_TOKEN", "dev_shared_secret_token_change_in_prod"))
    snapshot_base_dir: str = Field(
        default_factory=lambda: os.getenv(
            "SNAPSHOT_BASE_DIR",
            str(Path(__file__).resolve().parents[2] / "data" / "snapshots")
        )
    )
    sample_rate_fps: float = Field(default_factory=lambda: float(os.getenv("SAMPLE_RATE_FPS", "2.0")))
    ppe_sample_rate_fps: float = Field(default_factory=lambda: float(os.getenv("PPE_SAMPLE_RATE_FPS", "0.5")))
    heartbeat_interval_sec: float = Field(default_factory=lambda: float(os.getenv("HEARTBEAT_INTERVAL_SEC", "5.0")))
    coverage_lost_timeout_sec: float = Field(default_factory=lambda: float(os.getenv("COVERAGE_LOST_TIMEOUT_SEC", "15.0")))
    ffmpeg_bin: str = Field(default_factory=lambda: os.getenv("FFMPEG_BIN", "ffmpeg"))
    cooldown_sec: float = Field(default_factory=lambda: float(os.getenv("EVENT_COOLDOWN_SEC", "5.0")))
    confidence_threshold: float = Field(default_factory=lambda: float(os.getenv("CONFIDENCE_THRESHOLD", "0.50")))
    model_path: str = Field(default_factory=lambda: os.getenv("MODEL_PATH", ""))
    ppe_model_path: str = Field(default_factory=lambda: os.getenv("PPE_MODEL_PATH", ""))

def scrub_credentials(text: str) -> str:
    """Masks plaintext RTSP credentials in error strings and logs per Anti-Failure Law 9 and ADR-012."""
    if not text:
        return text
    def _repl(match):
        prefix = match.group(1)
        cred = match.group(2)
        if ":" in cred:
            return f"{prefix}***:***@"
        return f"{prefix}***@"

    return re.sub(r'(rtsps?://)([^/@]+)@', _repl, str(text))

def validate_rtsp_url(url: str) -> bool:
    """Enforces strict allowlist validation on RTSP URLs per Anti-Failure Law 9 and ADR-012."""
    if not url:
        return False
    pattern = re.compile(r'^rtsps?://[a-zA-Z0-9_\-\.:@]+(/[a-zA-Z0-9_\-\./~]*)?(\?[a-zA-Z0-9_\-\.&=]*)?$')
    return bool(pattern.match(url))
