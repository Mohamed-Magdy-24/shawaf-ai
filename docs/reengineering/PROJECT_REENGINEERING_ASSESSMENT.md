# PROJECT RE-ENGINEERING ASSESSMENT
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Technical Discovery & Forensic Repository Audit  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Baseline:** Ultimate Master Directive (`Prompt.md`), `AGENTS.md`, and `00_READ_ME_FIRST.md`  
**Date:** 2026-11-18  

---

## 1. Executive Summary & Audit Mission

Pursuant to the **Ultimate Master Directive** (`Prompt.md`) and the **Mandatory Skills Preflight & Global Operating Pattern** (`AGENTS.md`), this document provides an exhaustive, forensic, evidence-based technical assessment of the Industrial AI Surveillance Platform repository.

The stated business objective is to deliver an autonomous, on-premises industrial AI surveillance, occupational safety hazard detection, and attendance verification system across two manufacturing facilities in Egypt:
- **BNF (Beni Suef facility):** Autonomous local data plane, local NVR/camera fleet (~200+ cameras), dedicated ZKTeco instance, local SQL Server staging backup.
- **RNF (Sadat City facility):** Autonomous local data plane, local NVR/camera fleet (~200+ cameras), dedicated ZKTeco instance, local SQL Server staging backup.
- **Interconnection:** Fully independent factory local-area networks and data planes with secure, role-scoped WireGuard VPN site-to-site tunnels for authorized administrative access only.

### Primary Audit Findings
1. **Zero Application Code in Repository:** The active workspace contains **zero lines of application source code** (0 Go files, 0 Python application files, 0 Flutter/Dart widgets, 0 SQL migration scripts, 0 Docker compose implementations). The repository currently consists solely of documentation, specifications, audit reports, governance registers, and one archive integrity script (`verify_archive_manifest.py`).
2. **Clean-Room Baseline Established:** Historical architectural conflicts (Valkey, TimescaleDB, React/Vite, MinIO, TensorRT, YOLOv8) have been formally eliminated from the Active Set via amendments `ADR-012` through `ADR-017` and `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`.
3. **Local Dev vs. Production Bifurcation:** Local development on simulated and synthetic data is authorized (`OWNER_AUTHORIZATION_LOCAL_DEV.md`). Conversely, any access to real factory hardware (cameras, NVRs, ZKTeco terminals, SQL Server attendance databases), real employee biometrics, or production deployment remains strictly blocked pending formal owner and legal approvals (`DEC-03`..`DEC-08`, `SPK-01`, `SPK-03`, `SPK-04`).
4. **Empirical Workstation Constraints:** The development workstation is an Intel Xeon E-2236 with 16 GB RAM and an NVIDIA Quadro P600 (4 GB VRAM). This hardware is capable of benchmarking 4–8 simulated video channels under ONNX Runtime, but cannot support concurrent 200+ camera inference or heavy training workloads.

---

## 2. Repository Forensic Audit & Physical State

### 2.1 Git Branch & Commit State
- **Active Git Branch:** `industrial_ai_surveillance`
- **Working Tree State:** Clean (`nothing to commit, working tree clean`).
- **Latest Verified Commits:**
  - `f266610` — `docs(governance): reconcile handoff, purge forbidden names & update manifest sha256`
  - `a5216f8` — `WP1: reconciliation audit of WP-0 and WP-1 deliverables`
  - `fe01560` — `Merge wp-0.5-pack-hotfix into wp-1-adr-amendments`
  - `1320a1d` — `WP0.5: hotfix pack defects and governance deadlocks`
  - `ae5ae59` — `WP1: architecture amendments ADR-012..017`
  - `2e2fb33` — `WP0: rework TOOLCHAIN_PINS with live verified official sources`
  - `b58ea5b` — `WP0: repair the pack`

### 2.2 Physical File Inventory
- **Workspace Root Files:**
  - `PROJECT_HANDOFF.md` (41,692 bytes) — Canonical handoff register.
  - `ANTIGRAVITY_FIX_PROMPT.md` (37,712 bytes) — Remediation orders.
  - `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` (62,309 bytes) — Step-by-step phased execution instructions.
  - `CTO_DIRECTIVES_EN.md` (7,083 bytes) — Binding engineering mandates.
  - `Industrial_AI_Surveillance_Project_Pack/` — The primary specification package.
- **Pack Subdirectories & File Counts:**
  - `ai/` (1 file: `04_VIDEO_AI_SPEC.md`)
  - `antigravity/` (3 files: `09_MASTER_OPERATING_PROMPT.md`, `10_PHASE_0_DISCOVERY_PROMPT.md`, `11_PHASE_PROMPTS.md`)
  - `architecture/` (1 file: `02_TARGET_ARCHITECTURE.md`)
  - `cto_readiness_audit_reports/` (10 audit reports + subdirectories; all marked SUPERSEDED / REFERENCE-ONLY)
  - `docs/` (`docs/ai/`, `docs/discovery/`, `docs/governance/`)
  - `integrations/` (1 file: `03_INTEGRATION_AND_DATA_SPEC.md`)
  - `planning/` (2 files: `08_ADR_AND_OPEN_QUESTIONS.md`, `09_REQUIREMENTS_TRACEABILITY.csv`)
  - `requirements/` (1 file: `01_SRS.md`)
  - `security/` (1 file: `05_SECURITY_PRIVACY_AND_ACCESS.md`)
  - Root pack tools: `00_PROJECT_CHARTER.md`, `00_READ_ME_FIRST.md`, `verify_archive_manifest.py`, `MANIFEST.sha256`, `PACK_VERSION.txt`.
- **Application Code Files:** Exactly **0** (`*.go`, `*.py`, `*.dart`, `*.ts`, `*.tsx`, `*.sql` outside verification utility).

### 2.3 Workstation Environment & Host Toolchain Inventory
Empirical commands were executed to verify host capabilities directly:

| Subsystem / Tool | Expected Baseline | Empirical Host Command | Actual Measured Host Result | Status / Assessment |
|---|---|---|---|---|
| **Operating System** | Windows 10/11 x64 | `Get-CimInstance Win32_OperatingSystem` | Windows 10 Pro 64-bit | VERIFIED |
| **CPU Architecture** | Multi-core x86_64 | `Get-CimInstance Win32_Processor` | Intel(R) Xeon(R) E-2236 CPU @ 3.40GHz (6 Cores, 12 Threads) | VERIFIED |
| **System RAM** | Minimum 16 GB | `Get-CimInstance Win32_OperatingSystem` | 15.69 GB Total, 9.37 GB Available | VERIFIED (~9.4 GB free headroom) |
| **Discrete GPU** | Dedicated NVIDIA GPU | `nvidia-smi` | NVIDIA Quadro P600 (Pascal GP107GL, 4096 MiB GDDR5, Driver 552.55, CUDA 12.4) | VERIFIED (Dev/Spike only) |
| **Python** | Python 3.11+ | `python --version` | Python 3.14.4 on Windows host PATH | VERIFIED |
| **Go Compiler** | Go 1.23+ | `go version` | `The term 'go' is not recognized` | UNINSTALLED on Windows PATH (Must use container/WSL) |
| **Flutter SDK** | Flutter 3.24+ | `flutter --version` | Flutter 3.44.7 (Dart 3.12.2, DevTools 2.57.0) | VERIFIED on host PATH |
| **Docker Engine** | Docker 26+ | `docker --version` | Docker version 29.8.0, build 88096ef | VERIFIED |
| **WSL Subsystem** | WSL2 Ubuntu | `wsl -l -v` | `docker-desktop` (Stopped, Version 2) | PARTIAL (No Ubuntu distro yet registered) |

---

## 3. Subsystem-by-Subsystem Technical Audit

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ SUBSYSTEM AUDIT STATUS MATRIX                                                                          │
├───────────────────────────────┬───────────────────┬────────────────────────────────────────────────────┤
│ Subsystem Area                │ Maturity State    │ Findings & Technical Verdict                       │
├───────────────────────────────┼───────────────────┼────────────────────────────────────────────────────┤
│ Web Administration Console    │ NOT IMPLEMENTED   │ React/Vite removed (ADR-014); Flutter Web approved. │
│ Mobile Handheld Application   │ NOT IMPLEMENTED   │ Flutter Android specs complete; zero UI code.      │
│ Backend Service Core (edged)  │ NOT IMPLEMENTED   │ Go Clean Architecture designed; zero Go files.     │
│ Video Ingestion & Delivery    │ NOT IMPLEMENTED   │ go2rtc sidecar designed; zero runtime containers.   │
│ AI Inference & Analytics      │ NOT IMPLEMENTED   │ ONNX Runtime pipeline designed; no model files.    │
│ Database & Persistence        │ NOT IMPLEMENTED   │ PostgreSQL 16 schema designed; no migrations run.  │
│ ZKTeco Attendance Integration │ NOT AUTHORIZED    │ Protocol spec ready; physical access prohibited.   │
│ SQL Server Sync Integration   │ NOT AUTHORIZED    │ Query plan ready; database access prohibited.      │
│ Alert & Event Notification    │ NOT IMPLEMENTED   │ Outbox pattern designed; zero notification code.   │
│ Factory Isolation & Security  │ NOT IMPLEMENTED   │ RLS & WireGuard designed; zero active rules.       │
│ Test & Quality Harness        │ MINIMAL SCRIPT    │ verify_archive_manifest.py only; zero unit tests.  │
│ Observability & Telemetry     │ NOT IMPLEMENTED   │ NFR-OBS-002 defined; zero metrics/health probes.   │
└───────────────────────────────┴───────────────────┴────────────────────────────────────────────────────┘
```

### 3.1 Web Administration Console
- **Original Plan:** React + Vite + Tailwind dashboard.
- **Architectural Amendment:** `ADR-014` unified the frontend client on Flutter, deploying a single codebase to Flutter Android (mobile) and Flutter Web (desktop/web console). This eliminates dual-language client fragmentation (Dart + TypeScript) and prevents duplicate state-management logic.
- **Current State:** `NOT IMPLEMENTED`. Wireframes and token definitions exist in Documents 09, 10, and 33, but zero Flutter Web code exists.

### 3.2 Mobile Handheld Application (Flutter Android)
- **Scope:** Dedicated handheld application for on-duty security supervisors and floor managers.
- **Capabilities:** Push notifications, immediate incident dispatch, low-latency live WebRTC stream playback, incident resolution/acknowledgment workflow (`FR-ALT-008`).
- **Current State:** `NOT IMPLEMENTED`. Core journey requirements (`FR-AND-001` through `FR-AND-007`) are documented in `01_SRS.md`.

### 3.3 Backend Service Core (`edged`)
- **Scope:** Edge daemon managing camera configuration, incident state machines, database persistence, event outbox dispatch, and client APIs.
- **Architecture:** Go with Clean Architecture (Domain, Application, Infrastructure, Ports/Adapters).
- **Video Decoding Boundary:** Pursuant to `ADR-012`, **Go never decodes video frames**. Python AI workers pull the camera sub-streams directly and perform all decoding, sampling, inference, and tracking, forwarding only lightweight protobuf events (`proto/surveillance/v1/events.proto`) to Go.
- **Current State:** `NOT IMPLEMENTED`. Protobuf contracts and API endpoints are specified, but no Go modules exist.

### 3.4 Video Ingestion & go2rtc Sidecar
- **Scope:** Multi-camera RTSP ingestion, WebRTC multiplexing for browser/mobile playback, and stream health monitoring.
- **Boundary & Security:** `go2rtc` is kept strictly on the internal Docker network. Port 1984 is never exposed directly to external networks or web browsers. All WebRTC SDP offer/answer exchanges are proxied through an authenticated Go endpoint verifying HMAC tokens and role-based permissions (`D-011`).
- **Current State:** `NOT IMPLEMENTED`. Configuration templates exist in Document 32.

### 3.5 AI Inference & Analytics Pipeline (`py-worker`)
- **Scope:** Computer vision inference for restricted zone intrusion (`FR-AI-001`), PPE compliance (`FR-AI-002`), fall detection (`FR-AI-003`), fire/smoke anomalies (`FR-AI-005`), and phone usage (`FR-AI-006`).
- **Runtime:** ONNX Runtime CPU baseline with optional CUDA execution provider (`ADR-016`).
- **Candidate Models:** YOLOX, RT-DETR, ByteTrack, RTMPose.
- **Licensing Constraint:** InsightFace/ArcFace and YOLOv8 (Ultralytics AGPL) are strictly rejected. All candidate models are marked `UNVERIFIED` in `docs/ai/MODEL_REGISTER.md` pending commercial dataset and weights provenance audits.
- **Current State:** `NOT IMPLEMENTED`. No weights downloaded, no inference scripts implemented.

### 3.6 Database & Persistence Layer
- **Scope:** On-premises persistent storage for site configuration, camera metadata, incident events, and audit logs.
- **Simplification (`ADR-013`):** Removed Valkey and TimescaleDB. Standard PostgreSQL 16 satisfies all requirements using:
  - Table-level Row-Level Security (`ENABLE` + `FORCE ROW LEVEL SECURITY`) with session setting `app.site_id`.
  - Transactional Outbox table with `FOR UPDATE SKIP LOCKED` for worker queues.
  - Native PostgreSQL `LISTEN / NOTIFY` for real-time internal event triggers.
- **Current State:** `NOT IMPLEMENTED`. SQL schema definitions exist in `02_TARGET_ARCHITECTURE.md`, but no migrations exist.

---

## 4. Architectural & Governance Health Audit

### 4.1 Resolution of Historical Governance Deadlocks
Previous development was stalled due to conflicting statements in historical documentation (e.g., "Sprint 1 STRICTLY NOT AUTHORIZED" vs. "Execute Phase 0 and proceed"). 

This conflict was definitively resolved by:
1. `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`: Explicitly authorizes local development sprints (`WP-1` through `WP-6`) on the owner's workstation using synthetic/public data.
2. `docs/governance/CTO_AMENDMENTS.md`: Formally ratifies `ADR-012` through `ADR-017` and supersedes outdated stack proposals.
3. `requirements/01_SRS.md`: Reconciled to exactly 97 requirements (78 Functional + 19 Non-Functional, including `NFR-OBS-002` Coverage Lost Alert) with 100% 1:1 parity with `planning/09_REQUIREMENTS_TRACEABILITY.csv`.

### 4.2 Windows Line-Ending (CRLF vs LF) Quirk
During repository verification, running `verify_archive_manifest.py` on the Windows host initially reported 13 hash mismatches. Investigation revealed that the physical files on disk have CRLF (`\r\n`) line endings due to Windows git checkout configuration, whereas `MANIFEST.sha256` recorded hashes computed from UNIX LF (`\n`) bytes. Stripping `\r` yielded bit-exact matches to the expected SHA-256 hashes (e.g., `PACK_VERSION.txt` hash `129DEB98911D4A594D413D748D79CBFB90133BC4CAC775BE052E1C1A164D8D93`). This is an OS text-encoding artifact, not data corruption.

---

## 5. Technical Risk & Blocker Analysis

| Risk / Blocker ID | Description & Severity | Root Cause / Technical Impact | Mitigation & Closure Path |
|---|---|---|---|
| **BLK-001** | ZKTeco Biometric Photo Extraction Unknown (`HIGH`) | Factory terminals may encrypt or withhold raw RGB enrollment photos, preventing local face embedding generation. | Execute `SPK-01` on 1 isolated test terminal or obtain owner approval for photo-upload fallback `DEC-03`. |
| **BLK-002** | Workstation & Factory GPU Capacity (`CRITICAL`) | Existing factory edge servers possess zero GPU acceleration. Workstation has only 4 GB VRAM (Quadro P600). | Benchmark candidate ONNX models in local simulation (`SPK-02-LOCAL`) to determine exact per-frame latency and size production server BOM. |
| **BLK-003** | Heterogeneous NVR Fleet Stream Limits (`HIGH`) | Mixed Dahua, Hikvision, Tiandy NVRs across BNF/RNF may drop connections under concurrent sub-stream requests. | Execute `SPK-03` on isolated test switch to validate go2rtc RTSP multiplexing stability. |
| **BLK-004** | Core Network Switch Uplink Saturation (`MEDIUM`) | Ingesting 200+ camera streams across 1GbE uplinks can cause packet loss and frame drops. | Physical audit by factory IT; enforce strict sub-stream resolution (640×360 @ 10-15 fps, ~0.5 Mbps/stream). |
| **BLK-005** | Legal Compliance (Egyptian Law 151/2020) (`CRITICAL`) | Processing employee biometrics and continuous surveillance requires explicit consent and regulatory registration. | Submit Document 34 to qualified Egyptian counsel (`DEC-06`); maintain zero face recognition in local dev baseline. |
| **BLK-006** | Official Emergency Recipient Rosters (`HIGH`) | Fire and intrusion alert routing cannot be hardcoded without verified phone numbers and device rosters. | Owner submission of verified personnel rosters (`DEC-05`); local dev uses mock test recipients only. |

---

## 6. Phase 0 Assessment Verdict

**STATUS: PHASE 0 RE-ENGINEERING ASSESSMENT COMPLETE.**

The project architecture has been successfully pruned of technical bloat and unmaintainable dependencies. The functional scope is solidly documented in the 97-requirement SRS baseline. 

The immediate imperative is to establish the authoritative Phase 0 deliverables mandated by `Prompt.md`:
1. Capability Matrix (`EXISTING_SYSTEM_CAPABILITY_MATRIX.md`)
2. Rebuild vs. Refactor Decisions (`REBUILD_VS_REFACTOR_DECISIONS.md`)
3. Master Re-Engineering Plan (`MASTER_REENGINEERING_PLAN.md`)
4. Skill Usage Matrix (`SKILL_USAGE_MATRIX.md`)
5. UX/UI Blueprint (`PROPOSED_PRODUCT_UX_BLUEPRINT.md`)
6. SRS Gap Closure Plan (`SRS_GAP_AND_REQUIREMENTS_CLOSURE_PLAN.md`)
7. Architecture Gap Review (`ARCHITECTURE_AND_INTEGRATION_GAP_REVIEW.md`)
8. Quality & Verification Strategy (`QUALITY_AND_VERIFICATION_STRATEGY.md`)
9. Production Readiness Plan (`PRODUCTION_READINESS_PLAN.md`)
10. Updated Project Handoff (`PROJECT_HANDOFF.md`)

No application code shall be written until these foundational specifications and plans are formally reviewed and approved.
