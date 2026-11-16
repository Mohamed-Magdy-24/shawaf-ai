> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# CANONICAL SRS RE-AUDIT: 96-REQUIREMENT FULL BASELINE
## Industrial AI Surveillance Platform — BNF & RNF
**Document ID:** DISC-43-SRS-96-REAUDIT  
**Classification:** Canonical Requirements Quality & Verification Audit  
**Status:** CANONICAL BASELINE AUDIT — GOVERNANCE GATE ACTIVE  
**Baseline Examined:** `requirements/01_SRS.md` — Baseline 1.0.0 (96 Requirements)  
**Historical Predecessor:** cto_readiness_audit_reports/03_SRS_FORENSIC_AUDIT.md (55 Requirements, Draft v2.0.0)  
**Date:** 2026-11-16  

---

## 1. NOTICE OF SCOPE & HISTORICAL SUPERCEDENCE

This re-audit establishes the authoritative, complete verification assessment for the entire 96-requirement baseline defined in `requirements/01_SRS.md` (Baseline 1.0.0).

### 1.1 Resolution of Historical Audit Version Mismatch
The historical audit document (cto_readiness_audit_reports/03_SRS_FORENSIC_AUDIT.md) evaluated 55 requirements against an earlier working draft labeled v2.0.0. The canonical, finalized project specification defines exactly 96 unique requirement IDs (78 Functional Requirements and 18 Non-Functional Requirements) under Baseline 1.0.0.

- cto_readiness_audit_reports/03_SRS_FORENSIC_AUDIT.md is preserved intact as historical evidence of the initial discovery audit.
- planning/05_REQUIREMENTS_TRACEABILITY_MATRIX.md is preserved intact as the historical 55-requirement traceability audit.
- **This document (docs/discovery/43_CURRENT_SRS_96_REQUIREMENT_REAUDIT.md) is the sole canonical audit covering all 96 requirements.**
- The canonical traceability source is planning/09_REQUIREMENTS_TRACEABILITY.csv (96 rows with Owner_Evidence_Reference, exactly aligned with this re-audit).

### 1.2 Meaning of TESTABLE_AS_WRITTEN

TESTABLE_AS_WRITTEN means that a requirement has sufficiently clear conditions to define a future verification procedure.

It does NOT mean:

- Application code exists.
- The feature has been implemented.
- A test has already been executed.
- The test has passed.
- The owner has signed off on the complete Phase 0 baseline.
- The requirement is ready for production.

All 60 requirements in this classification remain subject to implementation and subsequent evidence-based verification.

DEC-01 remains **AWAITING SIGN-OFF** until explicit written owner approval is recorded.

---

## 2. EXECUTIVE REQUIREMENTS QUALITY BREAKDOWN

`
┌─────────────────────────────────────────────────────────────────────────────┐
│                   CANONICAL 96-REQUIREMENT QUALITY METRICS                  │
├────────────────────────────────────────┬─────────────┬──────────────────────┤
│ Classification Category                │ Count       │ Percentage           │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ TESTABLE_AS_WRITTEN                    │ 60          │ 62.5%                │
│ MISSING_QUANTITATIVE_CRITERIA          │ 14          │ 14.6%                │
│ BLOCKED_BY_EXTERNAL_DEPENDENCY         │ 5           │ 5.2%                │
│ INCOMPLETE_TBD                         │ 1           │ 1.0%                │
│ REQUIRES_OWNER_DECISION                │ 13          │ 13.5%                │
│ REQUIRES_LEGAL_REVIEW                  │ 3           │ 3.1%                │
│ ARCHITECTURE_GAP                       │ 0           │ 0.0%                │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ TOTAL AUDITED BASELINE                 │ 96          │ 100.0%               │
└────────────────────────────────────────┴─────────────┴──────────────────────┘
`

### 2.1 Rigorous Accounting of the 36 Unresolved Requirements

The 36 requirements that prevent immediate Phase 1 implementation resolve into 5 distinct engineering categories:

| Classification | Count | Nature of Blocker / Prerequisite |
|---|---:|---|
| **Missing quantitative acceptance criteria** | 14 | Requires representative factory footage, camera angle surveys, network bandwidth probes, or owner-defined tolerance bounds. |
| **Requires owner decision** | 13 | Pending explicit business policy decisions (DEC-02, DEC-03, DEC-07) or architecture selections (ADR-011). |
| **Blocked by external hardware/integration dependency** | 5 | Physical equipment access required on test switch (SPK-01, SPK-03, SPK-04). |
| **Requires legal review** | 3 | Egyptian Personal Data Protection Law 151/2020 legal counsel review (DEC-06, DEC-04). |
| **Incomplete workflow / TBD** | 1 | Incident review and dismissal states undefined (OQ-021). |
| **Total Unresolved Requirements** | **36** | **All 36 tracked with explicit resolution dependencies.** |

> **GOVERNANCE REALITY CHECK:** Not all 36 unresolved requirements are hardware blockers, and not all require financial approval. Specifically, the 14 quantitative gaps require empirical measurements or policy bounds; the 13 owner decisions require business sign-offs; the 5 hardware blockers require physical test bench access; the 3 legal items require counsel opinion; and 1 item requires workflow definition. Furthermore, production server hardware procurement remains **STRICTLY PROHIBITED** and the GPU compute budget remains unresolved under OQ-011. No financial or CapEx authorization has been requested, granted, or completed.

---

## 3. CANONICAL 96-REQUIREMENT AUDIT REGISTER

| Requirement ID | Testability | Acceptance Criteria Status | Required External Evidence | Owner Decision | Architecture Mapping | Verification Method | Status |
|---|---|---|---|---|---|---|---|
| **FR-SITE-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-001 (Owner Confirmed Requirement) | SiteRegistry | Integration and tenant isolation verification | TESTABLE_AS_WRITTEN |
| **FR-SITE-002** | BLOCKED | BLOCKED_EXTERNAL_HARDWARE | Staging SQL Server backup & ZKBioTime API endpoint | No separate owner decision identified; baseline approval pending DEC-01 (SPK-01, SPK-04 awaiting authorization). | AttendanceIntegration;Infrastructure/Persistence | Database connection and connector contract test | BLOCKED_BY_EXTERNAL_DEPENDENCY |
| **FR-SITE-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | SiteRegistry;Infrastructure/Persistence | Negative security and cross-tenant query test | TESTABLE_AS_WRITTEN |
| **FR-SITE-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-010 (Owner Confirmed Requirement) | IdentityAccess;AndroidApp | Authorization and context-switch UI test | TESTABLE_AS_WRITTEN |
| **FR-SITE-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Presentation/Api;SiteRegistry | API contract and request header audit | TESTABLE_AS_WRITTEN |
| **FR-SITE-006** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Simulated cross-site VPN latency profile | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | SiteRegistry;IdentityAccess | Multi-site authorization and dashboard query latency benchmark | MISSING_QUANTITATIVE_CRITERIA |
| **FR-SITE-007** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | EdgeProcessing/LocalEventStore;DeviceRegistry | Network partition disconnect chaos test | TESTABLE_AS_WRITTEN |
| **FR-SITE-008** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AlertRouting;NotificationDelivery | Tenant routing filter and negative delivery test | TESTABLE_AS_WRITTEN |
| **FR-EMP-001** | BLOCKED | BLOCKED_EXTERNAL_HARDWARE | Live ZKBioTime API contract and network route | No separate owner decision identified; baseline approval pending DEC-01 (SPK-01 awaiting authorization). | AttendanceIntegration | ZKBioTime API connector contract test | BLOCKED_BY_EXTERNAL_DEPENDENCY |
| **FR-EMP-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-006 (Owner Confirmed Requirement) | EmployeeDirectory;AttendanceIntegration | Employee record reconciliation test | TESTABLE_AS_WRITTEN |
| **FR-EMP-003** | BLOCKED | BLOCKED_EXTERNAL_HARDWARE | Isolated bench terminal on test switch | No separate owner decision identified; baseline approval pending DEC-01 (SPK-01 awaiting authorization). | BiometricImageAcquisition | Bench terminal photo extraction test | BLOCKED_BY_EXTERNAL_DEPENDENCY |
| **FR-EMP-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | BiometricImageAcquisition | Photo status enumeration unit test | TESTABLE_AS_WRITTEN |
| **FR-EMP-005** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | HR enrollment policy for missing terminal photos | DEC-03 — PROPOSED | BiometricImageAcquisition | Template isolation and format boundary test | REQUIRES_OWNER_DECISION |
| **FR-EMP-006** | CONDITIONALLY_TESTABLE | REQUIRES_LEGAL_CLEARANCE | Written legal counsel opinion under Law 151/2020 & Decree 816/2025 | DEC-06 — AWAITING SUBMISSION | Tracking;AuditObservability | Identity match audit log verification | REQUIRES_LEGAL_REVIEW |
| **FR-EMP-007** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking;IdentityAccess | Confidence threshold boundary test | TESTABLE_AS_WRITTEN |
| **FR-EMP-008** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | EmployeeDirectory | Cross-site employee key collision test | TESTABLE_AS_WRITTEN |
| **FR-VID-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | DeviceRegistry;VideoAccess | NVR adapter contract test | TESTABLE_AS_WRITTEN |
| **FR-VID-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | DeviceRegistry;VideoAccess | Adapter contract and sidecar isolation test | TESTABLE_AS_WRITTEN |
| **FR-VID-003** | BLOCKED | BLOCKED_EXTERNAL_HARDWARE | Physical NVR and cameras on isolated test VLAN | No separate owner decision identified; baseline approval pending DEC-01 (SPK-03 awaiting authorization). | DeviceRegistry;VideoAccess | Physical NVR stream capability discovery probe | BLOCKED_BY_EXTERNAL_DEPENDENCY |
| **FR-VID-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-011 (Owner Confirmed Requirement) & D-009 | VideoAccess;AndroidApp | Role authorization and live player test | TESTABLE_AS_WRITTEN |
| **FR-VID-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-011 (Owner Confirmed Requirement) & D-009 | VideoAccess;AndroidApp | Role authorization and recording playback test | TESTABLE_AS_WRITTEN |
| **FR-VID-006** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | VideoAccess;IdentityAccess | Streaming token proxy security audit | TESTABLE_AS_WRITTEN |
| **FR-VID-007** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-008 (Owner Confirmed Requirement) | VideoAccess;Infrastructure/Persistence | Storage retention policy audit | TESTABLE_AS_WRITTEN |
| **FR-VID-008** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | VideoAccess;Infrastructure/Persistence | Payload and metadata storage isolation audit | TESTABLE_AS_WRITTEN |
| **FR-VID-009** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | VideoAccess;AndroidApp;WebAdmin | Video player viewport OSD overlay inspection | TESTABLE_AS_WRITTEN |
| **FR-VID-010** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Physical camera RTSP disconnect behavior | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | DeviceRegistry;VideoAccess | Camera discovery probe and timeout test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-VID-011** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | WebAdmin;AndroidApp | Viewport canvas transformation test | TESTABLE_AS_WRITTEN |
| **FR-VID-012** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | WebAdmin;AndroidApp | UI zoom mode badge validation | TESTABLE_AS_WRITTEN |
| **FR-VID-013** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | PTZ camera vendor ONVIF PTZ spec | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | DeviceRegistry;WebAdmin | PTZ permission and travel limit boundary test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-VID-014** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Factory floor camera overlap survey | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | DeviceRegistry;AnalyticsInference | Tracking authorization and background recording continuity test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-VID-015** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking;DeviceRegistry | Software bounding box tracking handoff test | TESTABLE_AS_WRITTEN |
| **FR-AI-001** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Factory floor labeled video dataset | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference;ZonePolicy | Held-out labeled dataset evaluation | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-002** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Factory layout zone geometry | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference;ZonePolicy | Polygon geofence intersection test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-003** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Staged factory fall and maintenance video dataset | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference | Temporal video validation on factory dataset | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-004** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Camera placement survey across work cells | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference | Camera mounting angle and resolution test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-005** | CONDITIONALLY_TESTABLE | REQUIRES_LEGAL_CLEARANCE | Scope approved per D-018, D-013, D-014; production deployment gated on DEC-04 & DEC-06 | D-018, D-013, D-014 (Scope Approved); DEC-04 (Auxiliary Sign-Off) & DEC-06 (Legal Review) | AnalyticsInference;AlertRouting | Emergency fast-path dispatch test | REQUIRES_LEGAL_REVIEW |
| **FR-AI-006** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Factory-labeled material image dataset | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference;Tracking | Site-specific labeled material image test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-007** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Warehouse operating schedule and transfer routes | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking;ZonePolicy | Movement pattern rule simulation test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-008** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Transit times between camera views and disk budget | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking | Sighting reconciliation and retention test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-009** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | EventManagement;AnalyticsInference | Event schema validation and evidence reference test | TESTABLE_AS_WRITTEN |
| **FR-AI-010** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference;Tracking | Low-confidence state preservation test | TESTABLE_AS_WRITTEN |
| **FR-AI-011** | CONDITIONALLY_TESTABLE | REQUIRES_LEGAL_CLEARANCE | Egyptian Labor Law and Data Protection compliance review | DEC-06 — AWAITING SUBMISSION | EventManagement;IdentityAccess | Safeguard policy review and legal audit | REQUIRES_LEGAL_REVIEW |
| **FR-AI-012** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | ZonePolicy | Zone policy versioning and migration test | TESTABLE_AS_WRITTEN |
| **FR-AI-013** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking;AnalyticsInference | Tracking pipeline architecture review | TESTABLE_AS_WRITTEN |
| **FR-AI-014** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Factory floor physical distances and walk times | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking;DeviceRegistry | Spatial transition matrix adjacency test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-AI-015** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Tracking | Blind spot transition discontinuity test | TESTABLE_AS_WRITTEN |
| **FR-AI-016** | BLOCKED | BLOCKED_EXTERNAL_HARDWARE | Bench ZKTeco terminal + Law 151/2020 legal clearance | DEC-06 — AWAITING SUBMISSION (SPK-01 awaiting authorization). | Tracking;IdentityAccess | Biometric confidence calibration and consent audit | BLOCKED_BY_EXTERNAL_DEPENDENCY |
| **FR-ALT-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | NotificationDelivery;AndroidApp | In-app notification delivery test | TESTABLE_AS_WRITTEN |
| **FR-ALT-002** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | Confirmed employee names, roles, phone numbers | D-012 (Owner Confirmed Requirement); DEC-05 — AWAITING SUBMISSION | AlertRouting | Recipient matrix routing test | MISSING_QUANTITATIVE_CRITERIA |
| **FR-ALT-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AlertRouting | Cross-site tenant isolation delivery test | TESTABLE_AS_WRITTEN |
| **FR-ALT-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-013, D-014 (Owner Confirmed Requirement) | AlertRouting;NotificationDelivery | Fire alert fast-path dispatch test | TESTABLE_AS_WRITTEN |
| **FR-ALT-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AlertRouting;NotificationDelivery | Priority queue dispatch benchmark under load | TESTABLE_AS_WRITTEN |
| **FR-ALT-006** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AuditObservability;NotificationDelivery | Notification delivery audit log verification | TESTABLE_AS_WRITTEN |
| **FR-ALT-007** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AlertRouting | Unmediated pipeline delivery test | TESTABLE_AS_WRITTEN |
| **FR-ALT-008** | UNTESTABLE_TBD | INCOMPLETE_WORKFLOW_SPECS | Formal incident resolution SOP from factory management | No separate owner decision identified; workflow definition pending under OQ-021. | IncidentManagement | Incident workflow state verification | INCOMPLETE_TBD |
| **FR-REP-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-009, D-015 (In-App Reporting Confirmed; manager dashboard aggregation scope unconfirmed pending owner review) | Reporting;AndroidApp | Manager dashboard functional UI test | TESTABLE_AS_WRITTEN |
| **FR-REP-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-015, D-016 (Owner Confirmed Requirement) | Reporting;AndroidApp | Embedded reporting generation test | TESTABLE_AS_WRITTEN |
| **FR-REP-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-015 (Owner Confirmed Requirement) | Reporting;AndroidApp | Chart calculation and percentage metric test | TESTABLE_AS_WRITTEN |
| **FR-REP-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-015 (Owner Confirmed Requirement) | Reporting | Scheduled report generation test | TESTABLE_AS_WRITTEN |
| **FR-REP-005** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Factory shift cutoff rules (23:59:59 Africa/Cairo) | DEC-07 — PROPOSED | Reporting | Report multi-dimensional filter test | REQUIRES_OWNER_DECISION |
| **FR-REP-006** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Factory management reporting guidelines | DEC-07 — PROPOSED | Reporting;IncidentManagement | Event lifecycle status report test | REQUIRES_OWNER_DECISION |
| **FR-REP-007** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-017 (Owner Confirmed Requirement) | Reporting;Infrastructure/Security | Channel isolation and egress prevention audit | TESTABLE_AS_WRITTEN |
| **FR-APP-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-009 (Owner Confirmed Requirement) | AndroidApp | Android APK packaging and build test | TESTABLE_AS_WRITTEN |
| **FR-APP-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AndroidApp | Mobile functional navigation test | TESTABLE_AS_WRITTEN |
| **FR-APP-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-011 (Owner Confirmed Requirement) | AndroidApp;IdentityAccess | Role-based mobile view gating test | TESTABLE_AS_WRITTEN |
| **FR-APP-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AndroidApp | UI context banner inspection | TESTABLE_AS_WRITTEN |
| **FR-APP-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AndroidApp | Session revocation and network error resilience test | TESTABLE_AS_WRITTEN |
| **FR-VPN-001** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Factory network infrastructure topology | ADR-011 — PROPOSED (Pending Owner Review) | Infrastructure/Networking | VPN tunnel encryption and throughput test | REQUIRES_OWNER_DECISION |
| **FR-VPN-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Networking | VLAN isolation port scan audit | TESTABLE_AS_WRITTEN |
| **FR-VPN-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | Firewall rule and bastion transit test | TESTABLE_AS_WRITTEN |
| **FR-VPN-004** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Factory WAN failover capability data | ADR-011 — PROPOSED (Pending Owner Review) | Infrastructure/Networking | Tunnel recovery and failover test | REQUIRES_OWNER_DECISION |
| **FR-VPN-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | EventManagement;EdgeProcessing/LocalEventStore | Outbox replay and deduplication test | TESTABLE_AS_WRITTEN |
| **FR-WEB-001** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Web management deployment decision | DEC-02 — PROPOSED | WebAdmin | Browser console accessibility and build test | REQUIRES_OWNER_DECISION |
| **FR-WEB-002** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | WebRTC sidecar performance review | DEC-02 — PROPOSED (ADR-011 — PROPOSED) | WebAdmin;DeviceRegistry | Web stream preview functional test | REQUIRES_OWNER_DECISION |
| **FR-WEB-003** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Web canvas UX review | DEC-02 — PROPOSED | WebAdmin;ZonePolicy | Polygon canvas interaction test | REQUIRES_OWNER_DECISION |
| **FR-WEB-004** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Browser playback buffering benchmarks | DEC-02 — PROPOSED (ADR-011 — PROPOSED) | WebAdmin;VideoAccess | Timeline synchronization test | REQUIRES_OWNER_DECISION |
| **FR-WEB-005** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Security audit log retention policy | DEC-02 — PROPOSED | WebAdmin;AuditObservability | Administrative grid inspection test | REQUIRES_OWNER_DECISION |
| **FR-WEB-006** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Web management role permission matrix | DEC-02 — PROPOSED | Presentation/Api | Contract parity and permission schema test | REQUIRES_OWNER_DECISION |
| **NFR-SEC-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | IdentityAccess;Presentation/Api | Security penetration and authorization bypass test | TESTABLE_AS_WRITTEN |
| **NFR-SEC-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | SiteRegistry;Infrastructure/Persistence | Multi-tenant isolation security review | TESTABLE_AS_WRITTEN |
| **NFR-SEC-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | TLS cipher scan and storage encryption audit | TESTABLE_AS_WRITTEN |
| **NFR-SEC-004** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | Automated secret scanning and binary audit | TESTABLE_AS_WRITTEN |
| **NFR-SEC-005** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | CCTV network scan and routing audit | TESTABLE_AS_WRITTEN |
| **NFR-REL-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | EdgeProcessing/LocalEventStore | Autonomous edge operation disconnect test | TESTABLE_AS_WRITTEN |
| **NFR-REL-002** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Valkey memory sizing benchmark | ADR-011 — PROPOSED (Pending Owner Review) | EventManagement;NotificationDelivery | Queue persistence and duplicate delivery test | REQUIRES_OWNER_DECISION |
| **NFR-SCL-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-004 (Owner Reported Environment Fact — approximate planning input; capacity acceptance threshold pending inventory & load test) | VideoIngestion;AnalyticsInference | Load test after physical inventory | TESTABLE_AS_WRITTEN |
| **NFR-SCL-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | VideoIngestion;AnalyticsInference | Capacity sizing model calculation audit | TESTABLE_AS_WRITTEN |
| **NFR-MNT-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Presentation/Api;Infrastructure/Persistence | Architecture boundary dependency test | TESTABLE_AS_WRITTEN |
| **NFR-MNT-002** | CONDITIONALLY_TESTABLE | MISSING_NUMERICAL_BOUNDS | DevSecOps automated test coverage benchmark | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | CI contract test coverage audit | MISSING_QUANTITATIVE_CRITERIA |
| **NFR-OBS-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AuditObservability | Telemetry endpoint inspection and probe test | TESTABLE_AS_WRITTEN |
| **NFR-UX-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AndroidApp;WebAdmin | Usability evaluation and WCAG compliance audit | TESTABLE_AS_WRITTEN |
| **NFR-DATA-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | D-008 (Owner Confirmed Requirement) | VideoAccess;Infrastructure/Persistence | Storage sizing calculation and ring buffer audit | TESTABLE_AS_WRITTEN |
| **NFR-AI-001** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference | Evaluation protocol inspection against test dataset | TESTABLE_AS_WRITTEN |
| **NFR-AI-002** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference | Evaluation report audit | TESTABLE_AS_WRITTEN |
| **NFR-AI-003** | TESTABLE | COMPLETE | None (Local deterministic verification) | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | AnalyticsInference;AlertRouting | Safety rule audit and determinism verification | TESTABLE_AS_WRITTEN |
| **NFR-LIC-001** | TESTABLE_UPON_APPROVAL | PENDING_OWNER_DECISION | Third-party license register audit | No separate owner decision identified; overall Gate 0 baseline approval remains pending DEC-01. | Infrastructure/Security | Release SBOM and license compliance audit | REQUIRES_OWNER_DECISION |

---

## 4. CROSS-CUTTING AUDIT FINDINGS

### 4.1 External Hardware & Factory Network Dependencies (5 Requirements)
The 5 requirements marked BLOCKED_BY_EXTERNAL_DEPENDENCY (FR-SITE-002, FR-EMP-001, FR-EMP-003, FR-VID-003, FR-AI-016) cannot be validated on a developer workstation without physical device access.
- SPK-01: Physical bench testing of isolated ZKTeco standalone terminal to verify attendance log extraction and photo retrieval over UDP port 4370.
- SPK-03: Physical bench testing of test NVR and RTSP cameras over isolated test VLAN to discover stream profiles, sub-stream H.264 codecs, and WebRTC streaming latency.
- SPK-04: Read-only connection to staging backup of factory SQL Server database.

### 4.2 Missing Quantitative Criteria (14 Requirements)
The 14 requirements marked MISSING_QUANTITATIVE_CRITERIA are tracked in detail within docs/discovery/42_REQUIREMENT_ACCEPTANCE_CRITERIA_GAPS.md. Numerical thresholds (latency limits, precision/recall targets, watchdog timeouts, and bounding box dimensions) must not be fabricated arbitrarily. They will be benchmarked and finalized using real factory footage and physical network measurements.

### 4.3 Mandatory Legal Review & Compliance (3 Requirements)
FR-EMP-006, FR-AI-005, and FR-AI-011 carry regulatory and compliance prerequisites prior to production deployment:
- Biometric verification on employees requires formal written certification under Egyptian Personal Data Protection Law 151/2020 and Decree 816/2025 (DEC-06).
- For FR-AI-005, feature scope is approved by the Project Owner (D-018, D-013, D-014); however, production deployment is independently gated on DEC-04 (owner sign-off on auxiliary early-warning disclaimers) and DEC-06 (corporate legal review). Video AI fire/smoke alerts do not replace certified NFPA fire alarm infrastructure.

### 4.4 Owner Business & Architecture Approvals (13 Requirements)
The requirements for the Web Administration Console (FR-WEB-001 through FR-WEB-006, DEC-02), Biometric Photo Fallback (FR-EMP-005, DEC-03), Shift Daily Cutoffs (FR-REP-005, FR-REP-006, DEC-07), WireGuard site-to-site VPN (FR-VPN-001, FR-VPN-004), Valkey queue durability (NFR-REL-002), and Permissive Open-Source Stack (NFR-LIC-001) remain subject to explicit Project Owner approval.

---

## 5. GATE STATUS & CONCLUSION

- **Documentation Remediation Status:** COMPLETE
- **Requirements Traceability Parity:** 96 SRS IDs / 96 Traceability CSV Rows / 96 Audit Register Entries (Zero Discrepancy)
- **Phase Gate Determination:** SPRINT 1 IMPLEMENTATION REMAINS STRICTLY NOT AUTHORIZED
