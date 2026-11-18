# REBUILD VS. REFACTOR DECISIONS
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Architectural Justification & Technical Removal Register  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Standard:** Section 7 of Ultimate Master Directive (`Prompt.md`)  
**Date:** 2026-11-18  

---

## 1. Overview & Decision Framework

The Ultimate Master Directive mandates that before discarding or rebuilding any component, the engineering team must document the technical evidence, defects, risks, dependencies, security impact, migration path, and rollback strategy.

Because the current repository contains **zero lines of executable application code**, these decisions govern **specification-level architectural removals and redesigns**, ensuring that no time, tokens, or compute are wasted implementing obsolete, dangerous, or unmaintainable architectural dead-ends.

---

## 2. Detailed Removal & Replacement Register

---

### DECISION REM-01: Removal of React / Vite Web Admin Console in Favor of Flutter Web

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | Web Administration Console (`frontend-web` / React + Vite + Tailwind) |
| **Action** | **`REMOVE`** (Purge React from Active Set; replace with Flutter Web per `ADR-014`) |
| **Exact Technical Reason** | Maintaining two independent frontend client ecosystems (React/TypeScript for Web + Flutter/Dart for Android) creates massive code duplication, dual state management implementations, duplicate WebSocket/WebRTC client libraries, and doubles ongoing maintenance and testing overhead for a small engineering team. |
| **Current Behavior** | Described in historical specification documents (Docs 01, 02, 10, 23); zero code exists in repository. |
| **Known Defects** | Dual API contract drift, disjoint authentication session handling, inability to share models or business logic between mobile and web. |
| **Dependencies** | Node.js, npm/pnpm, Vite, React 18/19, Tailwind, Lucide icons, separate web testing harnesses (Jest/Playwright). |
| **Migration Impact** | Zero code migration needed (no React code exists). Client engineering consolidates 100% on Flutter (Dart). |
| **Data Compatibility** | Full compatibility. Both clients consume the identical Go REST, WebSocket, and WebRTC backend contracts. |
| **Security Impact** | Positive. Eliminates hundreds of transitive npm dependencies (reducing supply chain vulnerabilities) and centralizes auth token storage logic in a single Dart client library. |
| **Replacement Design** | **Unified Flutter Client (`ADR-014`):** A single Flutter multi-platform codebase targeting Android (handheld apk) and Web (desktop responsive admin console). Shares 100% of domain models, state management (BLoC/Cubit), API clients, and WebRTC streaming logic. |
| **Rollback Strategy** | If Flutter Web fails browser performance benchmarks for the live video grid, the Go backend maintains standard REST/WebSocket endpoints that can be consumed by any future web frontend without backend modifications. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md` (DEC-02). |

---

### DECISION REM-02: Removal of Go Video Decoding in Favor of Python-Worker Direct Decoding

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | Backend Video Decoding Layer (`edged` Go frame decoder) |
| **Action** | **`REMOVE`** (Purge Go decoding from Target Architecture; assign direct decode to Python worker per `ADR-012`) |
| **Exact Technical Reason** | Go lacks mature, memory-safe, hardware-accelerated video decoding libraries. CGo FFmpeg bindings introduce high cgo call overhead, memory leak risks, and compilation fragility across operating systems. Furthermore, decoding in Go and transferring raw uncompressed video frames (1920×1080 RGB24 = ~6 MB per frame) over gRPC to Python AI workers saturates localhost bandwidth, spikes CPU cache thrashing, and exhausts workstation RAM. |
| **Current Behavior** | Described in historical architecture documents (Doc 02); zero code implemented. |
| **Known Defects** | High serialization overhead, gRPC payload message size limits, high memory consumption, complex multi-step pipeline failure modes. |
| **Dependencies** | CGo, libavcodec, libavformat, libswscale on Go build host. |
| **Migration Impact** | Clean architectural boundary. Go remains pure, fast, statically compiled orchestration, auth, and persistence. |
| **Data Compatibility** | High. The protobuf contract between Go and Python (`proto/surveillance/v1/events.proto`) transfers only metadata, timestamps, bounding boxes, and relative JPEG snapshot file paths—zero raw pixel bytes. |
| **Security Impact** | Positive. Removes complex CGo memory management from the privileged Go backend daemon; isolates video codec execution inside sandboxed Python worker containers. |
| **Replacement Design** | **Worker Direct RTSP Ingestion (`ADR-012`):** Python AI workers pull camera sub-streams directly via OpenCV / FFmpeg subprocess, decode frames directly into memory buffers, sample frames at required detection intervals, run ONNX inference, and emit structured event messages to Go over gRPC. |
| **Rollback Strategy** | If Python RTSP ingestion experiences stream dropouts, `go2rtc` can act as the local RTSP/WebRTC rebroadcaster on the internal Docker network. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/CTO_AMENDMENTS.md` (`ADR-012`). |

---

### DECISION REM-03: Removal of Valkey / Redis in Favor of PostgreSQL 16 Native Outbox & LISTEN/NOTIFY

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | In-Memory Message Broker & Cache (Valkey / Redis) |
| **Action** | **`REMOVE`** (Purge Valkey container from Docker stack; use PostgreSQL 16 outbox per `ADR-013`) |
| **Exact Technical Reason** | Adding an in-memory key-value store (Valkey) introduces an additional stateful daemon to maintain, backup, monitor, and size on factory edge servers. In an on-premises industrial system generating ~1–10 events/minute per factory, introducing distributed transactions (two-phase commit between PostgreSQL and Valkey) creates split-brain risks, zombie alert locks, and message loss on edge crashes. |
| **Current Behavior** | Proposed in historical Docs 02, 30, 39; zero containers deployed. |
| **Known Defects** | Dual-write problem: if PostgreSQL transaction commits but Valkey publish fails (or vice versa), event state becomes permanently inconsistent. |
| **Dependencies** | Valkey container image, redis-cli, Go `go-redis` client, memory allocation. |
| **Migration Impact** | Eliminates one container service from `docker-compose.yml`, reducing idle RAM consumption by ~150–250 MB. |
| **Data Compatibility** | Complete transactional atomicity. Event creation and outbox queuing occur within a single ACID SQL transaction (`BEGIN ... INSERT INTO events ... INSERT INTO outbox ... COMMIT;`). |
| **Security Impact** | Positive. Eliminates unauthenticated or password-based TCP port 6379 from local network surface. |
| **Replacement Design** | **PostgreSQL 16 Transactional Outbox (`ADR-013`):** 
1. Database table `outbox` with columns `(id, event_id, site_id, payload, status, locked_until, created_at)`.
2. Dispatcher workers claim batches using `SELECT ... FOR UPDATE SKIP LOCKED`.
3. Urgent fire alerts use dedicated connection listening on `LISTEN outbox_fire`.
4. Expired lease reaper query automatically recovers crashed worker batches (`locked_until < NOW()`). |
| **Rollback Strategy** | Standard database table schema. If throughput ever requires distributed streaming (e.g. 100,000 events/sec), an external broker could be inserted in front of the outbox reader without altering application domain logic. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/CTO_AMENDMENTS.md` (`ADR-013`). |

---

### DECISION REM-04: Removal of TimescaleDB in Favor of Native PostgreSQL 16 Partitioning

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | Time-Series Database Extension (TimescaleDB) |
| **Action** | **`REMOVE`** (Purge TimescaleDB extension; use standard PostgreSQL 16 per `ADR-013`) |
| **Exact Technical Reason** | TimescaleDB is a complex C extension that complicates database upgrades, requires proprietary tuning parameters (`timescaledb-tune`), introduces specialized backup constraints with `pg_dump`, and adds licensing ambiguity. Industrial safety event volume (~5,000–20,000 events/month per factory) is trivial for standard PostgreSQL. |
| **Current Behavior** | Mentioned in historical architectural diagrams; zero databases running. |
| **Known Defects** | Complex upgrade paths between major PostgreSQL versions; incompatible with standard lightweight Alpine/Debian PostgreSQL containers without custom image builds. |
| **Dependencies** | Custom `timescale/timescaledb` Docker image, shared_preload_libraries. |
| **Migration Impact** | Simplifies deployment to standard official `postgres:16-alpine`. |
| **Data Compatibility** | Full relational compatibility. Detection events use standard timestamp indexes `(site_id, created_at DESC)` and native declarative range partitioning if table exceeds 10M rows. |
| **Security Impact** | Positive. Standard PostgreSQL container has rapid CVE patching and minimal surface. |
| **Replacement Design** | **Standard PostgreSQL 16 (`ADR-013`):** Single `events` table with standard B-tree index on `(site_id, created_at)` and partial index on unacknowledged alerts `WHERE acknowledged_at IS NULL`. |
| **Rollback Strategy** | If long-term analytics query performance degrades after 2 years of data accumulation, native monthly table partitioning (`PARTITION BY RANGE (created_at)`) can be attached without downtime. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/CTO_AMENDMENTS.md` (`ADR-013`). |

---

### DECISION REM-05: Removal of MinIO S3 Storage in Favor of Local POSIX Directory Storage

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | S3-Compatible Object Storage Service (MinIO) |
| **Action** | **`REMOVE`** (Purge MinIO from architecture; store snapshot JPEGs directly on local POSIX filesystem) |
| **Exact Technical Reason** | MinIO is licensed under GNU AGPL-3.0, creating strict copyleft licensing risks for proprietary enterprise systems. Furthermore, running an S3-compatible HTTP object store on an on-premises single-node factory server introduces unnecessary HTTP overhead, credential management, bucket provisioning logic, and memory usage just to store 100 KB event snapshot JPEG files. |
| **Current Behavior** | Proposed in historical Docs 02, 32; zero instances deployed. |
| **Known Defects** | AGPL-3.0 copyleft license viral risk; memory consumption (>500 MB RAM idle); port proliferation (9000, 9001). |
| **Dependencies** | MinIO Docker image, AWS S3 Go/Python SDKs, S3 access keys. |
| **Migration Impact** | Eliminates MinIO container from Docker stack; saves ~300 MB host RAM. |
| **Data Compatibility** | Event snapshots are saved to `/var/lib/surveillance/snapshots/{site_id}/{YYYY}/{MM}/{DD}/{event_id}.jpg`. Database stores only relative string path `snapshots/{site_id}/...`. |
| **Security Impact** | High positive impact: Eliminates AGPL-3.0 legal risk completely; restricts file access to OS filesystem permissions and authenticated Go static file endpoints. |
| **Replacement Design** | **Local POSIX Snapshot Storage:**
1. Direct file write by Python worker into site-jailed directory path.
2. Go backend serves snapshots via authenticated endpoint `GET /api/v1/sites/{site_id}/events/{event_id}/snapshot` with RBAC check.
3. Automated cron/reaper prunes snapshot files older than retention policy (e.g., 90 days). |
| **Rollback Strategy** | Storage abstraction in Go (`type SnapshotStore interface`) allows swapping POSIX implementation with an S3 adapter in the future if cloud/central archiving is authorized. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/CTO_AMENDMENTS.md`. |

---

### DECISION REM-06: Removal of TensorRT & Ultralytics YOLOv8 in Favor of ONNX Runtime CPU/CUDA

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | Deep Learning Inference Stack (TensorRT + Ultralytics YOLOv8) |
| **Action** | **`REMOVE`** (Purge TensorRT and YOLOv8; establish ONNX Runtime CPU baseline per `ADR-016`) |
| **Exact Technical Reason** | Ultralytics YOLOv8 is strictly licensed under AGPL-3.0, prohibiting proprietary closed-source deployment without purchasing commercial licenses. Additionally, existing factory edge servers have **zero GPUs**, and TensorRT cannot run without dedicated modern NVIDIA hardware. TensorRT also introduces brittle driver-coupled engine compilation and gigabytes of CUDA image bloat. |
| **Current Behavior** | Claimed in historical benchmarks; zero TensorRT engines built. |
| **Known Defects** | AGPL license breach; inability to run on CPU-only factory servers; huge Docker image footprint (>12 GB). |
| **Dependencies** | NVIDIA TensorRT, CUDA toolkit, cuDNN, Ultralytics python package. |
| **Migration Impact** | Eliminates AGPL licensing hazard; standardizes inference on vendor-neutral ONNX Runtime. |
| **Data Compatibility** | Standard ONNX `.onnx` model format. Candidate models (YOLOX, RT-DETR) export natively to standard ONNX. |
| **Security Impact** | High positive impact: Eliminates severe legal compliance risk; runs on audited ONNX Runtime runtime binaries. |
| **Replacement Design** | **ONNX Runtime Baseline (`ADR-016`):**
1. Mandatory baseline: ONNX Runtime CPU (`onnxruntime`) with OpenVINO / oneDNN acceleration.
2. Optional hardware acceleration: `onnxruntime-gpu` (CUDA Execution Provider) auto-detected when compatible GPU exists.
3. Multi-rate sampling: 0.5–2.0 FPS per camera rather than brute-force 30 FPS processing, keeping CPU load predictable. |
| **Rollback Strategy** | If ONNX Runtime CPU latency exceeds 250ms on workstation benchmark, candidate models can be quantised to INT8 (`onnxruntime.quantization`) or GPU acceleration enabled. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/CTO_AMENDMENTS.md` (`ADR-016`). |

---

### DECISION REM-07: Removal of InsightFace / ArcFace Face Recognition

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | Facial Recognition & Cross-Camera Biometric Tracking Module |
| **Action** | **`REMOVE`** (Purge facial recognition from development baseline; mark `NOT APPROVED` in `MODEL_REGISTER.md`) |
| **Exact Technical Reason** | InsightFace and its standard pretrained weights (ArcFace / Glint360k) contain explicit **non-commercial research-only license clauses**, making commercial industrial use illegal without licensing agreements. Furthermore, Egyptian Data Protection Law 151/2020 classifies biometric facial identification as sensitive personal data requiring prior regulatory registration and explicit employee consent (`BLK-005`, `DEC-06`), which does not exist. |
| **Current Behavior** | Mentioned in historical SRS and architecture files; zero models deployed. |
| **Known Defects** | Non-commercial license violation; potential legal liability under Egyptian Law 151/2020; low accuracy in industrial environments (dust, masks, safety goggles, variable lighting). |
| **Dependencies** | InsightFace, ONNX ArcFace models, biometric photo databases. |
| **Migration Impact** | Attendance verification relies on proven ZKTeco hardware terminal punch logs rather than unverified camera-based face recognition. |
| **Data Compatibility** | ZKTeco attendance logs use standard employee ID, timestamp, and device ID fields. |
| **Security Impact** | Critical risk mitigation. Completely eliminates biometric privacy liability and employee surveillance legal exposure. |
| **Replacement Design** | Attendance tracking is handled via direct integration with ZKTeco attendance logs (`integrations/03_INTEGRATION_AND_DATA_SPEC.md`). Camera AI focuses on safety hazards (PPE, intrusion, falls, fire), not biometric facial identification. |
| **Rollback Strategy** | If the owner obtains explicit legal clearance (`DEC-06`) and procures commercially licensed face models in the future, face recognition can be introduced as an isolated optional plugin. |
| **Required Approval** | **OWNER APPROVED** via `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md` & `CTO_AMENDMENTS.md`. |

---

## 3. Detailed Refactoring Register

---

### DECISION REF-01: Refactoring of `go2rtc` Streaming Architecture (Zero-Trust SDP Proxy)

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | `go2rtc` Video Multiplexer & WebRTC Streamer |
| **Action** | **`REFACTOR`** (Isolate in internal Docker network; proxy WebRTC SDP via authenticated Go endpoint) |
| **Exact Technical Reason** | In default configurations, `go2rtc` exposes an unauthenticated web UI and API on port 1984. If exposed to factory networks, any operator or attacker could view camera streams, hijack control, or extract NVR plaintext RTSP credentials. |
| **Refactoring Plan** | 
1. `go2rtc.yaml` binds API only to localhost / internal Docker bridge network (`surveillance_net`).
2. Port 1984 is **never published** to the host or external network.
3. Go daemon exposes authenticated endpoint `POST /api/v1/sites/{site_id}/cameras/{camera_id}/webrtc`.
4. Go verifies user session, checks `D-011` video permissions, forwards SDP offer to `go2rtc:1984/api/webrtc?src={camera_id}`, and returns SDP answer to client. |
| **Required Approval** | Governed by `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Step 4.2 / Step 4.5. |

---

### DECISION REF-02: Refactoring of PostgreSQL Row-Level Security (Tenant Isolation Hardening)

| Dimension | Technical Analysis & Evidence |
|---|---|
| **Component Name** | PostgreSQL Multi-Site Isolation Layer |
| **Action** | **`REFACTOR`** (Enforce `FORCE ROW LEVEL SECURITY`, separate DB roles, composite foreign keys) |
| **Exact Technical Reason** | Standard PostgreSQL RLS is bypassed by table owners (`app_migrator`). If the runtime application connects using the migration role, RLS policies fail open. Additionally, single-column foreign keys (`camera_id UUID`) allow cross-site corruption (e.g. associating a BNF incident with an RNF camera). |
| **Refactoring Plan** | 
1. Separate roles: `app_migrator` (DDL owner) vs `app_runtime` (`NOBYPASSRLS`, DML only).
2. All tenant tables execute `ALTER TABLE <name> ENABLE ROW LEVEL SECURITY;` AND `ALTER TABLE <name> FORCE ROW LEVEL SECURITY;`.
3. Fail-closed policy: `USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid)`.
4. Composite foreign keys: `FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, id)`. |
| **Required Approval** | Governed by `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Step 4.1. |

---

## 4. Rebuild vs. Refactor Execution Summary

By executing these 7 removals and 2 refactorings:
- Container services required on edge servers drop from **9 to 3** (`postgres:16-alpine`, `edged`, `py-worker` + unexposed `go2rtc` sidecar).
- Programming languages required across the entire platform drop from **4 to 3** (Go for backend core, Python for AI workers, Dart for Android & Web clients).
- Idle memory consumption drops from **>5.8 GB to <2.5 GB**, fitting comfortably within the owner's 16 GB workstation and factory edge servers.
- Severe legal, licensing, and security vulnerabilities (AGPL copyleft, unauthenticated video streams, RLS bypasses, biometric privacy violations) are completely eliminated.
