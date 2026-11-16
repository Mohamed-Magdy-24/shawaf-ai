> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# CTO Review — Industrial AI Surveillance Platform
## Archive audit and mandatory Phase 0 remediation

**Review date:** 2026-11-11  
**Reviewed archive:** `Industrial_AI_Surveillance_Project_Pack.rar`  
**Review scope:** 40 files, including the 25 `docs/discovery` documents and the original requirements, architecture, integration, security, AI, roadmap, testing, and Antigravity prompt files.

## 1. Executive decision

**Decision: DO NOT SIGN OFF Phase 0 yet. Do not authorize Phase 1 hardware purchases, real biometric processing, production deployment, or application implementation.**

The remediation is materially better than the initial discovery report. It correctly recognizes the two-site architecture, removes several unsupported claims, separates tracking from re-identification, corrects HMAC terminology, and identifies important legal and hardware blockers. However, the archive still contains stale technical selections, unproven performance claims, incorrect capacity arithmetic, legal mis-citations, and inconsistencies between original documents and the newer discovery package.

The archive is suitable as a working discovery baseline, not as an approved implementation specification.

## 2. Findings by severity

### P0 — Must be corrected before Phase 0 sign-off

#### P0-01 — Evidence classification is still wrong

`docs/discovery/01_PROJECT_UNDERSTANDING.md` labels many facts supplied by the project owner as `VERIFIED_OFFICIAL_SOURCE`. Examples include the two-site separation, SQL Server separation, Employee ID, retention, Android scope, manager switching, and video permissions.

These are stakeholder-confirmed requirements or owner-reported environment facts, not official-source findings. Replace classifications with a taxonomy such as:

- `OWNER_CONFIRMED_REQUIREMENT`
- `OWNER_REPORTED_ENVIRONMENT_FACT`
- `OBSERVED_IN_REPOSITORY`
- `VERIFIED_OFFICIAL_SOURCE`
- `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`
- `MEASURED_IN_POC`
- `PROPOSED`
- `UNKNOWN`
- `BLOCKED`

Do not convert an approximate count such as “about 200+ cameras” into an exact or mathematically verified count.

#### P0-02 — Technology matrix and compatibility matrix are stale

The original research tables still pin old candidate versions and contain false lifecycle statements. Examples include Flutter 3.24 described as LTS, Go 1.22/1.23 treated as current candidates, TensorRT 10.x pinned while the report elsewhere cites later releases, and PostgreSQL 18 described as unreleased. The two technology documents also contradict each other.

Do not simply replace every version with the newest release. Rebuild the matrix using official release/support pages and the actual target OS, GPU, driver, CUDA, ONNX Runtime, TensorRT, camera SDK, and extension compatibility. Distinguish:

- latest release;
- supported stable release;
- release compatible with the selected driver/CUDA/GPU;
- release tested in the project PoC;
- selected production version.

The last two remain `UNKNOWN` until tested. Exclude release candidates and preview releases from production candidates unless separately justified and explicitly approved.

MinIO Community is still referenced in older architecture/integration/screen documents even though the discovery report notes its repository was archived. Remove stale MinIO references from active candidate architecture or clearly mark the dependency as rejected / superseded. Evaluate maintained alternatives, licensing, S3 compatibility, backup, erasure coding, upgrade path, and support model. SeaweedFS is a candidate, not automatically the selected solution.

#### P0-03 — GPU, CPU, decode, and VRAM assertions remain unmeasured

`docs/discovery/13_INFRASTRUCTURE_ASSESSMENT.md` and `24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md` still contain assertions such as:

- hardware decode uses `0% CPU`;
- a specified GPU can handle 400 FPS at a stated latency;
- a minimum 16 GB VRAM is sufficient;
- estimated VRAM usage is 11.7 GB;
- 1,040 FPS decode capacity proves application-level capacity.

These are not established by a general GPU specification. Hardware decoding offloads codec work to a dedicated engine; it does not make the complete video pipeline consume zero CPU. Demuxing, network I/O, scheduling, memory copies, queues, frame transforms, post-processing, and application services still consume resources.

Mark all unbenchmarked values as `ESTIMATED` or `PROPOSED`. Remove definitive feasibility wording. Define a reproducible benchmark using representative clips, exact codecs/resolutions/FPS, model versions, batch sizes, decoding mode, GPU/driver/CUDA, concurrent streams, and sustained run duration. Measure p50/p95/p99 latency, throughput, GPU/VRAM, CPU/RAM, dropped frames, queue lag, thermals, and recovery after worker failure.

#### P0-04 — A flat 2 FPS baseline is not validated for every AI use case

The document applies 2 FPS across the complete fleet, while the roadmap suggests 2–5 FPS across multiple tasks. A uniform rate must not be assumed sufficient for falls, short-duration phone usage, handovers, fire/smoke dynamics, or fast restricted-zone events.

Define independent capture/inference policies for each use case, including temporal window length, minimum event duration, acceptable detection delay, and missed-event risk. Also establish whether cameras/NVRs can supply a suitably configured low-rate substream. Sampling decoded frames at 2 FPS does not automatically mean the decoder only decodes 2 FPS of a 25 FPS stream.

The figure 400 FPS per factory / 800 FPS total is mathematically valid only under the explicit assumption of exactly 200 streams at 2 analyzed frames per second. The user's counts are approximate and may exceed 200, so it is not a final workload.

#### P0-05 — Storage and RAID arithmetic is internally inconsistent

The model states 14 × 16 TB = 207.4 TB raw after RAID-6. That is incorrect.

For 14 drives of 16 TB each:

- raw capacity = 224 TB;
- RAID-6 parity equivalent to two drives = 32 TB;
- theoretical data capacity = 192 TB before filesystem formatting, reserved space, hot spare policy, and operational reserve.

The report's 165.92 TB requirement may be a planning estimate, but it must be rebuilt transparently. The 2.5 TB evidence allocation has no reproducible input model. Define evidence volume from expected events/day, clips/event, average clip duration, codec/bitrate, still images, retention period, and replication policy. Define VBR uplift as an explicit planning assumption, not a measured fact. Do not conflate filesystem reserve, OS space, RAID parity, hot spare, and free operational headroom.

Recalculate both factories separately and show decimal TB vs TiB consistently. Include disk failure/rebuild behavior and usable capacity under degraded RAID conditions.

#### P0-06 — Legal register contains substantive errors

`25_LEGAL_COMPLIANCE_ACTION_REGISTER.md` must be corrected by qualified Egyptian legal counsel before production biometric processing.

- It attributes a DPIA mandate to Article 11 of Law 151/2020; the cited Article 11 is not a DPIA provision. A privacy impact assessment may still be imposed as an internal engineering control or arise from another applicable rule, but do not cite Article 11 as its legal source without proof.
- It says affected data subjects are notified within 72 hours. The breach workflow needs to distinguish the notification to the Centre from notification to affected individuals and verify the exact trigger and timeline in the law and Executive Regulations.
- It presents occupational safety / crime-prevention language as a broad legal exception to biometric consent. Do not assume these purposes automatically exempt the controller from Article 12 licensing/permit and consent requirements. Obtain a written legal opinion.
- Do not assume every ordinary face photograph is automatically biometric sensitive data in every context. Distinguish an ordinary identifiable photo from data processed technically for unique biometric identification.
- Do not automatically delete embeddings 30 days after employee termination unless the lawful purpose, retention basis, employee rights, and other applicable recordkeeping duties have been reviewed.
- Avoid claiming that non-biometric CCTV is outside the law. Identifiable video is still personal data and requires legal review, notices, safeguards, retention controls, and the applicable controller/processor compliance.
- Remove the unsupported statement that the platform retains “90% of its operational value” without facial recognition. If the product offers a non-biometric mode, describe its actual supported functions without an arbitrary percentage. Do not claim that all non-biometric safety processing is legally unblocked: identifiable CCTV and tracking can still involve personal data and require legal review.
- Keep the DPIA as a project-required privacy risk assessment if desired, but label it as an internal control unless counsel confirms the precise statutory basis.

The English translation is not a substitute for the official Arabic statutory text or counsel's opinion. Do not process real employee biometrics until required approvals, licences/permits, notices, lawful basis, and consent conditions are confirmed.

#### P0-07 — Fire alert path must not rely solely on a phone push service

The architecture evaluates FCM for Android push. FCM is an external cloud dependency, even if the application backend and video processing are on-premises. It requires internet connectivity and cannot guarantee receipt while the handset or network is unavailable.

Document the exact delivery model:

- local app/WebSocket delivery while connected to the factory network;
- Android push via FCM when permitted and internet is available;
- payload limited to a non-sensitive event identifier and minimal metadata;
- authenticated retrieval from the on-premises API;
- retry, acknowledgement, idempotency, timeout, escalation, and audit;
- clear indication of delivery state vs dispatch attempt.

Do not claim an end-to-end alert guarantee or sub-second delivery without measurement. The visual AI fire detector is an auxiliary warning channel only. It must not replace the certified fire alarm panel/detectors. Determine whether the existing fire alarm system can provide a reliable independent integration path. If the owner requires app-only notification, explicitly document its availability limitations and get owner/safety approval.

### P1 — Must be resolved before the relevant phase or implementation task

#### P1-01 — LACP is not equivalent to one 2 Gbps pipe for every stream

LACP distributes flows according to a hashing algorithm. Aggregate bandwidth across many flows may increase, but a single flow usually remains on one physical member. Do not write `2 × 1 Gbps = 2 Gbps` as a guarantee for a single video session. Base network design on measured flow distribution, uplink topology, switch buffers, multicast/unicast behavior, NVR pulls, playback concurrency, and failure scenarios.

A calculated 685 Mbps does not by itself prove packet loss or microburst drops. Treat it as a scenario estimate until measured. 10GbE is a candidate, not a mandatory requirement by assertion.

#### P1-02 — One sample device cannot validate a mixed fleet

One NVR, two cameras, and one ZKTeco terminal are useful first PoC devices, but they cannot validate dozens of mixed terminals and multiple NVR makes/models/firmware versions. First obtain a read-only inventory. Then define representative device families and compatibility tiers. Unsupported models must remain explicitly unsupported rather than silently assumed compatible.

The PoC must test the exact APIs, SDKs, firmware, channel/session limits, playback, audio/video codecs, RTSP/ONVIF behavior, and ZKBioTime version actually present.

#### P1-02A — Do not claim biometric templates are universally mathematically impossible to convert

The project should prohibit reverse-engineering vendor templates and should not treat proprietary templates as RGB photos. However, avoid a universal mathematical claim about every device/template format without an authoritative vendor specification. State the practical rule: only supported export APIs and verified image files count as an acceptable image source; all other template formats remain unsupported for this project unless the vendor documents an interoperable method.

#### P1-03 — ByteTrack is not cross-camera re-identification

Keep within-camera object tracking separate from cross-camera person association. Cross-camera Re-ID requires additional embeddings/appearance models, camera topology, clock synchronization, calibrated matching thresholds, and a way to handle false matches. It must report confidence and uncertainty and must never invent an employee route when matching evidence is insufficient.

#### P1-04 — UTC is not the factory's business-day boundary

Daily reports are scheduled at 00:00 UTC. The factories operate in Egypt. Store timestamps in UTC, but calculate operational calendar days and reporting boundaries using the approved factory timezone (`Africa/Cairo`) and explicitly defined cutoffs. Handle timezone/DST rule changes and backfills. Do not silently define the business day as 02:00/03:00 local time.

#### P1-05 — UI contrast ratios are not consistently correct

The color strategy's contrast claims need recomputation for each actual foreground/background pair using WCAG relative luminance. For the listed tokens, examples calculated using the WCAG formula are:

- `#0D9488` on `#0B111E`: approximately 5.04:1;
- `#0D9488` on `#161F30`: approximately 4.41:1;
- `#0D9488` on `#F8F9FA`: approximately 3.55:1;
- `#F8F9FA` on `#0B111E`: approximately 17.90:1;
- `#EF4444` on `#0B111E`: approximately 5.01:1;
- `#F59E0B` on `#0B111E`: approximately 8.78:1;
- `#10B981` on `#0B111E`: approximately 7.44:1.

Teal therefore does not meet 4.5:1 for ordinary text on the Graphite surface. Define separate foreground tokens if needed. Test borders, focus indicators, icons, status badges, disabled states, chart series, and text in both themes. Do not claim a palette is WCAG-compliant based on a single pair.

#### P1-06 — Skills audit count is not auditable

The report claims a complete inventory of 29 packaged skills plus 8 workspace skills but the visible mapping table lists fewer entries. Provide a machine-generated full inventory or correct the count and state its scope. Record exact skill slug, path, version/hash if available, read status, capability, limitations, and tasks. Do not publish absolute local home-directory paths or usernames in GitHub documentation; use repository-relative or sanitized identifiers.

A missing named skill is not proof that a technical capability is unavailable. Also, a read skill is not proof that it was invoked for a particular task.

#### P1-07 — Define one source of truth and retire contradictory copies

The archive contains original documents and newer discovery documents that repeat architecture and technology decisions. Several old documents still mention old Go/Flutter/TensorRT/PostgreSQL/MinIO candidates. Add a document precedence policy, version index, and supersession map. For each requirement and ADR, identify exactly one canonical owner document. Mark stale duplicated sections as `SUPERSEDED` and link to the canonical record. Update the master prompt and phase prompts to obey this source of truth.

#### P1-08 — Strict no-mock policy needs precise test/runtime separation

The owner's prohibition applies to runtime UI, dashboards, reports, operational records, camera streams, and production paths. Test doubles and synthetic fixtures may be used only in isolated automated unit/contract tests when they are necessary, clearly labelled, never seeded into development/staging/production user-facing dashboards, never used as model-performance evidence, and never presented as real operational data. Accuracy benchmarks need held-out representative footage with lawful approval and ground truth. Never use fabricated events to make a dashboard look populated.

#### P1-09 — Web Admin scope is not yet owner-approved

Android for managers is confirmed. A separate Web Admin Console for camera registry, zone polygons, employee image enrollment, and model settings is a proposed addition. Keep it `PROPOSED / REQUIRES OWNER APPROVAL`. Identify intended admin personas and access boundaries. Desktop access can be a browser experience; do not create a Windows desktop app without a separate requirement. Employee photo import needs special legal and access controls.

#### P1-10 — Define management-plane placement and degraded modes

Specify where the shared Management API / Context Router / identity service resides. Define what happens when the inter-factory link or central management plane is unavailable. Local safety monitoring and local event persistence should continue at each factory; cross-site switching and aggregation may become temporarily unavailable and must recover/synchronize safely. Define where the central audit trail is stored, its availability, replication, and integrity model.

#### P1-11 — Alert delivery claims and SLOs are unapproved

Targets such as sub-second fire alerting, <800 ms, <500 ms video, 60 FPS UI, 99.x uptime, RTO <2h, and RPO <15m are proposals until the owner approves them and a benchmark validates them. Make them explicit candidate SLOs with measurement points, percentiles, test conditions, and failure handling.

## 3. Specific corrections to the existing archive

At minimum, revise these documents and their dependent references:

- `01_PROJECT_UNDERSTANDING.md`: correct provenance/classification for all D-001 onward; separate owner requirements from technical verification.
- `04_SKILLS_AUDIT.md`: reconcile inventory count; sanitize local paths; record scope and hashes.
- `07_TECHNOLOGY_RESEARCH_MATRIX.md` and `23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md`: reconcile into one current matrix; remove stale and contradictory release statements.
- `08_TARGET_ARCHITECTURE_PROPOSAL.md` and `17_ARCHITECTURE_DECISION_REGISTER.md`: define management plane hosting, network-loss behavior, FCM dependency, event delivery semantics, and reporting timezone.
- `09_UI_UX_DESIGN_STRATEGY.md` and `22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md`: correct contrast calculations and claims.
- `10_SCREEN_AND_NAVIGATION_INVENTORY.md`: mark Web Admin as owner-approval required; remove stale MinIO reference; define roles and actual screen scope.
- `11_SECURITY_AND_PRIVACY_ASSESSMENT.md` and `25_LEGAL_COMPLIANCE_ACTION_REGISTER.md`: correct legal article references, breach deadlines, lawful basis assumptions, retention and DPIA statements.
- `13_INFRASTRUCTURE_ASSESSMENT.md` and `24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md`: replace unsupported hardware assertions; recalculate storage/RAID; fix LACP language; separate workload per AI use case.
- `14_TESTING_AND_QUALITY_STRATEGY.md`, `17_ARCHITECTURE_DECISION_REGISTER.md`, and `19_PHASED_IMPLEMENTATION_ROADMAP.md`: use Africa/Cairo business reporting boundaries; make SLOs proposed pending approval.
- `20_OWNER_APPROVAL_CHECKLIST.md`: remove mandatory authorization language for proposals; split business decisions from technical proof; remove cloud GPU default unless privacy/legal approval explicitly allows it.
- `antigravity/09_MASTER_OPERATING_PROMPT.md` and `antigravity/11_PHASE_PROMPTS.md`: point to one canonical source of truth and enforce this audit's gates.

## 4. Mandatory new deliverables

Create these documents in `docs/discovery/`:

1. `26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md`
2. `27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md`
3. `28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md`
4. `29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md`
5. `30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md`
6. `31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md`
7. `32_DEVICE_FLEET_INVENTORY_AND_COMPATIBILITY_PLAN.md`
8. `33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md`
9. `34_LEGAL_REGISTER_CORRECTION_AND_COUNSEL_QUESTIONS.md`
10. `35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md`

## 5. Owner decisions that must remain open

Do not presume approval of:

- Cloud/leased GPU testing with real factory footage;
- Web Admin Console scope and personas;
- administrative photo enrollment portal;
- Fire alarm / FACP integration method and named on-site emergency recipients;
- legal basis, PDPC licensing/permit, notices, and biometric consent path;
- specific hardware procurement or final software versions;
- final SLOs, RTO, RPO, and retention of biometric embeddings after employment ends.

For an initial GPU PoC, prefer a physically isolated on-prem test machine using lawful test data. Do not upload identifiable factory video or employee biometrics to a cloud GPU service unless the company/legal team explicitly authorizes it after reviewing data protection, transfer, processor, and contractual requirements.

## 6. Strict execution boundary

This task is documentation-only.

- Do not write application code.
- Do not install/upgrade dependencies.
- Do not initialize Git or push to GitHub.
- Do not purchase hardware.
- Do not access production systems with write permissions.
- Do not export real employee photos, biometrics, or video.
- Do not deploy anything.

Use actual official sources, cite exact pages/versions/dates, and preserve uncertainty. Do not claim a fact is measured unless the measurement was actually executed and recorded.

## 7. Required final response

Return:

1. File-by-file change summary.
2. Corrected claims register with old claim, correction, evidence, and status.
3. Updated task dependencies and blockers.
4. Exact PoC test inputs and benchmark protocol (not invented results).
5. Revised owner decision checklist separating owner choices from engineering proofs.
6. List of remaining unknowns.
7. Confirmation that no code, package, Git, production data, or hardware changes occurred.

**STOP after documentation remediation. Do not start Phase 1. Wait for explicit owner approval.**
