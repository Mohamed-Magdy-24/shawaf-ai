> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 35 — Phase 0 Final Review & Segregated Owner Decision Register

**Document ID:** DISC-35-FINAL-REVIEW  
**Version:** 1.2.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL PHASE 0 CLOSING DELIVERABLE  
**Classification:** `PROPOSED` (Decisions Awaiting Owner Sign-Off)  
**Directive Reference:** Sections 2 & 13 of CTO Review, Documents 38 & 41  

---

## 1. Executive Summary: Clean Separation of Owner Choices vs. Engineering Proofs

In strict accordance with the CTO Review:
> **The engineering organization must never presume owner approval, pre-approve business scope, or bundle technical proofs with commercial authorizations.**
> Decisions requiring business governance, capital expenditure, or legal policy are cleanly separated from technical proof-of-concept tasks.

This document serves as the final review gateway for Phase 0. **No application code, package installation, Git repository, hardware purchase, production deployment, or real biometric processing is authorized.**

---

## 2. Segregated Master Decisions Matrix (Owner Choices vs. Technical Proofs)

### Group A: Business Governance & Policy Choices (Sole Authority of Project Owner)

| Decision Item | Decision Scope & Description | Engineering Context & Implication | Owner Decision | Notes / Stakeholder Conditions |
|---|---|---|---|---|
| **DEC-01** | **Acceptance of Phase 0 Discovery & Remediation Baseline (Package v1.0.3 / Docs 01–44):** Approval of the remediated Phase 0 documentation baseline (Package version `1.0.3-final-source-of-truth-correction`, Documents 01–44, root `MANIFEST.sha256`, and `PROJECT_HANDOFF.md`). | Locks the requirements baseline (SRS 1.0.0, 96 reqs), evidence classifications, package version 1.0.3, and cryptographic checksums. | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-02** | **Web Administration Console Scope Approval:** Approval to provide an on-premise browser Web Admin Console for safety/IT staff alongside the manager Android app. | Android manager app is confirmed; Web Admin is a proposed addition for zone drawing and camera mapping. | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-03** | **Biometric Fallback Policy (Photo Upload Portal):** Approval to deploy an administrative photo upload studio if ZKTeco terminals export templates only. | Decouples project success from legacy terminal firmware limitations. | [ ] APPROVED<br/>[ ] REJECTED<br/>[ ] REVISED | |
| **DEC-04** | **Zero-Gate Fire Alert Auxiliary Status Acknowledgment:** Formal acknowledgment that optical video fire AI is an auxiliary early warning tool, not an NFPA certified fire alarm replacement. | Limits corporate liability and ensures conventional alarms remain primary. | [ ] APPROVED<br/>[ ] REJECTED | |
| **DEC-05** | **Fire Emergency Recipient Roster Submission:** Provision and authorization of the official on-site safety emergency personnel list for BNF and RNF. | Required to populate the urgent fire alert routing matrix. | [ ] APPROVED<br/>[ ] PENDING | |
| **DEC-06** | **Legal Counsel Engagement for Law 151/2020 & Decree 816/2025:** Authorization to submit Document 34 to corporate counsel to initiate PDPC licensing and employee privacy notices. | Prerequisite for activating production facial recognition and tracking. | [ ] APPROVED<br/>[ ] REJECTED | |
| **DEC-07** | **Operational Calendar Cutoff Approval:** Confirmation that daily reporting rollups close at 23:59:59 `Africa/Cairo` local time. | Aligns reporting with factory working shifts. | [ ] APPROVED<br/>[ ] REJECTED | |
| **DEC-08** | **Cloud Push Notification Service (FCM) Authorization:** Authorization to integrate Google Firebase Cloud Messaging as an auxiliary off-site push channel. | Acknowledges external network and cloud dependencies. | [ ] APPROVED<br/>[ ] REJECTED | |

> **GOVERNANCE NOTE:** Video viewing permissions are already established as an approved mandatory requirement under **`D-011`** (live and recorded video streaming restricted strictly to Security Managers and Senior Management). This is a confirmed constraint, not an open owner decision.

### Group B: Technical Spikes & PoC Rig Authorizations (SPK-01 to SPK-04)

| Spike Authorization | Technical Spike Scope & Constraints | Resource Required | Owner Decision | Safety & Governance Constraints |
|---|---|---|---|---|
| **SPK-01** | **ZKTeco Read-Only Photo Spike:** Authorization to run read-only API query against 1 isolated test terminal. | 1 isolated test terminal on test switch. | [ ] AUTHORIZED<br/>[ ] DEFERRED | Zero write permissions; test employee only. Resolves `BLK-001`. |
| **SPK-02** | **On-Premise GPU Benchmark Rig:** Authorization to bench candidate models (YOLOX / RT-DETR) and ByteTrack on ONNX Runtime (CPU baseline and optional CUDA) on a dedicated local test GPU. | 1 local test GPU workstation (e.g. RTX 3090/4000/A4000). | [ ] AUTHORIZED<br/>[ ] DEFERRED | **Zero real factory video on public cloud** without legal approval. Non-sensitive test loops. Resolves `BLK-002`. |
| **SPK-03** | **NVR Protocol & WebRTC Playback Spike:** Authorization to test `go2rtc` stream multiplexing on 1 test NVR + 2 test cameras. | 1 test NVR unit + 2 IP test cameras. | [ ] AUTHORIZED<br/>[ ] DEFERRED | Isolated test network; zero production NVR load. Resolves `BLK-003`. |
| **SPK-04** | **SQL Server Schema Read-Only Export:** Authorization to inspect table structures on a restored staging copy. | Staging database backup copy. | [ ] AUTHORIZED<br/>[ ] DEFERRED | Read-only service account; zero PII export. Resolves `OQ-005`. |

---

## 3. Explicit Prohibitions & Open Items

The following items **REMAIN STRICTLY OPEN AND UNAUTHORIZED**:
- **NO Production Server Hardware Purchases:** Final server procurement is frozen until Phase 1 benchmarks prove exact throughput on candidate models.
- **NO Real Employee Biometric Processing:** Face embedding extraction on factory workers is blocked until legal counsel issues written certification under Law 151/2020 (`BLK-005`).
- **NO Cloud GPU Upload of Factory Footage:** Testing must occur on physically isolated on-premise hardware unless legal counsel approves cross-border data transfer.
- **NO Arbitrary SLO Commitments:** Latency targets (<500ms server dispatch, WebRTC latency, 99.x% uptime) remain candidate SLOs until benchmarked.

---

## 4. Formal Review & Sign-Off Execution Block

```text
====================================================================================================
                        PHASE 0 FORMAL CLOSING & PHASE 1 SPIKE AUTHORIZATION
====================================================================================================

Project Name:       Industrial Smart Surveillance Platform (BNF & RNF)
Milestone:          Phase 0 Final Review & Remediation Sign-Off
Governing Archive:  docs/discovery/ (Documents 01 through 41)

PROJECT OWNER / EXECUTIVE SPONSOR:

Name:       __________________________________________________
Title:      __________________________________________________
Company:    __________________________________________________
Signature:  __________________________________________________
Date:       ________________________ (YYYY-MM-DD)

DECISION:   [  ] PHASE 1 TECHNICAL SPIKES AUTHORIZED (Group B Only)
            [  ] REVISIONS MANDATED (See Notes Below)
            [  ] PROJECT FROZEN / ON HOLD

STAKEHOLDER DIRECTIVES & CONDITIONS:
____________________________________________________________________________________________________
____________________________________________________________________________________________________
====================================================================================================
```

---

## 5. Next Operational Steps

Upon receipt of signed authorization:
1. Provision the **isolated on-premise PoC test bench** (1 test GPU, 1 test NVR, 2 test cameras, 1 standalone terminal).
2. Execute Spikes 1 through 4 in strict isolation.
3. Submit empirical benchmark logs at **Gate 1**.
