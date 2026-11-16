> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 21 — Phase 0 Remediation Changelog & Technical Audit

**Document ID:** DISC-21-REMEDIATION-CHANGELOG  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** REMEDIATION COMPLETE  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** CTO DIRECTIVE — PHASE 0 REMEDIATION & EVIDENCE VALIDATION  

---

## 1. Executive Summary & Purpose

Following formal technical review of the initial Phase 0 Discovery Deliverables (`01` through `20`), this remediation document records every corrected assertion, revised technical calculation, revalidated architectural assumption, and updated evidence classification.

The remediation establishes total adherence to the Principal AI Engineer / CTO operating pattern:
- **No speculation presented as fact.**
- **No hardware or license approvals granted without empirical benchmarks.**
- **Clear separation between verified observations, official vendor specifications, calculated assumptions, and unproven blockers.**
- **Zero code generated; strict documentation remediation under `docs/discovery/`.**

---

## 2. Master Itemized Remediation Register

The following table itemizes every material correction enacted across the Phase 0 baseline:

| Section / Topic | Original Assertion in v1.0 | Corrected Finding in v1.1 | Evidence Classification | Root Cause of Correction |
|---|---|---|---|---|
| **Hardware Sizing** | 400 streams require exactly 48–64 CPU cores. | CPU sizing was an unsupported theoretical rule of thumb. Dedicated capacity modeling now calculates BNF (~200 cameras) and RNF (~200 cameras) separately, establishing that software decoding and inference on CPU is non-deterministic, while GPU decoding/inference requires empirical profiling. | `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` | Eliminates unverified sizing claims; separates sites. |
| **Network Architecture** | 10GbE core uplinks are strictly mandatory based solely on 400 Mbps video traffic. | 400 Mbps average traffic can theoretically traverse 1GbE, but peak bursts, NVR recording, multi-user live viewing, and backup transfers easily saturate 1GbE. 10GbE is an architectural resilience recommendation for core distribution, not a mathematical absolute for stream transport alone. | `ESTIMATED` | Replaced oversimplified bandwidth claim with full network switching model. |
| **Storage Calculations** | Raw 129.6 TB per site presented as total required storage. | Storage model now separates BNF and RNF, factoring in Variable Bitrate (VBR) peaks (+30%), RAID-6 parity overhead (2 disk penalty = +20%), filesystem reserve (5%), NVR recording playback streams, and incident clip caching. | `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` | Accurately accounts for industrial storage realities. |
| **AI Capabilities** | ByteTrack presented alongside tracking without clearly separating cross-camera Re-ID. | ByteTrack is strictly an **intra-camera tracking algorithm** (Kalman filter + IoU association). It possesses **zero** appearance feature extraction. Cross-camera Re-ID is an independent, high-complexity problem requiring visual feature extractors (OSNet/FastReID) and spatial-temporal correlation. | `VERIFIED_OFFICIAL_SOURCE` | Corrects computer vision algorithmic scope. |
| **Fire Detection Role** | Immediate fire alert dispatch described without regulatory framing. | Optical video AI fire/smoke detection is strictly an **auxiliary early-warning tool** and is **NOT** a certified replacement for industrial fire alarm systems under NFPA 72 / EN 54. | `VERIFIED_OFFICIAL_SOURCE` | Critical life-safety and legal liability correction. |
| **Security & Tokens** | HMAC tokens described as providing stream encryption. | **HMAC provides message authentication and data integrity, NOT encryption.** Video stream confidentiality is provided by TLS 1.3 / SRTP. HMAC is used exclusively for tamper-evident signed URL/token claims. | `VERIFIED_OFFICIAL_SOURCE` | Corrected cryptographic terminology and architecture. |
| **Legal & Privacy** | AES-256 stated as a mandatory statutory requirement of Egyptian Law 151/2020. | Law No. 151/2020 and Executive Regulations Decree No. 816/2025 mandate "appropriate technical and organizational measures" and licensing from the Data Protection Center (DPC). AES-256 is an international best practice (NIST FIPS 197), not a named statutory algorithm. | `VERIFIED_OFFICIAL_SOURCE` | Accurate statutory legal citation. |
| **Alert Reliability** | Redis and Outbox stated to guarantee sub-millisecond dispatch and "zero lost alerts". | Redis is in-memory; asynchronous persistence (RDB/AOF) carries small edge-case data loss risks during catastrophic power loss. Transactional Outbox guarantees **at-least-once delivery**, which inherently introduces duplicate events; consumers **must** implement idempotency. | `VERIFIED_OFFICIAL_SOURCE` | Replaced marketing claims with distributed systems reality. |
| **UI Color System** | `#0EA5E9` labeled as "Muted Teal". | `#0EA5E9` is objectively **Sky Blue** (Hue ~199°). True industrial Muted Teal is `#0D9488` (Teal 600) / `#14B8A6` (Teal 500) (Hue ~174°). All contrast ratios recalculated with KaTeX luminance formulas. | `VERIFIED_OBSERVATION` | Design system colorimetric precision. |
| **Database Engines** | PostgreSQL 16 + TimescaleDB recommended without checking PG 17/18 compatibility. | PostgreSQL 16 is fully supported by TimescaleDB (v2.13+). PostgreSQL 17 support was introduced in TimescaleDB 2.17+. PostgreSQL 18 is unreleased. PostgreSQL 16 remains the pinned, stable production target. | `VERIFIED_OFFICIAL_SOURCE` | Verified database compatibility matrix. |
| **Message Broker** | Redis 7.x recommended without addressing Redis licensing change vs Valkey. | Redis Ltd. changed Redis licensing from BSD-3-Clause to RSALv2 / SSPLv1 in March 2024. For open-source enterprise compliance, **Valkey 7.2 / 8.0** (Linux Foundation BSD-3-Clause fork) or **Redis 7.2-open-source** must be pinned. | `VERIFIED_OFFICIAL_SOURCE` | Protects against commercial licensing liability. |
| **Object Storage** | MinIO Community recommended without AGPLv3 review. | MinIO Community uses GNU AGPLv3 and has deprecated standalone gateway modes. SeaweedFS (Apache 2.0) and Ceph RGW are evaluated as enterprise alternatives. | `VERIFIED_OFFICIAL_SOURCE` | Addressed open-source license governance. |
| **Skills Audit** | Skills catalog excluded Google capabilities entirely without evaluating FCM. | Clarified that while GCP cloud data pipelines (`bigquery-*`) are excluded, Google Firebase Cloud Messaging (FCM) is evaluated and permitted for mobile alert push delivery. Packaged skills distinguished from native engineering capabilities. | `VERIFIED_OFFICIAL_SOURCE` | Removed overbroad exclusions; clarified skills vs capabilities. |

---

## 3. Documents Remediated & Created in Phase 0

### Newly Authored Deliverables:
- [`21_PHASE_0_REMEDIATION_CHANGELOG.md`](21_PHASE_0_REMEDIATION_CHANGELOG.md) (This document).
- [`22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md`](22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md) (Evidence audit across all technical assertions).
- [`23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md`](23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md) (Deep dive on pinned versions, licenses, and ONVIF/ZKTeco interoperability).
- [`24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md`](24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md) (Site-separated mathematical capacity, compute, storage, and network models).
- [`25_LEGAL_COMPLIANCE_ACTION_REGISTER.md`](25_LEGAL_COMPLIANCE_ACTION_REGISTER.md) (Compliance roadmap under Egyptian Law 151/2020 & Decree 816/2025).

### Remediated Core Deliverables:
- `01_PROJECT_UNDERSTANDING.md`: Updated with rigorous evidence classifications and separated site boundaries.
- `04_SKILLS_AUDIT.md`: Revalidated all skills, added exact file paths, verified read status, clarified FCM push.
- `07_TECHNOLOGY_RESEARCH_MATRIX.md`: Pinned exact versions, added Valkey, PostgreSQL 16/17, MinIO/SeaweedFS, ONVIF Profile T/G/S.
- `08_TARGET_ARCHITECTURE_PROPOSAL.md`: Corrected at-least-once outbox reliability model and HMAC integrity vs TLS encryption.
- `09_UI_UX_DESIGN_STRATEGY.md`: Corrected color tokens to genuine Muted Teal (`#0D9488`) and provided mathematical contrast proofs.
- `11_SECURITY_AND_PRIVACY_ASSESSMENT.md`: Detailed statutory obligations under Law 151/2020 and Decree 816/2025; corrected AES-256 claim.
- `12_VIDEO_AI_EVALUATION_PLAN.md`: Explicitly separated 12 AI capabilities, decoupled ByteTrack from Re-ID, defined auxiliary fire role.
- `13_INFRASTRUCTURE_ASSESSMENT.md`: Separated BNF/RNF calculations, replaced arbitrary CPU formulas, detailed network capacity model.
- `17_ARCHITECTURE_DECISION_REGISTER.md`: Updated ADRs with evidence classifications and technology remediations.
- `18_BLOCKERS_AND_OPEN_QUESTIONS.md`: Expanded PoC equipment requirements and legal gating items.
- `20_OWNER_APPROVAL_CHECKLIST.md`: Updated checklist reflecting remediated findings.

---

## 4. Remediation Sign-Off

- **Remediation Completed By:** Principal AI Engineer / CTO  
- **Status:** REMEDIATED & PINNED.  
- **Action:** Deliverables submitted for independent technical review. No implementation code or package installations permitted.

