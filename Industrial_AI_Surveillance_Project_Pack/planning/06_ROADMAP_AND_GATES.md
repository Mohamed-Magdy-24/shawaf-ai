# Delivery Roadmap and Phase Gates

**Document ID:** PLAN-001  
**Rule:** One phase at a time. A phase is complete only when its evidence is reviewed and its gate is passed.  

## Phase 0 — Repository and environment discovery (NO IMPLEMENTATION)

**Goal:** Establish the actual starting point and remove unknowns that could invalidate architecture.

Tasks:
- Inspect repository, code, build, tests, dependencies, deployment, and current architecture if a repository exists.
- Inventory current technology versions and supported runtime environments.
- Create an evidence-based system context and module map.
- Identify existing working code versus stubs, mocks, dead code, and generated code.
- Create an integration discovery checklist for both factories.
- List all blockers and decisions requiring owner approval.
- Propose ADRs with options and trade-offs.

Deliverables:
- Repository inventory.
- Current-state architecture diagram.
- Build/test baseline and known failures.
- Requirements gap list.
- Device/integration discovery matrix.
- Proposed target architecture and ADR drafts.
- Phase 1 implementation plan.

**Gate 0:** Owner reviews the facts, unknowns, proposed architecture, and decision log. No application implementation is authorized before this gate.

## Phase 1 — Architecture decisions and technical spikes

**Goal:** Prove the riskiest dependencies before committing to production design.

Spikes:
- ZKBioTime access and conventional photo retrieval for representative device families.
- SQL Server schema and safe read-only synchronization.
- NVR live/playback capability for representative models at each site.
- Video stream throughput and network feasibility.
- AI inference benchmark on candidate hardware with representative stream properties.
- Android video playback feasibility without exposing NVR credentials.

Deliverables:
- Approved ADRs.
- Adapter capability matrix.
- Integration proof-of-concept reports with logs/test evidence.
- Hardware/network capacity report.
- Updated cost and deployment assumptions.

**Gate 1:** No unproven critical connector may be presented as production-ready. Blocked use cases are explicitly deferred or redesigned.

## Phase 2 — Engineering foundation

**Goal:** Establish code quality and deployment discipline before feature implementation.

Tasks:
- Repository structure and module boundaries.
- Domain/application/infrastructure/presentation layering.
- CI build, formatting, linting, static analysis, dependency scanning.
- Unit/integration/contract test harnesses.
- Configuration, secrets, structured logging, metrics, health checks.
- Site context and authorization foundation.

Deliverables: buildable foundation, architecture tests, CI pipeline, secure configuration template, runbook skeleton.

**Gate 2:** Build is reproducible; architecture tests pass; no fake integrations can start in production configuration.

## Phase 3 — Site, identity, and device integrations

**Goal:** Connect validated site sources through adapters.

Tasks:
- Separate BNF/RNF configuration and SQL/ZKBioTime connectors.
- Employee synchronization and site-scoped identity model.
- Device/NVR/camera inventory and capability/health monitoring.
- Face image acquisition as a separately gated capability.

Deliverables: verified read-only sync, reconciliation reports, device inventory, integration contract tests.

**Gate 3:** Correct source-to-platform mapping, failure handling, and strict site isolation demonstrated. Face recognition remains disabled if the image gate is not passed.

## Phase 4 — Video ingestion and AI proof of value

**Goal:** Build the video pipeline and validate one event class at a time.

Recommended order:
1. Person detection/tracking and camera/zone mapping.
2. Restricted-area entry.
3. PPE by zone.
4. Fire/smoke urgent alert path.
5. Fall/accident and phone-use behavior.
6. Object classification, movement, and possible handoff.
7. Cross-camera association and optional face-to-employee matching.

Deliverables: per-class evaluation, event schema, evidence clips, operational metrics, model version registry.

**Gate 4:** Each use case has representative validation data and approved thresholds. A model that fails acceptance stays in shadow mode or disabled.

## Phase 5 — Event, alert, and incident workflows

**Goal:** Normalize events, route alerts, and provide traceability.

Tasks:
- Rule evaluation and deduplication/correlation.
- Transactional outbox and durable notification queue.
- Approved alert routing matrix.
- Fire high-priority delivery path.
- In-app alert list and evidence links.
- Incident follow-up only to the extent the owner-approved workflow defines it.

Deliverables: routing tests, delivery reports, audit log, retry/dead-letter operations.

**Gate 5:** All routing matrix tests pass; no cross-site alert leakage; no human approval blocks fire notification.

## Phase 6 — Android application

**Goal:** Deliver manager workflows on Android.

Screens/modules:
- Secure login/session.
- Site switcher and visible site context.
- Site dashboard.
- Alert inbox and event details.
- Incident/event follow-up.
- Live camera view and playback with role checks.
- Analytics dashboard and scheduled report views.
- Operational health screen for authorized roles, if approved.

**Gate 6:** Device testing, accessibility/usability review, authorization tests, stream failure handling, and stale-data handling pass.

## Phase 7 — Reporting, hardening, and pilot

Tasks:
- Daily/weekly/monthly report generation and snapshots.
- Security/privacy review and remediation.
- Capacity/load/failure testing at representative scale.
- Backup/restore and disaster-recovery exercise.
- BNF pilot, then RNF pilot; compare results and correct site-specific issues.
- Production operations runbooks and support ownership.

**Gate 7:** Acceptance evidence complete for every MUST requirement; unresolved blockers are formally accepted as deferred, not hidden.

## Phase 8 — Scale and continuous improvement

- Add remaining camera/NVR models via adapters.
- Expand camera groups only after capacity checks.
- Add AI classes only after labeled-data and pilot gates.
- Re-evaluate costs, GPU usage, queue lag, false positives, and operator workload.

## Mandatory phase report format

Every Antigravity phase response must end with:

1. Scope completed.
2. Files changed (exact paths).
3. Requirements addressed (IDs).
4. Tests run (exact commands and results).
5. Evidence observed (logs, screenshots, measurements, reports).
6. Known failures and unresolved items.
7. Security/privacy impact.
8. Architecture deviations and ADR references.
9. Rollback instructions.
10. Gate status: PASS / FAIL / BLOCKED, with reasons.

A successful compile is not a phase gate by itself.
