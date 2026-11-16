> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# CTO FINAL ARCHITECTURAL RECOMMENDATIONS & IMPLEMENTATION ROADMAP
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: REF-RES-08 | Classification: STRATEGIC & EXECUTIVE DIRECTIVE
### Status: APPROVED FOR EXECUTION | Evidence Standard: VERIFIED

---

## 1. EXECUTIVE VERDICT & STRATEGIC SUMMARY

Following forensic source-code audits of nine open-source reference repositories, the Principal AI Engineer / CTO issues the following definitive engineering rulings:

1. **Strategic Anchor Affirmed**: The Project Owner’s mandate is technically sound and fully validated:
   - **Frigate** is the gold standard for review UX, alert lifecycles, and motion-gated AI triggering.
   - **Viseron** provides the benchmark for clean domain interface segregation and multi-stage detector chaining.
   - **DeepStream** represents the future high-density GPU production pipeline.
   - **Proprietary Core**: The core edge daemon (`edged` in Go), multi-tenant persistence (PostgreSQL 16 + TimescaleDB), edge-to-cloud security (WireGuard VPN), and cross-platform mobile client (Flutter) remain proprietary, robust, and uncompromised by third-party architectural shortcuts.
2. **Strict License Isolation**: Under no circumstances shall GPL-3.0 (Viseron) or GPL-2.0+ (ZoneMinder) source code be copied into the project. All abstractions must be implemented via clean-room Go interfaces and Python protocols.
3. **Hardware Pragmatism**: The developer’s workstation (NVIDIA Quadro P600, Pascal SM 6.1) cannot run DeepStream 7.0 or TensorRT 10.x. Development must proceed using **ONNX Runtime (CUDA/CPU) and PyTorch**, reserving DeepStream for future production factory server deployment.

---

## 2. REPOSITORY DECISION & INTEGRATION MATRIX

| # | Repository | License | Strategic Decision | Integration Role in BNF/RNF Platform |
|---|------------|---------|--------------------|--------------------------------------|
| 1 | **Frigate** | MIT | **ADOPT (UX & Lifecycle)** | Implement Frigate review segments, alert vs. detection hierarchy, and motion-gating. |
| 2 | **Viseron** | GPL-3.0 | **ADAPT (Clean-Room)** | Adopt domain-driven port/adapter pattern; zero code copying; re-implement in Python/Go. |
| 3 | **ZoneMinder**| GPL-2.0+ | **REJECT (Architecture)** | Consult for PTZ command sequences and polygon math; reject legacy C++/Perl daemons. |
| 4 | **go2rtc** | MIT | **ADOPT (Core Streaming)**| Deploy as external compiled Go sidecar for sub-200ms WebRTC and MSE stream routing. |
| 5 | **MediaMTX** | MIT | **RESERVE (Backup Broker)**| Standby alternative if RTMP/SRT multi-protocol broadcasting is mandated. |
| 6 | **DeepStream**| NVIDIA EULA | **ADOPT (Future Production)**| Target zero-copy GPU pipeline for procured enterprise factory servers with Ampere/Ada GPUs. |
| 7 | **ByteTrack** | MIT | **ADOPT (Intra-Cam MOT)** | Embed inside Python AI worker for continuous, occlusion-resilient person tracking. |
| 8 | **CVAT** | MIT | **ADOPT (UI Benchmark)** | Replicate polygon canvas interaction model in Web Admin Zone Editor (`FR-WEB-003`). |
| 9 | **pyzk** | MIT / LGPL | **RESTRICT (Lab Spike Only)**| Protocol reference for Spike `SPK-01`; strictly excluded from production attendance sync. |

---

## 3. PHASED IMPLEMENTATION ROADMAP

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: LOCAL WORKSTATION FOUNDATION & ARCHITECTURAL SPIKES (WEEKS 1 - 3)  │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Setup local development environment on host workstation.                  │
│ • Spike SPK-01: ZKTeco protocol verification vs. mock terminal.             │
│ • Spike SPK-02: go2rtc streaming sidecar integration (RTSP -> WebRTC/MSE).  │
│ • Spike SPK-03: Python AI worker with ONNX Runtime & ByteTrack on P600 GPU. │
│ • Initialize local PostgreSQL 16 + TimescaleDB schema and Outbox table.     │
│ • Gate 1 Review: Workstation stability, sub-250ms streaming, AI inference. │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: CORE EDGE ENGINE & ADVANCED ANALYTICS (WEEKS 4 - 7)                │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Build Go edge daemon (`edged`) with process supervisor and watchdog.      │
│ • Implement two-tier motion-gated AI dispatch (OpenCV MOG2 -> YOLOv8).      │
│ • Integrate ByteTrack intra-camera tracking and 90-frame fall detection.    │
│ • Implement zero-transcoding 10s fMP4 segment recording & tiered storage.   │
│ • Build React Web Admin: CVAT-style Zone Polygon Editor & Frigate Review UX.│
│ • Gate 2 Review: 24-hour soak test, zero memory leaks, reliable outbox.    │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: MULTI-FACTORY WIREGUARD MESH & CENTRAL PLATFORM (WEEKS 8 - 11)     │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Deploy WireGuard hub-and-spoke VPN connecting BNF Edge and RNF Edge.      │
│ • Build Central Management Server (`centrald`) with multi-tenant RLS.       │
│ • Implement cross-camera and cross-factory person Re-ID using OSNet.        │
│ • Integrate enterprise ZKBioTime REST API / SQL sync for attendance.        │
│ • Build Flutter Android application: FCM push alerts & live WebRTC player.  │
│ • Gate 3 Review: Multi-tenant security audit, WAN failover & sync test.     │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: PRODUCTION FACTORY DEPLOYMENT & GPU SCALING (WEEKS 12 - 14)        │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Commission dedicated industrial factory servers at BNF and RNF.           │
│ • Migrate AI pipeline to NVIDIA DeepStream & TensorRT INT8 on Ampere GPUs.  │
│ • Connect real factory Dahua/Hikvision cameras and physical sirens.         │
│ • Full legal compliance verification under Egyptian Data Protection Law 151.│
│ • Final Production Handover & Operations Runbook sign-off.                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. PHASE TRANSITION GATES & CRITERIA

| Transition Gate | Objective | Mandatory Verification Criteria |
|-----------------|-----------|---------------------------------|
| **Gate 1: PoC to Core Build** | Local Workstation Validation | - go2rtc serves WebRTC and MSE streams under 250ms latency.<br>- Python AI worker processes YOLOv8 + ByteTrack at $\ge 15$ FPS on P600 GPU.<br>- gRPC IPC over Unix socket functions with zero dropped frames.<br>- ZKTeco communication verified without device lockup. |
| **Gate 2: Core to Multi-Factory**| Edge Node Hardening | - 24-hour continuous recording without memory leaks or segment gaps.<br>- Motion gating eliminates $\ge 70\%$ idle frame inference.<br>- Transactional outbox persists and replays events across simulated crashes.<br>- Web Admin polygon editor correctly saves normalized coordinates ($0.0–1.0$). |
| **Gate 3: Multi-Factory to Prod**| Enterprise Multi-Tenancy & Security | - WireGuard VPN survives simulated WAN interruptions and automatically drains outbox.<br>- PostgreSQL Row-Level Security (RLS) strictly blocks BNF users from RNF data.<br>- Flutter app receives high-priority push notifications within 1.5s.<br>- Law 151/2020 compliance audit confirms biometric encryption and audit logging. |

---

## 5. TOP ENGINEERING RISKS & MITIGATION REGISTER

| Risk ID | Risk Description | Severity | Probability | Concrete Technical Mitigation |
|---------|------------------|----------|-------------|-------------------------------|
| **RSK-01** | GPL-3.0 legal infection from Viseron | CRITICAL | LOW | Enforce strict clean-room engineering. Author all Go/Python interfaces independently. Zero direct source copying. |
| **RSK-02** | Workstation GPU crash on DeepStream | CRITICAL | HIGH | Block DeepStream on Pascal P600. Standardize on ONNX Runtime + PyTorch FP32 for local development. |
| **RSK-03** | ZKTeco physical terminal lockup | HIGH | MEDIUM | Strictly prohibit direct socket polling in production. Connect via official ZKBioTime REST API or read-only SQL view. |
| **RSK-04** | WebRTC failure on corporate networks | HIGH | MEDIUM | go2rtc automatic fallback to Media Source Extensions (MSE) over WebSocket/HTTP. Zero UDP dependency. |
| **RSK-05** | Database lock contention under AI load | HIGH | MEDIUM | Replaced SQLite with PostgreSQL 16 + TimescaleDB. Hypertables partition high-volume telemetry. |
| **RSK-06** | WAN fiber cut isolating edge servers | MEDIUM | HIGH | Transactional Outbox Pattern. Edge server operates 100% autonomously, queuing events until WAN recovery. |
| **RSK-07** | Biometric privacy breach (Law 151) | CRITICAL | LOW | Store 512-d irreversible embeddings only. Encrypt at rest with AES-256-GCM. Mandatory employee consent check. |

---

## 6. VERIFICATION AND EVIDENCE CLASSIFICATION

- **Local Workstation Hardware Baseline**: `VERIFIED_BY_EXECUTION` (PowerShell WMI audit and `nvidia-smi` confirming Intel Xeon E-2236, 16GB RAM, Quadro P600 4GB).
- **GPL Copyleft Legal Impact**: `VERIFIED_OFFICIAL_SOURCE` (Free Software Foundation GPL-3.0 text and legal precedents).
- **DeepStream Enterprise GPU Requirements**: `VERIFIED_OFFICIAL_SOURCE` (NVIDIA DeepStream 7.0 documentation).
- **TimescaleDB Partitioning Throughput**: `VERIFIED_IN_SOURCE` (TimescaleDB hypertable benchmarks).

---
**Authored By:** Principal AI Engineer / CTO  
**Signed & Approved For Execution:** 2026-11-12

