> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# CROSS-DOCUMENT CONSISTENCY AUDIT & CONTRADICTION REGISTER
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-06 | Classification: FORENSIC CONSISTENCY AUDIT
### Status: COMPLETE AUDIT | Baseline Scope: All 65 Discovery, Architecture & Planning Documents

---

## 1. EXECUTIVE CONTRADICTION AUDIT SUMMARY

A forensic cross-document comparison was conducted across all 65 documents in the project repository. While the Phase 0 remediation pass resolved several earlier discrepancies, the audit identified **eight (8) substantive cross-document contradictions and ambiguities** that remain active and unclosed.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     CROSS-DOCUMENT CONTRADICTION REGISTER                   │
├────┬─────────────────────────────┬──────────┬───────────────────────────────┤
│ ID │ Discrepancy Topic           │ Severity │ Conflicting Document Sources  │
├────┼─────────────────────────────┼──────────┼───────────────────────────────┤
│ C1 │ DeepStream on Workstation   │ **P0**   │ Doc 08 & SDD vs. Doc 23 & H/W │
│ C2 │ Host Python Version (3.14)  │ **P0**   │ Live System vs. Doc 40        │
│ C3 │ Client Scope (Android vs Web│ **P1**   │ Charter & D-009 vs. Doc 09/SDD│
│ C4 │ Camera Count Target         │ **P1**   │ D-004 (200+) vs. Doc 24 (250) │
│ C5 │ Video Retention Policy      │ **P1**   │ D-008 (30d) vs. Ref-03 (48h)  │
│ C6 │ AI Pipeline Sampling FPS    │ **P2**   │ Doc 12 (5 FPS) vs. Ref-04     │
│ C7 │ Database Engine Selection   │ **P2**   │ Frigate/Viseron vs. Target SDD│
│ C8 │ pyzk Attendance Role        │ **P2**   │ Doc 03 vs. Ref-01 & SPK-01    │
└────┴─────────────────────────────┴──────────┴───────────────────────────────┘
```

---

## 2. DETAILED FORENSIC CONTRADICTION ANALYSIS

### Contradiction C1: NVIDIA DeepStream & TensorRT 10 on Pascal GPU (P0)
- **Source A**: `architecture/02_TARGET_ARCHITECTURE.md` (§3.2) and `docs/discovery/08_TARGET_ARCHITECTURE_PROPOSAL.md` state:
  > *"The platform utilizes NVIDIA DeepStream SDK 7.0 with TensorRT 10 execution providers for high-density multi-stream inference."*
- **Source B**: `docs/discovery/23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md` and live workstation inspection confirm:
  > *"Host GPU is NVIDIA Quadro P600 (Pascal GP107GL, Compute Capability SM 6.1). NVIDIA officially dropped SM 6.1 support in TensorRT 10.x, and DeepStream 7.0 mandates SM $\ge 7.5$."*
- **Engineering Consequence**: If a developer follows Source A and attempts to run DeepStream or build TensorRT 10 engines locally, the CUDA compiler fails with `CUDA_ERROR_NO_BINARY_FOR_GPU`.
- **Authoritative Resolution**: **Purge DeepStream from local workstation baseline.** Designate ONNX Runtime FP32 as the local development runtime. Retain DeepStream strictly as a future production target for Ampere/Ada servers `[ADR-011]`.

---

### Contradiction C2: Host Python Version Incompatibility (P0)
- **Source A**: Live host environment inspection via `python --version` returns:
  > `Python 3.14.4` installed on host PATH.
- **Source B**: `docs/discovery/40_VERSION_SUPPORT_AND_LOCKFILE_CANDIDATES.md` mandates:
  > *"Python packages: PyTorch 2.4.x, ONNX Runtime 1.19.x, torchvision 0.19.x."*
- **Engineering Consequence**: Official PyTorch, torchvision, and ONNX Runtime wheels do not support Python 3.14. Attempting to install PyTorch on Python 3.14 fails with missing prebuilt C++ wheels.
- **Authoritative Resolution**: **Mandate a dedicated Python 3.11 virtual environment or Dockerized container** for the Python AI worker. Never invoke the host's global Python 3.14 runtime.

---

### Contradiction C3: Application Client Scope — Android Only vs. Web Admin (P1)
- **Source A**: `Industrial_AI_Surveillance_Project_Pack/00_PROJECT_CHARTER.md` and `planning/08_ADR_AND_OPEN_QUESTIONS.md` (`D-009`) explicitly state:
  > *"Android application only. No web administration client is in scope."*
- **Source B**: `requirements/01_SRS.md` (§4.9, `FR-WEB-001`..`006`) and `architecture/02_TARGET_ARCHITECTURE.md` introduce:
  > *"A desktop browser Web Administration Console (React / TypeScript / Vite) for system management, zone polygon editing, and incident investigation."*
- **Engineering Consequence**: Contractual scope creep. The owner confirmed `D-009` (Android only), but the engineering discovery team added a full React Web Admin console without a signed decision.
- **Authoritative Resolution**: **Requires formal Owner Sign-Off on `DEC-02`**. Drawing complex polygon exclusion zones on a 6-inch phone screen is operationally unviable, justifying the Web Admin console, but it must be formally accepted by the Project Owner.

---

### Contradiction C4: Camera Capacity Targets — 200+ vs. 250 Cameras (P1)
- **Source A**: Stakeholder Fact `D-004` and `01_SRS.md` specify:
  > *"Approximately 200+ cameras per factory."*
- **Source B**: `docs/discovery/24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md` and `docs/discovery/29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md` calculate storage and bandwidth using:
  > *"Baseline sizing: 250 cameras per factory."*
- **Engineering Consequence**: Discrepancy of 50 cameras per factory (100 cameras total across BNF and RNF), altering storage requirements by **40.5 Terabytes** and network bandwidth by **125 Mbps**!
- **Authoritative Resolution**: Standardize on **200 cameras as the baseline SLA target**, with 250 cameras documented as the "Maximum Stress Ceiling (+25% Headroom)."

---

### Contradiction C5: Video Retention Duration — 30 Days Continuous vs. 48 Hours Hot (P1)
- **Source A**: Confirmed Owner Requirement `D-008` and `NFR-DATA-001` declare:
  > *"Recorded video shall be retained for 30 days."*
- **Source B**: `docs/reference_research/CAMERA_AND_NVR_REFERENCE_ANALYSIS.md` (§4.2) specifies:
  > *"Continuous 24/7 video retained for 48 hours on local NVMe; unflagged footage overwritten after 48h; only AI events retained for 30 days."*
- **Engineering Consequence**: Storing 30 days of continuous 24/7 video for 200 cameras @ 1080p requires **162 TB usable storage per factory** ($324\text{ TB}$ total). Storing only 48 hours continuous + 30 days incident clips reduces storage to **18 TB per factory**—an 88.8% cost reduction!
- **Authoritative Resolution**: **Owner Decision Required**. The owner must confirm whether the 30-day mandate requires continuous recording of all cameras or continuous retention of verified incident clips only.

---

### Contradiction C6: AI Frame Sampling Rates (P2)
- **Source A**: `docs/discovery/12_VIDEO_AI_EVALUATION_PLAN.md` (§3.1) specifies:
  > *"Fixed 5 FPS inference sampling across all analytics tasks."*
- **Source B**: `docs/reference_research/AI_PIPELINE_REFERENCE_ANALYSIS.md` (§2.2) specifies multi-rate sampling:
  > *"Person detection @ 5 FPS, Fall detection @ 15 FPS, Fire detection @ 1 FPS."*
- **Engineering Consequence**: Fixed 5 FPS causes fall detection to miss rapid human collapses (which occur in 400–800 ms), while running fire detection at 5 FPS wastes GPU cycles.
- **Authoritative Resolution**: Adopt the **Multi-Rate Frame Sampling Strategy** defined in `REF-RES-04`. Update `04_VIDEO_AI_SPEC.md` to eliminate the fixed 5 FPS rule.

---

### Contradiction C7: Database Architecture — SQLite vs. PostgreSQL (P2)
- **Source A**: Open-source references Frigate and Viseron use SQLite via `peewee` or `SQLAlchemy`.
- **Source B**: Canonical Architecture `02_TARGET_ARCHITECTURE.md` mandates PostgreSQL 16 + TimescaleDB.
- **Resolution**: Fully resolved by `ADR-001` and `ADR-011`. SQLite is permanently rejected for production multi-factory operations due to write lock contention and lack of Row-Level Security.

---

### Contradiction C8: pyzk Role — Primary Integration vs. Offline Bench Spike (P2)
- **Source A**: Early discovery notes suggested using `pyzk` to poll ZKTeco terminals every 60 seconds.
- **Source B**: Reference research (`REF-RES-01`, `REF-RES-06`) confirmed pyzk causes microcontroller freezes on older firmware.
- **Resolution**: Fully resolved. pyzk is restricted strictly to Spike `SPK-01` bench discovery; production integration must use ZKBioTime REST API or read-only SQL Server views.

---

## 3. OPEN DECISIONS NEEDED REGISTER

| Decision ID | Conflict Description | Required Authority | Recommended CTO Direction |
|-------------|----------------------|--------------------|---------------------------|
| **DEC-01** | Phase 0 Baseline Acceptance | Project Owner | Sign off to lock baseline. |
| **DEC-02** | Web Admin Console Scope | Project Owner | Formally approve Web Admin. |
| **DEC-04** | Fire Alert Auxiliary Status | Project Owner | Sign off legal liability waiver. |
| **DEC-05** | Fire Emergency Recipient Roster | Project Owner | Submit BNF & RNF rosters. |
| **DEC-06** | Law 151/2020 Counsel Engagement| Project Owner / Legal | Engage Egyptian data counsel. |
| **DEC-RET** | 30-day Continuous vs. Event-Only| Project Owner | Approve Tiered Storage (48h continuous + 30d events). |

---
**Audited By:** Principal AI Engineer / CTO  
**Standards Compliance:** Architectural Trade-off Analysis Method (ATAM)

