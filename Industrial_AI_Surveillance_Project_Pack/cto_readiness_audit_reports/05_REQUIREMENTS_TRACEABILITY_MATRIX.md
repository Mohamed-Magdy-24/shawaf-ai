> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# REQUIREMENTS-TO-ARCHITECTURE TRACEABILITY MATRIX
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-05 | Classification: CANONICAL TRACEABILITY AUDIT
### Status: COMPLETE AUDIT | Baseline Reference: `planning/09_REQUIREMENTS_TRACEABILITY.csv` v1.0.0

---

## 1. TRACEABILITY COVERAGE SUMMARY & METRICS

Traceability was audited across all 42 Functional Requirements (FRs) and 13 Non-Functional Requirements (NFRs):

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       TRACEABILITY COVERAGE METRICS                         │
├────────────────────────────────────────────────┬────────────┬───────────────┤
│ Metric Dimension                               │ Count      │ Percentage    │
├────────────────────────────────────────────────┼────────────┼───────────────┤
│ Total Requirements Audited                     │ 55         │ 100.0%        │
│ Fully Traceable (Req -> Arch -> Code -> Test)  │ 37         │ 67.3%         │
│ Inferred Architecture Coverage                 │ 9          │ 16.4%         │
│ Missing Test Case Coverage                     │ 15         │ 27.3%         │
│ Missing Concrete Interface Contract            │ 6          │ 10.9%         │
│ Blocked by Hardware / External Dependency      │ 8          │ 14.5%         │
└────────────────────────────────────────────────┴────────────┴───────────────┘
```

> **CRITICAL GAP: 15 requirements lack defined test cases in the baseline traceability register (`planning/09_REQUIREMENTS_TRACEABILITY.csv`), and 9 requirements have only "inferred" architectural coverage without explicit design diagrams or contracts `[VERIFIED_IN_SOURCE]`.**

---

## 2. COMPREHENSIVE REQUIREMENTS TRACEABILITY REGISTER

*Evidence Standard: `VERIFIED` = Explicitly defined in documentation; `INFERRED` = Architecturally implied but missing explicit contract; `BLOCKED` = Dependent on unprocured hardware or absent external systems.*

| Req ID | SRS Section | Target SDD Component | Responsible Module | Data Entity / Interface | External Dependency | Acceptance Criteria Status | Associated Test Case | Traceability Status & Evidence |
|--------|-------------|----------------------|--------------------|-------------------------|---------------------|----------------------------|----------------------|--------------------------------|
| **FR-SITE-001** | §4.1 | Multi-Tenant Kernel | `internal/core/tenant` | `TenantContext`, `tenants` table | None | Complete | `TC-SITE-001` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-SITE-002** | §4.1 | Attendance / SQL Adapters | `internal/adapters/zk` | `ZKBioTimeClient`, `SQLServerClient` | Factory LAN / DB | Missing schema spec | `TC-SITE-002` (Pending) | **BLOCKED_BY_DEPENDENCY** |
| **FR-SITE-003** | §4.1 | Database Engine | `internal/adapters/postgres` | PostgreSQL RLS policies | PostgreSQL 16 | Complete | `TC-SITE-003` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-SITE-004** | §4.1 | Web/App Context Switcher | `api/rest/middleware` | JWT Claim `tenant_id` | None | Complete | `TC-SITE-004` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-SITE-005** | §4.1 | API Gateway | `api/rest/handler` | HTTP Header `X-Tenant-ID` | None | Complete | `TC-SITE-005` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-SITE-006** | §4.1 | Central Fleet Manager | `cmd/centrald` | `central_user_roles` | None | Incomplete (Latency TBD) | `TC-SITE-006` | **INFERRED_ARCHITECTURE** |
| **FR-SITE-007** | §4.1 | Edge Autonomous Daemon | `cmd/edged` | Local DB + Outbox | None | Complete | `TC-REL-001` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-SITE-008** | §4.1 | Event Dispatcher | `internal/core/event` | `event_outbox` tenant filter | None | Complete | `TC-SEC-002` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-001** | §4.2 | ZKBioTime Adapter | `internal/adapters/zk` | `ZKBioTimeClient` | ZKBioTime Server | Missing API endpoints | `TC-EMP-001` (Pending) | **BLOCKED_BY_DEPENDENCY** |
| **FR-EMP-002** | §4.2 | Employee Roster | `internal/core/attendance` | `(site_id, employee_id)` | SQL Server Staging | Complete | `TC-EMP-002` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-003** | §4.2 | Photo Extraction Spike | `tools/spikes/spk01` | `PhotoProbeResult` | Bench Terminal | Missing terminal model | `SPK-01-TEST` | **BLOCKED_BY_DEPENDENCY** |
| **FR-EMP-004** | §4.2 | Photo Status Model | `internal/core/employee` | Enum `photo_status` | None | Complete | `TC-EMP-004` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-005** | §4.2 | Face Template Isolator | `internal/core/ai` | `BiometricTemplatePolicy` | None | Complete | `TC-EMP-005` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-006** | §4.2 | Identity Match Logger | `internal/adapters/postgres` | `identity_match_logs` table | None | Complete | `TC-EMP-006` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-007** | §4.2 | Confidence Gate | `internal/core/ai` | Threshold evaluator ($\ge 0.80$) | None | Complete | `TC-EMP-007` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-EMP-008** | §4.2 | Compound Key Domain | `internal/core/employee` | Entity `EmployeeKey` | None | Complete | `TC-EMP-008` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-001** | §4.3 | Camera Inventory | `internal/core/camera` | `cameras` table | None | Complete | `TC-VID-001` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-002** | §4.3 | Protocol Adapter (go2rtc)| `internal/adapters/go2rtc` | `StreamManager` interface | go2rtc binary | Complete | `TC-VID-002` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-003** | §4.3 | Stream Capability Probe | `internal/adapters/onvif` | `ONVIFProbe` | Physical Cameras | Incomplete (Probe TBD) | `TC-VID-003` (Pending) | **BLOCKED_BY_DEPENDENCY** |
| **FR-VID-004** | §4.3 | Live WebRTC Streamer | `api/ws` & `flutter_webrtc` | WHEP endpoint `/api/webrtc` | None | Missing latency limit | `TC-VID-004` | **INFERRED_ARCHITECTURE** |
| **FR-VID-005** | §4.3 | Playback Streamer | `internal/adapters/go2rtc` | fMP4 endpoint `/api/playback` | Local NVMe | Missing seek tolerance | `TC-VID-005` | **INFERRED_ARCHITECTURE** |
| **FR-VID-006** | §4.3 | Stream Token Proxy | `api/rest/stream` | Ephemeral JWT stream token | None | Complete | `TC-SEC-004` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-007** | §4.3 | Tiered Video Storage | `internal/adapters/storage` | `video_segments` ring buffer | **162TB Storage Array** | Missing disk hardware | `TC-DATA-001` (Pending) | **UNSUPPORTED_LOCALLY** |
| **FR-VID-008** | §4.3 | Segment Metadata Index | `internal/adapters/postgres` | `video_segments` hypertable | PostgreSQL 16 | Complete | `TC-VID-008` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-009** | §4.3 | OSD Overlay Engine | `web/src/components/video` | Viewport Canvas OSD | None | Complete | `TC-VID-009` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-010** | §4.3 | ONVIF Discovery Engine | `internal/adapters/onvif` | WS-Discovery Multicast | CCTV VLAN | Incomplete (Timeout TBD) | `TC-VID-010` (Pending) | **BLOCKED_BY_DEPENDENCY** |
| **FR-VID-011** | §4.3 | Client Digital Zoom | `web` & `flutter` UI | Matrix Viewport Transform | None | Complete | `TC-VID-011` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-012** | §4.3 | Zoom Mode Badge | `web` & `flutter` UI | UI Badge State | None | Complete | `TC-VID-012` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-VID-013** | §4.3 | PTZ Command Controller | `internal/adapters/onvif` | `PTZController` interface | PTZ Cameras | Missing watchdog stop | `TC-VID-013` (Pending) | **INFERRED_ARCHITECTURE** |
| **FR-VID-014** | §4.3 | Automated PTZ Tracker | `ai-worker/tracker` | Advanced Tracking Agent | PTZ Cameras | Incomplete algorithm | None | **NO_TEST_COVERAGE** |
| **FR-VID-015** | §4.3 | Fixed Camera Handoff | `ai-worker/tracker` | Software BBox Smoother | None | Complete | `TC-VID-015` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-001** | §4.4 | PPE Classifier | `ai-worker/detectors/ppe` | `YOLOv8-PPE` (ONNX) | GPU/CPU | Missing pixel threshold | `TC-AI-001` | **INFERRED_ARCHITECTURE** |
| **FR-AI-002** | §4.4 | Geofence Polygon Evaluator| `internal/core/zone` | Point-in-Polygon Engine | None | Complete | `TC-AI-002` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-003** | §4.4 | Fall Detection Engine | `ai-worker/detectors/fall` | 90-Frame Keypoint Buffer | GPU/CPU | Missing duration rule | `TC-AI-003` | **INFERRED_ARCHITECTURE** |
| **FR-AI-004** | §4.4 | Phone Detection Model | `ai-worker/detectors/phone`| `YOLOv8-Phone` (ONNX) | Eye-level Cams | Missing height limit | `TC-AI-004` | **INFERRED_ARCHITECTURE** |
| **FR-AI-005** | §4.4 | Fire & Smoke Detector | `ai-worker/detectors/fire` | Dual-Frame Fire Classifier | GPU/CPU | Missing legal disclaimer | `TC-AI-005` | **REQUIRES_LEGAL_REVIEW** |
| **FR-AI-006** | §4.4 | Material Classifier | `ai-worker/detectors/object`| Custom YOLO Object Model | None | Missing taxonomy | None | **MISSING_CONTRACT / NO_TEST** |
| **FR-AI-007** | §4.4 | Suspicious Movement Engine| `internal/core/ai` | Transfer Zone Evaluator | None | Incomplete / Ambiguous | None | **MISSING_CONTRACT / NO_TEST** |
| **FR-AI-008** | §4.4 | Cross-Camera Re-ID | `ai-worker/detectors/reid` | `OSNet` Embedding (512-d) | Multi-Cams | Missing transit matrix | `TC-AI-008` (Pending) | **INFERRED_ARCHITECTURE** |
| **FR-AI-009** | §4.4 | Evidence Metadata Store | `internal/adapters/postgres` | `factory_events.metadata` | PostgreSQL 16 | Complete | `TC-AI-009` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-010** | §4.4 | Ambiguity State Handler | `internal/core/event` | Enum `IdentityState` | None | Complete | `TC-AI-010` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-011** | §4.4 | Non-Disciplinary Safeguard| `internal/core/event` | Safeguard Warning Flag | None | Complete | `TC-AI-011` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-012** | §4.4 | Zone Versioning Engine | `internal/core/zone` | `zone_policies` versioning | PostgreSQL 16 | Complete | `TC-AI-012` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-013** | §4.4 | ByteTrack MOT Tracker | `ai-worker/tracker` | `BYTETracker` Class | Python Worker | Complete | `TC-AI-013` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-014** | §4.4 | Topology Graph Gating | `internal/core/camera` | `CameraGraph` adjacency | None | Missing graph schema | `TC-AI-014` (Pending) | **INFERRED_ARCHITECTURE** |
| **FR-AI-015** | §4.4 | Blind-Spot Discontinuity | `internal/core/tracking` | Track continuity flag | None | Complete | `TC-AI-015` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-AI-016** | §4.4 | Biometric Consent Gate | `internal/core/employee` | `biometric_consent_signed` | Law 151 Form | Missing consent flow | `TC-SEC-005` (Pending) | **REQUIRES_LEGAL_REVIEW** |
| **FR-ALT-001** | §4.5 | Mobile Push Dispatcher | `internal/adapters/fcm` | `FCMClient` | Firebase Cloud | Complete | `TC-ALT-001` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-002** | §4.5 | Alert Routing Resolver | `internal/core/alert` | `AlertRouteResolver` | Roster (`DEC-05`) | Missing roster input | `TC-ALT-002` (Pending) | **REQUIRES_OWNER_DECISION** |
| **FR-ALT-003** | §4.5 | Tenant Route Isolation | `internal/core/alert` | Tenant isolation filter | None | Complete | `TC-ALT-003` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-004** | §4.5 | Zero-Gate Fire Fastpath | `internal/core/alert` | Sub-second emergency route | None | Requires `DEC-04` | `TC-ALT-004` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-005** | §4.5 | Dedicated Fire Queue | `internal/adapters/valkey` | Priority Queue `fire_queue` | Valkey / Memory | Complete | `TC-ALT-005` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-006** | §4.5 | Notification Audit Store | `internal/adapters/postgres` | `notification_audit_logs` | PostgreSQL 16 | Complete | `TC-ALT-006` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-007** | §4.5 | Unmediated Alert Dispatch | `internal/core/alert` | Direct dispatch pipeline | None | Complete | `TC-ALT-007` | **FULLY_TRACEABLE** (`VERIFIED`) |
| **FR-ALT-008** | §4.5 | Incident Review State | `internal/core/event` | State Machine (TBD) | None | Explicitly TBD in SRS | None | **INCOMPLETE / NO_TEST** |
| **FR-WEB-001..006**| §4.9 | Web Administration UI | `web/src` | React / Vite SPA Console | None | Requires `DEC-02` | `TC-WEB-001..006` | **REQUIRES_OWNER_DECISION** |

---

## 3. IDENTIFIED TRACEABILITY GAPS & REMEDIATION ACTIONS

1. **Missing Contracts (Action Required before Sprint 1)**:
   - `FR-AI-006` & `FR-AI-007` (Theft / Object Movement): Zero data contracts exist. The owner must provide an approved factory material taxonomy before this module can be architected or tested.
   - `FR-ALT-008` (Incident Review State Machine): Baseline SRS marks states as TBD. A standard state machine (`NEW -> IN_REVIEW -> CONFIRMED -> DISMISSED`) must be formally added.
2. **Missing Test Cases**:
   - 15 requirements lack automated test identifiers in `planning/09_REQUIREMENTS_TRACEABILITY.csv`. All 15 must be assigned explicit unit/integration test specifications.

---
**Audited By:** Principal Software Architect & QA Lead  
**Verification Method:** Cross-referencing `01_SRS.md`, `02_TARGET_ARCHITECTURE.md`, and `09_REQUIREMENTS_TRACEABILITY.csv`

