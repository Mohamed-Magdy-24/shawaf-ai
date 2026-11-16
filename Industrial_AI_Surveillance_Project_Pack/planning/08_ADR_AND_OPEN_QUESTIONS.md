# Architecture Decision Records and Open Questions

**Document ID:** ADR-LOG-001  
**Status:** Initial decision log. Proposed decisions require owner approval.  

## 1. Decisions already confirmed by stakeholder

| ID | Decision | Status / note |
|---|---|---|
| D-001 | BNF and RNF are treated as operationally independent factories | CONFIRMED |
| D-002 | Each factory has its own SQL Server | CONFIRMED |
| D-003 | Each factory has its own environment/instance of the same ZKBioTime system family | CONFIRMED from clarification; exact version TBD |
| D-004 | Approximately 200+ cameras per factory; may increase | CONFIRMED estimate |
| D-005 | Approximately 18+ biometric terminals per factory; mixed models; may increase | CONFIRMED estimate |
| D-006 | Employee ID is stable within attendance and SQL records | CONFIRMED |
| D-007 | Employee face photos are currently only in biometric terminals/system | CONFIRMED; retrieval unproven |
| D-008 | Video retention target is 30 days | CONFIRMED |
| D-009 | Android application only | CONFIRMED |
| D-010 | Managers can switch between BNF and RNF | CONFIRMED |
| D-011 | Live and recorded video restricted to security managers and senior management | CONFIRMED |
| D-012 | Ordinary alerts go to affected factory manager + company management + security managers | CONFIRMED |
| D-013 | Fire alerts go immediately to responsible people in affected factory | CONFIRMED |
| D-014 | Fire dispatch does not wait for manual confirmation | CONFIRMED |
| D-015 | Dashboard and daily/weekly/monthly charts/percentages are inside app | CONFIRMED |
| D-016 | No Power BI subscription; no Power BI dependency | CONFIRMED |
| D-017 | No external email report delivery; app only | CONFIRMED |
| D-018 | AI scope includes PPE, restricted areas, falls/accidents, phone, fire, theft/object movement | CONFIRMED functional scope |
| D-019 | Employee tracking history across cameras with time and location | CONFIRMED desired capability; technical feasibility/accuracy TBD |

## 2. Proposed architecture decisions awaiting approval

### ADR-001 — Federated site data planes

**Proposal:** Run a self-contained BNF site data plane and RNF site data plane. Use a bounded management API to route authenticated managers to either site. Do not merge raw video or operational databases.

**Reason:** Preserves operational independence and reduces cross-site data leakage while still supporting manager navigation.

**Alternatives:** One shared operational database; central-only processing; fully separate apps. Each alternative has higher data coupling, single-failure risk, or duplicated management experience.

**Status:** PROPOSED. Approve after network/deployment discovery.

### ADR-002 — Modular monolith before microservices

**Proposal:** Build the business backend as a modular monolith with clean boundaries; isolate stream ingestion and inference into worker processes/services when needed.

**Reason:** Avoid distributed-system overhead before team size and scaling data justify it; video workloads need independent resource isolation.

**Status:** PROPOSED. Revisit with measured load and deployment constraints.

### ADR-003 — Clean Architecture and Ports & Adapters

**Proposal:** Domain/Application layers depend on ports; vendor SDKs and databases live in Infrastructure adapters.

**Status:** PROPOSED; recommended baseline.

### ADR-004 — Transactional Outbox for alert delivery

**Proposal:** Persist event and notification intent reliably; dispatch through durable queue with retry/idempotency.

**Reason:** Alert loss is operationally unacceptable, especially for fire routing.

**Status:** PROPOSED; recommended baseline.

### ADR-005 — Conventional photo retrieval only for face matching

**Proposal:** Use supported ZKBioTime/device photo retrieval. Do not reverse engineer or reinterpret proprietary biometric templates.

**Reason:** Compatibility, correctness, security, and supportability.

**Status:** PROPOSED; face matching remains blocked until POC and legal review.

### ADR-011 — Unified Edge, Streaming, and AI Runtime Baseline

- Status: PROPOSED — PENDING OWNER APPROVAL.
- Edge Core: Go modular monolith / edge daemon.
- Video Streaming: Isolated go2rtc sidecar, subject to device compatibility and release/license verification.
- AI Worker: Isolated Python 3.11 gRPC service.
- AI Runtime: ONNX Runtime with CPU as the mandatory baseline.
- Optional GPU acceleration: only after measured compatibility and performance verification.
- Intra-camera Tracking: ByteTrack, subject to dependency and release verification.
- AI Model Families: YOLOX and RT-DETR are candidates, not approved production models.
- Persistence: PostgreSQL 16, with TimescaleDB only after license and compatibility verification.
- Local Storage: Controlled filesystem storage behind an application storage abstraction.
- Cache/ephemeral data: Valkey candidate, subject to compatibility verification.
- Clients: Flutter Android application and React/Vite desktop Web Administration Console, consistent with the approved project scope.
- Connectivity: WireGuard candidate for site-to-site VPN, subject to deployment and security verification.
- Licensing: No mandatory paid software license or subscription in the approved baseline.
- Exclusions: Ultralytics/YOLOv8, pyzk, NVIDIA DeepStream, and TensorRT.

**Approval condition:** This ADR remains PROPOSED until the project owner explicitly approves it. Its contents must not be treated as an approved implementation baseline before that approval.

## 3. Open questions / blockers

| ID | Question / required evidence | Why it matters | Owner / next action |
|---|---|---|---|
| OQ-001 | What are the exact ZKBioTime version/build numbers for BNF and RNF? | API/photo compatibility | IT inventory |
| OQ-002 | What APIs/licenses are enabled in both ZKBioTime environments? | Employee/photo/attendance integration | Vendor/IT discovery |
| OQ-003 | Which biometric terminal models/firmware are installed at each site? | Photo extraction and compatibility | Device inventory |
| OQ-004 | Can conventional photos be retrieved for each terminal family through supported APIs? | Face recognition blocker | POC |
| OQ-005 | What are SQL Server versions, schemas, table sizes, and permissions? | Safe data mapping | Read-only schema export |
| OQ-006 | What NVR vendors/models/firmware exist at each site? | Live/playback adapter selection | Physical/network inventory |
| OQ-007 | Which NVRs expose supported live/playback APIs and session limits? | Video app feasibility | Vendor POC |
| OQ-008 | Are RTSP/ONVIF streams enabled and reachable by an approved service? | Inference ingestion | Network test |
| OQ-009 | What are camera resolution/FPS/codec/bitrate profiles? | GPU/network/storage sizing | Stream inventory |
| OQ-010 | What are current CPU/RAM/storage/OS/NIC specs? | Deployment sizing | IT inventory |
| OQ-011 | What GPU/edge compute budget is available? | AI throughput and placement | Capacity/cost decision |
| OQ-012 | What are the VLAN/firewall/bandwidth rules at both sites? | Secure connectivity | Network team |
| OQ-013 | Which people are “responsible recipients” for a fire alert at each factory? | Fire route cannot be guessed | Owner supplies roster |
| OQ-014 | Exact manager/security/senior-management memberships and permissions? | RBAC and video access | Business owner |
| OQ-015 | What PPE items are required in each zone and shift? | PPE rule configuration | Safety manager |
| OQ-016 | Which areas are restricted and what schedules/roles are permitted? | Intrusion rules | Factory/security owner |
| OQ-017 | Which products, materials, cartons, sacks, containers, and other objects should be classified? | Theft/object model taxonomy | Operations/warehouse |
| OQ-018 | What movements are legitimate (dispatch, transfers, shift changes)? | Reduce false positives | Operations owner |
| OQ-019 | What confidence and false-alarm thresholds are acceptable per event? | AI alert usability | Safety/security owner after pilot |
| OQ-020 | What report KPIs and formulas are required? | Avoid misleading percentages | Management |
| OQ-021 | What incident workflow states/actions are required? | “Follow-up” needs precise behavior | Management/security |
| OQ-022 | What retention applies to events, biometric data, audit logs, and incident evidence? | Privacy/storage compliance | Legal/security |
| OQ-023 | What legal/privacy approvals and employee notices are required for face recognition and tracking? | Production biometric gate | Legal/HR |
| OQ-024 | What Android device/OS versions and deployment model are supported? | App compatibility | IT |
| OQ-025 | What availability, recovery-time, recovery-point, and response-time targets are required? | Production SLOs | Management/IT |

## 4. Decision hygiene

Every new decision must be recorded as an ADR with: context, decision, alternatives, pros/cons, security/privacy impact, operational impact, reversibility, owner, date, and status. An AI agent may recommend but may not silently mark a proposed decision as approved.
