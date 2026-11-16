> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 20 — Project Owner Review, Sign-Off & Phase 1 Authorization Checklist (Historical Archive)

**Document ID:** DISC-20-APPROVAL-CHECKLIST  
**Version:** 1.3.0-historical  
**Date:** 2026-11-11  
**Status:** SUPERSEDED — HISTORICAL / NOT FOR SIGN-OFF OR EXECUTION  
**Classification:** HISTORICAL SNAPSHOT / NOT FOR EXECUTION  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Documents 36, 38 & 41  

> **SUPERSEDED — HISTORICAL DOCUMENT — NOT VALID FOR OWNER SIGN-OFF OR EXECUTION**
>
> This checklist contains obsolete decision descriptions, technology references, and authorization wording.
>
> It must not be used as an active approval instrument, implementation instruction, or source of owner authorization.
>
> Current canonical decision statuses are maintained in:
> - `docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md`
> - `docs/discovery/41_OWNER_APPROVAL_GAPS.md`
> - `docs/discovery/35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md`
>
> In case of conflict, these canonical documents and explicit written owner approvals take precedence.  

---

## 1. Executive Summary & Purpose

This checklist serves as the formal gateway between **Phase 0 (Discovery, Audit & Remediation)** and **Phase 1 (Technical & Hardware Spikes)**.

In accordance with CTO Operating Principles:
> **The project owner remains responsible for business direction, product goals, and final governance approvals. The engineering organization is responsible for providing high-grade technical judgment, exposing hidden risks, and preventing avoidable mistakes.**

No application code generation, package installations, repository pushes, hardware purchases, or production changes will commence until the decisions below are formally reviewed and signed off by the Project Owner.

---

## 2. Group A: Master Business & Policy Decisions (DEC-01 to DEC-07)

Every decision below falls under the sole authority of the **Project Owner**. Engineering cannot approve or infer them.

| Decision ID | Decision Title & Scope | Technical Recommendation | Owner Decision | Stakeholder Notes / Conditions |
|---|---|---|---|---|
| **DEC-01** | **Acceptance of Phase 0 Discovery Baseline (Docs 01–41):** Formal acceptance of documents `01` through `41` as the canonical project baseline, source-of-truth hierarchy, and evidence register. | **RECOMMENDED: APPROVE** | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-02** | **Web Administration Console Scope Approval:** Approval to provide an on-premise browser Web Admin Console (for zone polygon drawing, camera mapping, and audit logs) alongside the manager Android application. | **RECOMMENDED: APPROVE** (Drawing polygon geofences on mobile screens is an operational failure). | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-03** | **Biometric Fallback Policy (Photo Upload Portal):** Approval to deploy an administrative photo enrollment portal in the Web Admin Console if Phase 1 spike `SPK-01` confirms ZKTeco terminals export templates only. | **RECOMMENDED: APPROVE** (Decouples project success from legacy terminal firmware limitations). | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-04** | **Zero-Gate Fire Alert Auxiliary Status Acknowledgment:** Formal acknowledgment that optical video fire AI is an auxiliary early-warning notification tool (dispatching without manual triage) and does **NOT** replace certified industrial fire alarm systems. | **CONFIRMED BASELINE: APPROVE** (Limits liability; conventional alarms remain primary). | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-05** | **Fire Emergency Recipient Roster Submission:** Submission and formal approval of the designated on-site safety and operational personnel list for BNF and RNF receiving immediate fire alarms. | **MANDATORY FOR PHASE 5** | [ ] APPROVED<br/>[ ] PENDING | |
| **DEC-06** | **Legal Counsel Engagement for Law 151/2020 & Decree 816/2025:** Formal submission of Document 34 to qualified Egyptian corporate legal counsel to initiate PDPC licensing, DPIA review, and employee notice workflows. | **MANDATORY FOR BIOMETRICS: APPROVE** | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-07** | **Operational Calendar Cutoff Approval:** Confirmation that daily reporting rollups close at 23:59:59 `Africa/Cairo` local time, adopting Egyptian Law No. 24 of 2023 Daylight Saving Time rules. | **RECOMMENDED: APPROVE** (Aligns reports with factory shifts). | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-08** | **Cloud Push Notification Service (FCM) Authorization:** Authorization to integrate Google Firebase Cloud Messaging as an auxiliary off-site push channel. | **RECOMMENDED: APPROVE** (Acknowledges external cloud and internet dependency). | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |

> **GOVERNANCE NOTE:** Video viewing permissions are already established as an approved mandatory requirement under **`D-011`** (live and recorded video streaming restricted strictly to Security Managers and Senior Management). This is a confirmed constraint, not an open owner decision.

---

## 3. Group B: Engineering Technical Spike Authorizations (SPK-01 to SPK-04)

These authorizations cover temporary, non-production laboratory testing. They require owner consent to access test devices or allocate benchmarking resources, but do **NOT** commit to production hardware purchases.

| Spike ID | Spike Scope & Rig Required | Technical Recommendation | Owner Decision | Governance & Safety Boundary |
|---|---|---|---|---|
| **SPK-01** | **ZKTeco Read-Only Photo Spike:** Query 1 isolated test terminal on test switch. | **MANDATORY FOR BLK-001** | [ ] AUTHORIZED<br/>[ ] DEFERRED | Read-only API; 1 test employee profile; zero write permissions. |
| **SPK-02** | **On-Premise GPU Inference Benchmark Rig:** Benchmark YOLOv8, ByteTrack, TensorRT on 1 local GPU workstation. | **MANDATORY FOR BLK-002** | [ ] AUTHORIZED<br/>[ ] DEFERRED | **Zero real factory video on public cloud.** Synthetic test loops. |
| **SPK-03** | **NVR Protocol & WebRTC Playback Spike:** Test `go2rtc` stream ingest and Profile G seek on 1 test NVR + 2 cameras. | **MANDATORY FOR BLK-003** | [ ] AUTHORIZED<br/>[ ] DEFERRED | Isolated test network; zero production NVR load. |
| **SPK-04** | **SQL Server Schema Read-Only Export:** Inspect table structures on restored staging database backup. | **MANDATORY FOR OQ-005** | [ ] AUTHORIZED<br/>[ ] DEFERRED | Read-only account; zero PII data export; staging only. |

---

## 4. Risk Acceptance Acknowledgement

By approving this checklist, the Project Owner acknowledges the following operational truths exposed during Phase 0:

1. **AI Observations vs. Facts:** An AI detection (e.g., suspected fall, suspected phone use, candidate face match) is a probabilistic observation with an attached confidence score. It must never be used as automatic proof of misconduct or legal guilt without independent human supervisor verification.
2. **Auxiliary Fire Role:** Video AI fire and smoke detection is an auxiliary early-warning tool and does **NOT** replace certified industrial fire alarm systems.
3. **Hardware Procurement Timing:** No production server hardware (BOM) should be purchased until the Phase 1 GPU benchmarking spike measures empirical inference latency and throughput under Document 28 protocol.
4. **Legal Compliance Prerequisite:** Production facial recognition and employee tracking history are subject to formal privacy certification under Egyptian Personal Data Protection Law No. 151 of 2020 and Prime Ministerial Decree 816 of 2025.
5. **Strict No-Mock-Data Policy:** The platform will strictly display genuine empty states and connection indicators when physical data is unavailable. The engineering team will never fabricate fake employees, mock alerts, or artificial charts to make the interface look populated.

---

## 5. Formal Sign-Off & Phase 1 Execution Authorization

```text
====================================================================================================
                                FORMAL EXECUTIVE SIGN-OFF BLOCK
====================================================================================================

Project Name:       Industrial Smart Surveillance Platform (BNF & RNF)
Review Milestone:   Phase 0 — Engineering Discovery, Remediation & Final Consistency Gate
Target Activation:  Phase 1 — Technical Spikes & Hardware Verification

PROJECT OWNER / EXECUTIVE SPONSOR:

Name:       __________________________________________________
Title:      __________________________________________________
Company:    __________________________________________________
Signature:  __________________________________________________
Date:       ________________________ (YYYY-MM-DD)

DECISION:   [  ] PHASE 1 FULLY AUTHORIZED TO COMMENCE
            [  ] REVISIONS REQUIRED BEFORE PHASE 1 (See Notes Below)
            [  ] PROJECT ON HOLD

EXECUTIVE NOTES & DIRECTIVES:
____________________________________________________________________________________________________
____________________________________________________________________________________________________
____________________________________________________________________________________________________
====================================================================================================
```

---

## 6. Next Operational Steps

Upon receipt of signed authorization:
1. Initialize Phase 1 Spikes:
   - `SPK-01`: Execute read-only ZKTeco photo retrieval test on test terminal.
   - `SPK-02`: Stand up local GPU workstation to benchmark TensorRT 10.7.0.23 on factory video clips per Document 28.
   - `SPK-03`: Run `go2rtc` stream multiplexing and Profile G playback seek test against test NVR.
   - `SPK-04`: Inspect SQL Server read-only schema.
2. Submit Phase 1 Spike Reports and capability matrices at **Gate 1**.
