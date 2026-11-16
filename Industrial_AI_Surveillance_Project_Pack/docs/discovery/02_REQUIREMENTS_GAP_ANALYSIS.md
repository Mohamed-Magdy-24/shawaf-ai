> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 02 — Requirements Gap Analysis & Contradiction Audit

**Document ID:** DISC-02-GAP-ANALYSIS  
**Version:** 1.0.0-baseline  
**Status:** AUDIT COMPLETE  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Traceability Reference:** SRS-001 & CSV-001  

---

## 1. Traceability & Requirements Status Matrix

Every functional and non-functional requirement from SRS-001 has been evaluated against technical realities, existing documentation, and operational constraints.

| Requirement ID | Summary | Classification | Current Reality / Discovery Finding | Severity / Risk |
|---|---|---|---|---|
| **FR-SITE-001** | Support BNF and RNF as separate factory contexts | CONFIRMED | Explicit site isolation required across all layers | Medium (Architectural) |
| **FR-SITE-002** | Separate ZKBioTime and SQL Server per factory | CONFIRMED | Separate connection strings, credentials, network paths | Low |
| **FR-SITE-003** | Isolate operational records and video metadata by site | CONFIRMED | Logical/physical DB segregation, scoped queries | High (Security) |
| **FR-SITE-004** | Managers can switch between BNF and RNF | CONFIRMED | Requires server-side entitlement checks | Medium |
| **FR-SITE-005** | Explicit site context on all API requests/resources | CONFIRMED | Mandatory header/parameter validation | Low |
| **FR-SITE-006** | Cross-site viewing for Company/Security Mgmt | CONFIRMED | Role-scoped aggregate views permitted | Medium |
| **FR-SITE-007** | Local site resilience during inter-site outage | PROPOSED | Edge data plane must run autonomously | High (Architecture) |
| **FR-SITE-008** | No cross-site alert leakage to site-only users | CONFIRMED | Outbox and routing matrix must enforce strict filters | High (Security) |
| **FR-EMP-001** | Integrate with separate ZKBioTime per site | CONFIRMED | Requires site-specific API adapters | Medium |
| **FR-EMP-002** | Stable Employee ID used within site | CONFIRMED | Internal composite key required: `(site_id, employee_id)` | Low |
| **FR-EMP-003** | Prove photo retrieval from devices/ZKBioTime | BLOCKED | Unknown if biometric terminals export RGB photos | **CRITICAL (Blocker)** |
| **FR-EMP-004** | Distinguish photo availability states | CONFIRMED | Domain typed outcome: Available, Missing, Unsupported | Low |
| **FR-EMP-005** | Do not treat biometric templates as photos | CONFIRMED | Proprietary templates cannot be used in open CV | High (Correctness) |
| **FR-EMP-006** | Retain confidence, model, timestamp for face ID | CONFIRMED | Schema must store inference provenance | Low |
| **FR-EMP-007** | Unknown identity when confidence is low | CONFIRMED | Anti-hallucination rule: never force an employee match | High (Integrity) |
| **FR-EMP-008** | Site-scoped internal employee IDs | PROPOSED | UUID internal, composite natural key | Low |
| **FR-VID-001** | Support multiple NVR models/vendors | CONFIRMED | Mixed fleet requires protocol adapters | High (Integration) |
| **FR-VID-002** | Camera/NVR behind adapters, not in domain | CONFIRMED | Clean Architecture Ports & Adapters | Medium |
| **FR-VID-003** | Verify stream and playback capabilities | BLOCKED | NVR models, firmware, RTSP, and APIs unknown | **CRITICAL (Blocker)** |
| **FR-VID-004** | Authorized live video on Android | CONFIRMED | Restricted to Security & Senior Management only | High (Security) |
| **FR-VID-005** | Authorized recording playback on Android | CONFIRMED | Tokenized session grants, 30-day window | High (Security) |
| **FR-VID-006** | No permanent NVR credentials exposed to mobile | CONFIRMED | Backend stream proxy / tokenized session grants | High (Security) |
| **FR-VID-007** | 30-day video retention | CONFIRMED | Sizing and NVR storage capability unverified | High (Storage) |
| **FR-VID-008** | Video metadata separated from video payloads | PROPOSED | Relational DB for metadata, NVR/S3 for video | Medium |
| **FR-VID-009** | Display camera ID, site, zone, timestamp on video | CONFIRMED | Metadata overlay in UI | Low |
| **FR-AI-001** | PPE violation detection by zone | UNKNOWN | Zone polygons and PPE rule matrix missing | High (Operational) |
| **FR-AI-002** | Restricted-area entry detection | UNKNOWN | Polygons, allowed schedules, and roles missing | High (Operational) |
| **FR-AI-003** | Fall and accident detection | PROPOSED | Requires held-out validation dataset | High (Accuracy) |
| **FR-AI-004** | Mobile phone use detection | PROPOSED | Highly dependent on camera resolution/angle | High (Accuracy) |
| **FR-AI-005** | Immediate fire/smoke alert route | CONFIRMED | Immediate dispatch without human gate | **CRITICAL (Safety)** |
| **FR-AI-006** | Object classification (cartons, sacks, materials) | UNKNOWN | Object taxonomy and labeled datasets missing | High (Model) |
| **FR-AI-007** | Suspicious object movement & handoff | UNKNOWN | Process definitions for legitimate moves missing | High (Model) |
| **FR-AI-008** | Cross-camera employee sightings & timeline | UNKNOWN | Blocked if photo retrieval / clock sync fails | High (Feasibility) |
| **FR-AI-009** | Store confidence and evidence for all AI events | CONFIRMED | Event schema must include clip/snapshot refs | Low |
| **FR-AI-010** | Preserve unknown/ambiguous identity states | CONFIRMED | Strict anti-guessing policy | High (Integrity) |
| **FR-AI-011** | No automatic disciplinary actions from AI | CONFIRMED | AI produces observations; humans decide actions | High (Legal/Ethics) |
| **FR-AI-012** | Versioned detection thresholds & policies | PROPOSED | Audit trail for policy modifications | Medium |
| **FR-ALT-001** | In-app alert delivery on Android | CONFIRMED | FCM / WebSockets with persistent local inbox | Medium |
| **FR-ALT-002** | Ordinary alert recipient routing | CONFIRMED | Factory Manager + Company Mgmt + Security Mgmt | Medium |
| **FR-ALT-003** | Alert routing strictly preserves site context | CONFIRMED | Negative tests required to prove zero leakage | High (Security) |
| **FR-ALT-004** | Fire alert immediate dispatch (no human gate) | CONFIRMED | Dedicated fast-path queue and push route | **CRITICAL (Safety)** |
| **FR-ALT-005** | Fire alerts isolated from batching/throttling | PROPOSED | Dedicated queue channel with zero latency | High (Reliability) |
| **FR-ALT-006** | Full delivery attempt and retry auditability | CONFIRMED | Outbox pattern and audit table | Medium |
| **FR-ALT-007** | No security manager approval needed for alerts | CONFIRMED | Real-time dispatch | Low |
| **FR-ALT-008** | Incident acknowledgement & workflow states | UNKNOWN | Requires business owner workflow approval | Medium |
| **FR-REP-001** | Android manager dashboards | CONFIRMED | KPI summaries, active events, status cards | Medium |
| **FR-REP-002** | Reports generated in-app; no Power BI | CONFIRMED | Embedded charting and PDF/report generation | Medium |
| **FR-REP-003** | Reporting views with charts and percentages | CONFIRMED | Real DB aggregations, zero mock figures | High (Integrity) |
| **FR-REP-004** | Daily, weekly, monthly automated periods | CONFIRMED | Background scheduled rollup jobs | Medium |
| **FR-REP-005** | Multi-dimensional report filtering | PROPOSED | By site, zone, severity, event class | Low |
| **FR-REP-006** | Distinguish detections vs confirmed incidents | PROPOSED | Requires approved incident states | Medium |
| **FR-REP-007** | No external email/SMS report delivery | CONFIRMED | Client-side export / in-app viewing only | Low |
| **FR-APP-001** | Target client is Android only | CONFIRMED | Mobile app for manager workflows | Medium |
| **FR-APP-002** | Dashboards, site switch, inbox, playback, reports | CONFIRMED | Core application feature scope | High (UX) |
| **FR-APP-003** | Live/playback hidden without explicit video role | CONFIRMED | Server-side API refusal, not UI hiding alone | High (Security) |
| **FR-APP-004** | Clear visual indication of active factory | CONFIRMED | Distinct banner/header token for BNF vs RNF | Low (UX) |
| **FR-APP-005** | Graceful handling of network drops and stale data | CONFIRMED | Explicit offline/stale banner, no fake data | High (UX) |
| **NFR-SEC-001** | Server-side authorization on all operations | CONFIRMED | JWT with claim validation per site/action | High (Security) |
| **NFR-SEC-002** | Site isolation across DB, queues, logs, cache | CONFIRMED | Strict tenant-scoping across all stores | High (Security) |
| **NFR-SEC-003** | Encryption in transit (TLS 1.3) and rest (AES) | CONFIRMED | Mandatory security standard | High (Security) |
| **NFR-SEC-004** | Zero credentials in mobile apps, code, logs | CONFIRMED | Vault / Secret Manager + CI secret scanning | High (Security) |
| **NFR-REL-001** | Local edge site resilience during link outage | PROPOSED | Local event storage and edge inference | High (Architecture) |
| **NFR-REL-002** | Durable outbox, retry, and idempotency | PROPOSED | Guaranteed delivery for critical alerts | High (Reliability) |
| **NFR-SCL-001** | 200+ cameras per site (400+ total scale) | CONFIRMED | Edge stream ingestion architecture needed | **CRITICAL (Scale)** |
| **NFR-SCL-002** | Sizing derived from measured stream params | PROPOSED | Requires network and codec discovery | High (Infra) |
| **NFR-MNT-001** | Business rules isolated from vendor/UI SDKs | CONFIRMED | Clean Architecture adherence | High (Maintainability) |
| **NFR-OBS-001** | Structured logs, metrics, traces, health checks | CONFIRMED | Prometheus + Grafana / OpenTelemetry | Medium |
| **NFR-DATA-001**| 30-day video retention enforcement | CONFIRMED | Requires ~260 TB total storage verification | **CRITICAL (Storage)** |
| **NFR-AI-001** | AI accuracy measured on held-out site data | CONFIRMED | Precision/Recall benchmarks per camera zone | High (AI Quality) |
| **NFR-AI-002** | No unsubstantiated AI performance claims | CONFIRMED | Zero fabricated "99%" accuracy metrics | High (Integrity) |

---

## 2. Deep Dive: Architectural Contradictions & Hidden Flaws

### Contradiction 1: Zero-GPU Server vs. Real-Time 400-Camera Multi-Model AI
- **The Stated Expectation:** "Current server has no GPU; AI detection must run across 200+ cameras per site for PPE, Restricted Areas, Falls, Phones, Fire, and Objects."
- **The Physical Reality:** Running multi-class YOLO detectors, pose estimators, and tracker algorithms on CPU alone achieves ~1–3 FPS per stream on a high-end server CPU. Ingesting 200 streams would require 200–600 CPU cores per factory. A standard server CPU will instantly saturate, causing video ingestion lag, dropped frames, delayed alerts, and eventual out-of-memory crashes.
- **CTO Resolution:** Real-time AI on 400 cameras requires either:
  1. Procuring dedicated NVIDIA GPU compute servers (e.g., dual NVIDIA RTX A5000 / L40S per factory).
  2. Adopting an edge-distributed architecture using on-camera / edge AI appliances (Jetson Orin / edge micro-servers) dedicated to high-risk zones.
  3. Staged sampling (e.g., sampling key streams at 2–5 FPS rather than processing full 25–30 FPS).

### Contradiction 2: Existing Biometric Terminals vs. Facial Recognition Photos
- **The Stated Expectation:** "Employee photos currently exist only inside biometric terminals/ZKBioTime; no central photo repository exists."
- **The Biometric Hardware Reality:** Standard ZKTeco biometric terminals frequently store mathematical biometric templates (eigenvalues/feature points) that are cryptographically locked and irreversible to reconstruct an RGB face photo. Furthermore, older firmware versions do not expose raw face images via ZKBioTime APIs.
- **CTO Resolution:** This is marked as **BLOCKER BLK-001**. Phase 1 must execute a read-only script against representative terminals to verify whether actual JPEG images are retrievable. If not, facial recognition cannot proceed without an administrative employee photo enrollment workflow.

### Contradiction 3: Cross-Site Manager Navigation vs. Video Access Privilege Escalation
- **The Stated Expectation:** "Managers can switch between BNF and RNF... Live and recorded video restricted to Security Managers and Senior Management."
- **The Security Risk:** If the client application or backend treats "Manager" as a unified administrative role, switching factory context could accidentally expose live video streams to factory managers who lack explicit video clearance.
- **CTO Resolution:** RBAC must separate **Site Context** from **Capability Entitlements**. A user can possess `(Site: BNF, Role: FactoryManager)` which grants access to BNF dashboards and alert inboxes, but explicitly forbids `video:stream:live` and `video:stream:playback`. Every video token request must independently evaluate video authorization claims regardless of the selected active factory.

### Contradiction 4: Cross-Camera Movement Reconstruction vs. Industrial Clock Drift
- **The Stated Expectation:** "Maintain a time-ordered record of employee appearances between cameras with location and timestamp."
- **The Technical Reality:** The cameras connect through heterogeneous network switches and multiple NVR models. If NVR and camera clocks drift by even 30–60 seconds, time-ordered trajectory reconstruction becomes inverted or broken. Furthermore, clothing/uniform similarity without clear facial embeddings will cause re-identification (ReID) algorithms to switch identities between employees.
- **CTO Resolution:** Trajectory tracking must be presented as **discrete sightings with explicit confidence and gaps**, never as a continuous interpolated path. An NTP synchronization audit of all NVRs and switches is a mandatory prerequisite.

### Contradiction 5: Immediate Fire Alert Dispatch vs. Industrial Environment False Alarms
- **The Stated Expectation:** "Detect suspected fire/smoke and trigger the fire alert route without waiting for human confirmation."
- **The Industrial Environment Reality:** Industrial factories generate dust clouds, steam exhausts, diesel exhaust fumes, and welding light flashes. Standard vision models running on raw optical streams generate significant false positives when exposed to steam and welding flashes. Dispatching immediate critical notifications on every suspicion without debounce or multi-frame temporal confirmation will result in severe alert fatigue.
- **CTO Resolution:** Fire detection must employ **temporal multi-frame persistence** (e.g., fire/smoke signatures must persist for >3.0 seconds across consecutive frames with confidence >0.85) before dispatching. The UI must label the event as "Suspected Fire/Smoke Detected" with immediate snapshot evidence, while maintaining sub-second dispatch latency.

### Contradiction 6: Mobile-Only Interface vs. Complex Industrial Administration
- **The Stated Expectation:** "Client application: Android only."
- **The Operational Reality:** Configuring 200+ camera RTSP URLs, drawing complex zone polygon boundaries (ROIs), configuring multi-shift PPE rule matrices, mapping recipient escalation rosters, and auditing system logs is virtually impossible on a handheld Android mobile screen.
- **CTO Resolution:** Propose a bifurcated interface model:
  1. **Android Application:** Exclusively for Manager workflows (Live view, playback, incident inbox, alert push, daily/weekly/monthly dashboards, and triage).
  2. **Web Administration Console:** For System Administrators and Safety Officers (Camera registry, zone polygon drawing, rule configuration, device health, and audit logs).

---

## 3. Summary of Unresolved Decisions Requiring Owner Sign-Off

1. **Hardware Procurement Strategy:** Approval to require dedicated GPU inference compute or phased camera rollout.
2. **Face Photo Fallback Plan:** Approval to institute an administrative photo upload workflow if biometric terminals fail to yield RGB images.
3. **Admin Portal Approval:** Formal approval to include a lightweight Web Admin portal for zone and camera configuration.
4. **Fire Alert Recipient Registry:** Official roster of individuals designated as "responsible personnel" for BNF and RNF.
5. **Incident Workflow Approval:** Definition of formal lifecycle states for alert investigations.

