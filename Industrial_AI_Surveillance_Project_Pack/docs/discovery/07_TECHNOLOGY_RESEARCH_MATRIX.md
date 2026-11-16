> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 07 — Technology Research Matrix & Trade-Off Analysis (Remediated)

**Document ID:** DISC-07-TECH-RESEARCH  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** PROPOSED & PINNED FOR PHASE 1 SPIKES  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Section 5 of CTO Directive  

---

## 1. Pinned Technology Stack Matrix

| Component | Pinned Candidate Version | Official Documentation | License | Key Architectural Trade-Offs & Competitors | Status |
|---|---|---|---|---|---|
| **Mobile Client** | **Flutter 3.24.x LTS (Dart 3.5.x)** | https://docs.flutter.dev/ | BSD-3-Clause | **Selected:** Custom canvas rendering; native WebRTC/ExoPlayer integration. **Vs. Kotlin Compose:** Higher cross-platform reusability and design skill alignment. | `PROPOSED` |
| **Backend Core** | **Go 1.22.x / 1.23.x** | https://go.dev/doc/ | BSD-3-Clause | **Selected:** Microsecond routing, ~15MB RAM baseline, static binary deployment on-premise. **Vs. Python FastAPI:** Eliminates GIL lock under high concurrency. **Vs. .NET 8:** Lower memory footprint. | `PROPOSED` |
| **Video Gateway** | **go2rtc v1.9.4** | https://github.com/AlexxIT/go2rtc | MIT License | **Selected:** Multiplexes RTSP to prevent NVR saturation; sub-500ms WebRTC streaming. **Vs. MediaMTX:** Lower WebRTC handshake latency. **Vs. GStreamer:** Avoids complex custom C daemon. | `PROPOSED` |
| **AI Inference** | **NVIDIA TensorRT 10.3 / 10.4 + ONNX RT 1.19** | https://docs.nvidia.com/deeplearning/tensorrt/ | NVIDIA Proprietary / MIT | **Selected:** 3–5x faster inference than raw PyTorch via FP16/INT8 kernel fusion; isolated worker process. **Vs. TensorRT 11:** TensorRT 10 is more stable on current Ampere/Ada GPUs. | `PROPOSED` |
| **Intra-Camera Tracking**| **ByteTrack** | https://github.com/ifzhang/ByteTrack | MIT License | **Selected:** Blazing-fast Kalman + IoU tracking within a single camera; negligible compute. **Caveat:** Does **NOT** provide cross-camera Re-ID. | `PROPOSED` |
| **Cross-Camera Re-ID** | **FastReID / OSNet (Spatial-Temporal)** | https://github.com/JDAI-CV/fast-reid | Apache 2.0 | **Selected:** Extracts deep appearance embeddings only during cross-camera handovers; bounded by spatial-temporal camera topology graph. | `PROPOSED` |
| **Operational DB** | **PostgreSQL 16.5 + TimescaleDB 2.16.x** | https://docs.timescale.com/ | PostgreSQL / Timescale (Apache) | **Selected:** Fully stable pairing; TimescaleDB hypertables provide instant time-series rollups; PostGIS handles polygon geofences. **Vs. PG 17:** Ecosystem extensions fully mature on PG 16. | `PROPOSED` |
| **Message Streaming** | **Valkey 7.2.6-LTS / 8.0 (or Redis 7.2-OSS)** | https://valkey.io/ | BSD-3-Clause | **Selected:** Linux Foundation open-source fork preserving BSD-3-Clause license; sub-millisecond priority queue for fire alerts. **Vs. Redis 8:** Protects against RSALv2 commercial licensing liability. | `PROPOSED` |
| **Evidence Storage** | **SeaweedFS v3.70+ / MinIO Community** | https://github.com/seaweedfs/seaweedfs | Apache 2.0 / AGPLv3 | **Selected:** SeaweedFS provides S3 API, extreme small-file performance, and Apache 2.0 freedom. MinIO Community is secondary due to AGPLv3 compliance constraints. | `PROPOSED` |
| **Observability** | **Prometheus + Grafana + Loki** | https://prometheus.io/ | Apache 2.0 | **Selected:** Industry-standard lightweight edge metrics (<200MB RAM footprint); native exporters for Go, PostgreSQL, and go2rtc. | `PROPOSED` |

---

## 2. Pinned Technology Compatibility & Boundary Analysis

### 2.1 Database Ecosystem: PostgreSQL 16 vs. 17 vs. 18
- **PostgreSQL 16.5 (Pinned):** Released November 2023 / actively updated. TimescaleDB compatibility is mature and certified across versions 2.13 through 2.16. `pgvector` and `PostGIS` are fully stable on all enterprise Linux package managers.
- **PostgreSQL 17.x:** Released September 2024. TimescaleDB added support in v2.17+ (late 2024). While viable, third-party distribution packages on enterprise on-premise Linux distributions (e.g., RHEL 9 / Ubuntu 22.04 LTS) are still maturing.
- **PostgreSQL 18:** Currently under active upstream development (unreleased). Disqualified from consideration.
- **Decision:** **Pin PostgreSQL 16.5 + TimescaleDB 2.16.x** as the conservative, battle-tested baseline.

### 2.2 In-Memory Queues: Valkey vs. Redis License Change
- **Redis License Transition:** In March 2024, Redis Ltd. transitioned from BSD-3-Clause to dual RSALv2 / SSPLv1 licenses. This restricts commercial hosted offerings and creates legal compliance reviews for enterprise deployments.
- **Valkey Fork:** Backed by the Linux Foundation, AWS, Google Cloud, and Oracle, Valkey is the direct continuation of the BSD-3-Clause open-source Redis codebase. Valkey 7.2 is 100% wire-compatible with Redis 7.2; Valkey 8.0 introduces enhanced multi-threaded I/O.
- **Decision:** **Pin Valkey 7.2.6-LTS (or Redis 7.2.4-open-source)** to eliminate commercial licensing exposure while maintaining 100% compatibility with standard Redis client libraries.

### 2.3 Object Storage: SeaweedFS vs. MinIO Community
- **MinIO Considerations:** MinIO is licensed under GNU AGPLv3. In recent versions, MinIO deprecated its multi-cloud gateway and restricted web console capabilities in the community edition. While completely viable for internal private network use, AGPLv3 triggers legal review in enterprise environments.
- **SeaweedFS Alternative:** SeaweedFS is licensed under **Apache 2.0**. It implements the standard AWS S3 API, excels at storing billions of small images (JPEG snapshots) using the Facebook Haystack architecture, and integrates easily with Go backends.
- **Decision:** **Propose SeaweedFS v3.70+ as primary, MinIO as secondary alternative**, both behind an abstract `ObjectStoragePort`.

---

## 3. Technology Research Sign-Off

- **Status:** PINNED & PROPOSED.
- **Action Item:** No packages installed or dependencies upgraded during Phase 0. Validate pinned versions during Phase 1 technical spikes.
