# REQUIREMENT ACCEPTANCE CRITERIA GAPS & UNRESOLVED THRESHOLDS
## Industrial AI Surveillance Platform — BNF & RNF
**Document ID:** DISC-GAP-042  
**Classification:** Canonical Requirements Gap Register  
**Status:** ACTIVE GAPS REGISTER — PENDING OWNER & BENCHMARK INPUTS  
**Baseline Examined:** `requirements/01_SRS.md` — Baseline 1.0.0  
**Audit Reference:** `docs/discovery/43_CURRENT_SRS_96_REQUIREMENT_REAUDIT.md`  
**Last Updated:** 2026-11-16  

---

## 1. PURPOSE & AUDIT NOTICE

In accordance with strict requirements engineering discipline, numerical thresholds, timing bounds, and accuracy criteria must not be fabricated merely to achieve formal completeness. 

The canonical 96-requirement re-audit (`docs/discovery/43_CURRENT_SRS_96_REQUIREMENT_REAUDIT.md`) identified 14 Functional and Non-Functional Requirements in `requirements/01_SRS.md` (Baseline 1.0.0) that specify functional or maintenance capabilities but lack validated, quantitative acceptance criteria. This document maintains these gaps in an explicitly unresolved state until representative factory footage, network probes, and formal owner decisions are provided.

---

## 2. ACCEPTANCE CRITERIA GAPS REGISTER

| Requirement ID | Missing Criterion | Required Evidence/Input | Proposed Verification | Owner Decision Required | Status |
|---|---|---|---|---|---|
| **FR-SITE-006** | Multi-site aggregated dashboard load time and query latency thresholds | Network bandwidth measurement between factory edge nodes and management console | End-to-end latency benchmark across simulated site-to-site VPN link | Maximum acceptable cross-site dashboard latency target | UNRESOLVED |
| **FR-VID-010** | Camera capability discovery timeout duration and offline camera retry backoff intervals | Camera network inventory and physical device connection stability data | Network timeout and retry test harness against physical CCTV VLAN | Maximum discovery timeout and offline probe retry frequency | UNRESOLVED |
| **FR-VID-013** | Motorized PTZ travel speed limits and automatic server watchdog stop timeout | Physical PTZ camera specifications and mechanical travel tolerances | Automated command stop tests on physical PTZ test bench | Maximum continuous PTZ move duration before safety stop | UNRESOLVED |
| **FR-VID-014** | Automated PTZ tracking handoff algorithm, target loss re-acquisition time, and frame rate bounds | Factory floor spatial layout, camera field of view overlap, and PTZ motor response time | Multi-camera field tracking evaluation on representative factory footage | Approval of automated tracking policy and handoff rules | UNRESOLVED |
| **FR-AI-001** | Minimum pixel dimensions for worker bounding boxes, precision/recall targets for helmet and vest | Representative factory floor camera footage with varied lighting and worker distances | Held-out validation dataset evaluated against confusion matrix | Minimum acceptable PPE precision/recall and alert threshold | UNRESOLVED |
| **FR-AI-002** | Geofence dwell time tolerance, entry debounce latency, and false alert rate for restricted area intrusion | Factory layout zone geometry and operational workflow patterns | Simulation of boundary traversal across configured polygon geofences | Definition of authorized dwell vs. intrusion triggers | UNRESOLVED |
| **FR-AI-003** | Temporal fall detection latency, duration threshold distinguishing falls from sitting/kneeling, and false alert rate per camera-hour | Labeled factory video dataset of staged falls, normal sitting, bending, and machine maintenance | Confusion matrix evaluation on held-out factory validation dataset | Formal acceptance of fall detection evaluation protocol and false-positive tolerance | UNRESOLVED |
| **FR-AI-004** | Maximum camera mounting height and viewing angle bounds for reliable phone-use classification | Camera placement survey across factory work cells and ceiling height measurements | Optical test evaluation across ceiling-mounted vs. eye-level camera angles | Approval of designated camera locations eligible for phone monitoring | UNRESOLVED |
| **FR-AI-006** | Approved factory material and product taxonomy; distinguishing visual criteria | Owner-approved list of tracked products, cartons, sacks, and raw materials for BNF & RNF | Visual classification benchmark on factory-labeled material images | Official factory product and packaging taxonomy approval | UNRESOLVED |
| **FR-AI-007** | Permitted material transfer zones, authorized operating schedules, and transfer duration thresholds | Facility zone layout, warehouse operating hours, and authorized employee material handling routes | Simulation of material movement across configured geofences | Definition of authorized vs. suspicious material transfer rules | UNRESOLVED |
| **FR-AI-008** | Sighting retention period, maximum tracking gap duration, and cross-camera matching confidence threshold | Facility transit times between camera coverage areas and storage capacity budget | Multi-camera sighting reconciliation benchmark | Retention period policy for person movement history | UNRESOLVED |
| **FR-AI-014** | Camera topology graph schema, spatial transition matrix, and minimum/maximum transit times | Measured physical distances and walking travel times between camera coverage areas | Adjacency graph constraint validation tests on real sighting logs | Approval of site-specific camera topology transition matrix | UNRESOLVED |
| **FR-ALT-002** | Concrete alert recipient roster per factory, shift-based routing schedules, and delivery escalation timeouts | Official employee names, phone numbers, and notification escalation hierarchy from BNF & RNF | In-app notification delivery and receipt verification test | Submission of confirmed recipient rosters for BNF and RNF (`DEC-05`) | UNRESOLVED |
| **NFR-MNT-002** | Minimum automated test coverage target percentage (e.g. $\ge 80\%$) across core domain, API, and storage contracts | DevSecOps CI/CD quality gate policy and test suite complexity metrics | Automated code coverage report generated during build pipeline | Formal adoption of target coverage threshold | UNRESOLVED |

---

## 3. AUDIT CLASSIFICATION NOTES & ADDITIONAL EVIDENCE GAPS

1. **FR-ALT-008 (Incident Review Workflow):** Classified as `INCOMPLETE / TBD` in the baseline SRS. Alert acknowledgement, incident investigation, resolution, and dismissal states remain explicitly unresolved pending formal owner approval (`OQ-021`).
2. **FR-VID-004 & FR-VID-005 (Video Viewing Latency & Scrubbing Targets):** User authorization to view live streams and recordings is confirmed under owner decision `D-011` (restricted strictly to Security Managers and Senior Management). However, empirical glass-to-glass latency targets ($< 500\text{ms}$ WebRTC) and seek latency ($< 1.0\text{s}$) remain performance optimization goals subject to validation against real edge network conditions in Phase 1.
3. **Traceability Parity:** The 14 missing criteria above, together with `FR-ALT-008`, represent the exact 15 requirements classified as `TBD` in the canonical traceability matrix (`planning/09_REQUIREMENTS_TRACEABILITY.csv`).
4. **Resolution Prerequisite:** No requirement listed above shall be marked `VALIDATED` or `CONFIRMED` until the required factory evidence, labeled video datasets, or owner decisions have been formally supplied and verified.

