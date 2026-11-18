# MASTER RE-ENGINEERING PLAN
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Canonical Strategic Roadmap & Multi-Phase Engineering Master Plan  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Standard:** Section 11 through Section 22 of Ultimate Master Directive (`Prompt.md`)  
**Date:** 2026-11-18  

---

## 1. Master Strategic Principles & Lifecycle Framework

The Industrial AI Surveillance Platform is an on-premises, multi-site edge computing system engineered for Egyptian manufacturing facilities (BNF and RNF). It must operate continuously under challenging factory conditions (network dropouts, dust, electrical surges, high ambient heat, heterogeneous camera fleets, and strict regulatory isolation).

### Non-Negotiable Engineering Governance:
1. **Evidence-Based Progression:** No phase, sprint, or work package may be declared complete without physical, reproducible verification evidence (test outputs, benchmark reports, cryptographic manifests).
2. **Strict Phase Gating:** Work proceeds strictly one phase at a time. Completion of Phase N requires satisfying all objective exit criteria and obtaining explicit owner sign-off before commencing Phase N+1.
3. **Controlled Multi-Agent Workstreams:** Development is organized into 7 specialized engineering workstreams under one Lead Architect. Parallel execution is permitted only within isolated workstreams with disjoint write scopes.
4. **Local-Dev vs. Production Bifurcation:** Local development on synthetic/simulated media is authorized (`OWNER_AUTHORIZATION_LOCAL_DEV.md`). Physical factory device contact (cameras, NVRs, ZKTeco terminals, production SQL Server databases) and production deployment remain strictly blocked pending formal owner and legal approvals (`DEC-03`..`DEC-08`).

---

## 2. Multi-Agent Workstream Organization

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ LEAD PRINCIPAL ARCHITECT & PRODUCT DIRECTOR (Antigravity)                                              │
│ - Single point of architectural authority, requirements traceability, and cross-workstream gates       │
├──────────────────┬──────────────────┬──────────────────┬──────────────────┬────────────────────────────┤
│ Workstream A:    │ Workstream B:    │ Workstream C:    │ Workstream D:    │ Workstream E:              │
│ Product & SRS    │ UX/UI & Design   │ Backend & Data   │ AI & Video       │ Unified Client             │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┼────────────────────────────┤
│ - Scope boundary │ - Design system  │ - Go Clean Arch  │ - RTSP ingestion │ - Flutter Android          │
│ - 97 SRS Reqs    │ - High-density   │ - PostgreSQL 16  │ - ONNX Runtime   │ - Flutter Web Admin        │
│ - Decision gates │   operator UI    │ - RLS isolation  │ - YOLOX/RT-DETR  │ - WebRTC low-latency       │
│ - Traceability   │ - Screen specs   │ - Outbox queue   │ - ByteTrack      │ - Live event triage        │
├──────────────────┴──────────────────┼──────────────────┴──────────────────┴────────────────────────────┤
│ Workstream F: Security & Compliance │ Workstream G: QA, Verification & Production Readiness            │
├─────────────────────────────────────┼──────────────────────────────────────────────────────────────────┤
│ - Egyptian Law 151/2020 compliance  │ - Automated test suite (Unit, API, RLS, E2E)                     │
│ - Open source license audits        │ - 30-minute soak testing & memory leak detection (<10% RSS growth)│
│ - Zero-trust network & WireGuard    │ - Factory acceptance testing (FAT) & Disaster Recovery runbooks  │
└─────────────────────────────────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Comprehensive Phase-by-Phase Roadmap (Phase 0 to Phase 9)

---

### PHASE 0 — Complete Project Assessment & Governance Stabilization
- **Status:** **`ACTIVE & COMPLETE` (Deliverables generated; awaiting Owner Sign-Off)**
- **Objective:** Forensic repository audit, toolchain verification, elimination of obsolete stack components, creation of authoritative Phase 0 deliverables, and clean-room planning.
- **Governing Directives:** `Prompt.md` §12, `CTO_DIRECTIVES_EN.md`, `OWNER_AUTHORIZATION_LOCAL_DEV.md`.
- **Deliverables:**
  1. `docs/reengineering/PROJECT_REENGINEERING_ASSESSMENT.md`
  2. `docs/reengineering/EXISTING_SYSTEM_CAPABILITY_MATRIX.md`
  3. `docs/reengineering/REBUILD_VS_REFACTOR_DECISIONS.md`
  4. `docs/reengineering/MASTER_REENGINEERING_PLAN.md`
  5. `docs/engineering/SKILL_USAGE_MATRIX.md`
  6. `docs/design/PROPOSED_PRODUCT_UX_BLUEPRINT.md`
  7. `docs/reengineering/SRS_GAP_AND_REQUIREMENTS_CLOSURE_PLAN.md`
  8. `docs/reengineering/ARCHITECTURE_AND_INTEGRATION_GAP_REVIEW.md`
  9. `docs/quality/QUALITY_AND_VERIFICATION_STRATEGY.md`
  10. `docs/operations/PRODUCTION_READINESS_PLAN.md`
  11. `docs/reengineering/PHASE_ACCEPTANCE_REGISTER.md`
  12. `PROJECT_HANDOFF.md`
- **Exit Criteria:**
  - [x] Zero application source code confirmed (clean-room state).
  - [x] Host hardware capabilities empirically measured (Xeon E-2236, Quadro P600 4GB VRAM, 15.69 GB RAM).
  - [x] Toolchain inventory verified (Python 3.14.4, Flutter 3.44.7, Docker 29.8.0 on host; Go containerized).
  - [x] Obsolete stack removed (Valkey, TimescaleDB, React/Vite, MinIO, TensorRT/YOLOv8, InsightFace).
  - [x] All 11 authoritative Phase 0 deliverables written without duplication.
  - [x] `PROJECT_HANDOFF.md` updated with exact empirical findings.
- **Go / No-Go Gate:** Submission of Phase 0 Final Review to Owner. No code execution before Owner review.

---

### PHASE 1 — Complete Product Requirements & SRS Baseline
- **Status:** **`PREPARED & GATED` (Baseline exists; awaiting Owner DEC-01 formal ratification)**
- **Objective:** Finalize the 97-requirement baseline (`01_SRS.md`), resolve the 14 quantitative acceptance criteria gaps, and establish formal closure pathways for all 36 unresolved requirements.
- **Governing Directives:** `Prompt.md` §13, `requirements/01_SRS.md`, `planning/09_REQUIREMENTS_TRACEABILITY.csv`.
- **Deliverables:**
  1. Updated `requirements/01_SRS.md` with explicit quantitative thresholds.
  2. Updated `planning/09_REQUIREMENTS_TRACEABILITY.csv` with verification test references.
  3. Formal resolution logs for `DEC-03` (photo fallback) and `DEC-07` (daily cutoff).
- **Exit Criteria:**
  - 100% of functional requirements have defined preconditions, main flows, and failure states.
  - Zero ambiguous quantitative metrics (e.g. replacing "real-time" with "p95 < 500ms").
  - Owner sign-off on `DEC-01` baseline.
- **Go / No-Go Gate:** Gate 1 Review — Approved SRS Baseline required before technical design freeze.

---

### PHASE 2 — Technical Architecture, Hardened Contracts & Workstation Skeleton (`WP-2`)
- **Status:** **`LOCAL-DEV AUTHORIZED` (Awaiting kickoff)**
- **Objective:** Construct the repository skeleton, Docker development environment (WSL2 / Docker Engine), PostgreSQL 16 schema with hardened RLS, and Protobuf v1 event contracts.
- **Governing Directives:** `Prompt.md` §14, `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Steps 2.1–2.6.
- **Work Package Mapping:** `WP-2` (Workstation Measurement, Repo Skeleton & Hardened Contracts).
- **Deliverables:**
  1. `.wslconfig` and Docker Compose stack (`docker-compose.yml`: `postgres`, `edged`, `py-worker`, `go2rtc`).
  2. Protocol Buffer definition `proto/surveillance/v1/events.proto` (strictly zero raw frames).
  3. PostgreSQL 16 migration scripts (`migrations/001_initial_schema.sql`): RLS enabled + forced, composite FKs `(site_id, camera_id)`, transactional outbox table with lease recovery.
  4. Go backend service skeleton (`backend/cmd/edged/`, Clean Architecture layers).
  5. Python AI worker skeleton (`services/py-worker/`, gRPC server/client, RTSP subprocess harness).
  6. Synthetic test video generator (`scripts/generate_synthetic_streams.py`).
  7. Automated verification script `tests/verify_wp2_skeleton.py`.
- **Exit Criteria:**
  - `docker compose up -d` boots healthy within 30 seconds.
  - `make ci && make test` passes green.
  - Idle stack consumes < 2.5 GB host RAM.
  - RLS negative security tests prove tenant isolation fails closed.
- **Go / No-Go Gate:** Gate 2 Review — Verified runnable skeleton required before benchmarking or AI model loading.

---

### PHASE 3 — Empirical Local Benchmark & Hardware Capacity Sizing (`WP-3` / `SPK-02-LOCAL`)
- **Status:** **`LOCAL-DEV AUTHORIZED` (Awaiting kickoff)**
- **Objective:** Empirically benchmark video decoding, frame sampling, and ONNX Runtime inference latency on the owner's workstation using synthetic/public video. Size production edge server BOM based on measured metrics.
- **Governing Directives:** `Prompt.md` §16, `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Steps 3.1–3.4.
- **Work Package Mapping:** `WP-3` (`SPK-02-LOCAL`).
- **Deliverables:**
  1. Benchmark execution harness (`scripts/benchmark_onnx_pipeline.py`).
  2. Measured inference latency report across candidate models (YOLOX-S, RT-DETR-R18, ByteTrack).
  3. Multi-rate frame sampling policy verification (0.5–2.0 FPS).
  4. Production Edge Server Bill of Materials (BOM) proposal based on measured per-stream CPU/GPU footprint.
- **Exit Criteria:**
  - Zero unverified or hallucinated performance figures in reports.
  - Sustained processing of 4–8 simulated 1080p camera channels under < 5 GB RAM.
  - Measured p50/p95/p99 per-frame inference latency recorded on raw disk files.
- **Go / No-Go Gate:** Gate 3 Review — Owner approval of measured benchmark and server procurement sizing.

---

### PHASE 4 — Vertical Slice #1: Restricted Area Intrusion & Security Blueprints (`WP-4`)
- **Status:** **`LOCAL-DEV AUTHORIZED` (Awaiting kickoff)**
- **Objective:** Implement complete end-to-end vertical slice for restricted zone intrusion detection (`FR-AI-001`) integrating synthetic RTSP -> Python AI Worker -> Protobuf -> Go Backend -> PostgreSQL RLS -> Transactional Outbox -> WebSocket alert delivery. Enforce all 6 forensic security blueprints.
- **Governing Directives:** `Prompt.md` §17 & §18, `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Steps 4.1–4.7.
- **Work Package Mapping:** `WP-4` (Vertical Slice #1 + 6 Security Hardening Blueprints).
- **Deliverables:**
  1. Go backend event handler with outbox lease-reaper background worker (`Step 4.4`).
  2. Zero-trust authenticated WebRTC SDP proxy hiding `go2rtc` on internal network (`Step 4.2/4.5`).
  3. Single-use site-bound WebSocket ticket authentication (`POST /api/v1/sites/{site_id}/ws-ticket`).
  4. Python AI worker with RTSP regex allowlist, credential scrubbing, and gRPC interceptors (`Step 4.3`).
  5. Automated failure-injection tests (`tests/verify_failure_injection.py`: mid-dispatch crash recovery, zero duplicate alerts, zero lost fire alerts).
- **Exit Criteria:**
  - End-to-end latency from synthetic violation to WebSocket alert delivery < 500ms p95.
  - Outbox recovery daemon successfully claims and dispatches abandoned batches after worker SIGKILL.
  - Cross-site negative penetration tests prove Site BNF cannot receive Site RNF WebSocket alerts or read cameras.
- **Go / No-Go Gate:** Gate 4 Review — Verified resilient backend data plane required before client UI implementation.

---

### PHASE 5 — Unified Flutter Client MVP: Android & Web Admin (`WP-5`)
- **Status:** **`LOCAL-DEV AUTHORIZED` (Awaiting kickoff)**
- **Objective:** Implement the unified Flutter client codebase (`ADR-014`) targeting Android handheld devices and Web desktop browsers.
- **Governing Directives:** `Prompt.md` §15 & §19, `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Steps 5.1–5.3.
- **Work Package Mapping:** `WP-5` (Unified Flutter Client MVP).
- **Deliverables:**
  1. Flutter multi-platform project (`client/`): shared domain models, repositories, and BLoC state managers.
  2. Web Admin Console screens (Live Camera Wall, Incident Center, System Diagnostics, Site Switcher).
  3. Android Handheld screens (Urgent Alert Notification Feed, Low-latency WebRTC live stream, Incident Action Sheet).
  4. NotificationChannel port implementation (WebSocket default, FCM disabled adapter per `ADR-017`).
  5. Mobile 30-minute screen-off background heartbeat and notification reception test.
- **Exit Criteria:**
  - `flutter build web` and `flutter build apk` compile without errors or warnings.
  - Live video streams render smoothly via WebRTC without frame tearing.
  - Incident resolution workflow (`FR-ALT-008`: NEW -> ACKNOWLEDGED -> RESOLVED) operates reliably.
- **Go / No-Go Gate:** Gate 5 Review — Functional client operational demonstration on simulated data.

---

### PHASE 6 — Shadow-Mode AI Safety Use Cases (`WP-6`)
- **Status:** **`LOCAL-DEV AUTHORIZED` (Awaiting kickoff)**
- **Objective:** Incrementally introduce additional computer vision use cases, one model at a time, evaluated in shadow mode against public/synthetic test datasets.
- **Governing Directives:** `Prompt.md` §18, `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` Steps 6.1–6.3.
- **Work Package Mapping:** `WP-6` (Shadow-Mode AI Use Cases).
- **Deliverables:**
  1. PPE Compliance detection module (`FR-AI-002`: helmet and safety vest detection).
  2. Worker fall and collapse detection module (`FR-AI-003`: 2D skeleton pose estimation via RTMPose).
  3. Fire and smoke visual anomaly detection module (`FR-AI-005`: auxiliary alert path without triage delay).
  4. Phone usage in restricted equipment zones (`FR-AI-006`).
  5. Dataset and weights provenance audit reports for every adopted model.
- **Exit Criteria:**
  - Every model licensed under permissive commercial terms (Apache-2.0, MIT, BSD). Zero AGPL or non-commercial research models.
  - False positive and false negative rates evaluated on labeled test sets.
  - Total inference memory per stream fits within measured workstation/server limits.
- **Go / No-Go Gate:** Gate 6 Review — Model accuracy and stability sign-off before physical integration.

---

### PHASE 7 — Physical Device Integration & Factory Spikes
- **Status:** **`STRICTLY BLOCKED & NOT AUTHORIZED` (Requires explicit Owner & Legal Sign-off)**
- **Objective:** Connect to isolated physical test equipment in staging environments to validate real-world protocols.
- **Governing Directives:** `Prompt.md` §16 & §25.
- **Dependencies & Prerequisites:**
  - Owner authorization of `SPK-01` (ZKTeco photo retrieval on 1 isolated test terminal).
  - Owner authorization of `SPK-03` (RTSP multiplexing on 1 test NVR and 2 test cameras on an isolated switch).
  - Owner authorization of `SPK-04` (read-only punch log ETL on BNF staging SQL Server backup).
  - Egyptian Law 151/2020 legal review clearance (`DEC-06`).
- **Deliverables:**
  1. `SPK-01` execution report: confirmed capability of ZKTeco terminals to export RGB enrollment photos.
  2. `SPK-03` execution report: confirmed concurrent sub-stream limits across Dahua, Hikvision, and Tiandy NVRs.
  3. `SPK-04` execution report: verified read-only SQL Server schema and staging sync latency.
- **Exit Criteria:**
  - Empirical protocol compatibility confirmed on actual hardware.
  - Zero disruption to active factory operations.
- **Go / No-Go Gate:** Gate 7 Review — Hardware integration clearance.

---

### PHASE 8 — Quality Engineering, Failure Injection & Security Hardening
- **Status:** **`PLANNED`**
- **Objective:** Execute comprehensive, end-to-end automated quality, load, resilience, and penetration testing across all subsystems.
- **Governing Directives:** `Prompt.md` §20.
- **Deliverables:**
  1. 30-minute continuous soak test report (< 10% RSS memory growth across Go, Python, and PostgreSQL).
  2. Chaos / failure injection test suite: edge server reboot recovery, camera disconnect/reconnect recovery, database connection dropouts.
  3. Penetration testing report: RLS bypass attempts, WebSocket hijacking, gRPC injection.
  4. Software Bill of Materials (SBOM) and automated license scan (0 copyleft components).
- **Exit Criteria:**
  - Zero open critical or high-severity vulnerabilities.
  - 100% of the 97 SRS requirements traced to executable automated or manual tests.
  - Zero lost or duplicated notifications under simulated crash conditions.
- **Go / No-Go Gate:** Gate 8 Review — Security & Stability Sign-off.

---

### PHASE 9 — Production Deployment, Factory Acceptance (FAT) & DR
- **Status:** **`PLANNED`**
- **Objective:** On-premises installation, commissioning, operational training, backup/disaster recovery validation, and 14-day production pilot across BNF and RNF.
- **Governing Directives:** `Prompt.md` §21 & §22.
- **Dependencies & Prerequisites:**
  - Factory edge server and GPU procurement (`OQ-011`).
  - Owner submission of verified alert recipient rosters (`DEC-05`).
  - Egyptian legal compliance registration (`DEC-06`).
  - Owner sign-off on auxiliary fire notification status (`DEC-04`).
- **Deliverables:**
  1. Factory Acceptance Testing (FAT) evidence reports for BNF and RNF.
  2. Automated daily backup and disaster recovery test evidence (< 15-minute recovery time objective).
  3. Operator and administrator runbooks, troubleshooting guides, and incident escalation protocols.
  4. Final Production Readiness Sign-off Certificate.
- **Exit Criteria:**
  - Zero open P0/P1 defects.
  - Continuous 14-day error-free pilot operation at BNF and RNF.
  - Local edge servers operate autonomously during simulated 48-hour WAN/VPN disconnects.
- **Go / No-Go Gate:** Final Executive Sign-Off — Transition to production maintenance.

---

## 4. Work Package Execution Schedule & Checkpoints

```text
====================================================================================================
WP-0   | Pack Documentation Remediation (Canonical Numbers, Supersession Banners) | COMPLETED
WP-0.5 | Pack Hotfix & Governance Deadlock Resolution                            | COMPLETED
WP-1   | Architecture Amendments (ADR-012..017 Ratification, 97 Reqs Aligned)   | COMPLETED
-------+-------------------------------------------------------------------------+------------------
PHASE 0| Complete Project Assessment & Authoritative Discovery Deliverables      | COMPLETE (REVIEW)
-------+-------------------------------------------------------------------------+------------------
WP-2   | Workstation Measurement, Repo Skeleton, Docker Stack & Hardened RLS     | READY TO START
WP-3   | Empirical Local Benchmark (SPK-02-LOCAL) & Server Sizing Proposal       | GATED ON WP-2
WP-4   | Vertical Slice #1 (Intrusion Detection, Outbox, 6 Security Blueprints)   | GATED ON WP-3
WP-5   | Unified Flutter Client MVP (Android Handheld & Web Admin Console)       | GATED ON WP-4
WP-6   | Shadow-Mode AI Safety Models (PPE, RTMPose Falls, Fire Fast-Path)       | GATED ON WP-5
-------+-------------------------------------------------------------------------+------------------
SPIKES | Physical Test Hardware Integration (SPK-01, SPK-03, SPK-04)             | GATED ON OWNER
PROD   | Factory Acceptance Testing (FAT), Legal Filing & Production Commissioning| GATED ON HARDWARE
====================================================================================================
```
