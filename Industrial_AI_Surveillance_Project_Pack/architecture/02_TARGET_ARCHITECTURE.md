# Target Architecture and Engineering Rules

**Document ID:** ARCH-001  
**Status:** Proposed target architecture; finalize after Phase 0 discovery and ADR approval.  

## 1. Architecture decision in one sentence

Use a **federated, two-site deployment**: each factory runs an independently operable site data plane, while a carefully bounded management plane and Android application allow authorized managers to switch between BNF and RNF without merging the factories' operational databases or raw video.

## 2. Recommended architecture style

### 2.1 Modular monolith for business services, edge workers for video

Start with a modular backend rather than prematurely splitting every module into a microservice. Keep clear module boundaries and independently deployable video/AI workers where resource isolation or scaling requires it. The video pipeline is a different workload from ordinary CRUD/API traffic and must not starve the manager API.

**Why:** the project has substantial integration and inference complexity, but team size, operating capacity, deployment environment, and cloud/on-prem constraints are not yet known. Microservices add distributed failure modes, deployment overhead, observability cost, and data consistency work. Split a module only when a measured scaling, isolation, ownership, or availability need justifies it.

### 2.2 Clean Architecture / Ports and Adapters

Use dependency direction inward:

1. **Domain:** entities, value objects, invariants, domain events, policies. No database, HTTP, vendor SDK, Android, or AI framework dependency.
2. **Application:** use cases, commands/queries, orchestration, authorization checks, transaction boundaries, ports/interfaces.
3. **Infrastructure:** SQL repositories, ZKBioTime adapters, NVR/camera adapters, queue adapters, object storage, notification delivery, AI runtime adapters.
4. **Presentation:** API controllers/BFF and Android UI. Presentation translates input/output; it does not own business rules.

Dependencies point toward Domain/Application abstractions. Infrastructure implements ports; domain code never imports vendor SDKs.

### 2.3 Canonical Programming Language Strategy

In accordance with the CTO Master Directive on Canonical Technology Stack:
1. **Core Business Backend — GO:**
   - Primary language for all business logic, REST/JSON APIs, WebSocket streams, authentication, authorization, factory tenant isolation, camera/NVR orchestration, ZKBioTime adapters, and SQL Server read-only sync.
   - Clean Architecture, modular boundaries, strongly typed domain contracts.
2. **Artificial Intelligence & Video Analytics — PYTHON:**
   - Isolated processes/services for computer vision, ONNX Runtime inference, ByteTrack, Person Re-ID, PPE, falls, fire/smoke, and behavioral evaluation.
   - Communicates with Go backend exclusively via versioned **gRPC** interfaces.
3. **Desktop Web Admin Console — REACT / TYPESCRIPT (Vite):**
   - Desktop browser administration portal for camera inventory, topology maps, zone polygon editing, live WebRTC viewing, authorized playback, digital zoom, PTZ controls, and incident investigation.
4. **Android Management Application — FLUTTER / DART:**
   - Manager mobile client for real-time alert feeds, site switching, incident review, evidence inspection, and authorized video playback.
5. **Native Systems Optimization — C++:**
   - Permitted only when justified by measured benchmarks and approved licensing.

## 3. Logical context

```text
       +-------------------------------+       +------------------------------------+
       |  Android Manager App (Flutter)|       | Desktop Web Admin Console (React)  |
       |  Alerts / Feed / Video / Auth |       | Topology / PTZ / Zones / Audit     |
       +---------------+---------------+       +-----------------+------------------+
                       |                                         |
                       +--------------------+--------------------+
                                            | Authenticated REST / WebSocket
                               +------------v------------+
                               |    Go Core Backend      |
                               | (Modular Monolith / RLS)|
                               | Central Management Plane|
                               +------------+------------+
                                            |
                      +---------------------+---------------------+
                      | Site-to-Site WireGuard / IPsec VPN        |
                      |                                           |
           +----------v-----------+                   +-----------v----------+
           | BNF Factory Edge     |                   | RNF Factory Edge     |
           | - Go Edge Agent      |                   | - Go Edge Agent      |
           | - go2rtc Gateway     |                   | - go2rtc Gateway     |
           | - Local PostgreSQL   |                   | - Local PostgreSQL   |
           | - Local Valkey Queue |                   | - Local Valkey Queue |
           +----------+-----------+                   +-----------+----------+
                      | gRPC                                      | gRPC
           +----------v-----------+                   +-----------v----------+
           | Python AI Workers    |                   | Python AI Workers    |
           | (ONNX Runtime)        |                   | (ONNX Runtime)        |
           +----------+-----------+                   +-----------+----------+
                      |                                           |
               Isolated CCTV LAN                           Isolated CCTV LAN
           BNF Cameras / NVRs / SQL                    RNF Cameras / NVRs / SQL
```

The management API may query the two site APIs independently using explicit authorization. It must not silently replicate all site event/video/employee data into one shared operational database. The exact management identity/SSO topology is a **PROPOSED** decision and must be recorded in an ADR after deployment discovery.

## 4. Deployment boundaries

### BNF site plane

- Site-specific configuration and secrets.
- Site-specific SQL Server connector and credentials.
- Site-specific ZKBioTime connector and credentials.
- Site-specific camera/NVR inventory and stream credentials.
- Site-specific inference workers, event store, queue, cache, and monitoring.
- Site-specific policy configuration: zones, PPE, restricted areas, recipients.
- Local operation must not depend on the RNF site plane.

### RNF site plane

Same module capabilities, independently configured and deployed. No shared database connection strings, credentials, event queues, or video storage between sites.

### Management plane

- Authenticates managers and resolves their site/role entitlements.
- Routes requests to BNF or RNF site APIs.
- Aggregates only the data required for authorized cross-site dashboards.
- Applies server-side authorization per site and per capability.
- Does not grant video access merely because a user can switch sites.

## 5. Domain modules

Use explicit module contracts. Suggested modules:

1. `IdentityAccess`: authentication, users, roles, permissions, sessions.
2. `SiteRegistry`: site definitions, site context, endpoint registry.
3. `EmployeeDirectory`: site-scoped Employee IDs and profile metadata.
4. `AttendanceIntegration`: ZKBioTime synchronization and reconciliation.
5. `BiometricImageAcquisition`: photo retrieval, validation, provenance, lifecycle.
6. `DeviceRegistry`: cameras, NVRs, terminals, capabilities, health.
7. `VideoAccess`: live stream sessions, playback authorization, clip references.
8. `VideoIngestion`: frame/stream ingestion and scheduling.
9. `AnalyticsInference`: model execution and raw detections.
10. `Tracking`: person/object tracks and cross-camera association.
11. `ZonePolicy`: region definitions, PPE rules, restricted areas.
12. `EventManagement`: normalized events, deduplication, correlation.
13. `AlertRouting`: severity, recipients, site-specific dispatch policy.
14. `NotificationDelivery`: durable in-app notifications and delivery status.
15. `IncidentManagement`: follow-up records; workflow states remain TBD until approved.
16. `Reporting`: scheduled aggregates and report snapshots.
17. `AuditObservability`: audit trail, structured logs, metrics, traces.

Modules should be code packages/layers first, not automatically separate services.

## 6. Design patterns and where they belong

Apply patterns only when a concrete variation point exists.

| Pattern | Appropriate use | Avoid |
|---|---|---|
| Adapter | ZKBioTime versions, SQL Server access, Hikvision/Dahua/other NVRs, notification or storage providers | Vendor SDK calls inside use cases |
| Strategy | Select model/inference strategy, PPE policy evaluation, alert severity/route policy | A generic Strategy interface around every method |
| Factory / Abstract Factory | Construct the correct site/vendor adapter from validated configuration | A factory that hides arbitrary service location or runtime magic |
| Repository | Persist and retrieve domain aggregates through application ports | Generic repository abstractions that erase useful SQL behavior |
| Specification / Policy | Evaluate zone-specific PPE, restricted-zone, alert-routing rules | Hard-coded condition chains spread across controllers |
| Pipeline | Frame decode → preprocess → inference → tracking → rule evaluation → event normalization | One giant function that owns every video step |
| Observer / Domain Events | Publish accepted domain events to downstream modules | In-process events used as a substitute for durable delivery across process boundaries |
| Transactional Outbox | Persist an event and its dispatch intent atomically before publishing to a queue | Fire-and-forget notification calls after a DB transaction |
| State Machine | Only after incident workflow states are approved; model legal transitions | Inventing states or a workflow not requested by the owner |
| Circuit Breaker / Retry / Bulkhead | Unreliable vendor devices, NVR APIs, and external service calls | Infinite retries, retry storms, or blocking all site processing on one NVR |
| CQRS / Materialized Views | Reporting/read dashboards if measured query load warrants it | Introducing separate read/write stores before a demonstrated need |

## 7. Video and AI processing architecture

Separate the pipeline into bounded stages:

1. Stream/session discovery and health monitoring.
2. Frame sampling/decoding at a controlled rate.
3. Region-of-interest masking and camera calibration.
4. Detection inference by model family.
5. Object/person tracking within a camera.
6. Cross-camera association where camera layout/time synchronization supports it.
7. Identity association against permitted employee image references.
8. Policy/rule evaluation.
9. Event normalization and evidence packaging.
10. Alert routing and durable notification delivery.

Each stage must report health, lag, dropped frames, processing time, and errors. A failed AI worker must not block Android API traffic or take down camera inventory and attendance synchronization.

## Video Streaming Sidecar — go2rtc

go2rtc is the preferred candidate for an isolated streaming sidecar. Its adoption remains subject to ADR-011 owner approval, exact release and license verification, and successful compatibility testing against representative camera and NVR models.

Responsibilities:

- Accept only configured and authorized upstream streams.
- Provide supported WebRTC/MSE delivery paths to authorized clients.
- Keep camera/NVR credentials outside browser and mobile clients.
- Expose health and stream-status information to the Go core.
- Operate independently from the business-domain modules.
- Be deployed with a pinned and verified release.
- Be monitored for stream availability, connection failures, and resource consumption.

Security boundaries:

- go2rtc shall not expose unrestricted camera access to the public internet.
- Access shall be restricted to approved internal interfaces and authenticated application paths.
- Client playback access shall use short-lived authorization mechanisms controlled by the application.
- A streaming-sidecar failure shall not stop attendance synchronization, user authentication, or unrelated business API operations.

Limitations:

- go2rtc is not the system of record for events or attendance.
- go2rtc is not the approved long-term recording-retention engine.
- NVR playback and recording capabilities must be verified separately for each supported model.

## AI Inference Runtime Baseline

The platform shall use a decoupled Python AI worker communicating with the Go core through versioned gRPC contracts.

### Proposed Runtime Baseline — Pending ADR-011 Owner Approval

- AI worker language: Python 3.11, isolated from the host Python installation.
- Model execution: ONNX Runtime.
- Primary compatibility baseline: CPU inference.
- Optional acceleration: CUDA execution provider only after GPU, driver, CUDA, ONNX Runtime, and model compatibility are verified together.
- Worker communication: versioned gRPC and protobuf contracts.
- Intra-camera tracking: ByteTrack, subject to pinned release and dependency-license verification.
- Cross-camera Re-ID: separate research and validation capability; not assumed to be production-ready.
- Model selection: only models with verified source-code, model-weight, and dataset licenses may be approved.

### Explicit exclusions

The proposed baseline shall not depend on:

- Ultralytics YOLOv8.
- The `ultralytics` Python package.
- NVIDIA DeepStream SDK.
- TensorRT.
- The `pyzk` library.

No excluded component may be reintroduced without a separate architecture decision, compatibility proof, licensing review, and owner approval.

### Model Selection Policy

YOLOX and RT-DETR may be evaluated as candidate model families. Neither is automatically approved merely by naming it in this document.

Before selecting a model, record:

1. Exact repository and release or commit.
2. Source-code license.
3. Exact model-weight license.
4. Dataset and pretrained-weight provenance.
5. Runtime compatibility.
6. Hardware compatibility.
7. Measured accuracy and latency on the approved evaluation dataset.
8. Memory and throughput measurements.
9. Commercial distribution obligations.

The model selection decision shall be recorded in the AI model register.

### AI Frame Ingestion Backpressure and Drop Policy

The Go edge component shall enforce bounded memory usage for AI frame dispatch.

Requirements:

- AI frame queues shall be bounded per camera stream.
- The system shall not allow unbounded frame accumulation when inference is slower than ingestion.
- The implementation shall support a configurable latest-frame or bounded-frame strategy appropriate to each detector.
- Dropped frames shall be counted and exposed through metrics.
- Inference latency, queue depth, dropped-frame count, worker health, and processing errors shall be observable.
- A failed AI worker shall not block unrelated API requests, camera inventory, or attendance synchronization.
- Recovery shall not silently duplicate events or lose already persisted events.

Initial queue capacity, latency thresholds, and alert thresholds must be configurable and validated through benchmarks. Do not hardcode the proposed ring-buffer size of 2 or the proposed 200ms/five-frame alert threshold as approved production values.

## 8. Data and storage principles

### Storage Architecture and Retention

- **Video Payload Separation:** Keep video payloads separate from relational event metadata. Video payloads remain in the NVR or behind an application storage abstraction; event metadata and protected clip references are stored in relational storage.
- **Site Isolation:** Keep BNF and RNF operational storage completely isolated. No shared file/object namespace, database connections, or storage paths between sites.
- **Local Filesystem Storage:** For the initial on-premises deployment, the platform shall use controlled local filesystem storage on supported Linux filesystems such as ext4 or XFS, with explicit storage paths, access permissions, retention policies, and backup procedures. MinIO is removed from the proposed baseline to prevent incompatible licensing obligations.
- **Storage Abstraction:** File access shall be mediated by an application storage abstraction port; storage paths shall not be scattered through business logic. Local filesystem storage alone does not solve multi-site replication, backup, high availability, or evidence durability.
- **Video Retention Baseline:** Recorded video shall be retained for 30 days as specified in the project charter and SRS. The 30-day requirement shall not be changed without explicit owner approval. Retention policies for event metadata, biometric source images, face embeddings, and audit records shall be set independently; their retention periods remain TBD.
- **Database Engine:** PostgreSQL 16 is retained as the relational database baseline, subject to version and extension compatibility verification. Enforce site isolation and row-level security (RLS). TimescaleDB is retained as a candidate only if its exact license, extension availability, compatibility, and deployment obligations are verified and recorded. Hypertable partition intervals and retention periods shall not be invented without operational evidence.
- **In-Memory Store:** Valkey is the preferred candidate for in-memory caching and message queue buffering where a compatible feature set is required. Redis-specific APIs and configurations shall not be introduced into the proposed baseline.
- **Identity & Schema Rules:** Use stable UUIDs for platform records. Scope source Employee ID to the site. Store UTC timestamps and retain original camera/device timestamp plus synchronization offset where needed. Use schema versioning for event messages and transactional outbox for reliable publication.

## 9. API and contract rules

- Version public APIs and event schemas.
- Every site-scoped request includes site context and is authorized server-side.
- Avoid exposing vendor payloads as the public domain contract.
- Validate all external input at adapter boundaries.
- Use idempotency keys for commands that may be retried.
- Paginate event, camera, and employee searches.
- Use short-lived video playback tokens/session grants.
- Document error types and retryability.

## 10. Resilience and scale

- Site-level bulkheads: one failed NVR or AI worker should not stop other cameras.
- Durable queues with bounded retry and dead-letter handling.
- Local buffering during upstream/network interruption.
- Horizontal scaling of inference workers based on measured GPU/CPU capacity and per-model throughput.
- Do not size on camera count alone. Capture resolution, FPS, codec, stream count, inference sampling rate, number of models, retention mode, and concurrency.
- Do not route all high-bandwidth live streams through one central server without a bandwidth and capacity assessment.

## 11. Canonical multi-language repository structure

```text
repo/
  docs/                         # Project documentation and ADR registers
  proto/                        # Shared gRPC protobuf definitions (Go & Python)
    video_analytics.proto
    events.proto
    tracking.proto
  backend/                      # Core Business Platform (GO)
    cmd/
      server/                   # API Server & Management Plane entrypoint
      edge-agent/               # Factory Edge Ingestion Agent entrypoint
    internal/
      domain/                   # Clean Architecture: Entities & Value Objects
      application/              # Use Cases, Ports & Interfaces
      infrastructure/           # PostgreSQL, TimescaleDB, Valkey, go2rtc, ZKTeco
      presentation/             # REST API Handlers, WebSockets, gRPC Servers
  ai-workers/                   # Computer Vision & Inference Daemons (PYTHON)
    detectors/                  # Candidate models (PPE, Intrusion, Fire/Smoke)
    tracking/                   # ByteTrack & Person Re-ID embeddings
    fall_trigger/               # Decoupled temporal differencing & ring buffer
    runtime/                    # ONNX Runtime execution engines
    grpc_service/               # Python gRPC worker daemon
  web-admin/                    # Desktop Administration Console (REACT / TYPESCRIPT / VITE)
    src/
      components/               # UI Component Library (Teal/Graphite Tokens)
      features/                 # Camera Inventory, Topology, Zone Editor, Incidents
      api/                      # Typed REST/WebSocket client
  mobile-app/                   # Manager Application (FLUTTER / DART)
    lib/
      core/                     # Clean Code Core & Theme Tokens
      features/                 # Cubits, Alert Inbox, Video Player, Reports
  deploy/                       # Infrastructure & Deployment
    docker-compose.local.yml    # Reproducible local developer environment
    edge/                       # Factory edge systemd / docker manifests
    vpn/                        # WireGuard / IPsec configuration templates
  tests/                        # Automated Test Suites
    e2e/                        # End-to-end integration tests
    benchmarks/                 # GPU / NVDEC benchmark suites
```

## 12. Architecture guardrails

- Domain must not reference Infrastructure, UI, vendor SDKs, or framework web types.
- No SQL queries in controllers or view models.
- No business rules in UI components.
- No direct NVR/ZKBioTime calls from domain/application use cases except through ports.
- No cross-site query without explicit authorized site scope.
- No shared singleton containing mutable current-site state; site context must be request/job scoped.
- No AI inference inside the synchronous request path for ordinary dashboard/API calls.
- No fake adapter silently used in production configuration.
- No placeholder implementation marked complete.
- Every adapter needs contract tests and an explicit capability matrix.
