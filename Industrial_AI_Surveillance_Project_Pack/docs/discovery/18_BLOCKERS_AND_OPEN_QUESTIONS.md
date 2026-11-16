> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 18 — Critical Blockers, Open Technical Questions & PoC Requirements (Remediated)

**Document ID:** DISC-18-BLOCKERS-OQ  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** ACTIVE AUDIT REGISTER  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Sections 6, 8 & 13 of CTO Directive  

---

## 1. Executive Summary: The Reality-Check Register

Before writing production application code, all unverified assumptions must be addressed through empirical evidence. This document registers all active implementation blockers, open stakeholder questions, and the exact physical equipment required to execute Phase 1 technical spikes.

---

## 2. Critical Implementation Blockers (Must Be Resolved in Phase 1 Spikes)

| Blocker ID | Domain | Blocker Description | Operational Impact | Required Evidence / Spike Action | Classification | Responsible Party |
|---|---|---|---|---|---|---|
| **BLK-001** | Biometrics | **Biometric Terminal Photo Export Unproven:** Unknown whether installed ZKTeco terminals export RGB JPEG photos or only proprietary feature templates. | Directly blocks Category I (Face Identification) and Category K (Re-ID Cross-Camera Matching). | Execute safe read-only Python/curl script against test terminal in Phase 1. If templates only, activate photo upload portal fallback. | `BLOCKED` | Factory IT & Lead Architect |
| **BLK-002** | Hardware | **Zero GPU Compute on Current Server:** Running 12 vision models across 200 streams on CPU is physically unviable. | Severe stream lag, dropped frames, delayed fire alerts, worker OOM crashes. | Project Owner approval of Enterprise GPU Server specification (ADR-008) and procurement release. | `BLOCKED` | Project Owner & CFO |
| **BLK-003** | NVR Fleet | **Heterogeneous NVR Inventory & API Limits:** Specific NVR vendors, models, firmware, RTSP stream URLs, and max concurrent session caps are unknown. | Inability to connect video ingestion workers or mobile playback proxy. | IT network inventory of top 3 NVR models; run Phase 1 RTSP connection spike. | `UNKNOWN` | Factory IT & Security Head |
| **BLK-004** | Network | **Core Switch Uplink Saturation Risk:** Peak concurrent video and playback traffic reaches ~685 Mbps per site. Single unbonded 1GbE uplinks risk buffer drops. | Frame drops, RTSP socket resets, distorted camera footage. | Network team audit of switch models; confirmation of 10GbE SFP+ or bonded LACP 2x1GbE uplinks. | `ESTIMATED` | Factory Network Admin |
| **BLK-005** | Legal / Privacy | **Biometric Governance Under Egyptian Law No. 151/2020:** Production facial recognition and employee movement profiling lack legal compliance certification. | Severe regulatory penalties, labor union disputes, legal shutdown. | Formal legal review of employee privacy notice, data retention schedule, and lawful processing basis. | `BLOCKED` | Corporate Legal Counsel |
| **BLK-006** | Fire Routing | **Unassigned Fire Emergency Roster:** Specific names, phone numbers, and user IDs for "responsible personnel" receiving immediate fire alerts are missing. | Inability to configure fire notification delivery routes; safety risk. | Stakeholder submission of official emergency response rosters for BNF and RNF. | `UNKNOWN` | Factory Safety Director |
| **BLK-007** | Camera Clocks | **NTP Time Synchronization Drift Across NVRs:** If camera and NVR clocks drift by >5 seconds, cross-camera person tracking timeline becomes inverted. | Inaccurate movement history; corrupted incident clip timestamps. | Network audit verifying all NVRs and cameras synchronize to a common local NTP time server. | `UNKNOWN` | Factory IT Admin |

---

## 3. Required PoC Equipment & Test Conditions (Phase 1 Spikes)

To execute the Phase 1 technical spikes without purchasing production hardware prematurely or risking production disruptions:

```text
====================================================================================================
                        PHASE 1 PROOF-OF-CONCEPT (PoC) TEST ENVIRONMENT
====================================================================================================

1. TEST HARDWARE ENVIRONMENT:
   - 1x Leased Cloud or Benchmarking Workstation equipped with 1x NVIDIA RTX GPU (minimum 16GB VRAM,
     e.g., RTX 4000 / RTX 3090 / A4000) running Ubuntu 22.04 LTS.
   - Purpose: Measure empirical inference latency (ms) for YOLOv8x, ByteTrack, and ArcFace using
     TensorRT 10.x across batch sizes 1, 4, and 8.

2. ISOLATED TEST NVR & CAMERA RIG:
   - 1x Physical NVR representing the most common model installed at BNF/RNF (e.g., Hikvision / Dahua).
   - 2x IP Test Cameras connected to the test NVR.
   - Purpose: Validate go2rtc RTSP stream pulling, WebRTC handshake latency, Profile G playback seek,
     and concurrent connection limits.

3. ISOLATED BIOMETRIC TEST TERMINAL:
   - 1x Standalone ZKTeco terminal (representative of plant floor devices) connected to an isolated
     test switch.
   - 1x Test Employee profile registered on the terminal.
   - Purpose: Execute read-only API and SDK commands to inspect whether raw JPEG/PNG photos can be
     queried or whether only proprietary templates are returned.

4. READ-ONLY SQL SERVER TEST REPLICA:
   - Read-only test user provisioned against a restored backup or staging instance of BNF SQL Server.
   - Purpose: Validate attendance query execution time, schema types, and index performance.
====================================================================================================
```

---

## 4. Master Open Questions Register (OQ-001 to OQ-025)

| OQ ID | Category | Specific Question Requiring Factual Evidence | Classification | Owner / Next Action |
|---|---|---|---|---|
| **OQ-001** | Attendance | What are the exact ZKBioTime version and build numbers at BNF and RNF? | `UNKNOWN` | Factory IT discovery. |
| **OQ-002** | Attendance | Which API licenses and add-on modules are actively licensed in ZKBioTime? | `UNKNOWN` | ZKBioTime vendor audit. |
| **OQ-003** | Biometrics | Which exact biometric terminal models and firmware versions are installed? | `UNKNOWN` | Physical terminal inventory. |
| **OQ-004** | Biometrics | Can conventional face photos be queried via REST API for all 18+ terminals? | `BLOCKED` | Phase 1 Photo Spike. |
| **OQ-005** | SQL Server | What are the SQL Server versions, schemas, table sizes, and collations? | `UNKNOWN` | Schema-only export from IT. |
| **OQ-006** | CCTV / NVR | What NVR manufacturers and models exist at each site (Hikvision, Dahua, etc.)? | `UNKNOWN` | Physical NVR inspection. |
| **OQ-007** | CCTV / NVR | Which NVRs support ISAPI / ONVIF playback APIs and what are session limits? | `UNKNOWN` | Vendor API spike. |
| **OQ-008** | CCTV / NVR | Are RTSP sub-streams actively configured and accessible on cameras? | `UNKNOWN` | Network stream scan. |
| **OQ-009** | Video Profile| What are the exact camera resolutions, frame rates, and codecs (H.264 vs H.265)?| `UNKNOWN` | Camera stream discovery. |
| **OQ-010** | Server | What are the exact CPU model, RAM, storage, and OS specs of the current server?| `UNKNOWN` | Run discovery script. |
| **OQ-011** | Hardware | What is the approved capital expenditure budget for dedicated GPU servers? | `PROPOSED` | Project Owner sign-off. |
| **OQ-012** | Network | What are the exact VLAN IDs, firewall rules, and site-to-site bandwidth limits?| `UNKNOWN` | Network engineer meeting. |
| **OQ-013** | Safety | Who are the exact designated "responsible recipients" for immediate fire alerts?| `UNKNOWN` | Safety Director input. |
| **OQ-014** | Security | What is the exact personnel membership list for Security and Senior Management?| `UNKNOWN` | Project Owner sign-off. |
| **OQ-015** | Safety | What are the specific PPE requirements for each factory zone and shift? | `UNKNOWN` | Safety Manager matrix. |
| **OQ-016** | Security | Where are the restricted area spatial boundaries located on camera feeds? | `UNKNOWN` | Security Manager markup. |
| **OQ-017** | AI Models | Which specific cartons, sacks, and product packages must be classified? | `UNKNOWN` | Operations Manager input. |
| **OQ-018** | Operations | What are legitimate material movement routes (e.g., standard warehouse dispatch)?| `UNKNOWN` | Plant Operations input. |
| **OQ-019** | AI Models | What are the acceptable false-alarm budgets per camera/zone per shift? | `PROPOSED` | Safety Owner sign-off. |
| **OQ-020** | Analytics | What are the exact mathematical formulas for factory safety compliance KPIs?| `UNKNOWN` | Management sign-off. |
| **OQ-021** | Workflow | What are the approved lifecycle states for incident follow-up triage? | `UNKNOWN` | Project Owner sign-off. |
| **OQ-022** | Compliance | What retention periods apply to AI event metadata, snapshots, and audit logs?| `PROPOSED` | Legal / Security policy. |
| **OQ-023** | Legal | Has legal review certified worker privacy compliance under Law No. 151/2020?| `BLOCKED` | Legal Counsel sign-off. |
| **OQ-024** | Mobile | What are the supported Android OS versions and target rugged mobile devices?| `UNKNOWN` | IT mobile policy. |
| **OQ-025** | Ops / DR | What are the formal Recovery Time (RTO) and Recovery Point (RPO) objectives? | `PROPOSED` | Executive IT sign-off. |

---

## 5. Blockers & Open Questions Sign-Off

- **Status:** REVALIDATED AUDIT REGISTER.
- **Action Item:** Authorize Phase 1 PoC environment to systematically resolve Blockers `BLK-001` through `BLK-004`.
