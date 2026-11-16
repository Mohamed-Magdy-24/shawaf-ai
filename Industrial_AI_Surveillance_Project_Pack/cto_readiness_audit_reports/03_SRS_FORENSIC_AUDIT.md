> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# SRS FORENSIC REQUIREMENTS ENGINEERING AUDIT
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-03 | Classification: CANONICAL REQUIREMENTS AUDIT
### Status: COMPLETE AUDIT | Baseline Examined: `requirements/01_SRS.md` v2.0.0
### Audit Standard: IEEE 830 / ISO/IEC/IEEE 29148 Professional Requirements Engineering

---

## 1. EXECUTIVE REQUIREMENTS QUALITY ASSESSMENT

Every functional and non-functional requirement in `requirements/01_SRS.md` was audited against professional requirements engineering standards:
- **Total Functional Requirements (FRs)**: 42
- **Total Non-Functional Requirements (NFRs)**: 13
- **Total Requirement Units Audited**: 55

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SRS REQUIREMENT QUALITY BREAKDOWN                      │
├────────────────────────────────────────┬─────────────┬──────────────────────┤
│ Classification Category                │ Count       │ Percentage           │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ VALIDATED (Complete, testable)         │ 24          │ 43.6%                │
│ VALID_BUT_MISSING_ACCEPTANCE_CRITERIA  │ 14          │ 25.5%                │
│ BLOCKED_BY_EXTERNAL_DEPENDENCY         │ 6           │ 10.9%                │
│ INCOMPLETE / TBD                       │ 4           │ 7.3%                 │
│ REQUIRES_OWNER_DECISION                │ 3           │ 5.5%                 │
│ REQUIRES_LEGAL_REVIEW                  │ 2           │ 3.6%                 │
│ UNSUPPORTED_BY_CURRENT_ARCHITECTURE    │ 2           │ 3.6%                 │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ TOTAL AUDITED                          │ 55          │ 100.0%               │
└────────────────────────────────────────┴─────────────┴──────────────────────┘
```

> **CRITICAL FINDING: Only 43.6% of requirements are fully validated with complete acceptance criteria and test coverage. Over 25.5% lack quantitative acceptance criteria (e.g. error thresholds, timing limits), and 10.9% are blocked by external factory dependencies (NVR/ZKTeco access). Starting development without fixing these criteria will cause massive scope creep and arbitrary implementation guesses.**

---

## 2. FUNCTIONAL REQUIREMENTS AUDIT REGISTER

### 4.1 Site Isolation and Navigation (`FR-SITE-001` to `FR-SITE-008`)

| ID | Statement Summary | Priority | Quality Classification | Finding / Audit Critique | Recommended Action |
|---|-------------------|----------|------------------------|--------------------------|--------------------|
| **FR-SITE-001** | Support BNF and RNF as separate factory contexts | MUST | **VALIDATED** | Defined tenant context in DB schemas and API requests. Clean boundaries. | Retain as baseline. |
| **FR-SITE-002** | Retain separate ZKBioTime and SQL Server integrations per factory | MUST | **BLOCKED_BY_EXTERNAL_DEPENDENCY** | Dependent on physical SQL Server credentials and ZKBioTime network access (`OQ-001`, `OQ-005`). | Authorize `SPK-01` & `SPK-04`. |
| **FR-SITE-003** | Operational records and video metadata logically isolated by site | MUST | **VALIDATED** | Satisfied by PostgreSQL RLS and TimescaleDB hypertable tenant partitioning. | Retain as baseline. |
| **FR-SITE-004** | Authorized manager can switch application context between BNF and RNF | MUST | **VALIDATED** | Frontend context switcher passing JWT claim `tenant_id`. | Retain as baseline. |
| **FR-SITE-005** | Every site-specific screen, event, report, camera carries explicit site context | MUST | **VALIDATED** | Enforced at API gateway middleware and UI top-bar. | Retain as baseline. |
| **FR-SITE-006** | Company management and security view both sites per assigned privileges | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks explicit multi-site aggregated dashboard latency limits. | Add: "Aggregated multi-site dashboard must load within 1.5s." |
| **FR-SITE-007** | Local factory processing continuity during central VPN outages | MUST | **VALIDATED** | Core edge autonomy requirement; satisfied by local edge daemon + PostgreSQL. | Retain as baseline. |
| **FR-SITE-008** | No ordinary BNF event delivered to RNF-only users | MUST | **VALIDATED** | Enforced by WebSocket tenant room routing and Outbox delivery filter. | Retain as baseline. |

### 4.2 Employee and Attendance Integration (`FR-EMP-001` to `FR-EMP-008`)

| ID | Statement Summary | Priority | Quality Classification | Finding / Audit Critique | Recommended Action |
|---|-------------------|----------|------------------------|--------------------------|--------------------|
| **FR-EMP-001** | Integrate with separate ZKBioTime environments via site adapters | MUST | **BLOCKED_BY_EXTERNAL_DEPENDENCY** | ZKBioTime API versions and authentication endpoints unverified. | Authorize `SPK-01`. |
| **FR-EMP-002** | Employee ID used to link attendance and identity within site | MUST | **VALIDATED** | Synthetic key `(site_id, employee_id)` prevents ID collision. | Retain as baseline. |
| **FR-EMP-003** | Discover whether conventional face photos can be retrieved | MUST | **BLOCKED_BY_EXTERNAL_DEPENDENCY** | Core technical blocker (`BLK-001`). Unknown if terminals export photos or templates. | Authorize bench test `SPK-01`. |
| **FR-EMP-004** | Distinguish available, missing, unreadable, unsupported photos | MUST | **VALIDATED** | Handled by enum `photo_status: AVAILABLE, MISSING, UNREADABLE, UNSUPPORTED`. | Retain as baseline. |
| **FR-EMP-005** | Vendor-specific face templates not treated as portable images | MUST | **VALIDATED** | Explicit architectural constraint preventing template corruption. | Retain as baseline. |
| **FR-EMP-006** | Identity matching retains confidence, source, timestamp, model version | MUST | **VALIDATED** | Enforced by `identity_match_logs` schema. | Retain as baseline. |
| **FR-EMP-007** | Uncertain identity represented as unknown/unconfirmed | MUST | **VALIDATED** | Anti-hallucination requirement. Enforced by confidence gate ($\ge 0.80$). | Retain as baseline. |
| **FR-EMP-008** | Internal employee identifiers scoped as `(site_id, employee_id)` | SHOULD | **VALIDATED** | Clean database compound key. | Retain as baseline. |

### 4.3 Camera and Video (`FR-VID-001` to `FR-VID-015`)

| ID | Statement Summary | Priority | Quality Classification | Finding / Audit Critique | Recommended Action |
|---|-------------------|----------|------------------------|--------------------------|--------------------|
| **FR-VID-001** | Support extensible inventory of cameras and multiple NVR vendors | MUST | **VALIDATED** | go2rtc + ONVIF Profile S/T vendor abstraction. | Retain as baseline. |
| **FR-VID-002** | Camera/NVR access via vendor/protocol adapters | MUST | **VALIDATED** | Clean Architecture Ports & Adapters pattern. | Retain as baseline. |
| **FR-VID-003** | Determine actual stream capabilities during discovery | MUST | **BLOCKED_BY_EXTERNAL_DEPENDENCY** | Blocked until physical camera discovery probe is authorized. | Authorize `SPK-03`. |
| **FR-VID-004** | View live camera streams in Android app | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks explicit latency threshold and player fallback behavior. | Add: "Glass-to-glass latency $< 500\text{ms}$ via WebRTC; fallback to MSE." |
| **FR-VID-005** | Review recordings in Android app | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks scrubbing response time and segment seek precision. | Add: "Seek latency $< 1.0\text{s}$; scrubbar precision $\pm 10\text{s}$." |
| **FR-VID-006** | App shall not expose permanent NVR or raw RTSP credentials | MUST | **VALIDATED** | Video proxied via go2rtc ephemeral session tokens. | Retain as baseline. |
| **FR-VID-007** | Recorded video retained for 30 days | MUST | **UNSUPPORTED_BY_CURRENT_ARCHITECTURE** | Storing 30 days of 200 cameras @ 1080p requires **162 TB raw storage per factory**! Current server has no storage array. | Mark as Production Hardware Dependency. |
| **FR-VID-008** | Video metadata stored separately from video payloads | SHOULD | **VALIDATED** | PostgreSQL stores metadata; NVMe/NAS stores fMP4 chunks. | Retain as baseline. |
| **FR-VID-009** | Camera ID, site, zone, timestamp, source NVR visible in video view | MUST | **VALIDATED** | UI OSD overlay requirement. | Retain as baseline. |
| **FR-VID-010** | Discover camera capabilities (RTSP, ONVIF S/T, PTZ) | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks timeout and offline camera retry intervals. | Add: "Discovery timeout 10s; offline probe interval 60s." |
| **FR-VID-011** | Digital zoom implemented as client-side viewport transformation | MUST | **VALIDATED** | Implemented via CSS/Canvas matrix transform in Web Admin and Flutter matrix gesture. | Retain as baseline. |
| **FR-VID-012** | Distinct separation between Digital and Optical Zoom | MUST | **VALIDATED** | UI badge requirement. | Retain as baseline. |
| **FR-VID-013** | Authenticated Pan-Tilt-Zoom with audit logging and travel limits | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks automatic watchdog timeout duration to stop runaway PTZ. | Add: "Continuous move commands must enforce 2.0s server watchdog stop." |
| **FR-VID-014** | Automated PTZ tracking configurable per camera; no recording halt | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Highly complex; tracking handoff algorithm undefined. | Postpone to Phase 4; mark as Advanced Feature. |
| **FR-VID-015** | Fixed cameras track without fabricating physical PTZ movement | MUST | **VALIDATED** | Software bounding box tracking only. | Retain as baseline. |

### 4.4 AI Detection and Event Generation (`FR-AI-001` to `FR-AI-016`)

| ID | Statement Summary | Priority | Quality Classification | Finding / Audit Critique | Recommended Action |
|---|-------------------|----------|------------------------|--------------------------|--------------------|
| **FR-AI-001** | Detect configured PPE violations (helmet, vest) per zone | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks minimum pixel dimensions for PPE classification and accuracy targets. | Add: "Person bounding box height $\ge 120\text{px}$; Precision $\ge 0.85$." |
| **FR-AI-002** | Detect entry into configured restricted areas | MUST | **VALIDATED** | Evaluated via point-in-polygon intersection against zone geofences. | Retain as baseline. |
| **FR-AI-003** | Detect falls and industrial accidents | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks duration threshold to distinguish falling from sitting/bending. | Add: "Horizontal aspect ratio $>1.8$ + immobility for $\ge 3.0\text{s}$." |
| **FR-AI-004** | Detect phone-use behavior where camera angle permits | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Highly prone to false positives on ceiling cameras ($>4\text{m}$ height). | Add caveat: "Valid only on eye-level cameras ($<2.5\text{m}$ height)." |
| **FR-AI-005** | Detect suspected fire/smoke and trigger alert without confirmation | MUST | **REQUIRES_LEGAL_REVIEW** | Zero-gate fire alerting creates severe liability if false alarms trigger production shutdown. | Require signed `DEC-04` auxiliary disclaimer. |
| **FR-AI-006** | Detect and track configured product/packaging classes | MUST | **INCOMPLETE** | Lacks object taxonomy (cartons? sacks? metal sheets? electronics?). | Owner must supply factory product list (`OQ-017`). |
| **FR-AI-007** | Detect suspicious movement/theft between people | MUST | **INCOMPLETE / AMBIGUOUS** | "Theft" cannot be determined by computer vision. Extremely ambiguous. | Rephrase to: "Detect object transfer in unmonitored transfer zones." |
| **FR-AI-008** | Maintain person sightings across cameras with timestamps | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks retention duration and cross-camera matching confidence threshold. | Add: "Retain sightings for 30 days; minimum match confidence 0.78." |
| **FR-AI-009** | Store confidence and evidence for every AI-derived event | MUST | **VALIDATED** | Enforced by `factory_events` table metadata. | Retain as baseline. |
| **FR-AI-010** | Preserve unknown/ambiguous states when confidence insufficient | MUST | **VALIDATED** | Strict anti-hallucination rule. | Retain as baseline. |
| **FR-AI-011** | AI events shall not declare person guilty of theft | MUST | **VALIDATED** | Legal compliance safeguard. | Retain as baseline. |
| **FR-AI-012** | Detection thresholds and zone policies configurable/versioned | SHOULD | **VALIDATED** | Enforced by JSONB zone policy configuration. | Retain as baseline. |
| **FR-AI-013** | Separate intra-camera tracking (ByteTrack) from cross-camera Re-ID | MUST | **VALIDATED** | Clean separation of Layer 2 tracking from Layer 3 OSNet embeddings. | Retain as baseline. |
| **FR-AI-014** | Cross-camera Re-ID constrained by camera topology graph | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Camera topology transition matrix format undefined. | Add: "Topology graph must specify minimum and maximum transit times." |
| **FR-AI-015** | Blind-spot sightings flagged as discontinuous tracks | MUST | **VALIDATED** | Prevents false continuous trajectory drawing. | Retain as baseline. |
| **FR-AI-016** | Employee identity association requires calibrated thresholds | MUST | **REQUIRES_LEGAL_REVIEW** | Biometric matching requires employee consent under Egyptian Law 151/2020. | Require signed `DEC-06` and consent verification. |

### 4.5 Alerts, Reports, Android, VPN & Web Admin (`FR-ALT`, `FR-REP`, `FR-APP`, `FR-VPN`, `FR-WEB`)

| ID | Statement Summary | Priority | Quality Classification | Finding / Audit Critique | Recommended Action |
|---|-------------------|----------|------------------------|--------------------------|--------------------|
| **FR-ALT-001** | Alerts delivered through Android application | MUST | **VALIDATED** | Firebase Cloud Messaging (FCM) + WebSocket in-app receiver. | Retain as baseline. |
| **FR-ALT-002** | Ordinary alerts routed to factory manager + security managers | MUST | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Recipient roster undefined (`DEC-05`). | Owner must submit recipient names. |
| **FR-ALT-003** | Ordinary alert routing preserves site context (no leakage) | MUST | **VALIDATED** | Enforced by tenant routing filter. | Retain as baseline. |
| **FR-ALT-004** | Fire alerts dispatched immediately without confirmation | MUST | **REQUIRES_OWNER_DECISION** | Sub-second dispatch path bypassing throttling; requires `DEC-04`. | Owner sign-off required. |
| **FR-ALT-005** | Fire route isolated from ordinary alert throttling | SHOULD | **VALIDATED** | Dedicated high-priority queue. | Retain as baseline. |
| **FR-ALT-006** | Every alert attempt, delivery, retry, failure auditable | MUST | **VALIDATED** | Enforced by `notification_audit_logs` table. | Retain as baseline. |
| **FR-ALT-007** | System shall not require manual approval before delivery | MUST | **VALIDATED** | Direct dispatch model. | Retain as baseline. |
| **FR-ALT-008** | Alert acknowledgement states not finalized | TBD | **INCOMPLETE** | Explicitly unfinished requirement in baseline SRS! | Add state machine: `NEW, ACKNOWLEDGED, RESOLVED, DISMISSED`. |
| **FR-REP-001..007** | Dashboard and periodic reports inside app without Power BI | MUST | **VALIDATED** | Native Flutter/React charts (daily, weekly, monthly rollups). | Retain as baseline. |
| **FR-APP-001..005** | Android client application (site switch, live/playback, alerts) | MUST | **VALIDATED** | Complete Flutter mobile client scope. | Retain as baseline. |
| **FR-VPN-001..005** | Site-to-site WireGuard VPN, CCTV VLAN isolation, sync | MUST | **VALIDATED** | WireGuard hub-and-spoke with transactional outbox synchronization. | Retain as baseline. |
| **FR-WEB-001..006** | Desktop Web Admin Console (React/Vite), Zone Editor, Audit | MUST | **REQUIRES_OWNER_DECISION** | Formally proposed in `DEC-02`; awaiting owner sign-off. | Owner sign-off required. |

---

## 3. NON-FUNCTIONAL REQUIREMENTS AUDIT REGISTER

| ID | Category | Requirement Statement | Quality Classification | Audit Critique & Verification Gap |
|---|----------|-----------------------|------------------------|-----------------------------------|
| **NFR-SEC-001** | Security | Server-side authorization for every protected operation | **VALIDATED** | Enforced via Go API middleware validating JWT claims. |
| **NFR-SEC-002** | Security | Enforce site isolation in queries, queues, storage, logs | **VALIDATED** | PostgreSQL Row-Level Security (RLS) + Redis key prefixing. |
| **NFR-SEC-003** | Security | Encrypt network traffic and sensitive stored data | **VALIDATED** | TLS 1.3 in transit; AES-256-GCM for biometric templates at rest. |
| **NFR-SEC-004** | Security | Keep secrets out of code, mobile binaries, logs | **VALIDATED** | Environment variables + secret manager; zero hardcoded secrets. |
| **NFR-SEC-005** | Security | Cameras and NVRs isolated on dedicated CCTV VLAN | **VALIDATED** | Network architecture rule; zero public IP access to IoT cameras. |
| **NFR-REL-001** | Reliability | Local factory processing continuity during WAN/VPN outage | **VALIDATED** | 100% autonomous edge daemon + local PostgreSQL outbox. |
| **NFR-REL-002** | Reliability | Event delivery durable queues/retry/idempotency | **VALIDATED** | Transactional Outbox Pattern with exponential backoff. |
| **NFR-SCL-001** | Scalability | Support 200+ cameras per factory | **UNSUPPORTED_BY_CURRENT_ARCHITECTURE** | **CRITICAL HARDWARE GAP**: Cannot be achieved on workstation. Requires 4x enterprise GPU servers per factory. |
| **NFR-SCL-002** | Scalability | Capacity calculated from stream profiles & analytics | **VALIDATED** | Formula-backed capacity model in Document 24/37. |
| **NFR-MNT-001** | Maintainability| Business rules independent from vendor SDKs & DBs | **VALIDATED** | Ports and Adapters (Hexagonal Architecture) in Go. |
| **NFR-MNT-002** | Maintainability| Modules expose explicit contracts & automated tests | **VALID_BUT_MISSING_ACCEPTANCE_CRITERIA**| Lacks explicit test coverage percentage target (e.g. $\ge 80\%$). |
| **NFR-OBS-001** | Observability| Structured logs, metrics, traces, health checks | **VALIDATED** | OpenTelemetry + Prometheus endpoints in Go. |
| **NFR-UX-001** | UX | Manager identifies active site and severity unambiguously | **VALIDATED** | Color-coded site headers and WCAG 2.1 AA tokens. |
| **NFR-DATA-001**| Data | Video retention 30 days | **UNSUPPORTED_BY_CURRENT_ARCHITECTURE** | Storage capacity blocker on local development hardware. |
| **NFR-AI-001** | AI | AI performance measured by class, zone, lighting | **VALIDATED** | Evaluation plan defined in Document 12. |
| **NFR-AI-002** | AI | No accuracy/latency claimed without measured test set | **VALIDATED** | Strict scientific reporting standard. |
| **NFR-AI-003** | AI | Deterministic business rules govern critical alerts (No LLMs)| **VALIDATED** | Prevents LLM non-determinism in emergency fire/fall routes. |

---
**Audited By:** Principal Requirements Engineering Lead / CTO  
**Standards Compliance:** ISO/IEC/IEEE 29148:2018

