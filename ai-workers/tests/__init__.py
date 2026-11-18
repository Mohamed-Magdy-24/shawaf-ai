import sys
from pathlib import Path

# Ensure ai-workers is in sys.path when running tests with unittest
_workers_dir = str(Path(__file__).resolve().parent.parent)
if _workers_dir not in sys.path:
    sys.path.insert(0, _workers_dir)
