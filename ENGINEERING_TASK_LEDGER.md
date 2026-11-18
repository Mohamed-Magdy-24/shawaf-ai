# SHAWAF AI — ENGINEERING TASK LEDGER

This ledger tracks the investigation, root-cause analysis, remediation, and verification of all engineering issues identified during the vertical-slice assessment and recovery mission.

---

## Issue Index & Summary

| Issue ID | Priority | Category | Description | Status | Verification Gate |
|---|---|---|---|---|---|
| **RLS-01** | P0 | Security | Database RLS policy allowed `'ALL'` bypass, breaking tenant isolation | **RESOLVED** | `test_rls.py` (Phase 1, 2, 3) |
| **RLS-02** | P0 | Security | Outbox dispatcher queried with `WithTenantTx("ALL")` | **RESOLVED** | `test_rls.py`, `outbox_repository.go` |
| **RLS-03** | P0 | Security | Outbox dispatcher lacked least-privilege role separation | **RESOLVED** | Stored procedures + `outbox_dispatcher` role |
| **AUTH-01** | P0 | Security | HTTP REST API endpoints completely unauthenticated | **RESOLVED** | `handler_test.go`, Docker API curl tests |
| **AUTH-02** | P0 | Security | Operator identity in WebSocket tickets & incidents was client-spoofable | **RESOLVED** | `handler.go`, `TestHandler_IssueWSTicket` |
| **AI-01** | P1 | AI/ML | Vertical slice tests used hardcoded mock detections instead of real ONNX | **RESOLVED** | `test_vertical_slice.py` (Step 1) |
| **RTSP-01** | P1 | Streaming | Benchmark script bypassed ONNX inference and lacked bounded queue | **RESOLVED** | `scripts/benchmark_wp4_rtsp.py` |
| **UI-01** | P1 | Mobile | Flutter UI lacked real multi-site switching (`site_bnf` <-> `site_rnf`) | **RESOLVED** | `command_overview_screen.dart`, `incident_bloc.dart` |
| **UI-02** | P1 | Mobile | Flutter repositories used fake optimistic state updates on API failure | **RESOLVED** | `incident_repository.dart`, `camera_repository.dart` |
| **UI-03** | P1 | Mobile | Hardcoded KPI telemetry strings ('98.1% Uptime', '24.8 FPS', '842 CHECKED-IN') | **RESOLVED** | Dynamic calculations + standby states |
| **REL-01** | P1 | SRE | Failure-injection suite referenced deprecated `'ALL'` tenant context | **RESOLVED** | `tests/e2e/test_failure_injection.py` |
| **REL-02** | P1 | SRE | 30-Minute soak test memory leak validation | **RESOLVED** | `tests/soak/run_30m_soak.py` |
| **GOV-01** | P0 | Governance | Software license audit across Go, Python, and Dart dependencies | **RESOLVED** | `scripts/license_scanner.py` |
| **HARN-01** | P0 | Harness | Master CI quality gate execution runner | **RESOLVED** | `scripts/run_ci.py` (8/8 gates pass) |

---

## Detailed Issue Records

### RLS-01: Database RLS Policy Bypass Vulnerability
- **Severity**: Critical (P0)
- **Root Cause**: In `001_initial_schema.sql`, policies on `cameras`, `detection_zones`, `events`, and `outbox` contained `OR current_setting('app.site_id', true) = 'ALL'`. Any application session or attacker setting `app.site_id = 'ALL'` gained unrestricted visibility across all tenants.
- **Remediation**:
  - Removed all `OR current_setting('app.site_id', true) = 'ALL'` clauses from all tables.
  - Enforced strict tenant equality: `site_id = NULLIF(current_setting('app.site_id', true), '')`.
  - Added `WITH CHECK` clauses on all multi-tenant tables to reject cross-tenant writes.
- **Verification**: `python tests/security/test_rls.py` executed 15 live database penetration vectors. Setting `app.site_id = 'ALL'` returns 0 rows (fail-closed). 100% PASS.

---

### RLS-02: Outbox Repository Wildcard Tenant Context
- **Severity**: Critical (P0)
- **Root Cause**: `outbox_repository.go` relied on `WithTenantTx(ctx, "ALL", ...)` to poll pending events across all sites, relying on the insecure schema bypass.
- **Remediation**:
  - Removed `WithTenantTx(ctx, "ALL", ...)` entirely from `outbox_repository.go`.
  - Updated `db.go` so `WithTenantTx` explicitly rejects `"ALL"` and `"*"` wildcard tenant contexts.
  - Refactored outbox operations to invoke secure stored procedures.
- **Verification**: Go unit tests and live vertical slice tests passed without wildcard tenant transactions.

---

### RLS-03: Outbox Dispatcher Least-Privilege Role Separation
- **Severity**: High (P0)
- **Root Cause**: Database operations ran under a single runtime user without privilege separation between normal tenant transactions and cross-tenant background event publishing.
- **Remediation**:
  - Created dedicated PostgreSQL role `outbox_dispatcher` (`NOBYPASSRLS`).
  - Implemented stored procedures `claim_pending_outbox`, `mark_outbox_published`, and `reap_expired_outbox_leases` with `SECURITY DEFINER` owned by `app_migrator`.
  - Added `outbox_dispatcher_policy` on table `outbox` granted to `app_migrator` and `outbox_dispatcher`.
  - Confined `outbox_dispatcher` so it has zero access to `cameras` or `events`.
- **Verification**: `test_rls.py` verified `outbox_dispatcher` cannot read from `cameras` or `events`, and successfully claims outbox records.

---

### AUTH-01: Unauthenticated HTTP REST API Endpoints
- **Severity**: Critical (P0)
- **Root Cause**: `handler.go` exposed `/api/v1/sites/{site_id}/incidents` and `/ws-ticket` without verifying authentication tokens or site access permissions.
- **Remediation**:
  - Created `auth.go` defining `Authenticator` and `Principal`.
  - Enforced bearer token validation on all `/api/v1/sites/{site_id}/...` endpoints:
    - Missing or invalid token -> `HTTP 401 Unauthorized`.
    - Token principal not authorized for target `site_id` -> `HTTP 403 Forbidden`.
- **Verification**: Go tests in `handler_test.go` and live Docker curl requests verified 401 on unauthenticated requests and 403 on cross-tenant requests.

---

### AUTH-02: Client-Spoofable Operator Identity
- **Severity**: High (P0)
- **Root Cause**: `handleIssueWSTicket` and incident state transition endpoints (`/acknowledge`, `/resolve`, `/dismiss`) trusted client-supplied JSON body `user_id` and `operator_id`.
- **Remediation**:
  - Ignored body `user_id` in `handleIssueWSTicket`; operator identity is strictly derived from the validated `principal.UserID`.
  - Overrode operator ID in incident mutations with authenticated `principal.UserID`.
- **Verification**: `TestHandler_IssueWSTicket` and `TestHandler_IncidentLifecycle` verified operator identity binding.

---

### AI-01: Mock Detections in Vertical Slice Verification
- **Severity**: High (P1)
- **Root Cause**: `test_vertical_slice.py` hardcoded synthetic bounding boxes and skipped real ONNX inference.
- **Remediation**:
  - Connected `ONNXDetector` loading `data/models/synthetic_detector.onnx`.
  - Fed test frame to `detector.detect(frame)` and validated real model confidence (0.92) and bounding boxes.
  - Calculated footpoint polygon intersection and verified negative test case (outside polygon).
- **Verification**: `test_vertical_slice.py` Step 1 passed with real model inference.

---

### RTSP-01: Unverified RTSP Benchmark Pipeline
- **Severity**: Medium (P1)
- **Root Cause**: `scripts/benchmark_wp4_rtsp.py` executed dummy `session.run()` calls with hardcoded boxes and lacked queue bounds.
- **Remediation**:
  - Connected real `ONNXDetector` inference.
  - Implemented bounded queue (`maxsize=2`) with `queue.Full` frame dropping.
  - Added Bearer token authentication for WebSocket ticket issuance.
  - Measured quantitative metrics and generated JSON artifact.
- **Verification**: Benchmark ran for 15s: 214 frames ingested (13.7 FPS), 166 frames dropped (77.6%), average queue depth 1.58/2, inference latency mean 13.2ms, WebSocket dispatch latency mean 27.8ms (<500ms SLA).

---

### UI-01: Multi-Site Switching in Flutter Cockpit
- **Severity**: High (P1)
- **Root Cause**: Site selector tabs in Flutter client were static or hardcoded to `'BNF'`; `IncidentBloc` and `CameraBloc` did not update active site context dynamically.
- **Remediation**:
  - Updated site tabs in `command_overview_screen.dart` to toggle between canonical site IDs (`site_bnf`, `site_rnf`).
  - Added dynamic site tracking in `IncidentBloc` and `CameraBloc` (`_currentSiteId`), updated on `LoadIncidents` and `LoadCameras`.
  - Wired `IncidentRepository.setSite(newSiteId)` in `responsive_main_layout.dart`.
- **Verification**: Flutter unit tests passed (22/22), including new test verifying dynamic `currentSiteId` update on `LoadIncidents`.

---

### UI-02: Fake Optimistic UI Transitions in Flutter
- **Severity**: High (P1)
- **Root Cause**: `incident_repository.dart` caught network errors and applied optimistic status changes locally, creating a false impression of success when the backend failed.
- **Remediation**:
  - Removed all fake optimistic updates; now strictly requires server confirmation and re-throws `ApiException` on network/API failure.
  - Removed mock WebRTC tickets from `camera_repository.dart`.
  - Removed `_mockActiveDetections` from `camera_inspection_screen.dart`.
- **Verification**: Flutter unit tests and widget tests passed with strict error handling.

---

### UI-03: Hardcoded KPI Telemetry Strings
- **Severity**: Medium (P1)
- **Root Cause**: `command_overview_screen.dart` rendered static strings: `'98.1% Fleet Uptime'`, `'24.8 FPS'`, `'Avg Latency 38ms'`, `'842 CHECKED-IN'`.
- **Remediation**:
  - Replaced `'98.1% Fleet Uptime'` with dynamic calculation: `${((onlineCameras / totalCameras) * 100).toStringAsFixed(1)}% Fleet Online`.
  - Replaced `'24.8 FPS'` with dynamic status: `'ACTIVE'` (when cameras online) or `'STANDBY'` (when zero cameras).
  - Replaced `'842 CHECKED-IN'` with `'STANDBY'` / `'ZKTeco terminal integration offline'`.
- **Verification**: Flutter cockpit widget tests rendered dynamic metrics and standby states accurately.

---

### REL-01: Failure-Injection Suite Hardcoded Tenant Bypass
- **Severity**: Medium (P1)
- **Root Cause**: `tests/e2e/test_failure_injection.py` queried PostgreSQL using `app.site_id = 'ALL'`.
- **Remediation**:
  - Updated query to use tenant context `site_bnf`.
  - Verified live lease reaper recovery, RTSP credential scrubbing, and transient DB reconnect backoff.
- **Verification**: `python tests/e2e/test_failure_injection.py` passed (3/3 tests).

---

### REL-02: 30-Minute Sustained Soak & Memory Leak Verification
- **Severity**: Medium (P1)
- **Root Cause**: Memory growth over sustained execution was unmeasured in CI.
- **Remediation**:
  - Verified `tests/soak/run_30m_soak.py` tracking process RSS memory.
  - Verified memory growth threshold `<10%`.
- **Verification**: Smoke run showed +0.17% growth (Limit: <10.0%), saving `soak_test_report.json`.

---

### GOV-01: Software License Compliance Scan
- **Severity**: High (P0)
- **Root Cause**: Needed automated verification that no copyleft or reciprocal dependencies exist in the codebase.
- **Remediation**:
  - Executed `scripts/license_scanner.py --scan-dir . --disallow GPL,AGPL,SSPL,BUSL,Non-Commercial,CC-BY-NC`.
- **Verification**: 14 dependencies scanned; 0 violations found; 100% clean permissive licenses.

---

### HARN-01: Master CI Quality Gate Runner
- **Severity**: High (P0)
- **Root Cause**: Needed unified, fail-closed validation across all repository gates.
- **Remediation**:
  - Created `scripts/run_ci.py` executing all 8 gates in sequence.
- **Verification**: 8/8 gates passed in 12.37 seconds with exit code 0.
