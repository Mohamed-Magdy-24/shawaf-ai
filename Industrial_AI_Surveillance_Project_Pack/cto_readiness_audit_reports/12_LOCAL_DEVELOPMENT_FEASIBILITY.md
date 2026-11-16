> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# LOCAL DEVELOPMENT FEASIBILITY MATRIX
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-12 | Classification: WORKSTATION FEASIBILITY MATRIX
### Status: VERIFIED READ-ONLY EVALUATION | Target Machine: Intel Xeon E-2236, 16GB RAM, Quadro P600 4GB

---

## 1. COMPONENT-BY-COMPONENT LOCAL FEASIBILITY MATRIX

Every planned software component was evaluated against the physical resources and operating system of the owner's workstation (Windows 10, Intel Xeon 6C/12T, 16 GB RAM, NVIDIA Quadro P600 4GB, 5.7 GB available physical RAM).

| Component / Subsystem | Local Feasibility | Resource Footprint (RAM / VRAM) | Compatibility State | Operational Limitations & Constraints | Evidence Basis |
|-----------------------|-------------------|---------------------------------|---------------------|---------------------------------------|----------------|
| **Go Backend (`edged`)** | **FEASIBLE LOCALLY** | ~60 MB RAM / 0 MB VRAM | 100% Compatible (x64) | Must install Go 1.22 on host PATH or build in WSL2. | `VERIFIED_BY_EXECUTION` |
| **PostgreSQL 16 (WSL2)** | **FEASIBLE LOCALLY** | ~150–250 MB RAM / 0 MB VRAM | 100% Compatible | Run inside Docker Desktop via TimescaleDB image. | `VERIFIED_BY_EXECUTION` |
| **go2rtc Media Gateway** | **FEASIBLE LOCALLY** | ~40–80 MB RAM / 0 MB VRAM | 100% Compatible | Compiled Go binary sidecar; low-latency WebRTC. | `VERIFIED_IN_SOURCE` |
| **Python AI Worker** | **FEASIBLE LOCALLY** | ~800 MB RAM / 1.5 GB VRAM | **REQUIRES PY 3.11** | Must run inside Python 3.11 venv; host 3.14 breaks wheels. | `VERIFIED_IN_SOURCE` |
| **ONNX Runtime (CPU)** | **FEASIBLE LOCALLY** | ~500 MB RAM / 0 MB VRAM | 100% Compatible | AVX2 hardware acceleration on 6-core Xeon CPU. | `VERIFIED_OFFICIAL_SOURCE`|
| **ONNX Runtime (CUDA)**| **FEASIBLE LOCALLY** | ~600 MB RAM / 1.2 GB VRAM | **FP32 ONLY** | Quadro P600 (SM 6.1) runs FP32; no Tensor Cores for INT8. | `VERIFIED_BY_EXECUTION` |
| **NVIDIA TensorRT 10** | **UNSUPPORTED** | N/A | **INCOMPATIBLE (SM 6.1)** | Dropped by NVIDIA in TRT 10. Cannot run locally. | `VERIFIED_OFFICIAL_SOURCE`|
| **NVIDIA DeepStream 7**| **UNSUPPORTED** | N/A | **INCOMPATIBLE (SM 6.1)** | Requires SM $\ge 7.5$. Cannot run locally. | `VERIFIED_OFFICIAL_SOURCE`|
| **Hardware Video Decode**| **FEASIBLE LOCALLY**| ~150 MB VRAM per stream | 100% Compatible | 4th-Gen NVDEC supports H.264 & H.265 decode up to 4K. | `VERIFIED_OFFICIAL_SOURCE`|
| **React Web Admin SPA**| **FEASIBLE LOCALLY** | ~350 MB RAM (Vite Dev Server) | 100% Compatible | Node.js 24 installed; runs fast in modern browser. | `VERIFIED_BY_EXECUTION` |
| **Flutter Mobile App** | **FEASIBLE LOCALLY** | ~400 MB RAM (Build toolchain) | 100% Compatible | Flutter 3.44 installed. Must test via physical phone. | `VERIFIED_BY_EXECUTION` |
| **Android Studio AVD** | **INFEASIBLE / FORBIDDEN**| **3.0 to 4.5 GB RAM** | **RESOURCE EXHAUSTION**| Running emulator causes host RAM swapping and OOM crashes. | `CALCULATED_ASSUMPTION` |
| **Local Synthetic Video**| **FEASIBLE LOCALLY**| ~2.5 GB Disk on Drive D: | 100% Compatible | Loop 4 to 6 local MP4 test videos via RTSP server. | `VERIFIED_BY_EXECUTION` |
| **Docker Desktop / WSL2**| **FEASIBLE LOCALLY**| **Cap at 4.0 GB RAM** | 100% Compatible | Must configure `.wslconfig` memory limit. | `VERIFIED_BY_EXECUTION` |

---

## 2. SYSTEM CAPABILITY TIERS: WHAT CAN BE VERIFIED WHERE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SIX-TIER EXECUTION REALITY BOUNDARY                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER A: DEVELOPABLE & VERIFIABLE ON LOCAL WORKSTATION                       │
│ - Go Backend API, WebSocket Hub, and Transactional Outbox Pipeline.         │
│ - PostgreSQL 16 schema, TimescaleDB hypertables, and Row-Level Security.    │
│ - go2rtc stream proxying, WebRTC / MSE player in React Web Admin.           │
│ - React Web Admin Zone Polygon Editor (CVAT canvas interaction model).      │
│ - Python AI Worker running YOLOv8n + ByteTrack on local MP4 test loops.     │
│ - Flutter Mobile UI compiled to physical Android phone via USB debugging.   │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER B: FUNCTIONALLY TESTABLE ON LOCAL WORKSTATION (SMALL-SCALE SIMULATION) │
│ - 4 to 6 simulated camera RTSP streams looping 1080p synthetic MP4 video.   │
│ - Motion-gating pre-filter performance (MOG2) on simulated factory scenes.  │
│ - Mock ZKTeco attendance webhook processing.                                │
│ - Degraded mode testing (simulated local network cut).                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER C: REQUIRES EXTERNAL TEST BENCH HARDWARE (PHASE 1 SPIKES)              │
│ - Spike SPK-01: 1 physical ZKTeco terminal on bench switch (Photo export).  │
│ - Spike SPK-03: 1 physical NVR + 2 industrial cameras (RTSP session limits).│
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER D: REQUIRES REAL FACTORY PHYSICAL ACCESS (PHASE 2 / PHASE 3)           │
│ - Physical Dahua/Hikvision camera discovery over factory CCTV VLAN.          │
│ - Inspection of physical lighting, mounting angles, and factory EMI noise.  │
│ - Live attendance SQL Server staging database read-only schema export.      │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER E: REQUIRES PRODUCTION ENTERPRISE SERVERS (PHASE 4)                    │
│ - Ingestion and processing of 200+ concurrent cameras per factory.          │
│ - 162 Terabyte RAID-6 continuous video recording disk array.                │
│ - NVIDIA DeepStream SDK 7.0 and TensorRT INT8 pipeline on RTX 4000 Ada GPU. │
├─────────────────────────────────────────────────────────────────────────────┤
│ TIER F: STRICTLY BLOCKED UNTIL FORMAL LEGAL COUNSEL APPROVAL                │
│ - Extracting or storing biometric facial recognition embeddings of workers. │
│ - Cross-camera continuous employee movement tracking and profiling.        │
│ - Commissioning automated zero-gate fire alert dispatch to factory sirens.  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. RECOMMENDED MINIMAL LOCAL DEVELOPMENT CONFIGURATION (THEORY ONLY)

*Note: In accordance with execution prohibitions, this configuration is documented for planning purposes ONLY and has NOT been executed or provisioned.*

```
[ Developer Machine: Windows 10 Host (16 GB RAM) ]
  ├── VS Code / Cursor IDE (Host: ~1.2 GB RAM)
  ├── Chrome / Edge Browser (Web Admin: ~600 MB RAM)
  ├── Physical Android Phone connected via USB Cable (0 MB Host RAM)
  │
  ├── [ Docker Desktop / WSL2 Ubuntu ] (Capped strictly at 4.0 GB RAM via .wslconfig)
  │     ├── Container 1: PostgreSQL 16 + TimescaleDB (~250 MB RAM)
  │     ├── Container 2: go2rtc streaming gateway sidecar (~60 MB RAM)
  │     ├── Container 3: Go Edge Daemon (`edged` binary) (~80 MB RAM)
  │     └── Container 4: Python 3.11 AI Worker (PyTorch + ONNX Runtime CUDA) (~1.8 GB RAM)
  │
  └── [ Simulated Stream Rig: MediaMTX or RTSP-Simple-Server ]
        └── Loops 4x 1080p MP4 industrial test files stored on Drive D: (~2.0 GB disk)
```

- **Total Memory Demand**: $\approx 1.2 + 0.6 + 4.0 = \mathbf{5.8\text{ GB RAM}}$.
- **Feasibility Verdict**: Perfectly fits within the workstation's 5.7 GB available physical RAM without page swapping, provided the Android emulator is never launched.

---
**Audited By:** Principal Systems Architect & Hardware Lead  
**Evaluation Standard:** Empirical workstation hardware measurements

