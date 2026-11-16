# Software Requirements Specification (SRS)

**Document ID:** SRS-001  
**Baseline:** 1.0.0  
**Status:** Stakeholder baseline; unresolved technical items are explicitly marked TBD/BLOCKER.  

## 1. Purpose

Specify the functional and quality requirements for the BNF/RNF Industrial Smart Surveillance Platform. This SRS is the source of truth for implementation, testing, and acceptance. Requirements must not be silently changed by an AI coding agent.

## 2. Terminology

- **Site/Factory:** BNF or RNF.
- **Site data plane:** Runtime, integrations, event data, and video metadata belonging to one factory.
- **Management plane:** Authorized cross-site navigation and management functions.
- **AI observation:** A model output such as person, phone, fire/smoke, PPE item, or object detection.
- **Event:** A normalized record created after AI output is evaluated by configured rules.
- **Alert:** A routed notification generated from an event.
- **Employee ID:** Stable attendance identifier within the source site's employee system.
- **Face image:** A conventional image. It is not interchangeable with a vendor-specific biometric face template.

## 3. Stakeholders and roles

| Role | Requirements / access |
|---|---|
| Company management | Cross-site dashboard and navigation; receives ordinary alerts; senior-management video access only if included in that authorization group |
| BNF factory manager | Can switch between sites as a manager; receives BNF ordinary alerts. Site-specific business views must still display selected-site context |
| RNF factory manager | Can switch between sites as a manager; receives RNF ordinary alerts. Site-specific business views must still display selected-site context |
| Security managers | Receive ordinary alerts; authorized to view live and recorded video |
| Senior management | Authorized to view live and recorded video |
| System/platform administrators | **TBD:** operational role, separation of duties, and whether administrators can view video must be approved |

The statement that managers can navigate between factories does not grant every manager video access. Video authorization remains restricted to security managers and senior management.

## 4. Functional requirements

Priority legend: **MUST** = baseline requirement; **SHOULD** = recommended unless rejected; **TBD** = requires clarification or proof.

### 4.1 Site isolation and navigation

| ID | Requirement | Priority |
|---|---|---|
| FR-SITE-001 | The platform shall support BNF and RNF as separate factory contexts. | MUST |
| FR-SITE-002 | Each factory shall retain its own ZKBioTime environment and SQL Server integration. | MUST |
| FR-SITE-003 | Operational records and video metadata shall remain logically and operationally isolated by site. | MUST |
| FR-SITE-004 | An authorized manager shall be able to switch the application context between BNF and RNF. | MUST |
| FR-SITE-005 | Every site-specific screen, event, report, camera, and API request shall carry an explicit site context. | MUST |
| FR-SITE-006 | Company management and authorized security users may view both sites according to their assigned privileges. | MUST |
| FR-SITE-007 | A failure or network outage at one site or the central VPN link shall not stop core local processing, video ingestion, AI analytics, local event persistence, or local alert generation at the factory. | MUST |
| FR-SITE-008 | No ordinary BNF event shall be delivered to RNF-only recipients, and vice versa. Cross-site access is limited to authorized company-management/security recipients. | MUST |

### 4.2 Employee and attendance integration

| ID | Requirement | Priority |
|---|---|---|
| FR-EMP-001 | The platform shall integrate with the separate ZKBioTime environment for each factory through a site-specific adapter. | MUST |
| FR-EMP-002 | Employee ID shall be used to link attendance records and employee identity within the site. | MUST |
| FR-EMP-003 | The platform shall discover whether conventional employee face photos can be retrieved from each supported ZKBioTime/device model. | MUST |
| FR-EMP-004 | The system shall distinguish available, missing, unreadable, unsupported, and review-required face images. | MUST |
| FR-EMP-005 | Vendor-specific face templates shall not be treated as ordinary images or assumed portable between device vendors. | MUST |
| FR-EMP-006 | Employee identity matching shall retain confidence, source, timestamp, model/version, and review state. | MUST |
| FR-EMP-007 | An uncertain identity shall be represented as unknown/unconfirmed rather than forced to an employee. | MUST |
| FR-EMP-008 | If the same Employee ID can exist at both sites, internal identifiers shall be site-scoped (for example, `(site_id, employee_id)`). | SHOULD |

**Attendance Integration Constraints**

- The preferred integration route is an officially supported and documented ZKBioTime API, if the installed version exposes the required capabilities and the owner has the necessary permissions.
- A read-only SQL Server integration may be used as an alternative or supplementary data source only after the database version, schema, views, permissions, and data semantics have been verified.
- The platform shall not write to or modify the source attendance database.
- Direct proprietary biometric terminal protocol integration is not part of the approved baseline.
- The pyzk library shall not be included in the proprietary application baseline.
- Employee photo retrieval remains blocked until verified against representative terminal models and the installed ZKBioTime versions.

### 4.3 Camera and video

| ID | Requirement | Priority |
|---|---|---|
| FR-VID-001 | The platform shall support an extensible inventory of cameras and multiple NVR models/vendors per site. | MUST |
| FR-VID-002 | Camera and NVR access shall be implemented through vendor/protocol adapters. Video stream normalization and browser/mobile delivery shall use a separately isolated streaming component where required. Vendor-specific logic shall not be scattered through business code. | MUST |
| FR-VID-003 | The platform shall determine actual stream and playback capabilities during device discovery; RTSP/ONVIF availability is not assumed. | MUST |
| FR-VID-004 | Authorized security managers and senior management shall be able to view live camera streams in the Android app. | MUST |
| FR-VID-005 | Authorized security managers and senior management shall be able to review recordings in the Android app. | MUST |
| FR-VID-006 | The app shall not expose permanent NVR credentials or raw unrestricted RTSP credentials to the client. | MUST |
| FR-VID-007 | Recorded video shall be retained for 30 days, subject to storage and NVR capability verification. | MUST |
| FR-VID-008 | Video metadata and clip references shall be stored separately from large video payloads where appropriate. | SHOULD |
| FR-VID-009 | Camera identity, site, zone, timestamp, and source NVR shall be visible with each video view and event. | MUST |
| FR-VID-010 | The platform shall discover and inventory camera capabilities (RTSP, ONVIF Profile S/T/G, resolution, framerate, audio, and physical PTZ support). | MUST |
| FR-VID-011 | The viewing applications (Web Admin and Android) shall provide Digital Zoom as a client-side viewport transformation without modifying the incoming video stream. | MUST |
| FR-VID-012 | The platform shall explicitly distinguish Digital Zoom from Optical Zoom; digital magnification shall never be represented as physical camera zoom. | MUST |
| FR-VID-013 | For cameras with verified motorized PTZ capabilities, the Web Admin shall provide authenticated Pan-Tilt-Zoom control with explicit permission checks, audit logging, safe travel limits, and instant manual override. | MUST |
| FR-VID-014 | Automated PTZ target tracking shall be configurable per camera, shall require separate administrative authorization, and shall never override scheduled security monitoring or disable continuous background recording. | MUST |
| FR-VID-015 | For fixed cameras lacking motorized hardware, the platform shall execute tracking and camera-to-camera handoff without fabricating physical PTZ movement. | MUST |

**Streaming Component Constraint**

go2rtc is the preferred candidate for the isolated video-streaming sidecar, subject to release pinning, license verification, protocol compatibility testing, and successful integration tests.

The platform shall not assume that every camera or NVR supports RTSP, WebRTC, MSE, ONVIF, or a common playback API. Actual capabilities must be discovered and verified per device model and firmware.

### 4.4 AI detection and event generation

| ID | Requirement | Priority |
|---|---|---|
| FR-AI-001 | Detect configured PPE violations according to rules assigned to each factory zone. | MUST |
| FR-AI-002 | Detect entry into configured restricted areas. | MUST |
| FR-AI-003 | Detect candidate human fall events and configured accident indicators using temporal visual evidence. The system shall distinguish candidate falls from ordinary activities such as sitting, bending, kneeling, and lying down to the extent validated by the approved evaluation dataset. Each event shall retain confidence, timestamps, camera reference, and supporting evidence. | MUST |
| FR-AI-004 | Detect phone-use behavior where the camera angle and image quality support it. | MUST |
| FR-AI-005 | Detect suspected fire/smoke and trigger the fire alert route without waiting for human confirmation. | MUST |
| FR-AI-006 | Detect and track configured factory material and product classes within designated production or storage zones using an owner-approved object taxonomy. The taxonomy shall be configurable per factory and shall not assume that all products or materials are visually distinguishable. | MUST |
| FR-AI-007 | Identify and record configured material movement patterns across owner-defined zones, including movement between designated areas and possible handoffs. The system shall report observed movement and configured rule violations as events; it shall not determine criminal intent or declare theft. | MUST |
| FR-AI-008 | Maintain person sightings and cross-camera movement records with timestamps and camera/location references. | MUST |
| FR-AI-009 | Store confidence and evidence for every AI-derived event. | MUST |
| FR-AI-010 | Preserve unknown/ambiguous identity or object states when confidence is insufficient. | MUST |
| FR-AI-011 | AI events shall not automatically produce disciplinary actions or declare a person guilty of theft. | MUST |
| FR-AI-012 | Detection thresholds and zone policies shall be configurable and versioned. | SHOULD |
| FR-AI-013 | The platform shall separate intra-camera person tracking (using short-term temporal tracking such as ByteTrack) from cross-camera re-identification (Person Re-ID embeddings). | MUST |
| FR-AI-014 | Cross-camera Re-ID shall utilize a camera topology graph (spatial adjacency, entry/exit zones, and transition time windows) to constrain candidate matches and prevent improbable teleportation. | MUST |
| FR-AI-015 | Person sightings across blind spots or unmonitored zones shall be explicitly flagged as discontinuous tracks with identity ambiguity rather than forced continuous trajectories. | MUST |
| FR-AI-016 | Employee identity association to a person track shall require meeting calibrated confidence thresholds; tracks with insufficient biometric or visual confidence shall remain labeled `UNKNOWN_PERSON`. | MUST |

**Material Movement and Theft Interpretation Constraint**

AI observations shall describe detected objects, locations, movement, timestamps, and configured rule violations. An AI-generated event is not proof of theft, employee misconduct, or criminal intent.

The following inputs remain owner-controlled and must be supplied before factory-specific acceptance testing:

- Approved product/material/object taxonomy.
- Authorized transfer routes and movement zones.
- Restricted zones and permitted operating schedules.
- Authorized roles and legitimate movement scenarios.
- Labeled factory footage for evaluation.

Until these inputs are supplied, FR-AI-006 and FR-AI-007 remain functionally specified but cannot receive final quantitative acceptance thresholds.

**Fall Detection Acceptance Criteria Status**

The following values must be established through representative factory footage and an approved evaluation protocol:

- Detection latency.
- Minimum precision and recall.
- False alerts per camera-hour.
- Required observation duration.
- Day/night and lighting performance.
- Camera-angle and occlusion limitations.

No numerical performance threshold shall be considered approved until it is measured on a documented validation dataset and accepted by the owner.

A fall-detection event is an auxiliary notification and does not replace a certified safety or emergency system.

### 4.5 Alerts and routing

| ID | Requirement | Priority |
|---|---|---|
| FR-ALT-001 | Alerts shall be delivered through the Android application. | MUST |
| FR-ALT-002 | Ordinary alerts shall be routed to the manager of the affected factory, company management, and security managers. | MUST |
| FR-ALT-003 | Ordinary alert routing shall preserve site context and shall not broadcast one factory's event to the other factory's ordinary site users. | MUST |
| FR-ALT-004 | Fire alerts shall be dispatched immediately to the responsible recipients at the affected factory without a manual confirmation gate. | MUST |
| FR-ALT-005 | The fire route shall be isolated from ordinary alert throttling or batching rules that could delay dispatch. | SHOULD |
| FR-ALT-006 | Every alert attempt, recipient resolution, delivery result, retry, and failure shall be auditable. | MUST |
| FR-ALT-007 | The system shall not require a security manager to approve an alert before it is delivered. | MUST |
| FR-ALT-008 | Alert acknowledgement, rejection, incident investigation, resolution, dismissal, escalation, and related workflow states require owner approval. The implementation agent shall not create or assume workflow states, transition rules, acknowledgement behavior, siren-silencing behavior, or incident closure permissions. Amended 2026-11-16 (local-dev default, pilot review required): states NEW, ACKNOWLEDGED, RESOLVED, DISMISSED (reason mandatory); each transition audited with user and UTC time. No siren-silencing behavior. No other states. | TBD |

**Owner Decision Required:** The incident workflow and its permitted transitions must be defined and approved before implementation of the corresponding workflow functionality.

Reference: OQ-021 in `planning/08_ADR_AND_OPEN_QUESTIONS.md`.

### 4.6 Dashboard and reports

| ID | Requirement | Priority |
|---|---|---|
| FR-REP-001 | The Android application shall provide dashboards for authorized managers. | MUST |
| FR-REP-002 | Reports shall be generated and viewed inside the application; Power BI is not a dependency. | MUST |
| FR-REP-003 | The reporting view shall include charts and percentages. | MUST |
| FR-REP-004 | The system shall create daily, weekly, and monthly report periods automatically. | MUST |
| FR-REP-005 | Reports shall support site, date range, event category, and other approved dimensions. | SHOULD |
| FR-REP-006 | Reports shall distinguish AI detections, routed alerts, confirmed incidents, and unresolved events if incident review is later approved. | SHOULD |
| FR-REP-007 | No report shall be emailed or sent through external channels unless separately approved. | MUST |

### 4.7 Android application

| ID | Requirement | Priority |
|---|---|---|
| FR-APP-001 | The client application shall target Android. | MUST |
| FR-APP-002 | The app shall provide dashboards, site switching, alert inbox, event/incident follow-up, and scheduled reports. | MUST |
| FR-APP-003 | Live video and playback screens shall be shown only to users with explicit video permissions. | MUST |
| FR-APP-004 | The app shall clearly show the active factory context. | MUST |
| FR-APP-005 | The app shall handle expired sessions, denied permissions, stream failures, and network interruptions without presenting stale data as current. | MUST |

### 4.8 VPN and remote connectivity

| ID | Requirement | Priority |
|---|---|---|
| FR-VPN-001 | The platform shall support secure site-to-site VPN connectivity (WireGuard / IPsec) linking BNF and RNF edge environments with central management. | MUST |
| FR-VPN-002 | Camera and NVR physical networks shall remain isolated on local factory CCTV VLANs and shall never be exposed to the public internet. | MUST |
| FR-VPN-003 | Remote administration and diagnostic access shall transit exclusively through authorized, authenticated VPN routes. | MUST |
| FR-VPN-004 | The system shall monitor VPN tunnel health, detect connection loss, and automatically reconnect with exponential backoff without dropping local operational state. | MUST |
| FR-VPN-005 | Upon VPN reconnection, queued event metadata, audit logs, and incident clips shall synchronize idempotently to central management without duplicating events. | MUST |

### 4.9 Desktop Web Administration Console (Proposed — Pending DEC-02)

> **SCOPE GOVERNANCE NOTE:** The Desktop Web Administration Console is governed by Owner Decision `DEC-02` (`PROPOSED — PENDING OWNER APPROVAL`). Requirements FR-WEB-001 through FR-WEB-006 are candidate/proposed requirements excluded from the mandatory baseline until DEC-02 receives formal written owner approval.

| ID | Requirement | Priority |
|---|---|---|
| FR-WEB-001 | Subject to DEC-02 approval, the platform shall provide a desktop browser Web Administration Console (React / TypeScript / Vite) for comprehensive system management, configuration, and incident investigation. | PROPOSED |
| FR-WEB-002 | Subject to DEC-02 approval, the Web Admin shall support camera discovery, inventory, stream configuration, stream health monitoring, and live preview. | PROPOSED |
| FR-WEB-003 | Subject to DEC-02 approval, the Web Admin shall provide an interactive zone editor allowing administrators to draw and edit polygon boundaries for restricted zones, PPE check areas, and fall-risk zones. | PROPOSED |
| FR-WEB-004 | Subject to DEC-02 approval, the Web Admin shall provide an incident investigation workspace featuring multi-camera synchronized playback, evidence clipping, and person tracking timeline visualization. | PROPOSED |
| FR-WEB-005 | Subject to DEC-02 approval, the Web Admin shall support employee roster management, device integration status, user role/permission management, and tamper-evident audit log review. | PROPOSED |
| FR-WEB-006 | Subject to DEC-02 approval, the Web Admin and Android application shall query identical backend API contracts and enforce consistent permission boundaries. | PROPOSED |

## 5. Non-functional requirements

| ID | Requirement | Priority / evidence |
|---|---|---|
| NFR-SEC-001 | Enforce server-side authorization for every protected operation; hiding a screen is not authorization. | MUST; security tests |
| NFR-SEC-002 | Enforce site isolation in queries, queues, object storage, cache keys, logs, and notifications. | MUST; isolation tests |
| NFR-SEC-003 | Encrypt network traffic and sensitive stored data using approved mechanisms. | MUST; security review |
| NFR-SEC-004 | Keep secrets out of source code, mobile binaries, logs, and committed config. | MUST; secret scan |
| NFR-SEC-005 | Cameras, NVRs, and local biometric readers must be strictly isolated behind dedicated network firewalls and edge gateways. Zero direct WAN routing to IoT/CCTV hardware is permitted. | MUST; network scan |
| NFR-REL-001 | Local factory edge processing continuity during central management or VPN outages is a MANDATORY requirement. Each factory edge node shall autonomously ingest video, execute AI inference, persist events locally, and trigger local alarms during network severance. | MUST; chaos/network test |
| NFR-REL-002 | Event and alert delivery shall use durable queues/retry and idempotency to avoid silent loss or duplicate storms. | MUST |
| NFR-SCL-001 | The design shall support at least the current approximate scale of 200+ cameras per factory and growth beyond it. | MUST; load test after inventory |
| NFR-SCL-002 | Capacity shall be calculated from actual stream count, resolution, FPS, codecs, retention, and analytics workload. | MUST; sizing report |
| NFR-MNT-001 | Business rules shall be independent from vendor SDKs, databases, and UI frameworks. | MUST; architecture review |
| NFR-MNT-002 | Modules shall expose explicit contracts and have automated unit/contract/integration tests. | MUST |
| NFR-OBS-001 | Structured logs, metrics, traces, health checks, and per-site operational status shall be available. | MUST |
| NFR-OBS-002 | The platform shall raise an operational alert ("coverage lost") to configured administrators when a camera stream or an AI worker heartbeat is missing for a configurable threshold time. | PROPOSED_LOCAL_DEV |
| NFR-UX-001 | The manager shall be able to identify the active site and event severity without ambiguity. | MUST; usability test |
| NFR-DATA-001 | Video retention shall be 30 days unless an evidence-preservation policy is explicitly approved. | MUST/TBD exception |
| NFR-AI-001 | AI performance shall be measured by event class, camera/zone, day/night conditions, and site using labeled test data. | MUST |
| NFR-AI-002 | No accuracy, latency, or false-positive percentage shall be claimed without measured results and a stated test set. | MUST |
| NFR-AI-003 | Deterministic business rules shall govern critical event evaluation. Language models (LLMs) may only be used for natural-language incident summarization and query assistance; LLMs are strictly prohibited from evaluating guilt, triggering emergency actions, or modifying system configuration. | MUST; safety audit |
| NFR-LIC-001 | The distributed proprietary application baseline shall use only owner-approved third-party components whose licenses and distribution obligations have been documented. The release process shall generate and review an SBOM and license compliance report. | MUST; SBOM and license audit |

## 6. Required event record

At minimum, every normalized event should include:

- `event_id`, `site_id`, `event_type`, `severity`, `occurred_at_utc`, `received_at_utc`.
- `camera_id`, `nvr_id` if known, `zone_id`, and location description.
- `subject_type`, optional `employee_ref`, optional `object_ref`.
- `confidence`, `model_id`, `model_version`, `rule_id`, `rule_version`.
- Evidence references: still image, recording time range, clip locator, and relevant metadata.
- `processing_status`, routing status, and audit timestamps.
- Identity/object match state: `confirmed_by_system_threshold`, `unconfirmed`, or `unknown` as defined by approved policy; do not use a boolean that falsely suggests certainty.

## 7. Constraints and dependencies

- NVR model/firmware inventory is unknown.
- RTSP/ONVIF and playback API access are unverified.
- ZKBioTime version/build and API availability are unknown.
- The face-image retrieval route is unverified across mixed terminal models.
- Existing server specifications and GPU capacity are unknown; current server has no GPU.
- Camera count may exceed 200 per factory.
- Network bandwidth and topology need discovery.
- Zone maps, PPE policies, restricted-area polygons, and product/object taxonomy must be supplied per site.
- Egyptian privacy/legal review is required before production biometric identification and employee movement profiling.

### Software Licensing and Deployment Constraints

- The target platform shall operate on-premises without mandatory paid SaaS subscriptions or mandatory recurring software-license fees for its approved baseline components.
- The proprietary application core shall not incorporate GPL, AGPL, SSPL, or other reciprocal-license source code or components without a separate documented legal review and explicit owner approval.
- Permissive third-party components may be used only after their exact repository license, release, transitive dependencies, and distribution obligations have been recorded.
- Model architecture licenses, model-weight licenses, training-data licenses, and dataset usage restrictions shall be evaluated separately.
- No AI model shall be approved solely because its source-code repository has a permissive license.
- All distributed third-party components shall be recorded in a maintained third-party license register and Software Bill of Materials (SBOM).
- License notices and attribution obligations shall be preserved.
- No software component shall be described as legally risk-free.

## 8. Explicit non-goals and anti-requirements

- Do not implement Power BI integration.
- Do not create iOS scope.
- Do not share all events between factories.
- Do not assume all cameras are RTSP-ready.
- Do not assume all biometric terminals expose photos through ZKBioTime.
- Do not treat face templates as images.
- Do not assign a person identity where evidence is weak.
- Do not label an AI suspicion as proven theft.
- Do not create unrequested approval/disciplinary workflows.
- Do not claim production readiness based on a successful build alone.
