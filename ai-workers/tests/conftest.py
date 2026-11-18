import sys
from pathlib import Path

# Add ai-workers root to sys.path
_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)
