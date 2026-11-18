# EXISTING SYSTEM CAPABILITY MATRIX
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Subsystem Classification & Technical Evidence Matrix  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Standard:** Section 7 & Section 28 of Ultimate Master Directive (`Prompt.md`)  
**Date:** 2026-11-18  

---

## 1. Classification Categories & Evaluation Methodology

Every major existing subsystem, specification, integration, and architecture component is classified into exactly one of six mandatory categories:

1. **`KEEP`**: Proven, correct, aligned with project principles, and worth retaining without structural redesign.
2. **`REFACTOR`**: Functionally useful and sound in concept, but requiring code restructuring, hardening, interface realignment, or security remediation.
3. **`REBUILD`**: Existing approach is technically flawed, obsolete, violating architectural constraints, or creating unmaintainable complexity. Complete ground-up reconstruction justified by evidence.
4. **`REMOVE`**: Unnecessary, unsafe, incompatible, adding licensing hazards, or out of project scope. Purged from target architecture.
5. **`NOT IMPLEMENTED`**: Defined in specifications and required for the final product, but zero executable code currently exists.
6. **`NOT VERIFIED`**: Insufficient physical or empirical evidence to confirm viability, performance, or device compatibility.

---

## 2. Comprehensive Subsystem Capability Matrix

| # | Subsystem / Component | Current Physical Artifact / File | Observed Actual Behavior | Classification | Evidence & Rationale | Recommended Action |
|---|---|---|---|---|---|---|
| **1** | **Project Charter & Scope** | `Industrial_AI_Surveillance_Project_Pack/00_PROJECT_CHARTER.md` | Defines on-premises, multi-factory (BNF/RNF) surveillance scope for ~200+ cameras/site. | `KEEP` | Charter accurately reflects business reality and owner intent. | Retain as high-level product boundary. |
| **2** | **Software Requirements Specification (SRS)** | `Industrial_AI_Surveillance_Project_Pack/requirements/01_SRS.md` | Contains exactly 97 requirements (78 FR + 19 NFR, including `NFR-OBS-002`). | `KEEP` | 100% 1:1 ID parity with CSV traceability matrix; includes amended local-dev defaults. | Retain as authoritative requirements baseline. |
| **3** | **Traceability Matrix** | `Industrial_AI_Surveillance_Project_Pack/planning/09_REQUIREMENTS_TRACEABILITY.csv` | 97-row structured matrix tracking status, evidence, and verification methods. | `KEEP` | Verified 0 missing, duplicate, or dangling requirement IDs. | Maintain as canonical traceability register. |
| **4** | **Owner Decisions & Spike Register** | `Industrial_AI_Surveillance_Project_Pack/docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md` | Tracks `DEC-01`..`DEC-08`, `SPK-01`..`SPK-04`, `ADR-011`..`ADR-017`. | `REFACTOR` | Contains historical references; header amended but body needs full synchronization with `CTO_AMENDMENTS.md`. | Synchronize fully with `CTO_AMENDMENTS.md` and `OWNER_AUTHORIZATION_LOCAL_DEV.md`. |
| **5** | **Web Admin Console (React/Vite)** | Historical references in Docs 01, 02, 10, 23 | Proposed React + TypeScript + Vite + Tailwind dashboard. | **`REMOVE`** | Violates zero-redundancy rule (`ADR-014`). Replaced by Flutter Web to share Dart code with Android app. | Completely purged from Active Set; do not scaffold React. |
| **6** | **Web Admin Console (Flutter Web)** | `02_TARGET_ARCHITECTURE.md` (amended), `Prompt.md` §15.2 | High-density operations dashboard for live wall, alerts, incidents, attendance, audit logs. | **`NOT IMPLEMENTED`** | Zero Flutter Web lines written; host has Flutter 3.44.7 / Dart 3.12.2 installed. | Implement in Phase 7 (Sprint 2/3) using Clean Architecture. |
| **7** | **Android Handheld App (Flutter)** | Wireframes in Doc 33; SRS `FR-AND-001`..`007` | Handheld app for floor security supervisors (incident push alerts, low-latency WebRTC streams). | **`NOT IMPLEMENTED`** | Zero Flutter Android code exists in repo. | Implement in Phase 7 using shared Flutter client repository. |
| **8** | **Backend Service Core (`edged`)** | `02_TARGET_ARCHITECTURE.md` | Go-based edge daemon handling domain logic, RLS queries, outbox dispatch, and APIs. | **`NOT IMPLEMENTED`** | Zero Go files exist in workspace. Host Windows lacks Go on PATH. | Build containerized in WSL2/Docker in Sprint 1 (`WP-2`). |
| **9** | **Go Video Decoding Subsystem** | Proposed in historical Doc 02 / Doc 23 | Go daemon receiving RTSP streams and decoding video frames before dispatching to AI. | **`REMOVE`** | Architecturally defective (`ADR-012`). Go has poor CGo FFmpeg bindings; streaming raw frames over gRPC saturates memory. | Completely removed. Python worker owns direct RTSP decoding. |
| **10** | **Video Ingestion & Multiplexing (`go2rtc`)** | `Industrial_AI_Surveillance_Project_Pack/docs/discovery/32_CAMERA_INTEGRATION_AND_NETWORK_SPEC.md` | Lightweight RTSP/WebRTC streamer proxying H.264/H.265 sub-streams. | `REFACTOR` | Concept is sound, but must be hardened: isolate on Docker network; proxy WebRTC via Go (`Step 4.2/4.5`). | Deploy as unexposed sidecar in internal Docker network. |
| **11** | **Valkey / Redis Cache & Queue** | Historical Docs 02, 30, 39 | Proposed in-memory queue for event routing and alert caching. | **`REMOVE`** | Unnecessary operational dependency (`ADR-013`). Replaced by PostgreSQL 16 `SKIP LOCKED` outbox + `LISTEN/NOTIFY`. | Purged from Active Set; zero Valkey containers deployed. |
| **12** | **TimescaleDB Extension** | Historical Docs 02, 23, 40 | Proposed time-series hypertable engine for metrics and detection events. | **`REMOVE`** | Excessive maintenance overhead (`ADR-013`). Event volume on PostgreSQL 16 native partitioning is fully adequate. | Purged from Active Set; use standard PostgreSQL 16. |
| **13** | **MinIO S3 Object Storage** | Historical Docs 02, 32 | Proposed S3-compatible object store for event snapshot JPEGs and clips. | **`REMOVE`** | Complex distributed cluster unsuitable for factory edge servers. Local POSIX directory storage with date-partitioning suffices. | Purged from Active Set; use POSIX local filesystem with quota. |
| **14** | **Database & Persistence (PostgreSQL 16)** | `02_TARGET_ARCHITECTURE.md` | Standard relational database with table RLS, outbox queue, and full site-isolation. | **`NOT IMPLEMENTED`** | Schema specified in Target Architecture, but zero migration files or running instances. | Implement in Sprint 1 (`WP-2`) using goose migrations and Docker. |
| **15** | **AI Inference Engine (`py-worker`)** | `Industrial_AI_Surveillance_Project_Pack/ai/04_VIDEO_AI_SPEC.md` | Python worker pulling RTSP sub-streams, running ONNX Runtime, and emitting protobuf events. | **`NOT IMPLEMENTED`** | Zero Python AI worker scripts exist in repo. | Implement in Sprint 1 (`WP-2` / `WP-4`) with ONNX Runtime CPU. |
| **16** | **TensorRT / YOLOv8 Pipeline** | Historical Docs 04, 23, 28 | Proposed TensorRT FP16 inference on Ultralytics YOLOv8. | **`REMOVE`** | Severe licensing and hardware failure: Ultralytics is AGPL-3.0; factory servers have 0 GPUs; host has only Quadro P600. | Purged. Replaced by permissive ONNX Runtime CPU baseline. |
| **17** | **Candidate AI Models (YOLOX, RT-DETR, ByteTrack)** | `Industrial_AI_Surveillance_Project_Pack/docs/ai/MODEL_REGISTER.md` | Object detection and tracking models for restricted zone intrusion and safety hazards. | **`NOT VERIFIED`** | Models cataloged but marked `UNVERIFIED` pending weights and dataset license verification. Zero weights downloaded. | Download and evaluate Apache-2.0 / MIT weights during `SPK-02-LOCAL`. |
| **18** | **Pose & Fall Detection Model (RTMPose)** | `docs/ai/MODEL_REGISTER.md` | 2D skeleton pose estimation for worker fall/collapse detection. | **`NOT VERIFIED`** | No weights downloaded; commercial dataset license unverified. | Evaluate via local synthetic media benchmark before adoption. |
| **19** | **Face Recognition Model (InsightFace / ArcFace)** | Historical Docs 04, 23, 35 | Proposed facial embedding comparison for employee attendance verification. | **`REMOVE`** | Prohibited. InsightFace non-commercial research clause violates zero-cost commercial licensing; Egyptian Law 151/2020 legal block. | Zero face recognition in dev baseline; marked `NOT APPROVED`. |
| **20** | **ZKTeco Biometric Photo Extraction** | Protocol in Doc 35 / Doc 38 (`SPK-01`) | Direct TCP/push query to ZKTeco terminal to retrieve RGB employee enrollment photos. | **`NOT AUTHORIZED`** | Real hardware contact strictly prohibited without owner authorization (`BLK-001`). Zero code executed. | Awaiting owner authorization for `SPK-01` on 1 test device. |
| **21** | **SQL Server Attendance DB Sync** | Query plan in Doc 38 (`SPK-04`) | Read-only periodic ETL query extracting punch logs from BNF staging SQL Server backup. | **`NOT AUTHORIZED`** | Production database contact strictly prohibited (`OQ-005`). Staging query plan documented only. | Awaiting owner authorization for `SPK-04` on staging backup. |
| **22** | **Factory Camera / NVR Fleet Access** | Integration spec in Doc 32 (`SPK-03`) | RTSP sub-stream pulling from BNF/RNF Dahua, Hikvision, and Tiandy NVRs. | **`NOT AUTHORIZED`** | Real camera contact strictly prohibited (`BLK-003`). Test switch spec defined only. | Awaiting owner authorization for `SPK-03` on 1 test NVR. |
| **23** | **WireGuard Multi-Site VPN** | Security spec in `security/05_SECURITY_PRIVACY_AND_ACCESS.md` | Point-to-point encrypted tunnel between BNF, RNF, and authorized HQ management console. | **`NOT IMPLEMENTED`** | Architecture designed; zero network configurations or keys generated. | Configure in Phase 9 factory acceptance deployment. |
| **24** | **Push Notification Service (FCM)** | Notification spec in Doc 30 / Doc 39 | Google Firebase Cloud Messaging for Android push delivery. | **`NOT AUTHORIZED`** | Cloud dependency unapproved (`DEC-08`). ADR-017 defines WebSocketChannel as default; FCM disabled. | Implement WebSocket default; implement FCM adapter disabled. |
| **25** | **Coverage Lost Alerting (`NFR-OBS-002`)** | SRS `NFR-OBS-002`, `ADR-017` | Heartbeat watcher generating alerts when a camera or worker ceases sending telemetry. | **`NOT IMPLEMENTED`** | Requirement added to SRS; zero monitoring worker code. | Implement as core daemon background loop in Sprint 1 (`WP-2`). |
| **26** | **Integrity Verification Script** | `Industrial_AI_Surveillance_Project_Pack/verify_archive_manifest.py` | Python script verifying physical file bytes against root `MANIFEST.sha256`. | `KEEP` | Functional, cross-platform integrity utility. | Retain and run at each phase boundary. |

---

## 3. Summary of Component Classifications

```text
┌────────────────────────────────────────────────────────────────────────┐
│ SUMMARY OF COMPONENT CLASSIFICATIONS (26 SUBSYSTEMS AUDITED)           │
├──────────────────────────┬───────┬─────────────────────────────────────┤
│ Classification Category  │ Count │ Key Subsystems Included             │
├──────────────────────────┼───────┼─────────────────────────────────────┤
│ KEEP                     │   4   │ Charter, 97-Req SRS, CSV, Manifest  │
│ REFACTOR                 │   2   │ Decision Register, go2rtc sidecar   │
│ REBUILD                  │   0   │ (No code exists to rebuild directly)│
│ REMOVE                   │   7   │ React, Valkey, Timescale, MinIO,    │
│                          │       │ TensorRT/YOLOv8, InsightFace, GoDec │
│ NOT IMPLEMENTED          │   8   │ Flutter Web, Flutter Android,       │
│                          │       │ Go edged, py-worker, PostgreSQL 16, │
│                          │       │ WireGuard, NFR-OBS-002, Outbox      │
│ NOT VERIFIED             │   2   │ Candidate Detectors, RTMPose        │
│ NOT AUTHORIZED           │   3   │ SPK-01 (ZKTeco), SPK-03 (NVRs),     │
│                          │       │ SPK-04 (SQL Server)                 │
└──────────────────────────┴───────┴─────────────────────────────────────┘
```

This classification provides absolute clarity: we are **not destroying any working code** because zero application code currently exists. Our re-engineering effort is a **clean-room implementation** based on the ratified Active Set specifications, pruned of obsolete and unworkable historical ideas.
