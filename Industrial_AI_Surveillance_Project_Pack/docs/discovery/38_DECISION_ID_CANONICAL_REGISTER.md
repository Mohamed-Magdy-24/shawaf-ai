# 38 — Canonical Decision ID Register & Cross-Reference Mapping

**Document ID:** DISC-38-DECISION-REGISTER  
**Version:** 1.1.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL REFERENCE STANDARD  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` (CTO Consistency Gate)  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Section 2  

---

## 1. Purpose & Problem Resolution

An audit of the Phase 0 remediation documents revealed cross-reference contradictions across documents:
- Document 10 and previous summaries referenced Web Administration Console scope as `DEC-04`.
- Document 20 previously assigned Web Administration Console scope to `DEC-03` and fire-alert policy to `DEC-04`.
- Document 35 introduced a segregated schema (`DEC-BUS-01` to `DEC-BUS-07` and `SPIKE-AUTH-01` to `SPIKE-AUTH-04`), while earlier texts referenced `DEC-01` through `DEC-08`.
- In textual discussions, ADR references were occasionally conflated (e.g., citing ADR-007 instead of ADR-010 for the client architecture).
- Video-viewing restrictions were redundantly proposed as a new decision (DEC-09) despite already being an approved stakeholder requirement (`D-011`).

To eliminate all ambiguity, this document establishes **one canonical, immutable ID register**. Every identifier refers to exactly one item. All documents across `docs/discovery/` and `antigravity/` are reconciled to this register.

---

## 2. Master Decision Register: Owner Business & Policy Decisions (`DEC-01` to `DEC-08`)

These decisions fall under the sole authority of the **Project Owner**. Engineering cannot approve or infer them.

| Canonical ID | Legacy ID (Doc 35) | Decision Title & Scope | Description & Engineering Implication | Authority |
|---|---|---|---|---|
| **DEC-01** | `DEC-BUS-01` | **Acceptance of Phase 0 Discovery & Remediation Baseline (Package v1.0.3 / Docs 01–44)** | Formal acceptance of the remediated Phase 0 documentation baseline (Package version `1.0.3-final-source-of-truth-correction`, Documents 01–44, root `MANIFEST.sha256` cryptographic fingerprint, and `PROJECT_HANDOFF.md`) as the canonical project baseline, source-of-truth hierarchy, and evidence register. | Project Owner |
| **DEC-02** | `DEC-BUS-02` | **Web Administration Console Scope Approval** | Formal approval to develop an on-premise browser-based Web Admin Console (for zone polygon drawing, camera mapping, and audit logs) alongside the manager Android application. | Project Owner |
| **DEC-03** | `DEC-BUS-03` | **Biometric Fallback Policy (Photo Upload Portal)** | Approval to deploy an administrative photo enrollment portal in the Web Admin Console if Phase 1 spike `SPK-01` confirms ZKTeco terminals export templates only. | Project Owner |
| **DEC-04** | `DEC-BUS-04` | **Zero-Gate Fire Alert Auxiliary Status Acknowledgment** | Formal acknowledgment that optical video fire AI is an auxiliary early-warning notification tool (dispatching without manual triage) and does **NOT** replace NFPA/civil defense certified industrial fire alarm systems. | Project Owner |
| **DEC-05** | `DEC-BUS-05` | **Fire Emergency Recipient Roster Submission** | Submission and approval of the designated on-site safety and operational personnel list for BNF and RNF receiving immediate fire alerts. | Project Owner |
| **DEC-06** | `DEC-BUS-06` | **Legal Counsel Engagement for Law 151/2020 & Decree 816/2025** | Formal submission of Document 34 to qualified Egyptian corporate legal counsel to initiate PDPC licensing, DPIA review, and employee notice workflows. | Project Owner |
| **DEC-07** | `DEC-BUS-07` | **Operational Calendar Cutoff Approval** | Confirmation that daily reporting rollups close at 23:59:59 `Africa/Cairo` local time, adopting Law 24/2023 Egyptian Daylight Saving Time rules. | Project Owner |
| **DEC-08** | New | **Cloud Push Notification Service (FCM) Authorization** | Authorization to integrate Google Firebase Cloud Messaging as an auxiliary off-site push channel, acknowledging external cloud and internet dependencies. | Project Owner |

> **GOVERNANCE NOTE ON VIDEO RESTRICTIONS:** Video-viewing permissions are **NOT** an open owner decision. They are a confirmed, mandatory baseline requirement established in **`D-011`** (live and recorded video streaming is restricted strictly to Security Managers and Senior Management). This requirement is not duplicated as a decision.

---

## 3. Master Spike Register: Engineering PoC Rig Authorizations (`SPK-01` to `SPK-04`)

These authorizations cover temporary, non-production laboratory testing. They require owner consent to access test devices or allocate benchmarking resources, but do **NOT** commit to production hardware purchases.

| Canonical ID | Legacy ID (Doc 35) | Technical Spike Title | Scope, Rig & Physical Equipment Required | Governance & Safety Boundary |
|---|---|---|---|---|
| **SPK-01** | `SPIKE-AUTH-01` | **ZKTeco Read-Only Photo Extraction Spike** | Execute read-only API and SDK queries against 1 isolated test terminal to inspect whether raw JPEG/PNG photos can be queried. | Zero write permissions; isolated test switch; test employee profile only. Resolves `BLK-001`. |
| **SPK-02** | `SPIKE-AUTH-02` | **ONNX Runtime GPU/CPU Inference Benchmark Spike** | Benchmark the mandatory ONNX Runtime CPU baseline and evaluate optional CUDA acceleration only after exact GPU, driver, CUDA, ONNX Runtime, and model compatibility has been established. YOLOX and RT-DETR are candidate detector families only; ByteTrack is a candidate intra-camera tracker. Exact model artifacts, checkpoint files, source revisions, model-weight licenses, dataset provenance, and checksums must be verified before using a model artifact. | No YOLOv8/Ultralytics, TensorRT, or DeepStream. Zero real factory video on public cloud. Use approved non-sensitive test data. SPK-02 remains AWAITING AUTHORIZATION. No production hardware procurement is authorized. |
| **SPK-03** | `SPIKE-AUTH-03` | **NVR Protocol & WebRTC Playback Spike** | Test `go2rtc` stream ingestion, RTSP sub-streams, and Profile G timeline playback seek against 1 test NVR and 2 test cameras. | Isolated test network; zero production NVR load. Resolves `BLK-003`. |
| **SPK-04** | `SPIKE-AUTH-04` | **SQL Server Schema Read-Only Export Spike** | Inspect table structures, collations, indexing, and data types against a restored staging backup of the BNF attendance database. | Read-only service account; zero PII data extraction; staging environment only. Resolves `OQ-005`. |

> **IMPORTANT MODEL CONSTRAINT FOR SPK-02:**
> YOLOX and RT-DETR must not be assumed to be direct replacements for YOLOv8-pose. If a fall-detection method requires pose/keypoint outputs, the exact pose-estimation model and its artifact license must be identified separately. Do not invent a pose-capable YOLOX or RT-DETR variant. Do not assume all candidate models provide equivalent outputs.

---

## 4. Master Architecture Decision Register (`ADR-001` to `ADR-011`)

These records govern system architecture and strictly match [`./17_ARCHITECTURE_DECISION_REGISTER.md`](./17_ARCHITECTURE_DECISION_REGISTER.md):

| Canonical ID | Architecture Decision Title | Summary of Invariant | Traceability / Dependent Items |
|---|---|---|---|
| **ADR-001** | **Federated Site Data Planes with Centralized Context Router** | BNF and RNF operate fully autonomous local data planes; cross-site context switching occurs via tokenized routing. | Traceable to `D-001`, `D-010`. |
| **ADR-002** | **Modular Monolith Business Core with Isolated Edge Video Workers** | Business workflows reside in a clean modular monolith; compute-heavy video ingestion runs in isolated OS worker processes. | Traceable to `D-004`, `D-018`. |
| **ADR-003** | **Clean Architecture (Ports and Adapters) Boundary Enforcement** | Domain layer has zero external dependencies; adapters wrap ZKBioTime, SQL Server, and NVR APIs. | Traceable to `QA-001`. |
| **ADR-004** | **Transactional Outbox Pattern with Consumer Idempotency** | Atomic persistence of domain events in PostgreSQL; guaranteed at-least-once delivery to queue. | Traceable to `D-012`, `D-013`. |
| **ADR-005** | **Conventional Photo Extraction Gate** | Face recognition pipeline is hard-gated on retrieving RGB photos; zero reverse engineering of templates. | Traceable to `D-007`, `BLK-001`. |
| **ADR-006** | **Embedded In-App Reporting Engine (Zero Power BI)** | Reporting engine runs native scheduled rollups inside the platform with zero external BI dependencies. | Traceable to `D-015`, `D-016`, `D-017`. |
| **ADR-007** | **Zero-Trust Video Gateway with Scoped Signed Access Tokens** | Video streaming is strictly role-gated to Security and Senior Management using 60-second HMAC tokens. | Traceable to `D-011`. |
| **ADR-008** | **Dedicated Hardware Acceleration (Enterprise GPU Procurement Post-Benchmark)** | Procure dedicated GPU servers only after `SPK-02` measures empirical per-frame inference latency. | Traceable to `BLK-002`, `SPK-02`. |
| **ADR-009** | **Decoupled Multi-Tier Alert Routing with Urgent Fire Fast-Path** | Fire alerts bypass manual human confirmation and triage, consistent with D-013 and D-014. The <500ms server-dispatch value is only a candidate engineering target; it is not an owner-approved or validated production SLO. Measurement conditions and acceptance thresholds require explicit approval and empirical benchmarking. | Traceable to `D-013`, `D-014`. |
| **ADR-010** | **Native Android Handheld Interface paired with Web Administration Console** | Managers use Flutter Android app; administrators use on-premise Web Admin Console. | Traceable to `D-009`, `DEC-02`. |
| **ADR-011** | **Proposed Multi-Language Stack & Technology Allocation** | **Status: PROPOSED — PENDING OWNER APPROVAL.** Inclusion in this register does not mean the runtime stack has been approved or selected. Core backend candidate in Go (Clean Architecture); AI workers in Python (gRPC); Web Admin in React/TypeScript/Vite; Mobile in Flutter/Dart; C++ strictly when benchmark-justified. | Traceable to CTO Directive on SRS Correction & Canonical Stack. Pending owner review & approval. |

---

## 5. Master Owner Requirements & Environmental Facts Register (`D-001` to `D-019`)

Strictly matching [`./27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md`](./27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md):

| Canonical ID | Parameter / Statement | Provenance Classification |
|---|---|---|
| **D-001** | BNF and RNF are operationally independent factories in data, compute, and physical network. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-002** | Each factory maintains its own separate, dedicated Microsoft SQL Server instance. | `OWNER_REPORTED_ENVIRONMENT_FACT` |
| **D-003** | Both factories use the ZKTeco ZKBioTime product family (independent instances). | `OWNER_REPORTED_ENVIRONMENT_FACT` |
| **D-004** | Approximately 200+ cameras per factory (approximate planning estimate, subject to audit). | `OWNER_REPORTED_ENVIRONMENT_FACT` |
| **D-005** | Approximately 18+ mixed biometric terminals per factory (approximate planning estimate). | `OWNER_REPORTED_ENVIRONMENT_FACT` |
| **D-006** | Stable Employee ID natural key exists in attendance and SQL Server records. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-007** | Face images exist only in biometric terminals/ZKBioTime; extraction is unproven. | `OWNER_REPORTED_ENVIRONMENT_FACT` |
| **D-008** | Video retention requirement is 30 days continuous storage. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-009** | Mobile client platform is Android exclusively. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-010** | Authorized managers can switch context between BNF and RNF within the application. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-011** | Live and recorded video streaming is restricted to Security Managers and Senior Management. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-012** | Ordinary alerts route to affected Factory Manager, Company Management, and Security Managers. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-013** | Fire alerts dispatch immediately to designated on-site safety/operational personnel. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-014** | Fire alert dispatch does not wait for manual human confirmation or triage gate. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-015** | Daily, weekly, and monthly reports with charts, KPIs, and percentages generated in-app. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-016** | No Power BI integration, subscriptions, or external reporting dependencies. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-017** | No email, SMS, or WhatsApp report delivery; all reports reside inside the application. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-018** | AI detection scope: PPE, restricted zones, falls, phones, fire, theft/object movement. | `OWNER_CONFIRMED_REQUIREMENT` |
| **D-019** | Maintain time-ordered history of employee sightings across cameras with location and timestamp. | `OWNER_CONFIRMED_REQUIREMENT` |

---

## 6. Master Critical Implementation Blockers Register (`BLK-001` to `BLK-007`)

Strictly matching [`./18_BLOCKERS_AND_OPEN_QUESTIONS.md`](./18_BLOCKERS_AND_OPEN_QUESTIONS.md):

| Blocker ID | Domain | Summary Description | Status | Resolution Action / Owner Dependency |
|---|---|---|---|---|
| **BLK-001** | Biometrics | ZKTeco biometric terminal photo export capability unproven. | `BLOCKED` | Execute `SPK-01`. If templates only, activate fallback `DEC-03`. |
| **BLK-002** | Hardware | Current on-premise server has zero GPU compute. | `BLOCKED` | Execute `SPK-02` on local test GPU; submit measured BOM for procurement. |
| **BLK-003** | NVR Fleet | Heterogeneous NVR models, firmware versions, and RTSP session caps unknown. | `UNKNOWN` | Execute `SPK-03` and conduct physical inventory per Document 32. |
| **BLK-004** | Network | Core switch uplink saturation risk at peak concurrent video/playback load. | `ESTIMATED` | Conduct switch audit; evaluate 10GbE SFP+ vs. LACP bonded links. |
| **BLK-005** | Legal / Privacy | Biometric processing and employee tracking uncertified under Law 151/2020. | `BLOCKED` | Submit Document 34 to corporate counsel (`DEC-06`); obtain written clearance. |
| **BLK-006** | Fire Routing | Designated emergency fire alert recipient rosters unassigned. | `UNKNOWN` | Project Owner submits authorized personnel lists (`DEC-05`). |
| **BLK-007** | Camera Clocks | NTP time synchronization drift across NVRs risks timeline inversion. | `UNKNOWN` | IT audit verifying all cameras and NVRs sync to local NTP server. |

---

## 7. Cross-Reference Mapping & Changelog Audit

```text
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| AFFECTED DOCUMENT     | OLD / CONFLICTING REFERENCE | CORRECTED CANONICAL REFERENCE | REMEDIATION ACTION                        |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 10           | "DEC-04" for Web Admin      | DEC-02                        | Updated Screen inventory lines 5, 15,     |
|                       |                             |                               | 30–43 to cite DEC-02 (Web Admin Scope).   |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 10           | "DEC-03/DEC-04" for SCR-12  | DEC-02 (Web) & DEC-03 (Photo) | Disambiguated photo upload fallback portal|
|                       |                             |                               | as requiring DEC-02 + DEC-03.             |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 17 (ADR-010) | Conflated text in summaries | ADR-010                       | Confirmed ADR-010 governs Web Admin.      |
|                       | citing ADR-007              |                               | ADR-007 governs Video Access Tokens.      |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 20           | Mixed DEC-01..DEC-08 schema | DEC-01..DEC-08 (Business) &   | Re-architected checklist into Section 2   |
|                       |                             | SPK-01..SPK-04 (Technical)    | (DEC-01..08) and Section 3 (SPK-01..04).  |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 35           | DEC-BUS-01..07              | DEC-01..DEC-08 (Business) &   | Harmonized notation: DEC-01..08 equates   |
|                       | SPIKE-AUTH-01..04           | SPK-01..SPK-04 (Technical)    | to DEC-BUS-01..08; SPK-01..04 to SPIKE.   |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
| Document 34           | Mentions Law 151/2025 typo  | Law 151/2020 & Decree 816/2025| Corrected statutory text and dates.       |
+-----------------------+-----------------------------+-------------------------------+-------------------------------------------+
```
