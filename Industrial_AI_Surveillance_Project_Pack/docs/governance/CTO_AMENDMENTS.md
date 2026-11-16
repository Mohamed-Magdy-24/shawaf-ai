# CTO Amendments & Baseline Governance

Date: 2026-11-16 · Issued by: CTO · Status: ACTIVE BASELINE

## 1. Pack Defects Identified by CTO Audit (§2.4)

| # | Defect | Evidence |
|---|---|---|
| D1 | Agent is forbidden to write code: "Sprint 1 STRICTLY NOT AUTHORIZED", "zero installs" | `antigravity/09_MASTER_OPERATING_PROMPT.md` §3.1; `PROJECT_HANDOFF.md` §B |
| D2 | `verify_archive_manifest.py` currently FAILS (uncataloged `PROJECT_HANDOFF.md`) although HANDOFF claims 102/102 PASS | run `python3 -I verify_archive_manifest.py` |
| D3 | Contradictory numbers: 42 FR/13 NFR/55 reqs (audit reports) vs 96 (SRS); 16×18 TB/198.9 TB (master prompt) vs 16×16 TB/162 TB (AUDIT-09); 400 FPS/site (Doc 24) vs 250 FPS/site (AUDIT-09); WSL cap 4 GB vs 6 GB | audit 01, 09, 12; master prompt §3; Doc 24 |
| D4 | Banned tech (YOLOv8, TensorRT, DeepStream, RTX-4000-Ada TensorRT-INT8 sizing, MinIO) still used as active recommendations in ~30 files | `rg -il "YOLOv8\|TensorRT\|DeepStream"` |
| D5 | `VERIFIED_BY_EXECUTION` labels on numbers never executed (Go RAM, 50 ms latency, P600 CUDA) — Go is not installed and SPK-02 was never run | AUDIT-12 table, AUDIT-09 §5.1 |
| D6 | Local plan needs 5.8 GB RAM vs 5.7 GB free; PyTorch inside the runtime container | AUDIT-12 §3 |
| D7 | No owner of video decoding: architecture makes Go dispatch frames but Go has no native video decoder | `architecture/02_TARGET_ARCHITECTURE.md` §7 backpressure section |
| D8 | "Go 1.22.6 LTS" — Go has no LTS and 1.22 is out of support | AUDIT-08 |
| D9 | Docker Desktop is not free for larger companies; Windows 10 is past end of support | AUDIT-07/08/14 |
| D10 | Model gaps/errors: RT-DETR listed for fall/posture; InsightFace/ArcFace listed as Apache-2.0 without weights/dataset license check; no model identified for PPE, fire/smoke, phone, pose | `supplementary_license_audit/AI_MODELS_AND_DATASETS_LICENSE_AUDIT.md` |
| D11 | AUDIT-13 "proposed patches" invent thresholds (2.0 m/s etc.) and "siren silenced" semantics that contradict the SRS | `13_REQUIRED_DOCUMENTATION_CORRECTIONS.md` |
| D12 | 4 languages + ~9 services (Go, Python, React, Flutter, PG, TimescaleDB, Valkey, go2rtc, WireGuard) for a one-person test machine | `ADR-011` |
| D13 | Broken links (`docs/discovery/26_…` → `../../antigravity/…`; HANDOFF `file:///d:/…`; HANDOFF cites `architecture/03_INTEGRATION…` which lives in `integrations/`) | link check script in WP-0 |

## 2. Baseline Architecture Decisions (ADR-011 … ADR-017)

### ADR-011 — Unified Edge, Streaming, and AI Runtime Baseline
- Status: APPROVED AS AMENDED (amended by ADR-012 … ADR-017 below).

**ADR-012 — The AI worker owns video decode and inference.**
- Status: APPROVED (local-dev)
Context: Go has no native production video decoder; sending raw frames Go→Python over gRPC costs CPU/RAM and bandwidth. Decision: the Go core never decodes video. The Python worker pulls each camera's *sub-stream* (credentials supplied by Go at config time, never logged), decodes it with an ffmpeg subprocess (or PyAV), applies a fixed-rate sampler, keeps a **bounded latest-frame queue (size 1–2, drops counted)** per camera, runs ONNX inference, tracking and rule evaluation, and sends **only events + a JPEG evidence snapshot reference** to Go via versioned gRPC (idempotency key per event). Go owns camera/zone/policy configuration, scheduling, health, persistence, alerts. Transport: gRPC over TCP 127.0.0.1 (works identically in WSL2, Docker and Linux; no Unix sockets). Consequences: Go↔Python traffic is tiny; one worker process serves N cameras where N is MEASURED in WP-3; the "proto" file must contain no frame/pixel message.

**ADR-013 — Minimal data plane.**
- Status: APPROVED (local-dev)
Decision: PostgreSQL 16 only. Outbox = table with `priority`, `status`, `attempts`, `next_attempt_at`, unique `idempotency_key`; dispatch with `FOR UPDATE SKIP LOCKED` + `LISTEN/NOTIFY`. Fire-priority rows are served by a dedicated goroutine with its own connection and no batching/throttling. Events table uses native monthly partitioning. **Valkey and TimescaleDB are removed from the baseline** (re-introduce only through a new ADR citing a measured limit). Consequences: two fewer services, no Timescale License question, lower RAM.

**ADR-014 — One client codebase.**
- Status: APPROVED (local-dev)
Decision: Flutter (Dart) for the Android manager app AND the administration console (Flutter Web build, desktop browser). React/Vite is removed from the baseline. Cubit/Bloc (`flutter_bloc`) for state. Zone editor = CustomPainter polygon editor. Live view = WebRTC via go2rtc (`flutter_webrtc` after license check). Charts = in-app vector charts (`fl_chart` after license check). Consequences: 3 languages total (Go, Python, Dart).

**ADR-015 — Runtime environment.**
- Status: APPROVED (local-dev)
Decision: develop inside WSL2 Ubuntu LTS; run containers with Docker Engine (docker-ce, Apache-2.0) inside WSL2, **not Docker Desktop**, unless the owner confirms the company qualifies for the free tier. `%USERPROFILE%\.wslconfig`: `memory=5GB`, `processors=6`, `swap=6GB` with the swap file on D:. Keep project files and volumes inside the WSL2 ext4 filesystem (not `/mnt/d`). Production target: Ubuntu Server LTS. Windows 10 is past end of support: treat the workstation as a dev box only; never expose it to the factory network. The Android emulator is forbidden; use a physical phone over USB.

**ADR-016 — Inference runtime.**
- Status: APPROVED (local-dev)
Decision: the deployed worker image contains ONNX Runtime + OpenCV/NumPy only (no PyTorch). Models are exported to ONNX in a separate offline "model-export" environment; every model artifact is stored with source commit, SHA-256 and a MODEL_REGISTER row. CPU is the mandatory baseline; `onnxruntime-gpu` (CUDA) is optional and enabled only if WP-3 proves it works on the P600 with the pinned driver/CUDA/cuDNN — otherwise CPU only. TensorRT, DeepStream, Ultralytics, pyzk, MinIO stay excluded. Models use FP32 on the P600.

**ADR-017 — Notification channel port.**
- Status: APPROVED (local-dev)
Decision: `NotificationChannel` port with adapters: (1) `WebSocketChannel` (in-app, default), (2) `FcmChannel` (implemented, **disabled** until DEC-08; payload = event id + generic text only: no names, no images, no site-sensitive details), (3) `NtfyChannel` (self-hosted ntfy/UnifiedPush, Apache-2.0/GPL-check required before use — if its server license is copyleft, run it only as a separate unmodified process and record the legal note) as a Google-free fallback candidate. Android client: foreground service for the socket plus a documented battery-optimization exemption step; test on the physical phone with screen off for 30 min. Additionally the platform MUST raise an **operational alert ("coverage lost")** to configured admins when a camera stream or a worker heartbeat is missing for a configurable time — a silent blind spot is a safety defect. (New requirement NFR-OBS-002 — add to SRS and CSV as `PROPOSED_LOCAL_DEV`; CSV then has 97 rows; update CANONICAL_NUMBERS.md accordingly.)
