# 26 — Source of Truth, Document Precedence & Supersession Map

**Document ID:** DISC-26-PRECEDENCE  
**Version:** 1.1.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL GOVERNANCE DIRECTIVE  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` (CTO Audit & Governance)  

---

## 1. Executive Precedence Policy

To eliminate architectural contradictions, stale technology candidates, and conflicting storage/compute assertions across the project archive, this document establishes the **Single Canonical Source-of-Truth Hierarchy**.

When any statement, table, or calculation in an earlier document conflicts with a remediated or newer discovery document, the conflict is resolved strictly according to the precedence tiers defined below.

```text
====================================================================================================
                               DOCUMENT PRECEDENCE HIERARCHY
====================================================================================================
TIER 1 (Highest Authority):  Phase 0 Remediated Baseline & Consistency Deliverables (Docs 21–44, root MANIFEST.sha256, PROJECT_HANDOFF.md)
                             - Defines exact evidence taxonomy, 96-requirement SRS audit (Doc 43),
                               acceptance criteria gaps (Doc 42), cryptographic package manifest (Doc 44 / MANIFEST.sha256),
                               central handoff register (PROJECT_HANDOFF.md), recalculated storage/compute,
                               canonical decision IDs (Doc 38), and failure modes.
                             
TIER 2 (Core Architecture):  Remediated Core Discovery Deliverables (Docs 01–20, Rev 1.3+)
                             - Defines federated architecture, screen inventory, and testing strategy.
                             
TIER 3 (Baseline Pack):      Original Project Charter & Baseline Specs (Pack Root & Planning)
                             - Defines original mission, confirmed stakeholder baseline (D-001–D-019).
                             - Any stale technical details in Tier 3 are superseded by Tier 1 & 2.
====================================================================================================
```

---

## 2. Supersession & Canonical Ownership Map

For every critical engineering domain, exactly **one canonical owner document** is established. All other documents defer to the canonical owner.

| Engineering Domain / Topic | Current Authority | Historical / Superseded References |
|---|---|---|
| **Functional and Non-Functional Requirements** | Current SRS (`requirements/01_SRS.md`) & Document 43 (`docs/discovery/43_CURRENT_SRS_96_REQUIREMENT_REAUDIT.md`) | Historical SRS audits (`cto_readiness_audit_reports/03_SRS_FORENSIC_AUDIT.md`, `02_REQUIREMENTS_GAP_ANALYSIS.md`). |
| **Target Architecture** | `architecture/02_TARGET_ARCHITECTURE.md`, subject to ADR-011 | Historical architecture proposals (`08_TARGET_ARCHITECTURE_PROPOSAL.md`, `02_TARGET_ARCHITECTURE.md` drafts). |
| **Runtime Technology Decision** | ADR-011 (`planning/08_ADR_AND_OPEN_QUESTIONS.md`), `PROPOSED — PENDING OWNER APPROVAL` | Documents 23 and 40 (`docs/discovery/23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md`, `docs/discovery/40_VERSION_SUPPORT_AND_LOCKFILE_CANDIDATES.md`), superseded candidate research. |
| **Third-Party Licensing** | `docs/compliance/THIRD_PARTY_LICENSE_REGISTER.md` & `docs/compliance/CLEAN_ROOM_AND_REFERENCE_REPOSITORY_POLICY.md` | Historical license research in `03_REPOSITORY_DISCOVERY_REPORT.md` and initial audits. |
| **SPK-02 Benchmark** | Document 28 (`docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md`), `PROPOSED` and pending authorization | Historical GPU/TensorRT specifications; unmeasured 400 FPS throughput claims in `13` and `24`. |
| **Spike Authorization** | Documents 38 (`docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md`) & 41 (`docs/discovery/41_OWNER_APPROVAL_GAPS.md`) | Superseded Document 20 (`docs/discovery/20_OWNER_APPROVAL_CHECKLIST.md`). |
| **Current Archive Integrity** | Document 44 (`docs/discovery/44_CURRENT_PACKAGE_INVENTORY_AND_SHA256_MANIFEST.md`) & root `MANIFEST.sha256` | Historical Document 36 (`docs/discovery/36_FINAL_CONSISTENCY_AUDIT.md`) and inventory Document 02 (`cto_readiness_audit_reports/02_COMPLETE_DOCUMENT_INVENTORY.md`). |
| **Central Status & Handoff Authority** | `PROJECT_HANDOFF.md` (Package Root) | Superseded ad-hoc chat statuses and unverified completion summaries. |
| **Evidence Classification & Provenance** | [`./27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md`](./27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md) & [`./22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md`](./22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md) | `01_PROJECT_UNDERSTANDING.md` Section 3 table (where owner facts were labeled `VERIFIED_OFFICIAL_SOURCE`). |
| **Owner Review & Approval Instruments**| [`./35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md`](./35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md) & [`./41_OWNER_APPROVAL_GAPS.md`](./41_OWNER_APPROVAL_GAPS.md) | [`./20_OWNER_APPROVAL_CHECKLIST.md`](./20_OWNER_APPROVAL_CHECKLIST.md) (SUPERSEDED historical document; NOT valid for sign-off or execution). |
| **Storage & RAID-6 Mathematics** | [`./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md`](./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md) & [`./29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md`](./29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md) | Inconsistent RAID arithmetic in `13_INFRASTRUCTURE_ASSESSMENT.md`, `24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md`, and unverified 198.9 TB summary claims. |
| **Network Interfaces & LACP Topology** | [`./36_FINAL_CONSISTENCY_AUDIT.md`](./36_FINAL_CONSISTENCY_AUDIT.md) (Section 6) & [`./29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md`](./29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md) | Unqualified single-uplink 685 Mbps and 732 Mbps claims; conflated physical interfaces. |
| **Alert Delivery & Degraded Modes** | [`./39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md`](./39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md) & [`./30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md`](./30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md) | Unconditional "<800ms handset delivery" guarantees, APNs-specific FCM flags, and unauthorized FACP physical relay proposals in `08`, `17`, and `30`. |
| **Business Timezone & Calendar Cutoffs** | [`./31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md`](./31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md) | Unqualified UTC reporting cutoffs in `08_TARGET_ARCHITECTURE_PROPOSAL.md` and `14_TESTING_AND_QUALITY_STRATEGY.md`. |
| **Device Fleet & Protocol Compatibility** | [`./32_DEVICE_FLEET_INVENTORY_AND_COMPATIBILITY_PLAN.md`](./32_DEVICE_FLEET_INVENTORY_AND_COMPATIBILITY_PLAN.md) | Single-device PoC validation assumptions in `18_BLOCKERS_AND_OPEN_QUESTIONS.md`. |
| **UI Color Tokens & Contrast Math** | [`./33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md`](./33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md) | Inaccurate contrast ratio assertions and Sky Blue mislabeling in `09_UI_UX_DESIGN_STRATEGY.md`. |
| **Legal Compliance & Statutory Basis** | [`./34_LEGAL_REGISTER_CORRECTION_AND_COUNSEL_QUESTIONS.md`](./34_LEGAL_REGISTER_CORRECTION_AND_COUNSEL_QUESTIONS.md) | Mis-cited Article 11 DPIA, 72-hour subject breach claims, and Law 151/2025 typos in `11` and `25`. |
| **Skills Inventory & Verification** | [`./04_SKILLS_AUDIT.md`](./04_SKILLS_AUDIT.md) (Remediated Rev 1.2) | Unsanitized home directory paths and discrepancies in skill count totals. |
| **Master Prompts & Phase Execution** | [`../../antigravity/09_MASTER_OPERATING_PROMPT.md`](../../antigravity/09_MASTER_OPERATING_PROMPT.md) & [`../../antigravity/11_PHASE_PROMPTS.md`](../../antigravity/11_PHASE_PROMPTS.md) | Stale prompt instructions referencing superseded technology or unapproved Phase 1 execution. |
| **Acceptance Criteria Gap Register** | [`./42_REQUIREMENT_ACCEPTANCE_CRITERIA_GAPS.md`](./42_REQUIREMENT_ACCEPTANCE_CRITERIA_GAPS.md) | Authoritative register of 14 quantitative criteria gaps and 1 incomplete workflow state. |
| **Runtime Architecture Baseline** | [`../../architecture/02_TARGET_ARCHITECTURE.md`](../../architecture/02_TARGET_ARCHITECTURE.md) & `planning/08_ADR_AND_OPEN_QUESTIONS.md` | ADR-011 status is `PROPOSED — PENDING OWNER APPROVAL`; all candidates remain unapproved. |

> **GOVERNANCE RULE ON PRECEDENCE & DECISIONS:** No document or AI prompt can override written owner approvals or the canonical decision register (`38_DECISION_ID_CANONICAL_REGISTER.md`). Owner-confirmed requirements (`D-001` to `D-019`) retain highest authority. DEC-01 remains `AWAITING SIGN-OFF`.

---

## 3. Strict Operating Directives for AI Coding Agents

1. **Never Reintroduce Deprecated Tech:** Any reference to MinIO Community as an active production selection, unverified Flutter LTS versions, unmeasured 400 FPS CPU throughput, Video Codec SDK 13.x on driver 550, or unconditional zero-loss Redis claims is strictly prohibited.
2. **Obey the Evidence Tagging Mandate:** Every technical statement in future phase documentation must use the 7-tier canonical taxonomy (`VERIFIED_OFFICIAL_SOURCE`, `VERIFIED_OBSERVATION`, `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`, `ESTIMATED`, `PROPOSED`, `UNKNOWN`, `BLOCKED`). Never use `MEASURED_IN_POC` before empirical testing.
3. **Respect Execution Gates:** Phase 1 spikes may not execute without explicit, signed owner authorization on Document 35 and 41.
