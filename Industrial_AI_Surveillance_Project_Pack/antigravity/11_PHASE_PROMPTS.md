# Antigravity Phase Prompts — Run One at a Time

> ### LOCAL-DEV MODE
> Phases 1–7 may be executed against simulated sources (MediaMTX RTSP loops, mock ZKBioTime server clearly named `*_simulator`, synthetic SQL Server schema in PostgreSQL labeled `SIMULATED`) **provided** every capability matrix, report and UI label says `SIMULATED`, and no gate marked in OWNER_AUTHORIZATION "NOT AUTHORIZED" is bypassed. Production gates in each phase text are not removed.

Use one prompt only after the previous phase gate has been reviewed and approved per [35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md](../docs/discovery/35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md) and [41_OWNER_APPROVAL_GAPS.md](../docs/discovery/41_OWNER_APPROVAL_GAPS.md). Replace bracketed values with approved details. Never send all prompts as one request.

> **MANDATORY INTERPRETATION RULE:**
> Always distinguish between:
> - `NOT AUTHORIZED YET`: A temporary execution restriction pending approval (e.g., Sprint 1, physical camera connections to production networks, unapproved technical spikes).
> - `NOT PART OF PROJECT SCOPE`: A capability explicitly excluded from the product (e.g., iOS support, Power BI, MinIO, TensorRT, public cloud video processing, automatic disciplinary workflows).
> - `REQUIRED FINAL CAPABILITY`: A core feature that the final system must support (e.g., connecting to authorized factory cameras and NVRs, processing live RTSP streams, ZKTeco attendance synchronization, local on-premise edge processing, autonomous offline operation during WAN outage).
>
> Connecting cameras, NVRs, ZKTeco devices, and factory attendance systems is an essential final capability of the Industrial AI Surveillance Platform. Physical integration testing is required as part of authorized technical spikes. Never convert a temporary authorization restriction into a permanent product limitation.

---

## Phase 1 — Resolve critical technical unknowns (Spikes & Verification)

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Phase 0 has an explicit written APPROVED status (`DEC-01`) and the specific technical spike has written authorization (`SPK-01` to `SPK-04`) in the canonical owner/gate approval register.
> Authorization for one technical spike does NOT constitute authorization for the other three.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> The Phase 0 report and remediation deliverables (Documents 01–44) have been reviewed. Work on Phase 1 technical spikes only per [28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md](../docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md), Document 32, and [38_DECISION_ID_CANONICAL_REGISTER.md](../docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md). Do not build the full application. Do not purchase production hardware. The GPU benchmark itself remains unauthorized until SPK-02 receives explicit owner authorization. Validate the representative ZKBioTime version/device families (Spike 1: SPK-01 / BLK-001 photo extraction), candidate inference runtime (Spike 2: SPK-02 / BLK-002: Evaluate ONNX Runtime CPU inference as the required baseline. Evaluate CUDA execution only if the exact candidate GPU and software compatibility chain has been established. Do not use TensorRT or DeepStream), representative NVR live/playback APIs with go2rtc candidate sidecar (Spike 3: SPK-03 / BLK-003), and read-only SQL Server schema (Spike 4: SPK-04 / OQ-005). Use only approved test accounts and non-production test data. Produce reproducible commands, logs, capability matrices, measured throughput, failure cases, and ADR updates. Do not claim support for untested models. If the connector or photo retrieval path is unsupported, record the result as BLOCKED. Do not activate, implement, or assume the biometric photo-upload fallback until DEC-03 receives explicit written owner approval. Keep face recognition disabled while photo acquisition and legal/privacy gates remain unresolved. Continue only with other individually authorized, non-dependent spike work. Do not bypass an unavailable prerequisite. Stop at Gate 1.

---

## Phase 2 — Engineering foundation

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Gate 1 has an explicit written APPROVED status in the canonical owner/gate approval register.
> Additionally, require `ADR-011 = APPROVED` before selecting, installing, or implementing the proposed runtime technology stack.
> If ADR-011 remains PROPOSED, stop stack-specific implementation.
> Do not assume Go/Python runtime allocation, PostgreSQL, PostgreSQL 16 transactional outbox (ADR-013), or other proposed runtime candidates have been approved merely because they appear in the SDD.
> Do not authorize Sprint 1 by implication.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement only the foundation specified in the approved architecture: repository/module structure, Domain/Application/Infrastructure/Presentation boundaries, configuration/secrets handling, CI quality checks, structured logging/metrics/health, and automated test harnesses. Do not implement AI business features or fake vendor integrations. Add architecture tests that fail when dependency direction is violated. Provide exact changed files and test evidence. Stop at Gate 2.

---

## Phase 3 — Site identity and integrations

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Gate 2 has an explicit written APPROVED status in the canonical owner/gate approval register.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement the site-scoped BNF/RNF configuration, identity/access foundation, read-only SQL Server integration, ZKBioTime adapters, employee synchronization, and device/NVR inventory using only the verified contracts from Phase 1. Include reconciliation, pagination, retries, typed unsupported states, audit, and contract tests. Do not activate face matching unless its separate photo retrieval and legal/privacy gates have passed. Prove BNF/RNF isolation with negative tests. Stop at Gate 3.

---

## Phase 4A — Video pipeline foundation

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after:
> 1. Gate 3 is explicitly APPROVED in the canonical owner/gate approval register.
> 2. `ADR-011 = APPROVED` by the Project Owner.
> 3. `SPK-03` is completed with documented compatibility results for the specific test NVR/camera models.
> 4. The selected go2rtc release and license are verified.
> If any condition is absent, STOP and report BLOCKED. Do not implement go2rtc as a selected dependency while ADR-011 remains proposed.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement the video ingestion pipeline only for the explicitly tested NVR/camera families using go2rtc as a preferred candidate streaming sidecar, subject to ADR-011 approval and tested device compatibility. Use controlled local POSIX filesystem storage behind the application storage abstraction. Do not introduce SeaweedFS, MinIO, or S3 as baseline dependencies. Add health monitoring, bounded frame sampling, buffering, resource limits, timestamps, and failure isolation. Do not claim support for every camera. Add a capability matrix and load measurements. Keep AI events in shadow/test mode. Stop and report before enabling alerts.

---

## Phase 4B — One AI use case at a time

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after:
> 1. Phase 4A deliverables are explicitly APPROVED in the canonical owner/gate approval register.
> 2. `ADR-011 = APPROVED` by the Project Owner.
> 3. An exact model artifact is selected and approved, with exact source revision, checkpoint, model-weight license, dataset provenance, and checksum documented.
> 4. A representative validation dataset and owner-approved acceptance criteria are available.
> YOLOX and RT-DETR remain candidates, not automatic approvals. If model provenance or acceptance criteria are missing, do not implement the production detection use case; keep it blocked or in an explicitly authorized research-only state.
>
> **LEGAL AND PERSONAL-DATA PRODUCTION GATE:**
> `DEC-06` remains `AWAITING SUBMISSION`.
> Before production processing of:
> - Employee biometric data.
> - Face-recognition data.
> - Employee identity matching.
> - Cross-camera employee re-identification.
> - Longitudinal employee movement/sighting histories.
> - Other identifiable employee surveillance records requiring legal review.
>
> The project must have:
> 1. Document 34 submitted to qualified Egyptian legal counsel.
> 2. A documented legal review outcome.
> 3. Written owner approval of the resulting processing scope and controls.
> 4. Any legally required registrations, notices, permissions, or restrictions documented.
>
> Submission to counsel alone is not legal clearance.
> No production employee biometric or identifiable tracking processing is authorized while these requirements remain unresolved.
> Synthetic or non-identifiable research may proceed only when separately authorized and when it does not use restricted employee data.
>
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement only this approved AI use case: [AI USE CASE ID]. Read its specification and acceptance dataset. Define the event semantics, model/runtime interface, configuration, evidence format, thresholds, and failure states. Follow the multi-rate sampling policy in Document 28 (e.g. 10–15 FPS burst for falls, 2 FPS baseline for PPE). Evaluate on held-out labeled data representative of both sites. Report precision, recall, false positives, false negatives, latency, and limitations by camera conditions. Never invent metrics. Keep the feature in shadow mode until the owner approves the measured results. Do not start another AI class in this task.

---

## Phase 5 — Event normalization and alerts

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Gate 4 has an explicit written APPROVED status in the canonical owner/gate approval register.
> Additionally, require the following distinct prerequisites:
> 1. `ADR-011 = APPROVED` before using PostgreSQL, PostgreSQL 16 transactional outbox (ADR-013), or another selected runtime component as an implementation dependency.
> 2. `DEC-04 = OWNER SIGNED-OFF` before production deployment of the AI fire-alert auxiliary-status policy.
> 3. `DEC-05 = SUBMITTED AND VERIFIED` before production fire routing is configured, because official BNF/RNF recipient rosters are still missing.
> 4. `DEC-06 = LEGAL CLEARANCE & OWNER APPROVAL` before production alerting, notifications, or routing involving identifiable employee surveillance or biometric data.
> 5. `DEC-08 = APPROVED` before implementing or activating Firebase Cloud Messaging (FCM).
> If DEC-08 remains pending, do not enable FCM or upload factory/employee data to Firebase.
> If DEC-04 or DEC-05 remains pending, do not activate the production fire notification route.
> If DEC-06 remains pending, do not route or dispatch identifiable employee or biometric data.
> Preserve the owner-confirmed fast-path policy: fire dispatch must not wait for manual human confirmation; do not introduce a human triage gate into the urgent fire path; keep AI alerts explicitly auxiliary and non-certified.
> Implement only components whose specific architecture and owner prerequisites are satisfied. Do not allow one phase-gate approval to silently approve DEC-04, DEC-05, DEC-06, DEC-08, or ADR-011.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement the approved event and alert workflow against the confirmed routing matrix per [30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md](../docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md). Use durable PostgreSQL outbox, PostgreSQL 16 transactional outbox (ADR-013) priority queue processing, local WebSocket dispatch, FCM auxiliary push, idempotency, retry, deduplication, audit, and dead-letter visibility. Test ordinary alert recipients for BNF and RNF, explicit cross-site exclusions, and the urgent fire path without waiting for manual confirmation. Measure server event creation and dispatch latency using a documented test protocol. Any existing <500ms target remains a candidate engineering target only, not an approved acceptance threshold. Report measured percentiles and failure cases. Do not claim the target is met without actual test evidence. Do not invent acknowledgement/rejection/incident states; implement only the separately approved workflow. Stop at Gate 5.

---

## Phase 6 — Android application

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Gate 5 has an explicit written APPROVED status in the canonical owner/gate approval register.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement only the Android application scope approved for this phase. Connect real API contracts, enforce permissions on the server, show the active factory clearly with explicit two-tap confirmation, and handle loading/empty/error/offline/stale states per Document 10. Live/playback controls must use short-lived authorized sessions, never embedded NVR credentials. Follow the design tokens and WCAG contrast rules in [33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md](../docs/discovery/33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md). Do not use hard-coded production-looking data. Display verified empty states. Provide UI tests and API authorization evidence. Stop at Gate 6.

---

## Phase 7 — Reporting and production hardening

> **PREREQUISITE GATE VERIFICATION:**
> Execute this phase only after Gate 6 has an explicit written APPROVED status in the canonical owner/gate approval register.
> Before starting, verify: Gate ID, Gate status, Owner approval reference, Approved scope, Required completed predecessor deliverables.
> If any required approval is absent, outdated, or ambiguous, STOP and report BLOCKED. Do not infer approval from a prior phase document or an AI-generated summary.
>
> Implement the approved in-app daily, weekly, and monthly report definitions aligned to the Africa/Cairo timezone and calendar per [31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md](../docs/discovery/31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md). Do not invent KPI formulas or percentages. Obtain approval for every metric definition. Complete security/privacy review under Law 151/2020 per Document 34, site-isolation testing, load/resilience testing, backup/restore, retention validation, Android device tests, and operational runbooks. Pilot at one site for 14 days, review evidence, then pilot the second site. Do not declare production readiness until every MUST requirement has traceable acceptance evidence.

---

## Bug-fix prompt — Evidence-first

> Fix only the defect described here: [BUG ID + OBSERVED BEHAVIOR]. First reproduce it and identify the root cause with evidence. Map it to requirement/test IDs. Propose the smallest safe correction. Do not refactor unrelated code or weaken tests. Add a regression test that fails before the fix and passes after it. Run the relevant test suite and report exact commands/results, changed files, residual risks, and rollback. If the cause cannot be reproduced, report BLOCKED rather than guessing.

---

## Code review prompt — No feature additions

> Perform a review only. Do not modify files. Review the specified diff against the SRS, architecture, security/privacy constraints, coding standards, and tests. Rank findings by severity (Critical/High/Medium/Low), cite exact file and line, explain concrete failure mode, and propose a minimal fix. Specifically inspect site isolation, authorization, vendor boundary leakage, async/event reliability, AI uncertainty semantics, and fake success/placeholder code. Do not report stylistic preferences as defects unless they affect maintainability or correctness.
