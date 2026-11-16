> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# Test Strategy and Acceptance Criteria

**Document ID:** QA-001  
**Status:** Acceptance framework; numeric targets marked TBD must be approved after discovery/pilot.  

## 1. Test pyramid

- **Unit:** domain invariants, rules, routing, identity scoping, time calculations.
- **Architecture:** dependency direction, module boundary rules, no vendor SDK in Domain/Application.
- **Contract:** ZKBioTime, SQL Server, NVR, queue, and notification adapter contracts.
- **Integration:** per-site end-to-end paths using test environments and representative devices.
- **Security:** authz/authn, tenant/site isolation, secrets, video access, data protection.
- **AI evaluation:** labeled data, class metrics, camera-condition segmentation, regression.
- **Load/resilience:** camera stream concurrency, queue backlog, site outage, NVR failure, inference saturation.
- **Android UI/device:** login, site switch, alerts, video playback, reports, interrupted networks.

## 2. Functional acceptance scenarios

| Test ID | Scenario | Expected result |
|---|---|---|
| AT-SITE-001 | Manager switches from BNF to RNF | Active site changes explicitly; all subsequent data is scoped to RNF |
| AT-SITE-002 | BNF-only user requests RNF event API directly | Server denies request, regardless of UI state |
| AT-SITE-003 | RNF connector becomes unavailable | BNF site processing remains available |
| AT-EMP-001 | Employee sync retrieves a stable source Employee ID | Correct site-scoped employee record is created/updated idempotently |
| AT-EMP-002 | Two sites contain same Employee ID | Records remain distinct by site |
| AT-EMP-003 | Face image unavailable from one terminal family | Employee receives explicit unsupported/missing state; no fabricated image or identity |
| AT-VID-001 | Unauthorized manager requests live stream | Access denied server-side; no stream token issued |
| AT-VID-002 | Authorized security manager views live stream | Short-lived session issued and audited |
| AT-VID-003 | Authorized user requests playback range | Correct site/camera/time range returned or explicit unavailable result |
| AT-ALT-001 | PPE event occurs at BNF | Alert delivered to BNF manager, company management, and security managers per recipient policy |
| AT-ALT-002 | BNF event occurs | No delivery to RNF-only ordinary recipients |
| AT-ALT-003 | Fire event occurs at RNF | Immediate RNF responsible-recipient dispatch; no human approval required |
| AT-ALT-004 | Notification provider/queue temporarily fails | Event/dispatch intent persists; retry occurs; failure remains observable |
| AT-AI-001 | PPE rule differs between production and office zones | Only the production policy is applied to production camera/zone; office policy remains distinct |
| AT-AI-002 | Person identity confidence is below approved threshold | Identity is unknown/unconfirmed; no forced Employee ID assignment |
| AT-AI-003 | Cross-camera track has a gap | UI/report displays a gap; no fabricated route segment |
| AT-AI-004 | Object handoff is partially occluded | Result is marked uncertain/incomplete; not stated as confirmed theft |
| AT-AI-005 | Model upgrade causes regression on validation set | Rollout is blocked or rolled back according to model governance |
| AT-REP-001 | Daily report period closes | Daily report snapshot is generated and appears in the in-app reporting area |
| AT-REP-002 | User has access to BNF only | Cross-site report data is not exposed |
| AT-APP-001 | Network drops during playback | App shows failure/stale status clearly and does not pretend video is live |
| AT-RET-001 | Video older than 30 days is queried | It is unavailable under the approved retention policy unless an approved evidence hold applies |

## 3. AI acceptance protocol

Before live alerting for an AI class:

1. Define the event precisely with positive and negative examples.
2. Select a representative set of cameras and zones from both factories.
3. Collect and label approved clips with timestamps and ground truth.
4. Separate training/tuning data from the held-out test set.
5. Measure precision, recall, false positives/hour or another suitable operational rate, false negatives, latency, and coverage.
6. Segment results by day/night, lighting, angle, distance, crowding, and camera family.
7. Obtain business/safety-owner approval for thresholds and the operational false-alarm budget.
8. Run in shadow mode, compare with human observations, then enable limited alerting.
9. Monitor drift and provide rollback.

Do not publish a single overall accuracy percentage that hides poor performance in a site or camera subset.

## 4. Scale test requirements

The initial scale baseline is approximately 200+ cameras per factory, with growth expected. The test plan must derive actual workload from discovered streams and inference configuration. Measure:

- Active camera streams and reconnect behavior.
- Frame sampling rate and dropped frames.
- Decode/inference throughput by model and GPU/CPU.
- Queue lag and oldest-event age.
- API p50/p95/p99 latency under analytics load.
- Android concurrent live-view sessions and NVR limits.
- Storage throughput/capacity and retention behavior.
- Recovery after NVR, worker, database, queue, network, and site outages.

No numeric SLO is approved yet. The Phase 1 sizing report must propose measurable targets for owner approval.

## 5. Security acceptance

- Direct API authorization tests for every protected resource.
- Cross-site negative tests across DB, API, cache, queue, notification, report, and video layers.
- Expired/revoked video session test.
- Secret scanning and dependency scanning.
- Audit coverage for video/employee/policy/model access.
- Data deletion/retention exercise.
- Backup restore for each site.

## 6. Definition of Done

A requirement is Done only when:

- It has an ID and owner-approved interpretation.
- The implementation exists (not a placeholder/mock in production path).
- Automated tests cover normal, boundary, failure, and unauthorized cases.
- The relevant adapter/device has been tested where applicable.
- Logs/metrics/audit evidence exist where operationally required.
- Documentation and runbook are updated.
- No known blocker is hidden.
- The acceptance result is recorded as PASS with reproducible evidence.
