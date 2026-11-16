# RISK REGISTER & BLOCKER CLASSIFICATION REGISTER
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-11 | Classification: CANONICAL RISK & BLOCKER REGISTRY
### Status: ACTIVE AUDIT REGISTER | Prioritization Model: P0 (Critical) to P3 (Low)

---

## 1. RISK & BLOCKER TAXONOMY & CLASSIFICATION SUMMARY

All identified engineering risks and blockers have been classified according to their operational impact and resolution authority.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BLOCKER SEVERITY BREAKDOWN                          │
├──────────────────────────┬───────┬──────────────────────────────────────────┤
│ Severity Level           │ Count │ Impact on Project Execution              │
├──────────────────────────┼───────┼──────────────────────────────────────────┤
│ **P0 — Critical**        │ 4     │ Strictly blocks Gate A and Gate B.       │
│ **P1 — High**            │ 7     │ Blocks Sprint 1 and Phase 1 Spikes.      │
│ **P2 — Medium**          │ 8     │ Blocks Phase 2 and Phase 3 dependent work│
│ **P3 — Low**             │ 5     │ Maintenance / documentation improvement. │
├──────────────────────────┼───────┼──────────────────────────────────────────┤
│ **TOTAL ACTIVE ISSUES**  │ 24    │ Unresolved engineering findings          │
└──────────────────────────┴───────┴──────────────────────────────────────────┘
```

---

## 2. P0 — CRITICAL BLOCKERS (MANDATORY CLOSURE BEFORE SPRINT 1)

### BLK-P0-01: Python 3.14 Host Incompatibility
- **Category**: `TECHNICAL BLOCKER`
- **Severity**: **P0 (Critical)** | **Status**: `OPEN`
- **Description**: Host environment runs Python 3.14.4. PyTorch, ONNX Runtime CUDA, and torchvision wheels fail to install or execute on Python 3.14.
- **Evidence**: `python --version` returns 3.14.4; PyTorch official wheels support Python $\le 3.12$.
- **Affected Documents**: `08_TECHNOLOGY_VERSION_COMPATIBILITY.md`, `requirements-ai.txt`.
- **Root Cause**: Host workstation has bleeding-edge Python release installed.
- **Consequence**: Python AI worker cannot initialize or run neural models.
- **Recommended Resolution**: Provision an isolated Python 3.11 virtual environment or Docker container.
- **Responsible Authority**: Engineering Lead.

---

### BLK-P0-02: DeepStream / TensorRT 10 Contradiction on Pascal GPU
- **Category**: `HARDWARE BLOCKER`
- **Severity**: **P0 (Critical)** | **Status**: `OPEN`
- **Description**: Target architecture documents DeepStream SDK 7.0 and TensorRT 10.x, which are physically incompatible with the workstation's Quadro P600 (Pascal SM 6.1) GPU.
- **Evidence**: `nvidia-smi` confirms Quadro P600; NVIDIA official release notes drop SM 6.1 in TensorRT 10.
- **Affected Documents**: `02_TARGET_ARCHITECTURE.md`, `08_TARGET_ARCHITECTURE_PROPOSAL.md`.
- **Root Cause**: Architecture proposal assumed modern server GPU availability on local workstation.
- **Consequence**: Compilation failure with `CUDA_ERROR_NO_BINARY_FOR_GPU`.
- **Recommended Resolution**: Formally remove DeepStream from local development baseline; standardize on ONNX Runtime FP32.
- **Responsible Authority**: Principal AI Engineer / CTO.

---

### BLK-P0-03: Zero-Gate Fire Alert Auxiliary Status Sign-Off (`DEC-04`)
- **Category**: `LEGAL BLOCKER` / `OWNER DECISION REQUIRED`
- **Severity**: **P0 (Critical)** | **Status**: `AWAITING OWNER SIGN-OFF`
- **Description**: Automated fire alerts dispatch without human verification, creating catastrophic corporate liability if treated as a certified life-safety system.
- **Evidence**: `FR-AI-005`, `FR-ALT-004`, `docs/discovery/41_OWNER_APPROVAL_GAPS.md`.
- **Root Cause**: Missing legal disclaimer and owner acknowledgment of auxiliary warning status.
- **Consequence**: Corporate negligence and legal exposure in the event of industrial fire incident.
- **Recommended Resolution**: Project Owner must formally sign `DEC-04` acknowledging auxiliary status.
- **Responsible Authority**: Project Owner.

---

### BLK-P0-04: Egyptian Law 151/2020 Legal Counsel Engagement (`DEC-06`)
- **Category**: `LEGAL BLOCKER` / `OWNER DECISION REQUIRED`
- **Severity**: **P0 (Critical)** | **Status**: `AWAITING SUBMISSION`
- **Description**: Biometric face processing and worker tracking carry criminal penalties under Egyptian Law 151/2020 without employee consent and PDPC licensing.
- **Evidence**: Egyptian Law No. 151 of 2020 Articles 12, 13, 14, 35.
- **Affected Documents**: `05_SECURITY_PRIVACY_AND_ACCESS.md`, Document 34.
- **Root Cause**: Statutory compliance requires licensed Egyptian legal counsel.
- **Consequence**: Corporate fines up to 1,000,000 EGP and criminal imprisonment risks.
- **Recommended Resolution**: Owner formally engages legal counsel to review Document 34 and issue compliance certification.
- **Responsible Authority**: Project Owner & Corporate Legal Counsel.

---

## 3. P1 — HIGH DEPENDENCIES (MANDATORY BEFORE SPRINT 1 COMPLETION)

| ID | Title | Category | Status | Summary & Required Action |
|----|-------|----------|--------|---------------------------|
| **BLK-P1-01** | Missing Go on Host PATH | Technical | `OPEN` | Install Go 1.22.6 LTS on Windows host or configure WSL2 build path. |
| **BLK-P1-02** | ZKTeco Photo Spike (`SPK-01`) | External Integration | `AWAITING AUTH`| Authorize bench test on isolated terminal to verify photo vs. template extraction. |
| **BLK-P1-03** | NVR Stream Probe (`SPK-03`) | External Integration | `AWAITING AUTH`| Authorize RTSP/WebRTC probe on 1 test NVR + 2 cameras to determine session limits. |
| **BLK-P1-04** | Missing Acceptance Criteria (14 FRs)| Documentation | `OPEN` | Add quantitative acceptance criteria and failure flows to 14 incomplete FRs in SRS. |
| **BLK-P1-05** | Fire Recipient Roster (`DEC-05`)| Owner Decision | `AWAITING SUBMISSION`| Owner must submit exact names and phone numbers for BNF & RNF fire alerts. |
| **BLK-P1-06** | Web Admin Console Sign-Off (`DEC-02`)| Owner Decision | `AWAITING SIGN-OFF`| Owner must formally accept React Web Admin console scope. |
| **BLK-P1-07** | Factory Material Taxonomy | Documentation | `OPEN` | Define exact list of manufactured goods for `FR-AI-006` theft/movement tracking. |

---

## 4. P2 — MEDIUM DEPENDENCIES (PHASE 2 & PHASE 3 EXECUTION)

| ID | Title | Category | Status | Summary & Required Action |
|----|-------|----------|--------|---------------------------|
| **BLK-P2-01** | WSL2 Memory Ceiling Config | Technical | `OPEN` | Add `.wslconfig` setting RAM limit to 4GB to prevent host OOM freezes. |
| **BLK-P2-02** | SQL Server Staging Schema (`SPK-04`)| External Integration | `AWAITING AUTH`| Obtain read-only staging backup of BNF and RNF attendance SQL databases. |
| **BLK-P2-03** | Camera Topology Graph Spec | Architectural | `OPEN` | Author transition matrix schema between cameras for Cross-Camera Re-ID. |
| **BLK-P2-04** | Incident Review State Machine | Documentation | `OPEN` | Define state transitions for `FR-ALT-008` (`NEW -> IN_REVIEW -> RESOLVED`). |
| **BLK-P2-05** | Production Storage Array (162 TB)| Production Only | `FUTURE HARDWARE`| Procure 16x 16TB SAS disk array per factory before production deployment. |
| **BLK-P2-06** | Production GPU Server (RTX 4000 Ada)| Production Only | `FUTURE HARDWARE`| Procure edge servers with modern enterprise GPUs before 200-camera rollout. |
| **BLK-P2-07** | Mobile Push Notification Service (`DEC-08`)| Owner Decision | `PROPOSED` | Authorize Firebase Cloud Messaging (FCM) credentials for mobile push. |
| **BLK-P2-08** | Automated PTZ Watchdog Stop | Architectural | `OPEN` | Implement 2.0s server watchdog stop to prevent runaway motorized camera movement. |

---

## 5. P3 — LOW DEPENDENCIES (DOCUMENTATION & CODE QUALITY)

- **BLK-P3-01**: Add OpenTelemetry tracing instrumentation spans to Go API middleware.
- **BLK-P3-02**: Standardize date formatting across all discovery documents to ISO 8601 (`YYYY-MM-DD`).
- **BLK-P3-03**: Remove deprecated legacy discovery notes that mention TensorFlow or MediaPipe.
- **BLK-P3-04**: Add unit test coverage percentage targets ($\ge 80\%$) to `07_TEST_STRATEGY_AND_ACCEPTANCE.md`.
- **BLK-P3-05**: Author Arabic localized strings dictionary for Flutter and React UI consoles.

---
**Audited By:** Principal AI Engineer / CTO & Enterprise Risk Lead  
**Governance Principle:** Blockers remain OPEN until verified by physical proof or signed owner approval.

