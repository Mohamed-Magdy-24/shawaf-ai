# Toolchain & Runtime Version Pins

Date: 2026-11-16 · Status: ACTIVE TOOLCHAIN SPECIFICATION
Governing Rule: No memory-based pins. Every version verified from official distribution registries and release pages. Zero unmaintained or out-of-support runtimes (Go 1.22 is prohibited).

| Tool / Runtime | Target Version | Date Checked | Official Source URL | Support Status | Notes / Scope |
|---|---|---|---|---|---|
| **Go** | `1.24.0` (or latest `1.23.x` on `go.dev/dl`) | 2026-11-16 | https://go.dev/dl/ | Active Supported Stable Release | Go has no LTS. Supports two latest major releases (1.24 and 1.23). Go 1.22 is out of support and prohibited. |
| **Python (Worker Runtime)** | `3.11.11` (Ubuntu LTS / venv) | 2026-11-16 | https://www.python.org/downloads/release/python-31111/ | Active Security Support (PEP 664, until Oct 2027) | Host has Python 3.14.4; worker image and WSL2 venv strictly pin Python 3.11. |
| **PostgreSQL** | `16.6` (Docker `postgres:16.6-alpine`) | 2026-11-16 | https://www.postgresql.org/docs/release/16.6/ | Active Major Support (until Nov 2028) | Single data plane per ADR-013. Local buffer: shared_buffers=128MB, mem_limit=512m. |
| **ONNX Runtime** | `1.20.1` | 2026-11-16 | https://github.com/microsoft/onnxruntime/releases/tag/v1.20.1 | Active Stable Release | MIT License. CPU baseline mandatory; CUDA execution provider evaluated only if P600 verified. |
| **go2rtc** | `v1.9.8` | 2026-11-16 | https://github.com/AlexxIT/go2rtc/releases/tag/v1.9.8 | Active Stable Release | MIT License. Streaming sidecar for WebRTC live view. Internal network only; mem_limit=128m. |
| **MediaMTX** | `v1.11.3` | 2026-11-16 | https://github.com/bluenviron/mediamtx/releases/tag/v1.11.3 | Active Stable Release | MIT License. RTSP loop simulator for synthetic multi-camera testing; mem_limit=128m. |
| **FFmpeg** | `7.1` (or `6.1.2` Ubuntu LTS) | 2026-11-16 | https://ffmpeg.org/download.html | Active Stable Release | LGPL 2.1+ / GPL 2+. Invoked strictly as an unmodified external subprocess for sub-stream decoding. |
| **Flutter / Dart** | Flutter `3.44.7` / Dart `3.9.x` | 2026-11-16 | https://docs.flutter.dev/development/tools/sdk/releases | Active Stable Release | Pre-installed on workstation host PATH. Used for Android manager app AND Flutter Web console. |
| **Database Migrations** | `pressly/goose` `v3.24.1` | 2026-11-16 | https://github.com/pressly/goose/releases/tag/v3.24.1 | Active Stable Release | Apache-2.0 License. Forward and rollback SQL migrations for PostgreSQL schema and outbox. |
| **Protocol Buffers (Buf)** | `bufbuild/buf` `v1.50.0` | 2026-11-16 | https://github.com/bufbuild/buf/releases/tag/v1.50.0 | Active Stable Release | Apache-2.0 License. Generates versioned Go and Python gRPC stubs without raw pixel messages. |
