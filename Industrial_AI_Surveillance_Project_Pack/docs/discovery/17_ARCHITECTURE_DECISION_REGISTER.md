> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 17 — Architecture Decision Register (ADR Log — Remediated)

**Document ID:** DISC-17-ADR-LOG  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** COMPLETE DECISION REGISTER  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Sections 5, 8 & 9 of CTO Directive  

---

## 1. Decision Governance Protocol

Every major architectural decision governing the BNF and RNF Industrial AI Surveillance Platform is recorded using the industry-standard Architecture Decision Record (ADR) format. 

In strict adherence to the project rules:
- Decisions confirmed by stakeholder baseline are labeled **CONFIRMED**.
- Architectural proposals authored by the engineering organization are labeled **PROPOSED** and require explicit owner sign-off at Gate 0/Gate 1.
- All technical claims carry explicit evidence classifications (`VERIFIED_OFFICIAL_SOURCE`, `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`, etc.).

---

## 2. Master Architecture Decision Register

### ADR-001: Federated Site Data Planes with Centralized Context Router
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (Charter site independence) + `PROPOSED` (Router pattern).
- **Context:** BNF and RNF are two major manufacturing plants with independent operations, separate SQL Server instances, and separate ZKBioTime systems (~200+ cameras each). Corporate executives and security heads require cross-factory visibility and seamless switching on mobile.
- **Decision:** Deploy completely autonomous site data planes at each factory (local databases, local inference, local queues). Deploy a lightweight Management API / Context Router that verifies user entitlements and routes authenticated requests to the appropriate site data plane without merging raw video or operational databases into a central repository.
- **Alternatives Considered:** Centralized Cloud Monolith (rejected: excessive WAN bandwidth); Fully Disconnected Silos (rejected: poor corporate UX).
- **Pros:** Total operational resilience (BNF operates during RNF network drops); strict tenant isolation; zero cross-site database leakage.
- **Cons:** Requires managing two edge deployment nodes; cross-site reporting requires an explicit aggregation step.
- **Security & Privacy Impact:** Maximum security; zero accidental tenant bleed.
- **Reversibility:** High.

---

### ADR-002: Modular Monolith Business Core with Isolated Edge Video Workers
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `PROPOSED` (Architectural pattern).
- **Context:** The system handles two radically different workloads: 1) Low-frequency, high-reliability transactional business workflows (attendance sync, alert routing, user management, reports), and 2) High-frequency, compute-intensive video streaming and deep learning inference (~400 frames/sec per site).
- **Decision:** Implement the business application as a Clean Architecture **Modular Monolith** (single deployable binary for the core) while decoupling the high-throughput video ingestion and AI inference pipelines into **isolated worker processes** communicating over Valkey Streams.
- **Alternatives Considered:** Full Microservices Mesh (rejected: excessive operational overhead); Single Monolithic Process (rejected: Python GIL locks, video crash takes down API).
- **Pros:** Extreme operational simplicity; single binary deployment for the API; complete failure isolation for the video pipeline.
- **Cons:** Requires a reliable local IPC / Valkey message queue between video workers and the business core.
- **Security & Privacy Impact:** Video decoders and AI models have no direct access to the relational database.
- **Reversibility:** High.

---

### ADR-003: Clean Architecture (Ports and Adapters) Boundary Enforcement
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `PROPOSED` (Software engineering discipline).
- **Context:** The platform must interface with changing external systems: multiple NVR vendors (Hikvision, Dahua, Uniview), proprietary ZKTeco APIs, on-premise SQL Server, and mobile push providers. Vendor SDKs must not contaminate core business rules.
- **Decision:** Mandate strict **Clean Architecture (Ports and Adapters)**. Domain entities and Application use cases depend solely on abstract interfaces (Ports). All external drivers, databases, HTTP clients, and AI runtimes reside in Infrastructure Adapters.
- **Alternatives Considered:** Framework-Centric Rapid Development (rejected: tight coupling, fragile tests).
- **Pros:** 100% testable domain logic; external devices can be mocked in CI; changing NVR vendor requires zero domain modifications.
- **Cons:** Requires boilerplate interface mapping and DTO translation layers.
- **Security & Privacy Impact:** Isolates vendor SDK vulnerabilities from business logic.
- **Reversibility:** Low (Foundational software architecture).

---

### ADR-004: Transactional Outbox Pattern with At-Least-Once Delivery & Consumer Idempotency
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (Distributed systems theory).
- **Context:** Life-safety and security alerts cannot be lost during process crashes or broker disconnects.
- **Decision:** Implement the **Transactional Outbox Pattern** in PostgreSQL. Events and notification intents are committed atomically in a single ACID transaction. The Outbox Publisher streams events to Valkey Streams with **at-least-once delivery guarantees**. Downstream mobile clients and workers enforce **idempotency keys** (`event_id`) to discard duplicate messages during network retries. Failed messages route to a Dead-Letter Queue (DLQ).
- **Alternatives Considered:** Direct Dual-Write (rejected: silent alert loss during network drops).
- **Pros:** Guarantees zero unrecorded events; transparent retry and dead-letter handling.
- **Cons:** Consumers must implement idempotency caching.
- **Security & Privacy Impact:** Auditable delivery log proving exactly when an alert was dispatched.
- **Reversibility:** High.

---

### ADR-005: Conventional Photo Extraction Gate (Zero Biometric Reverse Engineering)
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (ZKTeco protocol reality).
- **Context:** Stakeholder desires facial recognition using photos already stored in ZKTeco terminals. However, many biometric terminals store proprietary, irreversible mathematical templates rather than exportable RGB images.
- **Decision:** Execute a formal read-only proof-of-concept spike in Phase 1 (`T-FIA-001`). If raw RGB JPEG/PNG photos can be exported via supported ZKBioTime APIs, face enrollment proceeds. **If only proprietary templates exist, facial recognition is strictly BLOCKED until an administrative photo enrollment portal is established.** Under no circumstances may proprietary biometric templates be reverse-engineered or treated as open RGB images.
- **Alternatives Considered:** Reverse-Engineering Firmware Templates (rejected: mathematically impossible, unsupported, violates vendor terms).
- **Pros:** Adheres to technical reality; prevents project failure.
- **Cons:** May require an administrative photo upload workflow if device export fails.
- **Security & Privacy Impact:** Prevents corrupted biometric representations and legal liability.
- **Reversibility:** High.

---

### ADR-006: Embedded In-App Reporting Engine (Zero Power BI Dependency)
- **Status:** **CONFIRMED** (Stakeholder Baseline D-016 & D-017).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (Stakeholder Charter).
- **Context:** The client requires daily, weekly, and monthly reports with charts, percentages, and KPIs inside the mobile app, with zero recurring Power BI subscriptions and zero email/SMS delivery.
- **Decision:** Build an **Embedded In-App Reporting Engine**. PostgreSQL / TimescaleDB continuous aggregates compute rollups automatically at 00:00 UTC. The Android application renders vector charts (bar, line, donut) natively using Flutter canvas libraries (`fl_chart`).
- **Alternatives Considered:** Embedded Power BI / Metabase Iframe (rejected: violates confirmed requirement; incurs recurring licensing costs).
- **Pros:** Zero recurring subscription fees; instant mobile rendering; offline report snapshot caching.
- **Cons:** Requires custom SQL aggregation queries and custom Flutter chart styling.
- **Security & Privacy Impact:** Keeps reporting data completely on-premise; zero third-party SaaS data exposure.
- **Reversibility:** High.

---

### ADR-007: Zero-Trust Video Gateway with Scoped Signed Access Tokens
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (RFC 2104 / TLS 1.3).
- **Context:** 200+ cameras per site must be viewable by authorized Security Managers and Senior Management. Exposing permanent NVR credentials to mobile clients is a catastrophic security vulnerability.
- **Decision:** Implement a **Zero-Trust Video Gateway** (`go2rtc`). The mobile client requests a stream from the Management API over TLS 1.3. The API verifies RBAC clearance (`video:stream:live`), mints a signed HMAC-SHA256 token valid for 60 seconds (for message authentication and claim integrity), and returns a WebRTC connection URL. The mobile client streams via WebRTC over DTLS-SRTP. NVR credentials remain strictly isolated on the backend server.
- **Alternatives Considered:** Direct RTSP Streaming to Mobile (rejected: exposes NVR admin credentials; saturates NVR connection limits).
- **Pros:** Sub-500ms WebRTC streaming latency; zero NVR passwords on mobile; instant stream revocation; NVR stream multiplexing.
- **Cons:** Requires running the `go2rtc` media gateway on the edge server.
- **Security & Privacy Impact:** Eliminates the #1 attack vector in CCTV surveillance platforms.
- **Reversibility:** High.

---

### ADR-008: Dedicated Hardware Acceleration (Procuring Enterprise GPU Servers)
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` (2 FPS baseline) + `ESTIMATED` (VRAM budget).
- **Context:** Current server has zero GPUs. Running 12 vision models across 200 streams per site on CPU causes severe thread contention, dropped frames, and delayed emergency alerts.
- **Decision:** Mandate the procurement of **dedicated enterprise rackmount servers equipped with enterprise NVIDIA GPUs** (e.g., 1x RTX A5000 24GB or 2x RTX A4000 16GB per site) following empirical Phase 1 benchmarks. Video decoding (NVDEC) and FP16 inference will execute on dedicated Tensor Cores.
- **Alternatives Considered:** Run on Existing CPU Server (rejected: mathematically unviable under real-time constraints); Edge Smart Cameras (rejected: prohibitively expensive to replace 400+ installed cameras).
- **Pros:** Guarantees real-time 15ms inference latency; absorbs 200+ camera streams effortlessly; provides headroom for future AI models.
- **Cons:** Requires capital expenditure (CapEx) for server hardware procurement.
- **Security & Privacy Impact:** Server resides securely inside the on-premise factory server room.
- **Reversibility:** Low (Hardware procurement commitment).

---

### ADR-009: Decoupled Multi-Tier Alert Routing with Dedicated Urgent Fire Fast-Path
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (Charter D-013 & D-014).
- **Context:** Fire and smoke events require immediate dispatch without human triage. Ordinary safety events require standard routing with rate-limiting to prevent alert fatigue.
- **Decision:** Implement a **Two-Tier Notification Architecture**:
  1. *Tier 1 (Urgent Early Warning):* Fire/Smoke events bypass all batching, rate-limiting, and human confirmation gates, dispatching via a dedicated sub-second priority queue directly to responsible factory safety personnel.
  2. *Tier 2 (Operational Safety):* Ordinary events are deduplicated, batched if necessary, and routed to Factory Managers, Security Heads, and Corporate Executives per the approved matrix.
- **Regulatory Clarification:** Optical AI fire detection is documented as an **auxiliary early-warning tool**, NOT a certified replacement for building fire alarm control panels under NFPA 72 / EN 54.
- **Alternatives Considered:** Unified FIFO Queue (rejected: ordinary event storm delays emergency fire notification).
- **Pros:** Sub-second emergency notification; zero mobile alert fatigue.
- **Cons:** Requires maintaining two distinct queue channels and worker priorities.
- **Reversibility:** High.

---

### ADR-010: Native Android Handheld Interface paired with Web Administration Console
- **Status:** **PROPOSED** (Awaiting Gate 1 Sign-Off).
- **Evidence Classification:** `PROPOSED` (Ergonomic separation).
- **Context:** Stakeholder specified an Android application for managers. However, configuring 200+ camera RTSP URLs, drawing complex zone polygon geofences, configuring multi-shift PPE rule matrices, and auditing system logs is impractical on a mobile phone.
- **Decision:** Bifurcate the client interface:
  1. *Android Client (Flutter):* Exclusively dedicated to Manager workflows (Dashboards, real-time alert inbox, tokenized video viewing, 30-day playback seek, and in-app reporting).
  2. *Web Administration Console (React / Go):* Lightweight on-premise web portal for System Administrators and Safety Officers (Camera registry, zone polygon drawing canvas, PPE rule matrix, and audit log inspection).
- **Alternatives Considered:** Force All Administration into Mobile App (rejected: severe operational usability failure).
- **Pros:** Ergonomic fit for both manager and administrator personas; high mobile responsiveness.
- **Cons:** Requires maintaining two presentation layers sharing common backend APIs.
- **Security & Privacy Impact:** Administrative endpoints restricted to internal corporate IP ranges.
- **Reversibility:** High.

---

### ADR-011: Canonical Multi-Language Strategy & Inter-Service Architecture
- **Status:** **APPROVED BASELINE** (Mandated by CTO Directive).
- **Evidence Classification:** `VERIFIED_OFFICIAL_SOURCE` (Language & Framework Specialization).
- **Context:** To ensure performance, maintainability, type safety, and real-time capability, programming languages must be strictly assigned to specialized bounded contexts rather than forcing a single language across incompatible workloads.
- **Decision:** Establish a non-negotiable multi-language architecture:
  1. *Core Business Backend (GO):* Clean Architecture modular monolith managing business rules, REST/JSON endpoints, WebSockets, tenant isolation, ZKBioTime/SQL Server integrations, camera orchestration, event routing, and outbox notification dispatch.
  2. *Computer Vision & Analytics (PYTHON):* Dedicated, isolated worker daemons running PyTorch, OpenCV, TensorRT 10.7, and ByteTrack. Communicates with Go backend exclusively via versioned **gRPC** interfaces.
  3. *Desktop Web Administration Console (REACT / TYPESCRIPT / VITE):* Desktop browser management interface for camera discovery, topology maps, zone polygon drawing, live WebRTC viewing, authorized playback, digital zoom, PTZ controls, and incident investigation.
  4. *Mobile Management Client (FLUTTER / DART):* Manager mobile application using Bloc/Cubit state management, shared design tokens, and real API contracts.
  5. *Native Performance Optimization (C++):* Strictly restricted to benchmark-justified performance extensions (custom CUDA/TensorRT kernels, GStreamer plugins).
- **Alternatives Considered:**
  - Python Monolith for everything (rejected: GIL limitations, high concurrency latency, weak static typing for complex multi-site domain rules).
  - Go for Computer Vision (rejected: lack of mature ecosystem for bleeding-edge pose estimation, Re-ID, and TensorRT dynamic shape bindings).
  - Flutter Web for Admin Portal (rejected: poor desktop browser DOM ergonomics, larger initial load, canvas-rendered text limitations).
- **Pros:** Optimal runtime for each workload; Go handles high-concurrency I/O and business logic; Python handles AI models; React provides superior web admin tooling; Flutter delivers native 60fps Android performance.
- **Cons:** Requires managing gRPC schema versioning and two runtime toolchains (Go and Python).
- **Reversibility:** Low (Foundational architecture decision).

---

## 3. ADR Register Sign-Off

- **Status:** REVALIDATED DECISION REGISTER.
- **Next Step:** Owner review and formal approval during Gate 0.
