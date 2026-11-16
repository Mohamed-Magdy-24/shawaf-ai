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

- Status: APPROVED AS AMENDED (by ADR-012 … ADR-017; see docs/governance/CTO_AMENDMENTS.md).
- Edge Core: Go modular monolith / edge daemon.
- Video Streaming: Isolated go2rtc sidecar, subject to device compatibility and release/license verification.
- AI Worker: Isolated Python 3.11 gRPC service (ADR-012).
- AI Runtime: ONNX Runtime with CPU as the mandatory baseline; FP32 (ADR-016).
- Optional GPU acceleration: only after measured compatibility and performance verification.
- Intra-camera Tracking: ByteTrack, subject to dependency and release verification.
- AI Model Families: YOLOX and RT-DETR are candidates, not approved production models.
- Persistence: PostgreSQL 16 only (TimescaleDB and Valkey removed per ADR-013).
- Local Storage: Controlled filesystem storage behind an application storage abstraction.
- Clients: Flutter Android application and Flutter Web Administration Console (React/Vite removed per ADR-014).
- Connectivity: WireGuard candidate for site-to-site VPN, subject to deployment and security verification.
- Licensing: No mandatory paid software license or subscription in the approved baseline.
- Exclusions: Ultralytics/YOLOv8, pyzk, NVIDIA DeepStream, TensorRT, MinIO, TimescaleDB, Valkey, React/Vite.

**ADR-012 — The AI worker owns video decode and inference.**
- Status: APPROVED (local-dev)
Context: Go has no native production video decoder; sending raw frames Go→Python over gRPC costs CPU/RAM and bandwidth. Decision: the Go core never decodes video. The Python worker pulls each camera's *sub-stream* (credentials supplied by Go at config time, never logged), decodes it with an ffmpeg subprocess (or PyAV), applies a fixed-rate sampler, keeps a **bounded latest-frame queue (size 1–2, drops counted)** per camera, runs ONNX inference, tracking and rule evaluation, and sends **only events + a JPEG evidence snapshot reference** to Go via versioned gRPC (idempotency key per event). Go owns camera/zone/policy configuration, scheduling, health, persistence, alerts. Transport: gRPC over TCP 127.0.0.1 (works identically in WSL2, Docker and Linux; no Unix sockets). Consequences: Go↔Python traffic is tiny; one worker process serves N cameras where N is MEASURED in WP-3; the "proto" file must contain no frame/pixel message.

**ADR-013 — Minimal data plane.**
- Status: APPROVED (local-dev)
Decision: PostgreSQL 16 only. Outbox = table with `priority`, `status`, `attempts`, `next_attempt_at`, unique `idempotency_key`; dispatch with `FOR UPDATE SKIP LOCKED` + `LISTEN/NOTIFY`. Fire-priority rows are served by a dedicated goroutine with its own connection and no batching/throttling. Events table uses native monthly partitioning. **Valkey and TimescaleDB are removed from the baseline** (re-introduce only through a new ADR citing a measured limit). Consequences: two fewer services, no Timescale License question, lower RAM.

**ADR-014 — One client codebase.**
- Status: APPROVED (local-dev)
Decision: Flutter (Dart) for the Android manager app AND the administration console (Flutter Web build, desktop browser). React/Vite is removed from the baseline. Cubit/Bloc (`flutter_bloc`) for state. Zone editor = CustomPainter polygon editor. Live view = WebRTC via go2rtc (`flutter_webrtc` after license check). Charts = in-app vector charts (`fl_chart` after license check). Consequences: 3 languages total (Go, Python, Dart).

**ADR-015 — Runtime environment.**
- Status: APPROVED (local-dev)
Decision: develop inside WSL2 Ubuntu LTS; run containers with Docker Engine (docker-ce, Apache-2.0) inside WSL2, **not Docker Desktop**, unless the owner confirms the company qualifies for the free tier. `%USERPROFILE%\.wslconfig`: `memory=5GB`, `processors=6`, `swap=6GB` with the swap file on D:. Keep project files and volumes inside the WSL2 ext4 filesystem (not `/mnt/d`). Production target: Ubuntu Server LTS. Windows 10 is past end of support: treat the workstation as a dev box only; never expose it to the factory network. The Android emulator is forbidden; use a physical phone over USB.

**ADR-016 — Inference runtime.**
- Status: APPROVED (local-dev)
Decision: the deployed worker image contains ONNX Runtime + OpenCV/NumPy only (no PyTorch). Models are exported to ONNX in a separate offline "model-export" environment; every model artifact is stored with source commit, SHA-256 and a MODEL_REGISTER row. CPU is the mandatory baseline; `onnxruntime-gpu` (CUDA) is optional and enabled only if WP-3 proves it works on the P600 with the pinned driver/CUDA/cuDNN — otherwise CPU only. TensorRT, DeepStream, Ultralytics, pyzk, MinIO stay excluded. Models use FP32 on the P600.

**ADR-017 — Notification channel port.**
- Status: APPROVED (local-dev)
Decision: `NotificationChannel` port with adapters: (1) `WebSocketChannel` (in-app, default), (2) `FcmChannel` (implemented, **disabled** until DEC-08; payload = event id + generic text only: no names, no images, no site-sensitive details), (3) `NtfyChannel` (self-hosted ntfy/UnifiedPush, Apache-2.0/GPL-check required before use — if its server license is copyleft, run it only as a separate unmodified process and record the legal note) as a Google-free fallback candidate. Android client: foreground service for the socket plus a documented battery-optimization exemption step; test on the physical phone with screen off for 30 min. Additionally the platform MUST raise an **operational alert ("coverage lost")** to configured admins when a camera stream or a worker heartbeat is missing for a configurable time — a silent blind spot is a safety defect. (New requirement NFR-OBS-002 — add to SRS and CSV as `PROPOSED_LOCAL_DEV`; CSV then has 97 rows; update CANONICAL_NUMBERS.md accordingly.)

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
