# QUALITY & VERIFICATION STRATEGY
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Quality Assurance, Verification Matrix & Testing Architecture  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & QA Lead  
**Governing Standard:** Section 20 of Ultimate Master Directive (`Prompt.md`), `verification-before-completion`, `test-driven-development`  
**Date:** 2026-11-18  

---

## 1. Quality Engineering Principles & Verification Doctrine

Testing in the Industrial AI Surveillance Platform is engineered directly from the 97 requirements baseline, not retrofitted at the end of development.

### Core Testing Mandates:
1. **The Iron Law (`verification-before-completion`):**
   ```text
   NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
   ```
   Never claim that a test passes, a bug is fixed, or an interface works without executing the exact verification command, reading the complete exit code, and confirming zero failures.
2. **Requirements-to-Test Traceability:** Every one of the 97 SRS requirements maps directly to one or more automated tests or verified manual inspection protocols.
3. **Disjoint Write Scopes (Author vs. Critic):** The Engineer subagent implements application source code, while an independent QA harness author creates the test suite that proves acceptance criteria.
4. **Zero Flakiness Tolerance:** Flaky tests are treated as P0 defects. Socket timeouts, thread contention, and race conditions must be systematically eliminated using mock clocks, deterministic synthetic streams, and isolated database fixtures.
5. **Coverage Is Not Correctness:** 100% statement coverage on trivial getters does not prove product reliability. Quality is evaluated by **edge case survival, failure recovery, security resistance, and memory leak absence**.

---

## 2. 18-Layer Testing Architecture

The verification harness spans 18 distinct testing layers, structured to validate the platform from individual mathematical algorithms up to multi-site disaster recovery:

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 18-LAYER QUALITY ENGINEERING ARCHITECTURE                                                              │
├────┬─────────────────────────────┬────────────────────────────────────────────────────────────────────┤
│ #  │ Testing Layer               │ Scope, Tools & Verification Strategy                               │
├────┼─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ 1  │ Unit Tests                  │ Pure Go & Python domain functions, math, token parsers (go test).  │
│ 2  │ Domain Logic Tests          │ State machine transitions (FR-ALT-008: NEW -> ACK -> RESOLVED).    │
│ 3  │ API Contract Tests          │ Go REST handlers, OpenAPI schema compliance, JSON error models.    │
│ 4  │ Database / RLS Tests        │ PostgreSQL 16 tenant isolation, NOBYPASSRLS, composite FK leaks.   │
│ 5  │ Integration Tests           │ Go edged + PostgreSQL outbox + Python gRPC round-trip.             │
│ 6  │ Camera Ingestion Tests      │ Synthetic RTSP stream pulling, packet loss, reconnection logic.    │
│ 7  │ Video Streaming Tests       │ go2rtc WebRTC SDP proxy offer/answer exchange, H.264 negotiation.  │
│ 8  │ AI Evaluation Tests         │ Precision, recall, mAP on labeled test video datasets.             │
│ 9  │ Event Notification Tests    │ WebSocket ticket handshake, priority fire channel LISTEN dispatch. │
│ 10 │ Frontend Component Tests    │ Flutter widget tests, color token contrast (WCAG 2.1 AA >= 4.5:1). │
│ 11 │ UI Interaction Tests        │ Operator triage workflows, acknowledgment forms, dismissal dialogs.│
│ 12 │ Android Mobile Tests        │ Flutter integration test on simulated Android runtime.             │
│ 13 │ End-to-End Workflow Tests   │ Synthetic frame breach -> Detection -> Outbox -> Push Notification.│
│ 14 │ Load & Capacity Tests       │ 8 concurrent simulated streams, 10 FPS aggregate inference load.   │
│ 15 │ 30-Minute Soak Test         │ Continuous 30m execution; memory leak detection (<10% RSS growth). │
│ 16 │ Failure-Injection Tests     │ Worker SIGKILL recovery, database disconnect, outbox lease reaper. │
│ 17 │ Security Penetration Tests  │ Cross-site RLS injection, unauthenticated WebRTC/WebSocket probes. │
│ 18 │ Backup & Migration Tests    │ pg_dump/restore integrity, goose schema migration forward/rollback.│
└────┴─────────────────────────────┴────────────────────────────────────────────────────────────────────┘
```

---

## 3. Detailed Test Level Specifications & Verification Commands

---

### Layer 1 & 2: Go Backend Domain & State Machine Tests
- **Target:** `backend/internal/domain/` (Incident state transitions, ticket generation, outbox message serialization).
- **Test Command:**
  ```bash
  go test -v -race -coverprofile=coverage.out ./backend/internal/domain/...
  ```
- **Acceptance Criteria:**
  - 100% branch coverage on `FR-ALT-008` incident state machine (`NEW -> ACKNOWLEDGED -> RESOLVED | DISMISSED`).
  - Dismissal without a valid reason string returns `ErrDismissalReasonRequired`.
  - Race detector reports 0 data races (`-race`).

---

### Layer 3: REST API & Error Contract Tests
- **Target:** `backend/internal/api/` (HTTP handlers, middleware, request validation).
- **Test Command:**
  ```bash
  go test -v ./backend/internal/api/...
  ```
- **Acceptance Criteria:**
  - All responses adhere strictly to RFC 7807 Problem Details JSON format.
  - Rate limiter blocks clients after 5 failed login attempts returning `429 Too Many Requests`.
  - Missing or invalid JWT returns `401 Unauthorized`.

---

### Layer 4: PostgreSQL 16 Row-Level Security Penetration Tests
- **Target:** `tests/security/test_rls_isolation.sql` and `tests/security/test_rls.py`.
- **Test Procedure:**
  1. Initialize database with 2 sites: `site_bnf` and `site_rnf`.
  2. Insert cameras and events for both sites using migration role.
  3. Connect as runtime user `app_runtime` with session variable `app.site_id = 'site_bnf'`.
  4. Attempt query: `SELECT * FROM cameras;` -> MUST return only BNF cameras.
  5. Attempt query: `SELECT * FROM events WHERE site_id = 'site_rnf';` -> MUST return 0 rows.
  6. Attempt insert: `INSERT INTO events (site_id, ...) VALUES ('site_rnf', ...);` -> MUST FAIL with policy violation.
  7. Attempt cross-site foreign key injection: `INSERT INTO events (site_id, camera_id) VALUES ('site_bnf', 'camera_rnf_id');` -> MUST FAIL with foreign key violation.
- **Verification Command:**
  ```bash
  python tests/security/test_rls.py --db-url "postgres://app_runtime:pass@localhost:5432/surveillance_dev"
  ```
- **Acceptance Criteria:** 0 cross-site leaks; 100% fail-closed isolation.

---

### Layer 5 & 13: End-to-End Vertical Slice Integration Tests
- **Target:** Full pipeline from synthetic frame generation to WebSocket client delivery.
- **Test Script:** `tests/e2e/test_vertical_slice.py`.
- **Workflow Verified:**
  1. Synthetic video generator generates a 5-second MP4 with an intentional bounding-box intrusion into restricted polygon.
  2. `py-worker` ingests stream, detects person at timestamp `T0`, saves snapshot JPEG to disk, and sends gRPC event to `edged`.
  3. `edged` writes event to `events` table and creates row in `outbox` table within single SQL transaction.
  4. Outbox dispatcher claims row using `SKIP LOCKED`, marks `locked_until = NOW() + 30s`, and pushes payload to connected WebSocket client.
  5. WebSocket test client receives event at timestamp `T1`.
- **Verification Command:**
  ```bash
  python tests/e2e/test_vertical_slice.py
  ```
- **Acceptance Criteria:**
  - Measured end-to-end latency `(T1 - T0) < 500ms`.
  - Snapshot file exists on disk and is readable via authenticated Go endpoint.
  - Incident row created in database with status `NEW`.

---

### Layer 14 & 15: 30-Minute Soak & Memory Leak Detection
- **Target:** All running container processes under sustained 4-channel video processing.
- **Test Script:** `tests/soak/run_30m_soak.py`.
- **Procedure:**
  1. Boot Docker stack with 4 synthetic 360p RTSP camera loops.
  2. Record baseline RSS memory of `edged`, `py-worker`, `postgres`, and `go2rtc` at minute 0 (`RSS_0`).
  3. Run continuous inference and event dispatch for exactly 30 minutes (1,800 seconds).
  4. Record final RSS memory at minute 30 (`RSS_30`).
  5. Calculate growth: `Memory_Growth = (RSS_30 - RSS_0) / RSS_0`.
- **Verification Command:**
  ```bash
  python tests/soak/run_30m_soak.py --duration 1800 --max-growth 0.10
  ```
- **Acceptance Criteria:**
  - `Memory_Growth < 10%` across all services.
  - Zero unhandled Python exceptions or Go panics.
  - Zero dropped camera streams.

---

### Layer 16: Failure-Injection & Crash Recovery Tests
- **Target:** System resilience under ungraceful termination and hardware disconnects.
- **Failure Cases Injected:**
  1. **Worker SIGKILL:** `kill -9` sent to `edged` while outbox rows are in `PROCESSING` state.
     - *Recovery Check:* Upon restart, the lease reaper queries `WHERE status = 'PROCESSING' AND locked_until < NOW()` and successfully dispatches orphaned alerts. Zero duplicate notifications sent.
  2. **RTSP Stream Interruption:** TCP socket to synthetic RTSP camera killed.
     - *Recovery Check:* `py-worker` detects stream loss within 2 seconds, logs credential-scrubbed warning, initiates exponential backoff reconnect, and Go triggers `NFR-OBS-002` Coverage Lost alert after 15 seconds.
  3. **Database Server Restart:** `docker restart postgres`.
     - *Recovery Check:* `edged` connection pool retries with backoff and resumes without crashing.

---

### Layer 17: Security & Supply Chain Scans
- **Target:** All shipped code, dependencies, container images, and model weights.
- **Verification Commands:**
  ```bash
  # 1. Dependency vulnerability audit
  govulncheck ./...
  pip-audit -r services/py-worker/requirements.txt
  
  # 2. License compliance scan (No GPL/AGPL/SSPL)
  python scripts/license_scanner.py --scan-dir . --disallow "GPL,AGPL,SSPL,BUSL,Non-Commercial"
  
  # 3. Secret & credential leak scan
  gitleaks detect --source . --verbose
  ```
- **Acceptance Criteria:**
  - 0 known critical/high vulnerabilities.
  - 0 forbidden reciprocal or non-commercial licenses in runtime artifacts.
  - 0 plaintext credentials or private keys in git history.

---

## 4. Test Execution Master Harness (`Makefile`)

All quality gates are codified into standard, automated `make` commands:

```makefile
.PHONY: all up down ci test test-unit test-rls test-e2e test-soak scan-licenses

up:
	docker compose up -d

down:
	docker compose down

test-unit:
	go test -v -race ./backend/...
	pytest services/py-worker/tests/

test-rls:
	python tests/security/test_rls.py

test-e2e:
	python tests/e2e/test_vertical_slice.py

test-soak:
	python tests/soak/run_30m_soak.py --duration 1800

scan-licenses:
	python scripts/license_scanner.py

# The Mandatory CI Quality Gate
ci: scan-licenses test-unit test-rls test-e2e
	@echo "=== ALL MANDATORY QUALITY GATES PASSED (EXIT 0) ==="
```
