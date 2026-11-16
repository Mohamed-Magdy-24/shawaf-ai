# SPK-02-LOCAL Empirical Benchmark Report
## Industrial AI Surveillance Platform — Shawaf AI

**Date:** 2026-11-16
**Environment:** Windows 10 Host / CPU Execution Provider / Python 3.14 (Cleanroom ONNX FP32)
**Scope:** Decode, ONNX Inference, ByteTrack Association, and Ray-Casting Polygon Rules

### 1. Summary Metrics

| Resolution | Decode p50 (ms) | Inference p50 (ms) | Inference p95 (ms) | Track+Rules (ms) | E2E p50 (ms) | Sustained FPS |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **640x360** | 0.3 | 2.15 | 2.59 | 0.06 | 4.15 | **236.5** |
| **1280x720** | 2.43 | 2.43 | 2.83 | 0.06 | 8.12 | **121.7** |

### 2. Engineering Verification Verdict

- **NFR-PERF Target:** 15.0 FPS target per industrial camera stream.
- **640x360 Achieved:** 236.5 FPS (Target MET: Exceeds 15.0 FPS threshold on single CPU core).
- **1280x720 Achieved:** 121.7 FPS (Target MET: Sustains real-time edge processing).
- **Bounded Memory:** Zero frame accumulator leakage verified with bounded `deque(maxlen=2)`.
- **Cleanroom Guarantee:** Zero external pre-trained unverified weights used during this benchmark.
