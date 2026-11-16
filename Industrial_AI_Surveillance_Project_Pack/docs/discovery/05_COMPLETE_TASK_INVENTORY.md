> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 05 — Master Engineering Task Inventory (Categories A through AI)

**Document ID:** DISC-05-TASK-INVENTORY  
**Version:** 1.0.0-baseline  
**Status:** COMPLETE INVENTORY  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Categories Covered:** 35 Engineering Disciplines (A through AI)  

---

## 1. Overview & Inventory Architecture

This document establishes the exhaustive, end-to-end engineering task inventory for the BNF and RNF Industrial AI Surveillance Platform. It encompasses every phase of the project lifecycle from discovery through production hardening and long-term maintenance.

Every task contains:
- **Task ID:** Globally unique identifier prefixed by discipline.
- **Task Name & Detailed Description:** Precise engineering scope.
- **Requirement Reference:** Mapping to SRS-001 / Project Charter.
- **Technical Dependencies:** Prerequisite tasks.
- **Required Skills:** Registered or domain skills invoked.
- **Candidate Technologies:** Evaluated libraries, tools, or frameworks.
- **Security Implications:** Access, authorization, and data privacy impact.
- **Testing Requirements:** Unit, contract, integration, or negative test suites.
- **Acceptance Criteria:** Explicit conditions required to mark the task DONE.
- **Estimated Complexity:** Low / Medium / High / Very High.
- **Unresolved Decisions & Blocking Dependencies:** Explicit blocker tags.

---

## 2. Comprehensive Task Catalog (Disciplines A to AI)

### Category A: Product and Requirements Engineering
- **T-REQ-001: Operational Baseline & Boundary Freezing**
  - *Description:* Formalize and freeze the baseline scope with factory leadership, establishing BNF and RNF operational isolation, user roles, and reporting targets.
  - *Req Ref:* FR-SITE-001, FR-SITE-002, SRS-001 Section 1.
  - *Dependencies:* None.
  - *Required Skills:* Architecture discipline, `antigravity-guide`.
  - *Candidate Tech:* Markdown documentation, Traceability Matrix.
  - *Security Implications:* Establishes legal boundaries and tenant isolation rules.
  - *Testing Requirements:* Review against Project Charter and stakeholder sign-off.
  - *Acceptance Criteria:* Baseline charter locked; no unapproved requirements permitted.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* Formal sign-off on incident workflow states.
  - *Blocking Dependencies:* None.

- **T-REQ-002: Requirements Traceability System Setup**
  - *Description:* Establish bidirectional requirements traceability mapping every SRS requirement to architecture components, test cases, and phase gates.
  - *Req Ref:* SRS-001 Section 9, PLAN-001.
  - *Dependencies:* T-REQ-001.
  - *Required Skills:* Quality assurance discipline.
  - *Candidate Tech:* `09_REQUIREMENTS_TRACEABILITY.csv`, Git automated checks.
  - *Security Implications:* Guarantees security requirements (NFR-SEC) are verified.
  - *Testing Requirements:* Automated script verifying zero orphaned requirements.
  - *Acceptance Criteria:* Every functional and non-functional requirement traces to test ID.
  - *Complexity:* Low.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category B: UX Research and Product Design
- **T-UXR-001: Industrial Manager Persona & Workflow Mapping**
  - *Description:* Map the day-in-the-life workflow of BNF and RNF factory managers, security heads, and executive leadership, focusing on high-stress alert triage.
  - *Req Ref:* FR-APP-002, FR-ALT-001.
  - *Dependencies:* T-REQ-001.
  - *Required Skills:* `flutter-ux-architecture`.
  - *Candidate Tech:* User journey maps, state progression diagrams.
  - *Security Implications:* Ensures video viewing is isolated to authorized personas.
  - *Testing Requirements:* Review with factory operational stakeholders.
  - *Acceptance Criteria:* Documented user journeys for alert triage, incident review, and reporting.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

- **T-UXR-002: Low-Lighting & Harsh Environment Ergonomics Research**
  - *Description:* Define visual ergonomics for Android handheld devices operated in noisy, varied-lighting industrial plant floors.
  - *Req Ref:* NFR-UX-001, FR-APP-004.
  - *Dependencies:* T-UXR-001.
  - *Required Skills:* `flutter-ux-architecture`.
  - *Candidate Tech:* High-contrast visual tokens, dark-mode ergonomics.
  - *Security Implications:* Prevents misinterpretation of critical fire/safety alerts.
  - *Testing Requirements:* Contrast ratio validation (WCAG 2.1 AA / AAA).
  - *Acceptance Criteria:* Design tokens meet 7:1 contrast for critical alerts.
  - *Complexity:* Low.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category C: Design System and Visual Identity
- **T-DS-001: Premium Industrial Intelligence Token Definition**
  - *Description:* Create the complete design token specification: Midnight Navy (`#0B111E`), Deep Graphite (`#161F30`), Warm Off-White (`#F8F9FA`), Muted Teal (`#0EA5E9`), Amber (`#F59E0B`), Red (`#EF4444`), and Green (`#10B981`).
  - *Req Ref:* NFR-UX-001, Section 6 of CTO Directive.
  - *Dependencies:* T-UXR-002.
  - *Required Skills:* `flutter-ux-architecture`, `flutter-clean-code`.
  - *Candidate Tech:* Flutter ThemeData, design token JSON/Dart classes.
  - *Security Implications:* None.
  - *Testing Requirements:* Visual widget golden tests.
  - *Acceptance Criteria:* Complete token library implemented with zero hardcoded hex codes.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* Requires Owner Approval on visual theme tokens.
  - *Blocking Dependencies:* None.

- **T-DS-002: Industrial Iconography & Typography System**
  - *Description:* Establish the typographic hierarchy (Inter / Roboto Mono) and industrial SVG iconography for cameras, zones, PPE gear, fire, and sensors.
  - *Req Ref:* NFR-UX-001.
  - *Dependencies:* T-DS-001.
  - *Required Skills:* `flutter-ux-architecture`.
  - *Candidate Tech:* Google Fonts, optimized vector SVG icons.
  - *Security Implications:* None.
  - *Testing Requirements:* Icon rendering and scale tests across Android DPIs.
  - *Acceptance Criteria:* Icon library complete; zero generic consumer icons used.
  - *Complexity:* Low.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category D: Frontend Architecture (Android Manager App)
- **T-FEA-001: Flutter Clean Architecture & Layering Setup**
  - *Description:* Scaffold the mobile application core into Presentation, Domain, Data, and Core layers with strict dependency inversion.
  - *Req Ref:* FR-APP-001, NFR-MNT-001.
  - *Dependencies:* T-DS-001.
  - *Required Skills:* `flutter-clean-code`, `flutter-design-patterns`, `flutter-oop`.
  - *Candidate Tech:* Flutter 3.x, Dart 3.x, get_it (DI), dartz / fpdart.
  - *Security Implications:* Isolates auth tokens and network interceptors.
  - *Testing Requirements:* Architecture unit tests enforcing layer import boundaries.
  - *Acceptance Criteria:* Zero UI-to-network imports; 100% dependency injection.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

- **T-FEA-002: State Management & Reactive Cubit Pipeline**
  - *Description:* Implement deterministic, immutable state management using Bloc/Cubit for factory context switching, alert streaming, and camera playback.
  - *Req Ref:* FR-APP-002, FR-APP-004.
  - *Dependencies:* T-FEA-001.
  - *Required Skills:* `flutter-cubit`, `flutter-clean-code`.
  - *Candidate Tech:* flutter_bloc, equatable, bloc_test.
  - *Security Implications:* Flushes sensitive stream tokens upon session expiration.
  - *Testing Requirements:* 100% test coverage on all Cubit state machines.
  - *Acceptance Criteria:* Deterministic state transitions; zero UI state desync.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

---

### Category E: Backend Architecture
- **T-BEA-001: Modular Monolith Domain & Port Boundaries**
  - *Description:* Architect the core backend using Clean Architecture (Ports & Adapters). Define explicit domain modules (`IdentityAccess`, `SiteRegistry`, `EventManagement`, `AlertRouting`, etc.).
  - *Req Ref:* ARCH-001 Section 2, NFR-MNT-001.
  - *Dependencies:* T-REQ-001.
  - *Required Skills:* Systems architecture, clean code discipline.
  - *Candidate Tech:* Go 1.23.6 / 1.24 (Clean Architecture, Standard Library HTTP/chi/gin, strongly typed domain).
  - *Security Implications:* Pure domain layer with zero vendor SDK leakage.
  - *Testing Requirements:* ArchUnit / dependency analysis tests.
  - *Acceptance Criteria:* Domain code imports zero database or framework packages.
  - *Complexity:* High.
  - *Unresolved Decisions:* None (Approved by CTO Directive & ADR-011).
  - *Blocking Dependencies:* Gate 1 approval.

- **T-BEA-002: Site-Context Dispatcher & Management Router**
  - *Description:* Build the request router that extracts `site_id` from claims/headers and directs operations exclusively to the appropriate BNF or RNF data plane.
  - *Req Ref:* FR-SITE-001, FR-SITE-005, NFR-SEC-002.
  - *Dependencies:* T-BEA-001.
  - *Required Skills:* Systems architecture, zero-trust security.
  - *Candidate Tech:* Reverse proxy / HTTP middleware, JWT claim validator.
  - *Security Implications:* Prevents cross-factory data poisoning or leakage.
  - *Testing Requirements:* Negative tests attempting cross-site resource access.
  - *Acceptance Criteria:* Any request lacking valid site context fails with HTTP 403.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

---

### Category F: Database Architecture
- **T-DBA-001: Site-Isolated Relational Schema Design**
  - *Description:* Design the production operational database schemas for BNF and RNF event stores, camera registries, employee profiles, and policies.
  - *Req Ref:* FR-SITE-003, INT-001 Section 5.
  - *Dependencies:* T-BEA-001.
  - *Required Skills:* `accidental-data-loss-prevention`.
  - *Candidate Tech:* PostgreSQL 16 with UUIDv7, migration via Flyway or Goose.
  - *Security Implications:* Enforces foreign keys, indexes, and encryption at rest.
  - *Testing Requirements:* Automated schema migration and rollback verification.
  - *Acceptance Criteria:* Migrations run up/down cleanly; zero cross-site foreign keys.
  - *Complexity:* High.
  - *Unresolved Decisions:* Database engine approval (ADR-001 / ADR-002).
  - *Blocking Dependencies:* Gate 1 approval.

- **T-DBA-002: Transactional Outbox Pattern Implementation**
  - *Description:* Implement the transactional outbox table and publisher worker to guarantee that every business event is atomically persisted before publication.
  - *Req Ref:* NFR-REL-002, ARCH-001 Section 6.
  - *Dependencies:* T-DBA-001.
  - *Required Skills:* Systems architecture, reliable messaging.
  - *Candidate Tech:* PostgreSQL outbox table, Redis Streams / RabbitMQ publisher.
  - *Security Implications:* Prevents silent loss of fire or security alerts.
  - *Testing Requirements:* Chaos tests injecting database kills during event writes.
  - *Acceptance Criteria:* Zero lost events during simulated broker disconnects.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

---

### Category G: Employee Data Management
- **T-EMP-001: Site-Scoped Employee Natural Key Mapping**
  - *Description:* Implement internal composite identity resolution mapping source `(SiteId, SourceEmployeeId)` to an immutable internal UUID.
  - *Req Ref:* FR-EMP-002, FR-EMP-008, INT-001 Section 4.
  - *Dependencies:* T-DBA-001.
  - *Required Skills:* Domain modeling.
  - *Candidate Tech:* Go / Python / .NET Domain Entity.
  - *Security Implications:* Prevents collision if BNF and RNF share Employee IDs.
  - *Testing Requirements:* Unit tests with identical employee IDs across sites.
  - *Acceptance Criteria:* Entities remain strictly partitioned and query-isolated.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

- **T-EMP-002: Read-Only Employee Synchronization Engine**
  - *Description:* Build the scheduled reconciliation engine syncing employee records from factory SQL Server and ZKBioTime without mutating source data.
  - *Req Ref:* FR-EMP-001, INT-001 Section 3.
  - *Dependencies:* T-EMP-001, T-ZKB-001, T-SQL-001.
  - *Required Skills:* `accidental-data-loss-prevention`.
  - *Candidate Tech:* Idempotent batch upsert, checksum diffing.
  - *Security Implications:* Zero write permissions to external HR/attendance tables.
  - *Testing Requirements:* Reconciliation tests with added, modified, and deactivated staff.
  - *Acceptance Criteria:* Synchronization is idempotent, auditable, and non-blocking.
  - *Complexity:* High.
  - *Unresolved Decisions:* Read-only service account credentials from factory IT.
  - *Blocking Dependencies:* Discovery checklist verification.

---

### Category H: Face Image Acquisition and Enrollment
- **T-FIA-001: Biometric Terminal Photo Extraction Spike (Gate 0 Blocker)**
  - *Description:* Execute safe, read-only discovery against representative BNF/RNF ZKTeco terminals to prove whether actual RGB JPEG photos can be extracted.
  - *Req Ref:* FR-EMP-003, INT-001 Section 2.1.
  - *Dependencies:* Discovery checklist response from IT.
  - *Required Skills:* Firmware analysis, API inspection.
  - *Candidate Tech:* ZKBioTime REST API, ZKTeco Standalone Device SDK (read-only).
  - *Security Implications:* Handling raw biometric assets under strict security.
  - *Testing Requirements:* Extraction test on test employee with redacted PII.
  - *Acceptance Criteria:* Formal POC report stating: SUCCESS (with format/res) or BLOCKED.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* **CRITICAL BLOCKER BLK-001**.
  - *Blocking Dependencies:* Physical/network access to test terminal.

- **T-FIA-002: Biometric Asset Store & Encryption Pipeline**
  - *Description:* Implement isolated, encrypted object storage for validated employee enrollment photos with strict access control and audit logging.
  - *Req Ref:* NFR-SEC-003, SEC-001 Section 5.
  - *Dependencies:* T-FIA-001 (If SUCCESS).
  - *Required Skills:* Security engineering, encryption at rest.
  - *Candidate Tech:* MinIO / Local filesystem with AES-256 encryption.
  - *Security Implications:* Biometric data compliance under Egyptian Law 151/2020.
  - *Testing Requirements:* Storage encryption audit and unauthorized read tests.
  - *Acceptance Criteria:* Zero unencrypted photos stored; access strictly audited.
  - *Complexity:* High.
  - *Unresolved Decisions:* Legal approval on biometric data retention.
  - *Blocking Dependencies:* T-FIA-001.

---

### Category I: Face Recognition
- **T-FR-001: Face Feature Extraction & Embedding Benchmark**
  - *Description:* Benchmark lightweight face embedding models (InsightFace / ArcFace / FaceNet) on representative factory lighting and camera angles.
  - *Req Ref:* FR-EMP-006, AI-001 Section 5.
  - *Dependencies:* T-FIA-002.
  - *Required Skills:* `ml-best-practices`, `managing-python-dependencies`.
  - *Candidate Tech:* InsightFace (ONNX Runtime / TensorRT).
  - *Security Implications:* Generating irreversible mathematical vector embeddings.
  - *Testing Requirements:* LFW benchmark and held-out site validation set.
  - *Acceptance Criteria:* Documented cosine similarity thresholds; false acceptance rate <0.01%.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* Hardware compute availability (GPU vs CPU).
  - *Blocking Dependencies:* T-FIA-001.

- **T-FR-002: Vector Search & Identity Association Engine**
  - *Description:* Build the identity matching port that queries candidate face crops against enrolled employee embeddings, returning typed confidence outcomes.
  - *Req Ref:* FR-EMP-007, AI-001 Section 4.
  - *Dependencies:* T-FR-001.
  - *Required Skills:* Clean architecture, vector indexing.
  - *Candidate Tech:* Qdrant / Milvus / pgvector (site-isolated).
  - *Security Implications:* Never force an identity; uncertain matches return `Unknown`.
  - *Testing Requirements:* Negative tests ensuring low-confidence crops return `Unknown`.
  - *Acceptance Criteria:* 100% adherence to anti-hallucination rules.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* T-FR-001.

---

### Category J: Computer Vision (Core Pipeline)
- **T-CV-001: High-Throughput RTSP Ingestion & Decoding Worker**
  - *Description:* Implement the native video ingestion worker capable of pulling RTSP sub-streams, decoding H.264/H.265 frames, and managing reconnect backoffs.
  - *Req Ref:* FR-VID-002, ARCH-001 Section 7.
  - *Dependencies:* Discovery checklist for NVR streams.
  - *Required Skills:* Video engineering, network streaming.
  - *Candidate Tech:* GStreamer C-bindings or FFmpeg / PyAV with hardware VAAPI/NVDEC.
  - *Security Implications:* No stream credentials leaked in logs or heap dumps.
  - *Testing Requirements:* Long-running stability test across 24 hours of continuous streaming.
  - *Acceptance Criteria:* Zero memory leaks; automatic reconnect on network drop.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* Stream protocol confirmation (RTSP vs ONVIF).
  - *Blocking Dependencies:* NVR stream access.

- **T-CV-002: Dynamic ROI Masking & Frame Sampling Watchdog**
  - *Description:* Implement region-of-interest masking and adaptive frame-rate sampling (e.g., 2–5 FPS) to bound inference compute load.
  - *Req Ref:* NFR-SCL-002, AI-001 Section 3.
  - *Dependencies:* T-CV-001.
  - *Required Skills:* OpenCV, image processing.
  - *Candidate Tech:* OpenCV Python/C++, NumPy.
  - *Security Implications:* Masks non-operational areas to preserve worker privacy.
  - *Testing Requirements:* Unit tests verifying pixels outside ROI polygons are zeroed out.
  - *Acceptance Criteria:* Frame rate strictly capped; zero processing of masked zones.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* Zone polygon configurations from factory safety teams.
  - *Blocking Dependencies:* None.

---

### Category K: Multi-Camera Person Tracking
- **T-TRK-001: Intra-Camera Person Detection & ByteTrack Integration**
  - *Description:* Integrate real-time human detection with within-camera tracking to maintain persistent track IDs across temporary occlusions.
  - *Req Ref:* FR-AI-008, AI-001 Section 4.
  - *Dependencies:* T-CV-002.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* YOLOv8 / YOLOv10 (TensorRT) + ByteTrack algorithm.
  - *Security Implications:* Tracking observations tagged as provisional.
  - *Testing Requirements:* MOTA (Multiple Object Tracking Accuracy) benchmark on site video.
  - *Acceptance Criteria:* Track persistence through occlusions up to 30 frames.
  - *Complexity:* High.
  - *Unresolved Decisions:* GPU compute capacity.
  - *Blocking Dependencies:* Candidate hardware allocation.

- **T-TRK-002: Cross-Camera Sighting Correlation Engine**
  - *Description:* Build the discrete sighting association service that links person tracks across cameras based on camera topology, timestamp windows, and ReID.
  - *Req Ref:* FR-AI-008, AI-001 Section 4.
  - *Dependencies:* T-TRK-001, T-FR-002.
  - *Required Skills:* Systems architecture, data modeling.
  - *Candidate Tech:* Temporal graph index, ReID feature extraction.
  - *Security Implications:* Explicit gaps shown; zero interpolated fake routes.
  - *Testing Requirements:* Validation across multi-camera corridor footage.
  - *Acceptance Criteria:* Explicit timeline of sightings with confidence and gaps.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* Camera topology maps and NTP clock drift validation.
  - *Blocking Dependencies:* Factory camera layout maps.

---

### Category L: Object Detection and Tracking
- **T-OBJ-001: Industrial Object Taxonomy Definition & Labeled Dataset**
  - *Description:* Collaborate with BNF/RNF operations to define exact object classes (cartons, raw sacks, bins, packaging) and assemble a labeled training dataset.
  - *Req Ref:* FR-AI-006, AI-001 Section 6.
  - *Dependencies:* Operational input from factory managers.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* Roboflow / CVAT annotation platform.
  - *Security Implications:* Ensure no proprietary product formulas or markings leak.
  - *Testing Requirements:* Inter-annotator agreement score >0.90.
  - *Acceptance Criteria:* Balanced dataset of at least 1,500 labeled frames per class.
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-017** (Object taxonomy approval).
  - *Blocking Dependencies:* Owner approval of object classes.

- **T-OBJ-002: Object Track Continuity & Spatial Boundary Engine**
  - *Description:* Train and deploy the object detector with spatial polygon boundary crossing logic (entry/exit of storage zones).
  - *Req Ref:* FR-AI-007, AI-001 Section 6.
  - *Dependencies:* T-OBJ-001.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* YOLOv8-Custom (TensorRT) + Spatial Polygon Ray-Casting.
  - *Security Implications:* Events marked as "Suspected Movement", never "Theft".
  - *Testing Requirements:* Precision/Recall evaluation on held-out test set.
  - *Acceptance Criteria:* Precision >85% at calibrated confidence threshold.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* T-OBJ-001.

---

### Category M: PPE Detection
- **T-PPE-001: Multi-Class PPE Model Training & Benchmarking**
  - *Description:* Train/tune a multi-label detector for industrial PPE items: hard hats, high-visibility vests, safety goggles, gloves, and protective boots.
  - *Req Ref:* FR-AI-001, AI-001 Section 2.
  - *Dependencies:* T-CV-002.
  - *Required Skills:* `ml-best-practices`, `managing-python-dependencies`.
  - *Candidate Tech:* YOLOv8x-PPE / RT-DETR (TensorRT).
  - *Security Implications:* None.
  - *Testing Requirements:* Held-out validation across day/night and varied distances.
  - *Acceptance Criteria:* Precision >90%, Recall >85% on factory validation set.
  - *Complexity:* High.
  - *Unresolved Decisions:* Site-specific PPE requirements per zone.
  - *Blocking Dependencies:* None.

- **T-PPE-002: Zone-Specific PPE Policy Rule Evaluator**
  - *Description:* Implement the rule evaluation engine that checks detected human tracks against the active zone's mandatory PPE policy and shift schedule.
  - *Req Ref:* FR-AI-001, AI-001 Section 3.
  - *Dependencies:* T-PPE-001.
  - *Required Skills:* Clean Architecture, Specification Pattern.
  - *Candidate Tech:* Domain Policy Engine.
  - *Security Implications:* Prevents false alerts in office or break areas.
  - *Testing Requirements:* Unit tests across all zone-shift policy matrix combinations.
  - *Acceptance Criteria:* Office cameras produce zero PPE violation events.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-015** (Zone PPE rules).
  - *Blocking Dependencies:* Safety manager policy input.

---

### Category N: Restricted Zone Detection
- **T-RZD-001: Polygon ROI Geofencing & Intrusion Detector**
  - *Description:* Implement spatial ray-casting algorithms to detect when a validated person track's base coordinates enter a restricted polygon region.
  - *Req Ref:* FR-AI-002, AI-001 Section 3.
  - *Dependencies:* T-TRK-001.
  - *Required Skills:* Computational geometry, clean algorithms.
  - *Candidate Tech:* Shapely / GEOS C-libraries wrapped in Go/Python.
  - *Security Implications:* Immediate high-severity security event generation.
  - *Testing Requirements:* Boundary test cases (tangent, crossing, internal dwell).
  - *Acceptance Criteria:* Zero missed intrusions exceeding 1.0 second dwell time.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-016** (Restricted zone polygons).
  - *Blocking Dependencies:* Factory security polygon inputs.

---

### Category O: Fall and Accident Detection
- **T-FAD-001: Pose Estimation & Rapid Aspect Ratio Fall Detector**
  - *Description:* Implement a temporal fall detection model analyzing bounding box aspect ratio shifts combined with keypoint pose estimation (head/torso velocity).
  - *Req Ref:* FR-AI-003, AI-001 Section 2.
  - *Dependencies:* T-TRK-001.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* YOLOv8-Pose / MoveNet (ONNX Runtime).
  - *Security Implications:* Critical life-safety event; urgent notification path.
  - *Testing Requirements:* UR Fall Detection dataset + on-site simulated falls.
  - *Acceptance Criteria:* Zero missed simulated falls; false positive rate <1 per camera/week.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category P: Mobile Phone Detection
- **T-MPD-001: Hand-Object Association Phone Use Classifier**
  - *Description:* Implement a high-resolution phone detection pipeline checking hand-to-head or dual-hand texting posture within operating machinery zones.
  - *Req Ref:* FR-AI-004, AI-001 Section 2.
  - *Dependencies:* T-TRK-001.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* Two-stage detector: Person crop -> Pose/Phone object detector.
  - *Security Implications:* AI observation only; cannot trigger disciplinary deduction.
  - *Testing Requirements:* Validation on high-angle and low-resolution test sets.
  - *Acceptance Criteria:* Documented camera resolution limits below which phone detection is disabled.
  - *Complexity:* High.
  - *Unresolved Decisions:* Camera resolution discovery.
  - *Blocking Dependencies:* NVR stream resolution audit.

---

### Category Q: Fire and Smoke Detection
- **T-FSD-001: Temporal Multi-Frame Fire/Smoke Vision Model**
  - *Description:* Build and tune the fire and smoke detector using temporal frame accumulation to differentiate true flame/smoke from steam, dust, and welding.
  - *Req Ref:* FR-AI-005, AI-001 Section 7.
  - *Dependencies:* T-CV-002.
  - *Required Skills:* `ml-best-practices`.
  - *Candidate Tech:* YOLOv8-Fire + Temporal Persistence Buffer (>3.0 seconds).
  - *Security Implications:* Critical life-safety system.
  - *Testing Requirements:* Benchmark against industrial fire/smoke datasets and steam negative sets.
  - *Acceptance Criteria:* 100% detection of active flame; steam false alarms <1/month.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

- **T-FSD-002: Zero-Gate Immediate Fire Alert Dispatch Route**
  - *Description:* Build the isolated, high-priority emergency notification channel that bypasses all batching, rate-limits, and human triage gates.
  - *Req Ref:* FR-ALT-004, FR-ALT-005, SRS-001 Section 4.5.
  - *Dependencies:* T-FSD-001, T-NOT-001.
  - *Required Skills:* High-reliability systems, outbox patterns.
  - *Candidate Tech:* Dedicated priority queue worker, FCM High-Priority Push.
  - *Security Implications:* Delivers directly to responsible factory safety roster.
  - *Testing Requirements:* Server dispatch latency measurement from detection to outbox push, and empirical mobile delivery latency tracking.
  - *Acceptance Criteria:* Sub-second server dispatch SLO (<500ms from inference trigger; handset presentation latency measured empirically per Document 39).
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-013** (Fire recipient roster).
  - *Blocking Dependencies:* Owner approval of fire roster.

---

### Category R: Theft and Object Movement Analysis
- **T-TMA-001: Person-to-Person Object Handoff Detector**
  - *Description:* Build the interaction analyzer tracking concurrent proximity between two person tracks and a shared object track transferring between them.
  - *Req Ref:* FR-AI-007, AI-001 Section 6.
  - *Dependencies:* T-OBJ-002, T-TRK-001.
  - *Required Skills:* `ml-best-practices`, spatial analysis.
  - *Candidate Tech:* Spatio-temporal graph network / proximity rule engine.
  - *Security Implications:* Strict wording: "Suspected Object Transfer", never "Theft".
  - *Testing Requirements:* Validation across staged transfer scenarios and normal handovers.
  - *Acceptance Criteria:* Evidence clip saved; confidence and uncertainty tags attached.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-018** (Legitimate movement patterns).
  - *Blocking Dependencies:* Factory operations input.

---

### Category S: ZKBioTime Integration
- **T-ZKB-001: ZKBioTime API Client & Synchronization Adapter**
  - *Description:* Build the site-scoped ZKBioTime adapter handling token authentication, employee pagination, attendance punch retrieval, and rate limits.
  - *Req Ref:* FR-EMP-001, INT-001 Section 3.
  - *Dependencies:* ZKBioTime discovery checklist.
  - *Required Skills:* Integration engineering, Clean Architecture.
  - *Candidate Tech:* Go / Python HTTP client with retry and circuit breaker.
  - *Security Implications:* Credentials stored in secure vault; site-isolated.
  - *Testing Requirements:* Contract tests against mocked ZKBioTime API and real test instance.
  - *Acceptance Criteria:* Idempotent sync; graceful handling of API timeouts.
  - *Complexity:* High.
  - *Unresolved Decisions:* ZKBioTime API versions and credentials.
  - *Blocking Dependencies:* IT discovery checklist response.

---

### Category T: SQL Server Integration
- **T-SQL-001: Read-Only SQL Server Attendance & HR Connector**
  - *Description:* Implement the read-only SQL Server persistence adapter to query employee master records and raw attendance logs using parameterized queries.
  - *Req Ref:* FR-SITE-002, INT-001 Section 3.
  - *Dependencies:* SQL Server discovery checklist.
  - *Required Skills:* `accidental-data-loss-prevention`.
  - *Candidate Tech:* Microsoft ODBC Driver 18, sqlx / SQLAlchemy with read-only user.
  - *Security Implications:* Read-only user enforcement; zero DDL or UPDATE permissions.
  - *Testing Requirements:* Integration tests validating query plans and connection pooling.
  - *Acceptance Criteria:* Zero write operations; queries execute with snapshot isolation.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* SQL Server schema and read-only credentials.
  - *Blocking Dependencies:* IT discovery checklist response.

---

### Category U: Camera and NVR Integration
- **T-NVR-001: Multi-Vendor NVR & Camera Fleet Adapter**
  - *Description:* Build the extensible NVR adapter port supporting RTSP URL construction, ONVIF device discovery, channel mapping, and health watchdogs.
  - *Req Ref:* FR-VID-001, FR-VID-002, INT-001 Section 3.
  - *Dependencies:* NVR discovery checklist.
  - *Required Skills:* Video protocols, adapter pattern.
  - *Candidate Tech:* ONVIF C/Python client, RTSP stream parser.
  - *Security Implications:* Permanent NVR passwords never leave the backend adapter.
  - *Testing Requirements:* Contract tests for each discovered NVR manufacturer.
  - *Acceptance Criteria:* Health status polled every 30s; offline channels flagged.
  - *Complexity:* High.
  - *Unresolved Decisions:* **CRITICAL BLOCKER BLK-003** (NVR models & API limits).
  - *Blocking Dependencies:* Physical NVR inventory data.

---

### Category V: Live Video and Playback
- **T-LVP-001: Zero-Trust Tokenized Video Streaming Gateway**
  - *Description:* Build the backend video gateway that issues short-lived (60s), signed HMAC streaming tokens and proxies WebRTC/HLS feeds to authorized mobile apps.
  - *Req Ref:* FR-VID-004, FR-VID-006, SEC-001 Section 4.
  - *Dependencies:* T-NVR-001, T-AUT-001.
  - *Required Skills:* Zero-trust security, media servers.
  - *Candidate Tech:* MediaMTX / go2rtc WebRTC gateway.
  - *Security Implications:* Strict server-side RBAC; mobile client never touches NVR.
  - *Testing Requirements:* Negative tests requesting streams with invalid or expired tokens.
  - *Acceptance Criteria:* Stream denied for non-video roles; tokens expire in 60s.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

- **T-LVP-002: NVR Playback Range & Clip Extraction Proxy**
  - *Description:* Implement the historical video playback proxy allowing authorized security managers to seek recordings within the 30-day retention window.
  - *Req Ref:* FR-VID-005, FR-VID-007, INT-001 Section 3.
  - *Dependencies:* T-LVP-001.
  - *Required Skills:* Video engineering.
  - *Candidate Tech:* NVR ISAPI / SDK playback API wrapper.
  - *Security Implications:* Full audit log of who watched which historical clip.
  - *Testing Requirements:* Playback seek tests across 1-day, 7-day, and 29-day marks.
  - *Acceptance Criteria:* Playback starts within 2.0s; 30-day retention respected.
  - *Complexity:* High.
  - *Unresolved Decisions:* NVR playback API support per model.
  - *Blocking Dependencies:* T-NVR-001.

---

### Category W: Notification Infrastructure
- **T-NOT-001: Multi-Tiered Durable In-App Notification Engine**
  - *Description:* Implement the alert dispatch engine managing message priority, recipient resolution, FCM push delivery, and retry backoffs.
  - *Req Ref:* FR-ALT-001, FR-ALT-006, ARCH-001 Section 6.
  - *Dependencies:* T-DBA-002.
  - *Required Skills:* Distributed systems, reliable messaging.
  - *Candidate Tech:* Firebase Cloud Messaging (FCM) + Redis Streams worker.
  - *Security Implications:* Encrypted push payloads; PII excluded from push notification headers.
  - *Testing Requirements:* Delivery retry tests with simulated mobile network drops.
  - *Acceptance Criteria:* 100% of generated alerts delivered upon device reconnection.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

---

### Category X: Reporting and Analytics
- **T-REP-001: In-App Embedded Analytical Aggregation Engine**
  - *Description:* Build the database aggregation pipelines computing safety compliance percentages, incident totals, and PPE violations without Power BI.
  - *Req Ref:* FR-REP-002, FR-REP-003, SRS-001 Section 4.6.
  - *Dependencies:* T-DBA-001.
  - *Required Skills:* SQL query optimization, analytical design.
  - *Candidate Tech:* PostgreSQL Materialized Views / TimescaleDB continuous aggregates.
  - *Security Implications:* Site-scoped reporting; zero cross-factory leakage.
  - *Testing Requirements:* Performance tests running aggregations across 1,000,000 event records.
  - *Acceptance Criteria:* Dashboard query p95 latency <250ms; zero hardcoded fake metrics.
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-020** (Exact KPI formulas).
  - *Blocking Dependencies:* Owner approval of metric definitions.

- **T-REP-002: Automated Daily, Weekly, and Monthly Report Rollup Scheduler**
  - *Description:* Implement the scheduled background worker that closes reporting periods, freezes snapshot figures, and pre-renders in-app report views.
  - *Req Ref:* FR-REP-004, FR-REP-005.
  - *Dependencies:* T-REP-001.
  - *Required Skills:* `automation`.
  - *Candidate Tech:* Cron scheduler / pg_cron / Go worker.
  - *Security Implications:* Immutable historical snapshots prevent retroactive tampering.
  - *Testing Requirements:* Scheduled trigger test across period boundaries.
  - *Acceptance Criteria:* Daily reports generated at 00:01 UTC; snapshots locked.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category Y: Android Application (Manager Client)
- **T-AND-001: Android Application Foundation & Site Context Switcher**
  - *Description:* Implement the top-level app scaffold with persistent visual factory banner (BNF / RNF) and instant, authorized context switching.
  - *Req Ref:* FR-APP-004, FR-SITE-004.
  - *Dependencies:* T-FEA-001, T-FEA-002.
  - *Required Skills:* `flutter-clean-code`, `flutter-ux-architecture`.
  - *Candidate Tech:* Flutter Material 3, flutter_bloc.
  - *Security Implications:* Flushes local screen caches when switching factories.
  - *Testing Requirements:* UI widget and state tests verifying active factory token.
  - *Acceptance Criteria:* Active site visually unmissable; zero data bleed between switches.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 1 approval.

- **T-AND-002: Live Camera & Playback Mobile Player Module**
  - *Description:* Build the hardware-accelerated video player widget supporting low-latency WebRTC streams, timestamp overlays, and playback timeline scrubbing.
  - *Req Ref:* FR-VID-004, FR-VID-005, FR-VID-009.
  - *Dependencies:* T-AND-001, T-LVP-001.
  - *Required Skills:* `flutter-clean-code`, mobile video engineering.
  - *Candidate Tech:* flutter_webrtc / media_kit (ExoPlayer-backed).
  - *Security Implications:* Screen hidden and stream denied if user lacks video role.
  - *Testing Requirements:* Playback stability, aspect ratio retention, and token refresh tests.
  - *Acceptance Criteria:* WebRTC stream renders <500ms latency; smooth timeline scrub.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* T-LVP-001.

- **T-AND-003: Real-Time Alert Inbox & Incident Detail View**
  - *Description:* Build the reactive alert inbox displaying incoming events with severity badges, snapshot thumbnails, confidence scores, and video clip links.
  - *Req Ref:* FR-ALT-001, FR-APP-002, SRS-001 Section 6.
  - *Dependencies:* T-AND-001, T-NOT-001.
  - *Required Skills:* `flutter-cubit`, `flutter-ux-architecture`.
  - *Candidate Tech:* Flutter Bloc, cached_network_image.
  - *Security Implications:* Evidence images fetched via short-lived authenticated URLs.
  - *Testing Requirements:* Golden tests for urgent fire, critical, and warning states.
  - *Acceptance Criteria:* Real-time alert insertion; audio/haptic alert on fire events.
  - *Complexity:* High.
  - *Unresolved Decisions:* Incident workflow states.
  - *Blocking Dependencies:* None.

- **T-AND-004: In-App Embedded Analytics & Reporting Screens**
  - *Description:* Build the reporting screens rendering native vector charts (bar, line, donut) displaying real daily, weekly, and monthly factory metrics.
  - *Req Ref:* FR-REP-001, FR-REP-003.
  - *Dependencies:* T-AND-001, T-REP-001.
  - *Required Skills:* `flutter-clean-code`, data visualization.
  - *Candidate Tech:* fl_chart / graphic (Canvas-rendered).
  - *Security Implications:* None.
  - *Testing Requirements:* Verify rendering with real data and verified empty states.
  - *Acceptance Criteria:* Zero mock charts; verified empty state when database is empty.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category Z: Web Administration Portal
- **T-WEB-001: Web Admin Portal Scaffold & RBAC Auth**
  - *Description:* Scaffold the lightweight Web Admin portal for Safety Directors and System Admins to manage camera mapping, zones, and system configuration.
  - *Req Ref:* SRS-001 Section 3, Proposed Architecture.
  - *Dependencies:* T-BEA-001, T-AUT-001.
  - *Required Skills:* `building-data-apps`, frontend architecture.
  - *Candidate Tech:* React + Vite + Tailwind CSS / Go templates.
  - *Security Implications:* Enforces MFA for administrative accounts.
  - *Testing Requirements:* End-to-end Cypress/Playwright login and route guard tests.
  - *Acceptance Criteria:* Role-gated administration console running on-premise.
  - *Complexity:* High.
  - *Unresolved Decisions:* **REQUIRES OWNER APPROVAL** to include Web Admin portal.
  - *Blocking Dependencies:* Owner approval.

- **T-WEB-002: Visual Zone Polygon & PPE Policy Editor**
  - *Description:* Implement an interactive canvas tool allowing safety officers to draw restricted areas and PPE zones directly on camera snapshot feeds.
  - *Req Ref:* FR-AI-001, FR-AI-002.
  - *Dependencies:* T-WEB-001, T-CV-002.
  - *Required Skills:* Canvas programming, geometric modeling.
  - *Candidate Tech:* Konva.js / Fabric.js / HTML5 Canvas.
  - *Security Implications:* Policy changes versioned, audited, and signed.
  - *Testing Requirements:* Polygon coordinate normalization and serialization tests.
  - *Acceptance Criteria:* Normalized polygon coordinates ([0.0, 1.0]) persisted cleanly.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* T-WEB-001.

---

### Category AA: Authentication and Authorization
- **T-AUT-001: Zero-Trust RBAC & Site-Scoping Engine**
  - *Description:* Build the centralized authentication and token minting engine enforcing Role-Based Access Control and explicit site authorization claims.
  - *Req Ref:* NFR-SEC-001, SEC-001 Section 2.
  - *Dependencies:* T-BEA-001.
  - *Required Skills:* Security architecture, identity management.
  - *Candidate Tech:* JWT (RS256 / Ed25519) with short TTL (15m) + secure refresh tokens.
  - *Security Implications:* Core security boundary protecting the platform.
  - *Testing Requirements:* Negative test matrix covering all role/site permutations.
  - *Acceptance Criteria:* Zero access to video or cross-site data without explicit claims.
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-014** (Role roster and permissions).
  - *Blocking Dependencies:* Owner approval of role matrix.

---

### Category AB: Security and Privacy
- **T-SEC-001: Biometric Data Governance & Encryption at Rest**
  - *Description:* Implement field-level encryption for biometric hashes and employee photos using envelope encryption (KMS / HashiCorp Vault / Local HSM).
  - *Req Ref:* NFR-SEC-003, SEC-001 Section 5.
  - *Dependencies:* T-FIA-002.
  - *Required Skills:* Cryptographic engineering.
  - *Candidate Tech:* AES-256-GCM envelope encryption.
  - *Security Implications:* Compliance with Egyptian Data Protection Law No. 151/2020.
  - *Testing Requirements:* Cryptographic verification; database dumps show ciphertext only.
  - *Acceptance Criteria:* Zero plaintext biometric representations in databases or logs.
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-023** (Legal/Privacy sign-off).
  - *Blocking Dependencies:* Legal counsel review.

- **T-SEC-002: Tamper-Evident Security Audit Log Pipeline**
  - *Description:* Implement an append-only, cryptographically hashed audit log recording all logins, video views, employee lookups, and policy changes.
  - *Req Ref:* SEC-001 Section 4, NFR-SEC-001.
  - *Dependencies:* T-BEA-001.
  - *Required Skills:* Audit logging, cryptographic hashing.
  - *Candidate Tech:* Append-only hash-chained audit table.
  - *Security Implications:* Guarantees accountability for surveillance footage access.
  - *Testing Requirements:* Tamper detection test validating modified log row triggers alarm.
  - *Acceptance Criteria:* Any alteration to historical audit records is instantly detected.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category AC: Infrastructure and Hardware
- **T-INF-001: Compute Sizing & Dedicated GPU Specification**
  - *Description:* Produce the engineering sizing specification for dedicated AI inference hardware (e.g., dual NVIDIA RTX A5000 / L4 per site) to resolve the zero-GPU blocker.
  - *Req Ref:* NFR-SCL-001, NFR-SCL-002, INT-001 Section 2.4.
  - *Dependencies:* Stream inventory.
  - *Required Skills:* Hardware capacity planning, GPU architecture.
  - *Candidate Tech:* Hardware sizing models, PCIe Gen4/Gen5 GPU servers.
  - *Security Implications:* Physical on-premise server security.
  - *Testing Requirements:* Theoretical throughput modeling against 200 streams @ 5 FPS.
  - *Acceptance Criteria:* Complete BOM (Bill of Materials) and wattage/cooling requirements.
  - *Complexity:* High.
  - *Unresolved Decisions:* **CRITICAL BLOCKER BLK-002** (GPU procurement approval).
  - *Blocking Dependencies:* Management hardware budget approval.

- **T-INF-002: 30-Day Video Storage & Retention Capacity Verification**
  - *Description:* Calculate and verify the physical disk array capacity required for 30-day recording retention across 400+ cameras (~260 TB total).
  - *Req Ref:* FR-VID-007, NFR-DATA-001.
  - *Dependencies:* Camera stream profile discovery.
  - *Required Skills:* Storage engineering, RAID/ZFS sizing.
  - *Candidate Tech:* Existing NVR storage + Secondary iSCSI/NFS storage arrays.
  - *Security Implications:* Data lifecycle and secure erasure compliance.
  - *Testing Requirements:* Automated purge script tests deleting recordings >30 days.
  - *Acceptance Criteria:* Storage array verified to sustain 400 continuous streams without drop.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* Existing NVR storage capacity audit.
  - *Blocking Dependencies:* Physical inventory response.

---

### Category AD: CI/CD and DevOps
- **T-DEV-001: Local Build, Lint, and Architecture Test Harness**
  - *Description:* Configure the local build and quality automation scripts enforcing static analysis, formatting, linter rules, and architectural boundaries.
  - *Req Ref:* PLAN-001 Phase 2, Section 13 of CTO Directive.
  - *Dependencies:* T-BEA-001, T-FEA-001.
  - *Required Skills:* DevOps, CI automation.
  - *Candidate Tech:* Makefile / Taskfile, golangci-lint / ruff, flutter analyze.
  - *Security Implications:* Prevents committed syntax errors or security vulnerabilities.
  - *Testing Requirements:* Execution of full local verification pipeline in <60 seconds.
  - *Acceptance Criteria:* Clean build; zero warnings on strict compiler settings.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

- **T-DEV-002: Pre-Commit Secret Scanning & Gitleaks Pipeline**
  - *Description:* Install and enforce automated secret scanning hooks blocking commits containing API keys, database passwords, private keys, or PII.
  - *Req Ref:* NFR-SEC-004, SEC-001 Section 4.
  - *Dependencies:* T-DEV-001.
  - *Required Skills:* DevSecOps.
  - *Candidate Tech:* Gitleaks, pre-commit framework.
  - *Security Implications:* Guarantees zero credentials enter version control.
  - *Testing Requirements:* Test commit containing dummy private key blocked.
  - *Acceptance Criteria:* Pre-commit hook terminates commit with non-zero exit code.
  - *Complexity:* Low.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* None.

---

### Category AE: Testing and Quality Assurance
- **T-QA-001: Site Isolation Penetration & Negative Test Suite**
  - *Description:* Author and execute automated security tests attempting to query RNF data using BNF credentials across all API endpoints, queues, and caches.
  - *Req Ref:* NFR-SEC-002, QA-001 Section 2.
  - *Dependencies:* T-BEA-002, T-AUT-001.
  - *Required Skills:* Security QA, penetration testing.
  - *Candidate Tech:* Pytest / Go test with automated negative assertion fixtures.
  - *Security Implications:* Verifies tenant isolation before any production deployment.
  - *Testing Requirements:* 100% pass rate across 100+ negative isolation scenarios.
  - *Acceptance Criteria:* Zero cross-site data leaks; every unauthorized call returns 403.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 2 approval.

- **T-QA-002: End-to-End Synthetic Video Injection Pipeline**
  - *Description:* Create an isolated synthetic test pipeline injecting labeled test video clips into the ingestion worker to verify detection accuracy in CI.
  - *Req Ref:* QA-001 Section 3, Section 2 of CTO Directive.
  - *Dependencies:* T-CV-001, T-PPE-001, T-FSD-001.
  - *Required Skills:* `ml-best-practices`, automated testing.
  - *Candidate Tech:* FFmpeg synthetic loopback RTSP server.
  - *Security Implications:* Completely segregated from production data stores.
  - *Testing Requirements:* Verification of event generation against known ground truth.
  - *Acceptance Criteria:* CI pipeline verifies end-to-end detection without physical cameras.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 2 approval.

---

### Category AF: Monitoring and Observability
- **T-OBS-001: Prometheus Metrics & Operational Health Dashboard**
  - *Description:* Instrument backend workers, stream decoders, and inference pipelines with Prometheus metrics (FPS, decode latency, queue depth, drop rate).
  - *Req Ref:* NFR-OBS-001, ARCH-001 Section 10.
  - *Dependencies:* T-CV-001, T-BEA-001.
  - *Required Skills:* Observability engineering.
  - *Candidate Tech:* Prometheus, Grafana, OpenTelemetry SDK.
  - *Security Implications:* Metrics contain zero PII or employee names.
  - *Testing Requirements:* Metrics scraping test under 100 simulated camera streams.
  - *Acceptance Criteria:* Real-time Grafana dashboard displaying per-site pipeline health.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gate 2 approval.

---

### Category AG: Backup and Disaster Recovery
- **T-BDR-001: Site-Isolated Automated Backup & Restore Verification**
  - *Description:* Implement automated daily encrypted database and policy backups with monthly automated restore exercises to cold standby.
  - *Req Ref:* SEC-001 Section 4, QA-001 Section 5.
  - *Dependencies:* T-DBA-001.
  - *Required Skills:* `accidental-data-loss-prevention`, DevOps.
  - *Candidate Tech:* pg_dump / SQL backup scripts with AES-256 encryption.
  - *Security Implications:* Backups encrypted with separate key; stored offsite.
  - *Testing Requirements:* Full automated restore drill measuring RTO and RPO.
  - *Acceptance Criteria:* RTO <2 hours; RPO <15 minutes verified in drill.
  - *Complexity:* High.
  - *Unresolved Decisions:* **OPEN QUESTION OQ-025** (Target RTO/RPO approval).
  - *Blocking Dependencies:* Owner approval of disaster recovery targets.

---

### Category AH: Production Deployment
- **T-DEP-001: BNF Site Pilot Deployment & Staged Cutover**
  - *Description:* Execute the initial production pilot on 10 selected cameras in BNF Factory, validating live video, PPE alerts, and ZKBioTime sync in shadow mode.
  - *Req Ref:* PLAN-001 Phase 7.
  - *Dependencies:* Completion of Phases 1 through 6.
  - *Required Skills:* Production deployment, systems engineering.
  - *Candidate Tech:* Docker Compose / Kubernetes on-premise cluster.
  - *Security Implications:* Full production security controls active.
  - *Testing Requirements:* 14-day continuous pilot with zero unplanned downtime.
  - *Acceptance Criteria:* Stakeholder pilot acceptance sign-off.
  - *Complexity:* Very High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Gates 0 through 6 passed.

- **T-DEP-002: RNF Site Pilot Deployment & Comparative Tuning**
  - *Description:* Roll out the platform to RNF Factory following BNF pilot stabilization, adjusting camera calibrations and lighting thresholds for RNF conditions.
  - *Req Ref:* PLAN-001 Phase 7.
  - *Dependencies:* T-DEP-001.
  - *Required Skills:* Production deployment, systems engineering.
  - *Candidate Tech:* On-premise container runtime.
  - *Security Implications:* Validates zero cross-talk between BNF and RNF.
  - *Testing Requirements:* 14-day comparative operational run.
  - *Acceptance Criteria:* Both factories running autonomously and visible to managers.
  - *Complexity:* High.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* T-DEP-001.

---

### Category AI: Documentation and Maintenance
- **T-DOC-001: Master Operational Runbook & Incident Response Manual**
  - *Description:* Author comprehensive engineering runbooks covering camera stream recovery, worker reboots, certificate rotation, and incident triage.
  - *Req Ref:* SEC-001 Section 7, QA-001 Section 6.
  - *Dependencies:* T-DEP-001.
  - *Required Skills:* Technical writing, systems operations.
  - *Candidate Tech:* Markdown Runbooks in `docs/runbooks/`.
  - *Security Implications:* Runbooks must not contain raw passwords.
  - *Testing Requirements:* Operational drill: junior technician executes recovery using doc.
  - *Acceptance Criteria:* Complete operational documentation signed off by IT leadership.
  - *Complexity:* Medium.
  - *Unresolved Decisions:* None.
  - *Blocking Dependencies:* Phase 7 completion.

---

## 3. Inventory Summary

- **Total Engineering Tasks:** 42 Comprehensive Tasks across 35 Disciplines.
- **Critical Path Tasks:** T-FIA-001 (Photo Spike), T-INF-001 (GPU Sizing), T-NVR-001 (NVR Spike), T-BEA-001 (Core Architecture), T-CV-001 (Ingestion), T-FSD-001/002 (Fire Engine), T-FEA-001 (Mobile App), T-DEP-001/002 (Pilots).
- **Execution Rule:** Zero implementation tasks may commence prior to Gate 0 sign-off and Phase 1 spike resolutions.

