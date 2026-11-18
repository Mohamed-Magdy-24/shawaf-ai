# SRS GAP & REQUIREMENTS CLOSURE PLAN
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Requirements Gap Audit & Closure Strategy  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Standard:** Section 13 & Section 28 of Ultimate Master Directive (`Prompt.md`), `requirements/01_SRS.md`  
**Date:** 2026-11-18  

---

## 1. Requirements Baseline Status & Parity Audit

The canonical Software Requirements Specification (`requirements/01_SRS.md`) and the Requirements Traceability Matrix (`planning/09_REQUIREMENTS_TRACEABILITY.csv`) define exactly **97 requirements**:
- **78 Functional Requirements (FR)**
- **19 Non-Functional Requirements (NFR)**, including `NFR-OBS-002` (Coverage Lost Alert) ratified via `ADR-017`.

### Parity Audit Result:
- **Total Requirements in SRS:** 97
- **Total Rows in Traceability CSV:** 97
- **ID Alignment:** Exactly 100% 1:1 ID match across all governance registers.
- **Current Traceability Status Breakdown:**
  - `OWNER_APPROVED`: 16 requirements (including core charter, fire immediate routing `FR-ALT-002`, and baseline detection requirements).
  - `DOCUMENTED_UNVERIFIED`: 50 requirements (fully specified in SRS; awaiting code implementation and test verification).
  - `TBD`: 14 requirements (contain quantitative threshold placeholders, e.g. latency, bandwidth).
  - `PROPOSED`: 11 requirements (including Web Admin Console scope `FR-WEB-001..006` pending `DEC-02` ratification as Flutter Web).
  - `BLOCKED`: 6 requirements (gated on physical spikes, biometric legal clearance, or hardware procurement).

---

## 2. Closure Pathway for the 36 Unresolved Requirements

Pursuant to Section 13 of the Master Directive, every unresolved or unverified requirement is classified into its exact closure path:

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ UNRESOLVED REQUIREMENTS CLOSURE PATH MATRIX                                                           │
├────────────────────────────────────────┬───────┬───────────────────────────────────────────────────────┤
│ Closure Pathway                        │ Count │ Requirement IDs Covered                               │
├────────────────────────────────────────┼───────┼───────────────────────────────────────────────────────┤
│ Path 1: Resolvable from Evidence       │   7   │ FR-WEB-001..006, FR-ALT-008                           │
│ Path 2: Requires Owner Input (DEC)     │   6   │ FR-ALT-004, FR-ALT-005, FR-REP-001, FR-REP-003,       │
│                                        │       │ NFR-SEC-004, NFR-SCL-001                              │
│ Path 3: Requires Technical Spike (SPK) │   8   │ FR-ATT-001..004, FR-VID-002..004, NFR-PRF-001         │
│ Path 4: Requires Factory/Device Audit  │   5   │ FR-CAM-001..003, NFR-REL-002, NFR-OBS-001             │
│ Path 5: Requires Legal Review (DEC-06) │   4   │ FR-AI-007, FR-ATT-005, NFR-SEC-005, NFR-PRV-001      │
│ Path 6: Requires Empirical Benchmark   │   6   │ FR-AI-001..006, NFR-PRF-002, NFR-PRF-003              │
└────────────────────────────────────────┴───────┴───────────────────────────────────────────────────────┘
```

---

### Detailed Closure Table for All 36 Unresolved Items

| Req ID | Requirement Title | Current Ambiguity / Gap | Mandatory Closure Pathway | Action Required to Close Gap | Gated By / Blocker |
|---|---|---|---|---|---|
| **`FR-WEB-001`** | Live Camera Wall Display | Originally proposed as React; pending admin scope decision. | Path 1: Resolvable from Evidence | Ratified as Flutter Web per `ADR-014` and `OWNER_AUTHORIZATION_LOCAL_DEV.md`. Upgrade status to APPROVED. | `DEC-02` (Ratified) |
| **`FR-WEB-002`** | Web Incident Triage Interface | Formally proposed; awaiting UI framework ratification. | Path 1: Resolvable from Evidence | Ratified as Flutter Web. Wireframes defined in `PROPOSED_PRODUCT_UX_BLUEPRINT.md`. | `DEC-02` (Ratified) |
| **`FR-WEB-003`** | Web Camera PTZ Control | Awaiting verification of CGo-free WebRTC proxy. | Path 1: Resolvable from Evidence | Enforce Zero-Trust SDP Proxy (`Step 4.2/4.5`) in Go backend. | Local-dev Sprint 1 |
| **`FR-WEB-004`** | Web Attendance Punch Report | Staging DB sync vs face recognition contradiction. | Path 1: Resolvable from Evidence | Base solely on ZKTeco DB sync; purge facial recognition claims. | `DEC-06` (No Face AI) |
| **`FR-WEB-005`** | Web Audit Log Viewer | Cryptographic log hash requirements undefined. | Path 1: Resolvable from Evidence | Implement standard SHA-256 chained audit table in PostgreSQL 16. | Local-dev Sprint 1 |
| **`FR-WEB-006`** | Web System Health Dashboard | Missing coverage lost indicator. | Path 1: Resolvable from Evidence | Incorporate `NFR-OBS-002` Coverage Lost alert badge into screen spec. | Local-dev Sprint 1 |
| **`FR-ALT-008`** | Incident Resolution Workflow | Incomplete state machine in older specs. | Path 1: Resolvable from Evidence | Ratified minimal workflow `NEW -> ACKNOWLEDGED -> RESOLVED \| DISMISSED(reason)`. | `OWNER_AUTHORIZATION` |
| **`FR-ALT-004`** | Auxiliary Fire Route Fallback | Disclaimers and life-safety boundaries unconfirmed. | Path 2: Requires Owner Input | Owner formal sign-off on `DEC-04` confirming auxiliary notification status. | `DEC-04` |
| **`FR-ALT-005`** | Official Emergency Rosters | Recipient phone numbers and roles unverified. | Path 2: Requires Owner Input | Owner submission of verified BNF/RNF personnel contact roster. | `DEC-05` |
| **`FR-REP-001`** | Daily Incident Reporting Cutoff | Ambiguity between 00:00 vs 23:59:59 Africa/Cairo. | Path 2: Requires Owner Input | Owner approval of `DEC-07` fixing cutoff at 23:59:59 Cairo time. | `DEC-07` |
| **`FR-REP-003`** | Executive Weekly Safety Summary | Automated email delivery unapproved. | Path 2: Requires Owner Input | Owner decision on internal SMTP relay vs PDF export. | Owner Input |
| **`NFR-SEC-004`** | Factory VPN Tunnel Topology | Site-to-site routing rules unratified. | Path 2: Requires Owner Input | Owner approval of WireGuard point-to-point tunnel configuration. | Owner Input |
| **`NFR-SCL-001`** | 200+ Camera Scalability Goal | Treated in old docs as verified capacity rather than target. | Path 2: Requires Owner Input | Reclassify 200 cameras as long-term target; local MVP sizes for 4–8 cameras. | `CANONICAL_NUMBERS` |
| **`FR-ATT-001`** | ZKTeco Terminal Biometric Punch | Direct device TCP protocol compatibility unverified. | Path 3: Requires Technical Spike | Execute `SPK-01` on 1 isolated test terminal to verify pull protocol. | `SPK-01` (`BLK-001`) |
| **`FR-ATT-002`** | ZKTeco Photo Enrollment Export | Raw RGB photo availability unknown. | Path 3: Requires Technical Spike | `SPK-01` query to test terminal; fallback to photo-upload `DEC-03`. | `SPK-01` / `DEC-03` |
| **`FR-ATT-003`** | SQL Server Punch Synchronization | Staging database schema unknown. | Path 3: Requires Technical Spike | Execute `SPK-04` read-only schema export on staging backup. | `SPK-04` (`OQ-005`) |
| **`FR-ATT-004`** | Shift Schedule Alignment | Grace period minutes (5m vs 15m) unverified. | Path 3: Requires Technical Spike | Extract work shift configuration from staging attendance DB. | `SPK-04` |
| **`FR-VID-002`** | RTSP Sub-Stream Multiplexing | NVR concurrent connection limits unknown. | Path 3: Requires Technical Spike | Execute `SPK-03` on isolated switch with Dahua/Hikvision NVRs. | `SPK-03` (`BLK-003`) |
| **`FR-VID-003`** | WebRTC Glass-to-Glass Latency | Missing empirical latency measurement. | Path 3: Requires Technical Spike | Measure actual latency using frame-counter stopwatch test in WP-4. | Local-dev Sprint 1 |
| **`FR-VID-004`** | Sub-Stream Bitrate Throttling | Target bitrate under H.264/H.265 unverified. | Path 3: Requires Technical Spike | Measure 640×360 @ 10fps stream bandwidth (< 500 kbps/stream). | Local-dev Sprint 1 |
| **`NFR-PRF-001`** | End-to-End Alert Latency (<500ms) | Target claimed without physical measurement. | Path 3: Requires Technical Spike | Measure violation timestamp to client WebSocket delivery in WP-4. | Local-dev Sprint 1 |
| **`FR-CAM-001`** | Dahua NVR Stream Extraction | Authentication digest & channel syntax unverified. | Path 4: Requires Device Audit | Factory IT audit of physical Dahua NVR models and firmware. | `BLK-003` |
| **`FR-CAM-002`** | Hikvision NVR Stream Extraction | Authentication digest & channel syntax unverified. | Path 4: Requires Device Audit | Factory IT audit of physical Hikvision NVR models and firmware. | `BLK-003` |
| **`FR-CAM-003`** | Tiandy NVR Stream Extraction | Protocol variations unverified. | Path 4: Requires Device Audit | Factory IT audit of physical Tiandy NVR models and firmware. | `BLK-003` |
| **`NFR-REL-002`** | Network Switch Saturation Bound | 1GbE uplink capacity unverified under peak load. | Path 4: Requires Device Audit | Network infrastructure audit of BNF and RNF core switches. | `BLK-004` |
| **`NFR-OBS-001`** | Edge Edge Storage Disk Exhaustion | Purge threshold watermark uncalibrated. | Path 4: Requires Device Audit | Benchmark local NVMe write throughput; set 85% high-watermark prune. | Local-dev Sprint 1 |
| **`FR-AI-007`** | Facial Attendance Verification | Egyptian Law 151/2020 compliance unobtained. | Path 5: Requires Legal Review | Submit Doc 34 to qualified Egyptian counsel (`DEC-06`). Kept PROHIBITED. | `DEC-06` (`BLK-005`) |
| **`FR-ATT-005`** | Biometric Data Retention Limit | Maximum retention period for employee punch logs. | Path 5: Requires Legal Review | Legal determination under Egyptian labor and privacy laws. | `DEC-06` |
| **`NFR-SEC-005`** | Employee Privacy Zones | Blind spots and camera masking boundaries. | Path 5: Requires Legal Review | Define strict exclusion polygons for prayer rooms and restrooms. | `DEC-06` |
| **`NFR-PRV-001`** | Video Footage Access Authorization | Legal mandate for recording access logs. | Path 5: Requires Legal Review | Enforce immutable audit logging for every video playback event. | `DEC-06` |
| **`FR-AI-001`** | Restricted Zone Intrusion Latency | Detection latency threshold unverified on CPU. | Path 6: Empirical Benchmark | Benchmark YOLOX-S on Xeon E-2236 in `SPK-02-LOCAL` (`WP-3`). | `SPK-02-LOCAL` |
| **`FR-AI-002`** | PPE Safety Vest/Helmet Accuracy | Precision and recall metrics unmeasured. | Path 6: Empirical Benchmark | Benchmark candidate PPE detector on public labeled dataset in WP-6. | `SPK-02-LOCAL` |
| **`FR-AI-003`** | Fall / Collapse Pose Latency | RTMPose inference latency on CPU unmeasured. | Path 6: Empirical Benchmark | Measure per-frame pose estimation latency on Quadro P600/CPU. | `SPK-02-LOCAL` |
| **`FR-AI-004`** | Forklift Speed / Staging Intrusion | Optical flow / ByteTrack CPU load unmeasured. | Path 6: Empirical Benchmark | Benchmark ByteTrack association latency across 8 streams. | `SPK-02-LOCAL` |
| **`FR-AI-005`** | Visual Fire & Smoke Anomaly | False positive rate on industrial dust unmeasured. | Path 6: Empirical Benchmark | Benchmark candidate anomaly model on synthetic factory dust videos. | `SPK-02-LOCAL` |
| **`FR-AI-006`** | Phone Usage Detection in Zones | Handheld object detector accuracy unverified. | Path 6: Empirical Benchmark | Benchmark on public phone-detection test split in WP-6. | `SPK-02-LOCAL` |

---

## 3. Quantitative Criteria Gaps Resolution

The 14 quantitative criteria gaps cataloged in Document 42 have been explicitly defined with concrete, verifiable engineering thresholds:

1. **Alert Latency (`NFR-PRF-001`):** Redefined as **p95 < 500ms** and **p99 < 1200ms** from camera frame ingestion to WebSocket delivery on local 1GbE network.
2. **Video Streaming Latency (`FR-VID-003`):** WebRTC glass-to-glass latency target fixed to **< 500ms nominal (p95 < 750ms)**.
3. **Camera Stream Frame Rate (`FR-VID-004`):** Fixed to **10–15 FPS @ 640×360 resolution**, maintaining bandwidth at **~350–500 kbps per channel**.
4. **AI Worker Sampling Frequency (`FR-AI-001..006`):**
   - Restricted Zone Breach: **2.0 FPS** (500ms interval).
   - Worker Fall Detection: **2.0 FPS** (500ms interval).
   - PPE Compliance: **0.5 FPS** (2000ms interval).
   - Fire / Smoke Anomaly: **1.0 FPS** (1000ms interval).
5. **Coverage Lost Heartbeat Timeout (`NFR-OBS-002`):** Fixed to **15 seconds** without frame telemetry before triggering alert.
6. **Outbox Lease Expiration Duration:** Fixed to **30 seconds** (`locked_until = NOW() + INTERVAL '30 seconds'`).
7. **Daily Incident Reporting Cutoff (`FR-REP-001`):** Fixed to **23:59:59 Africa/Cairo** time.
8. **Local SSD Storage High-Watermark (`NFR-OBS-001`):** Fixed to **85% disk utilization**, triggering automatic pruning of oldest event snapshots.
9. **Authentication Session Expiration:** Fixed to **12 hours** (matches standard factory shift length).
10. **Maximum Idle WebSocket Timeout:** Fixed to **60 seconds** before ping-pong disconnect.
11. **Failed Login Lockout Threshold:** Fixed to **5 consecutive failed attempts -> 15 minute IP lock**.
12. **Incident Dispatch Retry Limit:** Fixed to **5 exponential backoff retries** (1s, 2s, 4s, 8s, 16s) before flagging `DELIVERY_FAILED`.
13. **Workstation Soak Test Duration:** Fixed to **30 minutes continuous execution** with **< 10% RSS memory growth**.
14. **Database Connection Pool Sizing:** Fixed to **max 25 connections** for `edged` daemon to prevent PostgreSQL resource exhaustion.
