# MASTER ENGINEERING REMEDIATION & EXECUTION PROMPT — INDUSTRIAL AI SURVEILLANCE PLATFORM (BNF / RNF)
**Optimized Specifically For:** `Flash 3.8` inside **Google Antigravity**
**Target Baseline Version:** `1.2.0-flash38-hardened`
**Date:** 2026-11-16
**Execution Mode:** STRICT DETERMINISTIC EXECUTION — ZERO IMPROVISATION

> **OWNER OPERATING INSTRUCTIONS (Read Before Sending to Antigravity):**
> 1. This master prompt is engineered specifically for the **Flash 3.8** model in Google Antigravity. It eliminates high-level ambiguity, prevents partial file edits, resolves the governance deadlock loop, and embeds production-grade security blueprints directly into the execution steps.
> 2. Save this file in your repository root as `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` alongside the `Industrial_AI_Surveillance_Project_Pack/` directory.
> 3. Execute **one phase at a time** by copying and sending the corresponding kickoff command from **Section 0** below (`WP-0.5` -> `WP-1` -> `WP-2` -> `WP-3` -> `WP-4` -> `WP-5` -> `WP-6`).

## 0. DIRECT KICKOFF COMMANDS FOR ANTIGRAVITY (Send One Phase at a Time)

- **Kickoff Command 1 — Phase WP-0.5 (Fix Botched WP-0 Defects & Governance Deadlocks):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-0.5 ONLY** step by step (Steps 0.5.1 through 0.5.7). Do not skip any file, do not improvise, and run every verification script at the end of the phase. Stop immediately after outputting the WP-0.5 Execution Report.

- **Kickoff Command 2 — Phase WP-1 (Apply Architecture Amendments ADR-012..017 & Purge Active Set):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-1 ONLY** step by step (Steps 1.1 through 1.5). Apply every exact replacement and verification check. Stop immediately after outputting the WP-1 Execution Report.

- **Kickoff Command 3 — Phase WP-2 (Workstation Measurement, Repo Skeleton & Hardened Contracts):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-2 ONLY** step by step (Steps 2.1 through 2.6). Stop immediately after outputting the WP-2 Execution Report.

- **Kickoff Command 4 — Phase WP-3 (Empirical Local Benchmark SPK-02-LOCAL):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-3 ONLY** step by step (Steps 3.1 through 3.4). Stop immediately after outputting the WP-3 Execution Report.

- **Kickoff Command 5 — Phase WP-4 (Vertical Slice #1 + All 6 Mandatory Security Blueprints):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-4 ONLY** step by step (Steps 4.1 through 4.7). Enforce all 6 security hardening blueprints verbatim. Stop immediately after outputting the WP-4 Execution Report.

- **Kickoff Command 6 — Phase WP-5 (Unified Flutter Client MVP for Android & Web):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-5 ONLY** step by step (Steps 5.1 through 5.3). Stop immediately after outputting the WP-5 Execution Report.

- **Kickoff Command 7 — Phase WP-6 (Shadow-Mode AI Use Cases One at a Time):**
  > Read `ANTIGRAVITY_FLASH_3_8_MASTER_REMEDIATION_PROMPT.md` completely. Execute **PHASE WP-6 ONLY** step by step (Steps 6.1 through 6.3). Stop immediately after outputting the WP-6 Execution Report.

## 1. SYSTEM DIRECTIVES FOR FLASH 3.8 AGENT (OBEY LITERALLY)

You are executing on **Flash 3.8** inside **Google Antigravity**. Because Flash models optimize for speed, you MUST obey these 10 anti-failure laws without exception:

1. **NO PARTIAL FILE EDITS:** When instructed to remove deprecated technologies (`Valkey`, `TimescaleDB`, `React`, `Vite`, `YOLOv8`, `TensorRT`, `DeepStream`, `MinIO`) from a file, you MUST run `rg -n` on that file before and after editing until `0` active recommendations remain. Never edit only the first occurrence and leave stale sections below it.
2. **NO GOVERNANCE DEADLOCK LOOPS:** `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md` and `docs/governance/CTO_AMENDMENTS.md` are the **Supreme Law** of this repository. Whenever an older file (`PROJECT_HANDOFF.md`, `26_SOURCE_OF_TRUTH...`, `38_DECISION_ID...`, `11_PHASE_PROMPTS.md`) says `"Sprint 1 STRICTLY NOT AUTHORIZED"` or `"ADR-011 = PROPOSED"`, that restriction applies **ONLY to production deployment and real factory hardware**. Local development, Docker containers, Go/Python/Flutter code, and synthetic media benchmarks are **100% AUTHORIZED**. Never halt local development citing a production gate.
3. **NO DUPLICATE APPENDS OR BROKEN CODE FENCES:** Before appending to any log or register (`PROJECT_HANDOFF.md`, `08_ADR_AND_OPEN_QUESTIONS.md`, `CTO_AMENDMENTS.md`), inspect the last 60 lines of the file. Ensure markdown code fences (` ```text ` and ` ``` `) are properly balanced and never duplicate an entry.
4. **NO HALLUCINATED COMPILER/SDK CONSTRAINTS:** Never hardcode unverified compiler or SDK versions (such as `Flutter 3.44.7` or `Python 3.14.4` from historical audit text) into `pubspec.yaml`, `go.mod`, or `Dockerfile` before running `--version` on the actual host/container shell and capturing the real output.
5. **ZERO RAW FRAMES OVER gRPC:** The protobuf contract between Go and Python (`proto/surveillance/v1/events.proto`) MUST NEVER contain `bytes frame_data` or raw pixels. Python decodes RTSP sub-streams directly and sends only normalized events and relative snapshot paths.
6. **MANDATORY POSTGRESQL RLS HARDENING:** In PostgreSQL, table owners bypass Row-Level Security by default unless `FORCE ROW LEVEL SECURITY` is enabled! Every tenant-scoped table MUST have:
   - Composite primary/unique key `(site_id, id)` so child tables enforce same-site foreign keys `FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, id)`.
   - `ALTER TABLE <name> ENABLE ROW LEVEL SECURITY;` AND `ALTER TABLE <name> FORCE ROW LEVEL SECURITY;`.
   - Fail-closed policy: `USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid)`.
7. **CRASH-SAFE LEASE-BASED OUTBOX:** Never mark outbox rows `PROCESSING` without a lease expiration timestamp (`locked_until`). If `edged` crashes mid-dispatch, a background reaper query MUST recover rows where `status = 'PROCESSING' AND locked_until < NOW()`. Fire alerts (`CRITICAL_FIRE`) MUST use a dedicated database connection and `LISTEN outbox_fire` channel bypassing all ordinary batching.
8. **ZERO-TRUST `go2rtc` PROXY (NO `WP-4.5` BLOCK):** Never expose `go2rtc` port `1984` to the host or client. Keep `go2rtc` on the internal Docker network only, and proxy WebRTC SDP Offer/Answer exchange through an authenticated Go endpoint (`POST /api/v1/sites/{site_id}/cameras/{camera_id}/webrtc`) that verifies short-lived HMAC grants and `D-011` video permissions (`security_manager` or `senior_management`).
9. **CREDENTIAL SCRUBBING & SUBPROCESS SAFETY:** In the Python worker, always invoke `ffmpeg` as an argument list (`shell=False`), validate RTSP URLs against a strict allowlist (`^rtsps?://`), and scrub credentials (`re.sub(r'(rtsps?://)([^/@]+@)', r'\1***:***@', text)`) before logging any error or stderr output.
10. **ONE PHASE PER RUN:** Execute ONLY the phase requested by the user, run its mandatory verification script, print the exact output, and STOP.

## 2. SUMMARY OF FORENSIC VULNERABILITIES FIXED BY THIS PROMPT

| ID | Severity | Vulnerability / Defect Discovered in Current Archive (`v1.1.0`) | Exact Fix Enforced in This Prompt |
|---|---|---|---|
| **VULN-01** | **CRITICAL (P0)** | **`PROJECT_HANDOFF.md` Corruption & Self-Contradiction:** WP-0 entry is pasted twice in §H with a broken markdown code fence; §B still claims `"1. Sprint 1: STRICTLY NOT AUTHORIZED"`; §D still marks `DEC-01`, `DEC-02`, `SPK-02`, and `ADR-011` as unapproved; §A says `BNF (Beni Suef)` while `00_READ_ME_FIRST.md` says `BNF in Borg El-Arab`. | **Step 0.5.1 & 0.5.2:** Repairs `PROJECT_HANDOFF.md` §A/§B/§C/§D/§H, fixes the broken fence, removes the duplicate WP-0 block, and reconciles site location metadata. |
| **VULN-02** | **CRITICAL (P0)** | **Governance Precedence Loop in `09_MASTER_OPERATING_PROMPT.md` & `Doc 26`:** `09_MASTER_OPERATING_PROMPT.md` §1 still ranks Documents 01–41 as Tiers 1–3, and `Doc 26` / `Doc 38` still say `DEC-01 AWAITING SIGN-OFF` and `ADR-011 PROPOSED`, causing agents to refuse coding. | **Step 0.5.3 & 0.5.4:** Rewrites `09_MASTER_OPERATING_PROMPT.md` §1 and updates `Doc 26` & `Doc 38` headers to subordinate them to `OWNER_AUTHORIZATION_LOCAL_DEV.md` and `CTO_AMENDMENTS.md`. |
| **VULN-03** | **HIGH (P1)** | **28 Unbannered Stale Files Leaking Banned Tech:** 28 reference/discovery/audit files containing `YOLOv8`, `TensorRT`, `DeepStream`, `MinIO`, `Valkey`, `TimescaleDB`, and `React` were missed during WP-0 `P-03`. | **Step 0.5.5:** Automated Python script prepends the canonical `SUPERSEDED / REFERENCE-ONLY` banner to all 28 missed non-Active-Set files. |
| **VULN-04** | **CRITICAL (P0)** | **Active Set Files Still Prescribe Removed Stack (`WP-1` Missing):** `02_TARGET_ARCHITECTURE.md`, `01_SRS.md`, `08_ADR_AND_OPEN_QUESTIONS.md`, `Doc 30`, `Doc 31`, `Doc 39`, and `11_PHASE_PROMPTS.md` still mandate `React/Vite`, `Valkey`, `TimescaleDB`, and Go frame decoding. | **Phase WP-1 (Steps 1.1–1.5):** Appends `ADR-012..017`, adds `NFR-OBS-002` (97 requirements), and purges all removed stack references across every Active Set file. |
| **VULN-05** | **HIGH (P1)** | **Unverified Toolchain Version Trap (`Flutter 3.44.7` / `Python 3.14.4`):** `TOOLCHAIN_PINS.md` copies unverified host strings that break `pubspec.yaml` and Docker builds if treated as strict SDK constraints. | **Step 0.5.6 & Step 2.1:** Binds `TOOLCHAIN_PINS.md` to empirical shell verification (`flutter --version`, `go version`, `docker --version`) during WP-2. |
| **VULN-06** | **CRITICAL (P0)** | **PostgreSQL RLS Table-Owner Bypass & Cross-Site FK Injection:** Standard RLS fails open if the migration user runs the app (`NOBYPASSRLS` alone is insufficient without `FORCE ROW LEVEL SECURITY`), and single-column foreign keys allow linking a `BNF` event to an `RNF` camera. | **Step 4.1:** Enforces `ENABLE` + `FORCE ROW LEVEL SECURITY`, separate `app_migrator` vs `app_runtime` DB roles, `NULLIF(current_setting('app.site_id', true), '')::uuid`, and composite FKs `(site_id, camera_id)`. |
| **VULN-07** | **CRITICAL (P0)** | **Outbox Zombie Locks on Crash & Fire Alert Head-of-Line Blocking:** Killing `edged` mid-dispatch leaves rows stuck in `PROCESSING` forever or causes duplicate storms; ordinary alerts can delay fire alerts. | **Step 4.4:** Implements lease-based claiming (`locked_until`), expired-lease recovery reaper, per-recipient idempotency keys, and a dedicated fire-priority connection (`LISTEN outbox_fire`). |
| **VULN-08** | **CRITICAL (P0)** | **`go2rtc` Stream Hijacking & NVR Credential Exposure + WebSocket Cross-Site Leak:** Exposing `go2rtc` directly leaks RTSP credentials and bypasses `D-011` RBAC; JWTs in WebSocket URLs leak in logs and lack site binding. | **Step 4.2 & Step 4.5:** Implements single-use site-bound WebSocket tickets (`POST /api/v1/sites/{site_id}/ws-ticket`) and a Go Zero-Trust WebRTC SDP Proxy hiding `go2rtc` inside the internal Docker network. |
| **VULN-09** | **HIGH (P1)** | **Python Worker RTSP Command Injection, Credential Log Leak & Path Traversal:** Unvalidated RTSP URLs in `ffmpeg`, plaintext passwords in error tracebacks, unauthenticated gRPC, and arbitrary snapshot file paths. | **Step 4.3:** Enforces gRPC shared-secret interceptor, `shell=False`, strict `rtsp://` validation, regex credential scrubbing, and site-jailed snapshot storage. |

## PHASE WP-0.5 — HOTFIX BOTCHED WP-0 DEFECTS & GOVERNANCE DEADLOCKS
**Branch:** `wp-0.5-pack-hotfix`
**Scope:** Documentation and manifest repair inside `Industrial_AI_Surveillance_Project_Pack/` (and workspace root mirror `PROJECT_HANDOFF.md`). Zero code installs.

### Step 0.5.1 — Reconcile Factory Location Metadata in `00_READ_ME_FIRST.md`
In `Industrial_AI_Surveillance_Project_Pack/00_READ_ME_FIRST.md` §1, replace `(BNF in Borg El-Arab and RNF in Sadat City)` with `(BNF and RNF manufacturing facilities, treated as operationally independent sites per D-001)` so no unconfirmed city name contradicts `PROJECT_HANDOFF.md`.

### Step 0.5.2 — Fix Corrupted History Fence & Contradictions in `PROJECT_HANDOFF.md`
Update `Industrial_AI_Surveillance_Project_Pack/PROJECT_HANDOFF.md` (and copy the finished file verbatim to workspace root `PROJECT_HANDOFF.md` if present):
1. In the header block, change:
   `Current Operating Mode: STRICT READ-ONLY / AUDIT & GOVERNANCE COMPLETED / ZERO IMPLEMENTATION`
   to:
   `Current Operating Mode: LOCAL-DEV SIMULATION AUTHORIZED (PER OWNER_AUTHORIZATION_LOCAL_DEV.md) / PRODUCTION BLOCKED`
2. In **Section A**, change `Last Verified Commit SHA` note from `(Git repository not yet initialized; Sprint 1 NOT AUTHORIZED)` to `(Local-dev sprints AUTHORIZED per OWNER_AUTHORIZATION_LOCAL_DEV.md; production deployment NOT AUTHORIZED)`.
3. In **Section B**, under `Explicitly Blocked & Not Yet Authorized Activities -> 1. Sprint 1`, replace:
   `- STRICTLY NOT AUTHORIZED until the required owner decisions, ADR-011 approval, and implementation gates are formally approved.`
   with:
   `- Local development sprints (WP-1 through WP-6 on synthetic/public data) are AUTHORIZED per docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md. Production deployment and real factory device/data access remain STRICTLY NOT AUTHORIZED.`
4. In **Section C** (`Phase Progress Table`), update `SPK-02`, `Phase 1`, and `Phase 2..7` status descriptions to note: `LOCAL-DEV SIMULATION AUTHORIZED (via WP-1..WP-6); PRODUCTION BLOCKED`.
5. In **Section D** (`MASTER GOVERNANCE & DECISION REGISTER`), update the statuses to match `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`:
   - `DEC-01`: `APPROVED (Local-Dev Baseline as amended by CTO_AMENDMENTS.md)`
   - `DEC-02`: `APPROVED AS FLUTTER WEB (per ADR-014; React removed)`
   - `SPK-02`: `SPK-02-LOCAL APPROVED (Workstation synthetic/public media only)`
   - `ADR-011`: `APPROVED AS AMENDED (by ADR-012 .. ADR-017)`
   - Keep `DEC-03`, `DEC-04`, `DEC-05`, `DEC-06`, `DEC-08` and `SPK-01`, `SPK-03`, `SPK-04` (real devices) marked `BLOCKED / NOT AUTHORIZED`.
6. In **Section H** (`Append-Only Progress History`), remove the duplicate early copy of `Phase / Task: WP-0 — Repair the Pack` that broke the markdown code fence before `Phase / Task: Audit Issue Remediation & Manifest Integration of PROJECT_HANDOFF.md`, ensure there is only ONE ` ```text ` opening fence at the start of Section H and ONE ` ``` ` closing fence at the very end of Section H, keep the chronological order (`2026-11-11` -> `2026-11-14` -> `2026-11-16 Final Governance` -> `2026-11-16 Audit Issue Remediation` -> `2026-11-16 WP-0`), and append one new entry at the bottom inside the fence for `WP-0.5 — Pack Hotfix & Governance Deadlock Resolution`.

### Step 0.5.3 — Eliminate Precedence Deadlock in `antigravity/09_MASTER_OPERATING_PROMPT.md`
In `Industrial_AI_Surveillance_Project_Pack/antigravity/09_MASTER_OPERATING_PROMPT.md`, replace **Section 1 (`## 1. Source of truth and Precedence Hierarchy`)** down to `## 2. Absolute anti-hallucination rules` with this exact text:

```markdown
## 1. Source of truth and Precedence Hierarchy

The Active Set listed in [00_READ_ME_FIRST.md](../00_READ_ME_FIRST.md) is the sole binding technical foundation. All other files in the pack are strictly reference-only.

When any specification or status table conflicts, resolve strictly in this order:
1. **Tier 1 (Supreme Governance & Local-Dev Authorization):** [OWNER_AUTHORIZATION_LOCAL_DEV.md](../docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md) and [CTO_AMENDMENTS.md](../docs/governance/CTO_AMENDMENTS.md) (including ADR-012 through ADR-017).
2. **Tier 2 (Canonical Numbers & Toolchain Baseline):** [CANONICAL_NUMBERS.md](../docs/governance/CANONICAL_NUMBERS.md), [TOOLCHAIN_PINS.md](../docs/governance/TOOLCHAIN_PINS.md), [WORKSTATION_PROFILE.md](../docs/governance/WORKSTATION_PROFILE.md), and [MODEL_REGISTER.md](../docs/ai/MODEL_REGISTER.md).
3. **Tier 3 (Core Requirements & Architecture):** [01_SRS.md](../requirements/01_SRS.md), [09_REQUIREMENTS_TRACEABILITY.csv](../planning/09_REQUIREMENTS_TRACEABILITY.csv), [02_TARGET_ARCHITECTURE.md](../architecture/02_TARGET_ARCHITECTURE.md), and [08_ADR_AND_OPEN_QUESTIONS.md](../planning/08_ADR_AND_OPEN_QUESTIONS.md).
4. **Tier 4 (Remaining Active Set Specifications):** [00_PROJECT_CHARTER.md](../00_PROJECT_CHARTER.md), [03_INTEGRATION_AND_DATA_SPEC.md](../integrations/03_INTEGRATION_AND_DATA_SPEC.md), [04_VIDEO_AI_SPEC.md](../ai/04_VIDEO_AI_SPEC.md), [05_SECURITY_PRIVACY_AND_ACCESS.md](../security/05_SECURITY_PRIVACY_AND_ACCESS.md), and Active Set discovery documents (`28`, `30`, `38`, `39`).

All statements and claims MUST strictly adhere to the 9-tier provenance system:
- `OWNER_CONFIRMED_REQUIREMENT`
- `OWNER_REPORTED_ENVIRONMENT_FACT`
- `OBSERVED_IN_REPOSITORY`
- `VERIFIED_OFFICIAL_SOURCE`
- `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`
- `MEASURED_IN_POC`
- `PROPOSED`
- `UNKNOWN`
- `BLOCKED`

Never turn PROPOSED/UNKNOWN/BLOCKED into CONFIRMED without explicit approval or measured empirical evidence.
```

Also in `antigravity/09_MASTER_OPERATING_PROMPT.md` **Section 9 (`## 9. Execution protocol`)**, replace the first paragraph with:
```markdown
Work strictly in the Work Package order (`WP-0.5` -> `WP-1` -> `WP-2` -> `WP-3` -> `WP-4` -> `WP-5` -> `WP-6`) governed by [OWNER_AUTHORIZATION_LOCAL_DEV.md](../docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md) and [CTO_AMENDMENTS.md](../docs/governance/CTO_AMENDMENTS.md). Stop after completing each Work Package and wait for explicit owner approval before starting the next Work Package.
```

### Step 0.5.4 — Synchronize Governance Headers in `Doc 26` and `Doc 38`
1. In `Industrial_AI_Surveillance_Project_Pack/docs/discovery/26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md`, prepend directly below the title:
   ```markdown
   > **AMENDMENT NOTICE (2026-11-16):** This document is subordinate to [00_READ_ME_FIRST.md](../../00_READ_ME_FIRST.md), [OWNER_AUTHORIZATION_LOCAL_DEV.md](../governance/OWNER_AUTHORIZATION_LOCAL_DEV.md), and [CTO_AMENDMENTS.md](../governance/CTO_AMENDMENTS.md). Where this document lists `DEC-01` as awaiting sign-off or `ADR-011` as proposed, `OWNER_AUTHORIZATION_LOCAL_DEV.md` supersedes it for local development (`DEC-01` accepted as amended, `ADR-011` approved as amended by `ADR-012..017`, `DEC-02` approved as Flutter Web, `SPK-02-LOCAL` approved).
   ```
2. In `Industrial_AI_Surveillance_Project_Pack/docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md`, prepend the exact same `> **AMENDMENT NOTICE (2026-11-16):** ...` block directly below the title.

### Step 0.5.5 — Banner All Remaining Unbannered Non-Active-Set Files
Run this exact Python script from `Industrial_AI_Surveillance_Project_Pack/` to prepend the canonical `SUPERSEDED / REFERENCE-ONLY` banner to every non-Active-Set `.md` file that still lacks it:

```python
import os, glob

ACTIVE_SET = {
    "00_READ_ME_FIRST.md",
    "00_PROJECT_CHARTER.md",
    "PROJECT_HANDOFF.md",
    "README_AR.md",
    "requirements/01_SRS.md",
    "planning/08_ADR_AND_OPEN_QUESTIONS.md",
    "architecture/02_TARGET_ARCHITECTURE.md",
    "integrations/03_INTEGRATION_AND_DATA_SPEC.md",
    "ai/04_VIDEO_AI_SPEC.md",
    "security/05_SECURITY_PRIVACY_AND_ACCESS.md",
    "docs/discovery/26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md",
    "docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md",
    "docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md",
    "docs/discovery/31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md",
    "docs/discovery/33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md",
    "docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md",
    "docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md",
    "docs/discovery/44_CURRENT_PACKAGE_INVENTORY_AND_SHA256_MANIFEST.md",
    "antigravity/09_MASTER_OPERATING_PROMPT.md",
    "antigravity/11_PHASE_PROMPTS.md",
    "docs/ai/MODEL_REGISTER.md",
    "docs/governance/CANONICAL_NUMBERS.md",
    "docs/governance/CTO_AMENDMENTS.md",
    "docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md",
    "docs/governance/TOOLCHAIN_PINS.md",
    "docs/governance/WORKSTATION_PROFILE.md",
}

BANNER = (
    "> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. "
    "Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. "
    "Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), "
    "capacity sizing, \"VERIFIED_BY_EXECUTION\" labels, Docker Desktop/Go 1.22 LTS claims.\n\n"
)

bannered = []
for f in sorted(glob.glob("**/*.md", recursive=True)):
    rel = f.replace("\\", "/")
    if rel in ACTIVE_SET:
        continue
    content = open(f, "r", encoding="utf-8").read()
    if "SUPERSEDED / REFERENCE-ONLY" not in content[:400]:
        with open(f, "w", encoding="utf-8") as out:
            out.write(BANNER + content)
        bannered.append(rel)

print(f"Newly bannered files: {len(bannered)}")
for b in bannered:
    print(" -", b)
```

### Step 0.5.6 — Harden `docs/governance/TOOLCHAIN_PINS.md` Against Unverified Host Version Strings
Append this mandatory rule to `Industrial_AI_Surveillance_Project_Pack/docs/governance/TOOLCHAIN_PINS.md`:
```markdown
## 2. Host Version Verification Rule (Anti-Failure Guardrail for WP-2 & WP-5)
- Host strings reported in historical audit tables (such as `Flutter 3.44.7`, `Python 3.14.4`, `Node.js 24.15.0`, `Docker Desktop 29.8.0`) are tagged `OWNER_REPORTED_ENVIRONMENT_FACT (to be re-measured in WP-2)`.
- Before writing `go.mod`, `pubspec.yaml`, or `Dockerfile`, the agent MUST execute `go version`, `flutter --version`, `python3 --version`, and `docker --version` in the shell and set the SDK constraint in `pubspec.yaml` (`environment: sdk: ...`) to match the **actual** installed Dart/Flutter SDK version on the machine. Never hardcode an unverified SDK constraint that causes `flutter pub get` to fail.
```

### Step 0.5.7 — Regenerate `MANIFEST.sha256` and Run Verification
1. Copy the updated `Industrial_AI_Surveillance_Project_Pack/PROJECT_HANDOFF.md` to workspace root `PROJECT_HANDOFF.md` (if workspace root has a mirror copy).
2. Recompute `Industrial_AI_Surveillance_Project_Pack/MANIFEST.sha256` for all 110 payload files inside `Industrial_AI_Surveillance_Project_Pack/`:
   ```python
   import os, hashlib
   pack_dir = "."
   entries = []
   for root, _, files in os.walk(pack_dir):
       for f in files:
           rel = os.path.relpath(os.path.join(root, f), pack_dir).replace(os.sep, "/")
           if rel == "MANIFEST.sha256":
               continue
           h = hashlib.sha256(open(os.path.join(root, f), "rb").read()).hexdigest().upper()
           entries.append((rel, h))
   entries.sort(key=lambda x: x[0])
   with open("MANIFEST.sha256", "w", encoding="utf-8") as out:
       for rel, h in entries:
           out.write(f"{h}  {rel}\n")
   print("Wrote MANIFEST.sha256 entries:", len(entries))
   ```
3. Run `python3 -I verify_archive_manifest.py` (must exit `0` with `110/110 PASSED`) and run the link checker script (must output `broken 0`).
4. Output the report in the format of Section 8 and **STOP**.

## PHASE WP-1 — ARCHITECTURE AMENDMENTS (`ADR-012..017`) & ACTIVE SET PURGE
**Branch:** `wp-1-adr-amendments`
**Scope:** Documentation only. Mutates `planning/08_ADR_AND_OPEN_QUESTIONS.md`, `docs/governance/CTO_AMENDMENTS.md`, `architecture/02_TARGET_ARCHITECTURE.md`, `requirements/01_SRS.md`, `planning/09_REQUIREMENTS_TRACEABILITY.csv`, `docs/governance/CANONICAL_NUMBERS.md`, `docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md`, `docs/discovery/31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md`, `docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md`, `antigravity/11_PHASE_PROMPTS.md`, `PROJECT_HANDOFF.md`, and `MANIFEST.sha256`.

### Step 1.1 — Append `ADR-012` through `ADR-017` Verbatim and Update `ADR-011`
1. In `planning/08_ADR_AND_OPEN_QUESTIONS.md`:
   - Change `ADR-011` status line from `- Status: PROPOSED — PENDING OWNER APPROVAL.` to:
     `- Status: APPROVED AS AMENDED (by ADR-012 through ADR-017 in docs/governance/CTO_AMENDMENTS.md; Valkey, TimescaleDB, and React/Vite removed).`
   - Directly below `ADR-011`, append `ADR-012` through `ADR-017` using the exact text below.
2. In `docs/governance/CTO_AMENDMENTS.md`, replace `## 2. ADR texts: see WP-1` with `## 2. Approved Architecture Amendments (ADR-012 … ADR-017)` followed by the exact same six ADRs:

```markdown
### ADR-012 — The AI worker owns video decode and inference
- **Status:** APPROVED (local-dev)
- **Context:** Go has no native production video decoder; sending raw frames Go→Python over gRPC costs CPU/RAM and bandwidth.
- **Decision:** The Go core never decodes video. The Python worker pulls each camera's *sub-stream* (credentials supplied by Go at config time, never logged), decodes it with an `ffmpeg` subprocess (with `shell=False` and strict `rtsp://` validation), applies a fixed-rate sampler, keeps a **bounded latest-frame queue (size 1–2, drops counted)** per camera, runs ONNX inference, tracking, and rule evaluation, and sends **only events + a relative JPEG evidence snapshot reference** to Go via versioned gRPC (with idempotency key per event and shared-secret metadata authentication). Go owns camera/zone/policy configuration, scheduling, health, persistence, and alerts. Transport: gRPC over TCP `127.0.0.1` (or internal Docker network; no Unix sockets).
- **Consequences:** Go↔Python traffic is tiny; one worker process serves $N$ cameras where $N$ is MEASURED in WP-3; the `.proto` file must contain zero frame/pixel messages.

### ADR-013 — Minimal data plane (PostgreSQL 16 only)
- **Status:** APPROVED (local-dev)
- **Decision:** PostgreSQL 16 only. Outbox = table with `priority`, `status`, `attempts`, `next_attempt_at`, `locked_until` (lease timestamp for crash recovery), and unique `idempotency_key`; dispatch with `FOR UPDATE SKIP LOCKED` + `LISTEN/NOTIFY`. Fire-priority rows (`CRITICAL_FIRE`) are served by a dedicated goroutine with its own connection listening on `NOTIFY outbox_fire` with zero batching/throttling. Events table uses native monthly partitioning. **Valkey and TimescaleDB are removed from the baseline** (re-introduce only through a new ADR citing a measured limit).
- **Consequences:** Two fewer services, no Timescale License question, lower RAM footprint.

### ADR-014 — One client codebase (Flutter Android + Flutter Web)
- **Status:** APPROVED (local-dev)
- **Decision:** Flutter (Dart) for the Android manager app AND the administration console (Flutter Web build, desktop browser). **React/Vite is removed from the baseline.** State management uses `flutter_bloc` (Cubit/Bloc). Zone editor = `CustomPainter` polygon editor. Live view = WebRTC via `go2rtc` fronted by the Go Zero-Trust SDP Proxy (`flutter_webrtc` after license check). Charts = in-app vector charts (`fl_chart` after license check).
- **Consequences:** 3 languages total (Go, Python, Dart); zero duplicated DTO/API client code across mobile and web.

### ADR-015 — Runtime environment
- **Status:** APPROVED (local-dev)
- **Decision:** Develop inside WSL2 Ubuntu LTS; run containers with Docker Engine (`docker-ce`, Apache-2.0) inside WSL2, **not Docker Desktop**, unless the owner confirms the company qualifies for the free tier. `%USERPROFILE%\.wslconfig`: `memory=5GB`, `processors=6`, `swap=6GB` with the swap file on `D:`. Keep project files and volumes inside the WSL2 `ext4` filesystem (not `/mnt/d`). Production target: Ubuntu Server LTS. Windows 10 is past end of support: treat the workstation as a dev box only; never expose it to the factory network. The Android emulator is forbidden; use a physical phone over USB.

### ADR-016 — Inference runtime
- **Status:** APPROVED (local-dev)
- **Decision:** The deployed worker image contains ONNX Runtime + OpenCV/NumPy only (no PyTorch). Models are exported to ONNX in a separate offline `model-export` environment; every model artifact is stored with source commit, SHA-256, and a `MODEL_REGISTER.md` row. CPU is the mandatory baseline; `onnxruntime-gpu` (CUDA) is optional and enabled only if WP-3 proves it works on the Quadro P600 with the pinned driver/CUDA/cuDNN — otherwise CPU only. TensorRT, DeepStream, Ultralytics, pyzk, and MinIO stay excluded. Models use FP32 on the P600.

### ADR-017 — Notification channel port & coverage-lost operational alert
- **Status:** APPROVED (local-dev)
- **Decision:** `NotificationChannel` port with adapters: (1) `WebSocketChannel` (in-app, default, authenticated via single-use site-bound ticket), (2) `FcmChannel` (implemented, **disabled** until DEC-08; payload = event id + generic text only: no names, no images, no site-sensitive details), (3) `NtfyChannel` (self-hosted ntfy/UnifiedPush, Apache-2.0/GPL check required before use — if its server license is copyleft, run it only as a separate unmodified process and record the legal note) as a Google-free fallback candidate. Android client: foreground service for the socket plus a documented battery-optimization exemption step; test on the physical phone with screen off for 30 min. Additionally, the platform MUST raise an **operational alert ("coverage lost", `NFR-OBS-002`)** to configured admins when a camera stream or a worker heartbeat is missing for a configurable time — a silent blind spot is a safety defect.
```

### Step 1.2 — Purge Contradictions in `architecture/02_TARGET_ARCHITECTURE.md`
Edit `Industrial_AI_Surveillance_Project_Pack/architecture/02_TARGET_ARCHITECTURE.md` so it aligns 100% with `ADR-012`..`ADR-017`:
1. **Section 2.3 (`Canonical Programming Language Strategy`)**:
   - Combine items 3 and 4 into a single unified client item:
     `3. **Unified Client Application (Android Manager App & Desktop Web Admin Console) — FLUTTER / DART (per ADR-014):** Single codebase targeting Android handhelds and desktop browsers (Flutter Web). React/TypeScript/Vite is removed from the baseline.`
2. **Section 3 (`Logical context` ASCII diagram)**:
   - Replace `Desktop Web Admin Console (React)` with `Desktop Web Admin Console (Flutter Web, ADR-014)`.
   - Remove `- Local Valkey Queue` from both `BNF Factory Edge` and `RNF Factory Edge` boxes and replace with `- PostgreSQL 16 (RLS + Outbox SKIP LOCKED, ADR-013)`.
   - Change the arrow between `Factory Edge` and `Python AI Workers` to indicate: `Python AI Workers pull RTSP sub-streams directly via FFmpeg and send only events + snapshot refs to Go Edge over gRPC (127.0.0.1 TCP, ADR-012)`.
3. **Section 4 (`Deployment boundaries`)**:
   - In `BNF site plane` and `RNF site plane`, replace `event store, queue, cache, and monitoring` with `PostgreSQL 16 event store and transactional outbox (no Valkey or TimescaleDB per ADR-013)`.
4. **Section 7 (`AI Frame Ingestion Backpressure and Drop Policy`)**:
   - Replace `The Go edge component shall enforce bounded memory usage for AI frame dispatch.` with:
     `Per ADR-012, the Go core never decodes or dispatches video frames. The Python AI worker pulls camera sub-streams directly via FFmpeg, decodes frames, and enforces a bounded latest-frame queue (size 1–2 per camera, with dropped frames counted and exposed via metrics). Only normalized events and relative JPEG snapshot references cross the gRPC boundary to Go.`
5. **Section 8 (`Data and storage principles`)**:
   - Under `Database Engine`: Replace the TimescaleDB sentence with: `Per ADR-013, PostgreSQL 16 is the sole database engine using native monthly table partitioning and transactional outbox (FOR UPDATE SKIP LOCKED + LISTEN/NOTIFY). TimescaleDB is removed from the baseline.`
   - Under `In-Memory Store`: Replace the Valkey paragraph with: `Per ADR-013, Valkey is removed from the baseline. Queueing and pub/sub dispatch use PostgreSQL 16 transactional outbox with SKIP LOCKED and LISTEN/NOTIFY.`
6. **Section 11 (`Canonical multi-language repository structure`)**:
   - In `backend/internal/infrastructure/`, change comment to `# PostgreSQL 16 (RLS + Outbox), go2rtc proxy, ZKTeco/NVR adapters`.
   - Remove the entire `web-admin/` directory block from the tree.
   - Update `mobile-app/` comment to `# Unified Client: Android Manager App + Flutter Web Admin Console (FLUTTER / DART, ADR-014)`.

### Step 1.3 — Add `NFR-OBS-002` and Update `FR-WEB-001` in `01_SRS.md`, `09_REQUIREMENTS_TRACEABILITY.csv`, and `CANONICAL_NUMBERS.md`
1. In `requirements/01_SRS.md`:
   - In `FR-WEB-001` (§4.9), replace `(React / TypeScript / Vite)` with `(Flutter Web per ADR-014; React/Vite removed)` and change priority/status note to reflect `APPROVED (local-dev per OWNER_AUTHORIZATION_LOCAL_DEV.md & ADR-014)`.
   - In **Section 5 (`Non-functional requirements`)**, directly after `NFR-OBS-001`, insert row `NFR-OBS-002`:
     `| NFR-OBS-002 | The platform shall detect missing camera streams or missing AI worker heartbeats exceeding a configurable timeout and raise an auditable "coverage lost" operational alert to configured administrators (ADR-017). | MUST (PROPOSED_LOCAL_DEV); fault-injection test |`
2. In `planning/09_REQUIREMENTS_TRACEABILITY.csv`:
   - Append a 97th row for `NFR-OBS-002` matching the exact CSV column structure, with Status set to `PROPOSED_LOCAL_DEV` and traced to `ADR-017` and `architecture/02_TARGET_ARCHITECTURE.md`.
3. In `docs/governance/CANONICAL_NUMBERS.md`:
   - Update the `Requirements` row from `96 = 78 FR + 18 NFR` to `97 = 78 FR + 19 NFR (including NFR-OBS-002 added in WP-1 per ADR-017)`.

### Step 1.4 — Purge `Valkey` and `TimescaleDB` from Active Set Discovery Specs (`Doc 30`, `Doc 31`, `Doc 39`, and `11_PHASE_PROMPTS.md`)
1. In `docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md` (§4.2 Scenario 4):
   - Replace `Event stream buffered in Valkey.` and `Worker resumes consumption from Valkey Streams checkpoint` with `Python worker reconnects to RTSP sub-stream and sends events to Go PostgreSQL 16 Outbox (per ADR-012 & ADR-013; Valkey removed).`
2. In `docs/discovery/31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md` (§6 Action Item):
   - Replace `PostgreSQL TimescaleDB rollup queries` with `PostgreSQL 16 native partitioned rollup queries (TimescaleDB removed per ADR-013)`.
3. In `docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md` (§2 table row 4):
   - Replace `4. Broker Enqueue (Valkey) | 5 – 15 ms | Candidate Valkey high-priority fire queue.` with `4. Outbox Notify (PostgreSQL LISTEN/NOTIFY) | 5 – 15 ms | Dedicated PostgreSQL fire-priority connection (ADR-013; Valkey removed).`
4. In `antigravity/11_PHASE_PROMPTS.md` (Phase 2 and Phase 5):
   - Replace all mentions of `Valkey` with `PostgreSQL 16 Outbox (SKIP LOCKED + LISTEN/NOTIFY per ADR-013)`.

### Step 1.5 — Update `PROJECT_HANDOFF.md` and Regenerate `MANIFEST.sha256`
1. Append a `WP-1 — Architecture Amendments (ADR-012..017)` entry to `PROJECT_HANDOFF.md` §H, and sync the root mirror if present.
2. Regenerate `MANIFEST.sha256` and update `docs/discovery/44_CURRENT_PACKAGE_INVENTORY_AND_SHA256_MANIFEST.md` if any file counts changed.
3. Run these verification checks and require 100% pass:
   - `python3 -I verify_archive_manifest.py` -> `PASSED` (exit 0).
   - Link check script -> `broken 0`.
   - Active Set banned-tech check: verify `architecture/02_TARGET_ARCHITECTURE.md`, `docs/discovery/30_*`, `31_*`, `39_*` have zero active recommendations for `Valkey`, `TimescaleDB`, or `React`.
   - CSV check: `97` rows in `planning/09_REQUIREMENTS_TRACEABILITY.csv` matching the `97` requirement IDs in `requirements/01_SRS.md`.
4. Output the WP-1 Execution Report and **STOP**.

## PHASE WP-2 — WORKSTATION MEASUREMENT, REPO SKELETON & HARDENED CONTRACTS
**Branch:** `wp-2-skeleton`
**Scope:** Measure real host environment, configure WSL2/Docker limits, create repository directory structure, define versioned gRPC `.proto` contract (zero raw pixels), create hardened `deploy/docker-compose.local.yml`, generate synthetic RTSP test clips, and pass `make ci` on the skeleton.

### Step 2.1 — Measure Real Workstation & Toolchains (Zero Guessing)
Run actual shell commands to capture:
- OS & WSL version (`uname -a`, `cat /etc/os-release`)
- CPU & RAM (`lscpu`, `free -m`)
- Disk free space (`df -h`)
- GPU status (`nvidia-smi` — max 2 attempts; if unavailable or failing in container, record `CPU baseline only per ADR-016` and proceed immediately)
- Installed toolchains (`go version`, `python3 --version`, `flutter --version`, `docker --version`, `ffmpeg -version`)
Update `docs/governance/WORKSTATION_PROFILE.md` and `docs/governance/TOOLCHAIN_PINS.md` with the exact `MEASURED` outputs, dates, and commands.

### Step 2.2 — Create Canonical Repository Skeleton (ADR-014 Applied — No `web-admin/`)
Create the following directory layout at the repository root:
```text
proto/
  buf.yaml
  buf.gen.yaml
  surveillance/v1/
    events.proto
backend/
  go.mod
  cmd/
    edged/main.go
  internal/
    domain/
    application/
    infrastructure/
      postgres/
        migrations/
      go2rtc/
      grpcserver/
      outbox/
    presentation/
      httpapi/
      ws/
ai-workers/
  pyproject.toml
  worker/
    __init__.py
    config.py
    decoder.py
    detector.py
    tracker.py
    rules.py
    grpc_client.py
    main.py
  tests/
mobile-app/
  pubspec.yaml
  lib/
    core/
    features/
  test/
deploy/
  docker-compose.local.yml
  postgres/
    init-roles.sh
  go2rtc/
    go2rtc.yaml
  mediamtx/
    mediamtx.yml
tests/
  arch_test.go
data/
  SOURCES.md
Makefile
.env.example
.gitignore
```

### Step 2.3 — Write the Versioned gRPC Contract (`proto/surveillance/v1/events.proto`)
Write `proto/surveillance/v1/events.proto` with **ZERO frame or pixel fields** (enforcing `ADR-012`):
```protobuf
syntax = "proto3";
package surveillance.v1;
option go_package = "github.com/industrial-ai/surveillance/backend/internal/infrastructure/grpcserver/pb;pb";

service EdgeIngestionService {
  rpc SubmitEvent(SubmitEventRequest) returns (SubmitEventResponse);
  rpc SendHeartbeat(HeartbeatRequest) returns (HeartbeatResponse);
}

message SubmitEventRequest {
  string schema_version = 1;
  string event_id = 2;              // Deterministic UUIDv5 or UUIDv4 idempotency key
  string site_id = 3;               // Mandatory site UUID (BNF or RNF)
  string camera_id = 4;
  string zone_id = 5;
  string event_type = 6;            // e.g., "restricted_zone.entry.detected", "fire.suspected"
  string severity = 7;              // "INFO", "WARNING", "CRITICAL", "CRITICAL_FIRE"
  int64 occurred_at_utc_ms = 8;
  int64 received_at_utc_ms = 9;
  string model_id = 10;
  string model_version = 11;
  string rule_id = 12;
  string rule_version = 13;
  float confidence = 14;
  string snapshot_rel_path = 15;    // Strict format: "<site_id>/<yyyy>/<mm>/<dd>/<event_id>.jpg"
  string subject_status = 16;       // Always "UNKNOWN_PERSON" or "UNCONFIRMED_OBJECT" in local MVP
}

message SubmitEventResponse {
  bool accepted = 1;
  bool duplicate = 2;
  string status_message = 3;
}

message HeartbeatRequest {
  string worker_id = 1;
  string site_id = 2;
  int64 timestamp_utc_ms = 3;
  repeated CameraStreamHealth camera_streams = 4;
}

message CameraStreamHealth {
  string camera_id = 1;
  bool online = 2;
  double fps_decoded = 3;
  uint64 dropped_frames = 4;
  int64 last_frame_utc_ms = 5;
}

message HeartbeatResponse {
  bool ok = 1;
}
```

### Step 2.4 — Create Hardened `deploy/docker-compose.local.yml` with Least-Privilege DB Roles & Internal-Only `go2rtc`
Create `deploy/postgres/init-roles.sh` so PostgreSQL initializes two separate roles:
- `app_migrator` (runs schema migrations and owns tables)
- `app_runtime` (`NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS` — used by `edged` at runtime so PostgreSQL RLS policies cannot be bypassed by table ownership!).

Create `deploy/docker-compose.local.yml` enforcing:
- `postgres:16.6-alpine`: `mem_limit: 512m`, command `postgres -c shared_buffers=128MB -c max_connections=50`, bound to `127.0.0.1:5432:5432`.
- `mediamtx`: `mem_limit: 128m`, internal network + `127.0.0.1:8554:8554`.
- `go2rtc`: `mem_limit: 128m`, **NO host port published for `1984`** (`expose: ["1984"]` on internal Docker bridge network only so clients cannot bypass `edged` RBAC!), WebRTC media port `127.0.0.1:8555:8555`.
- `camsim`: `mem_limit: 512m`, loops synthetic MP4 streams via `ffmpeg -re -stream_loop -1` into `mediamtx`.
- `edged`: `mem_limit: 256m`, connects to PostgreSQL strictly as `app_runtime`, exposes REST/WS on `127.0.0.1:8080:8080` and gRPC on internal network `:50051`.
- `ai-worker`: `mem_limit: 1536m`, Python 3.11 + ONNX Runtime CPU (`onnxruntime==1.20.1`, `opencv-python-headless`, `numpy`, `grpcio`, **zero PyTorch**).

### Step 2.5 — Generate Synthetic Test Media (`data/`)
Use `ffmpeg -f lavfi -i testsrc=duration=15:size=640x360:rate=10` (and a moving synthetic box simulating a person entering a restricted polygon) to generate synthetic MP4 test clips in `data/synthetic/`, record their exact generation commands, license (`Public Domain / Synthetic Generated`), and SHA-256 hashes in `data/SOURCES.md`.

### Step 2.6 — Add Architecture Boundary Test (`tests/arch_test.go`) and `Makefile`
1. Write `tests/arch_test.go` using Go's `go/parser` and `go/ast` to parse all `.go` files under `backend/internal/domain` and `backend/internal/application` and fail the test if:
   - `domain` imports `infrastructure`, `presentation`, `database/sql`, `net/http`, `google.golang.org/grpc`, or any vendor package.
   - `application` imports `infrastructure` or `presentation`.
2. Create `Makefile` with targets: `up`, `down`, `test`, `lint`, `proto`, `bench`, `licenses`, `mem`, `ci`.
3. Run `make up`, `make mem`, and `make ci`. Verify total WSL RAM `< 3 GB` while idle. Output the WP-2 Execution Report and **STOP**.

## PHASE WP-3 — EMPIRICAL BENCHMARK (`SPK-02-LOCAL`)
**Branch:** `wp-3-bench`
**Scope:** Execute real measurements on the workstation using synthetic RTSP streams from `mediamtx`/`camsim` and ONNX Runtime FP32. Zero fabricated numbers.

1. **Step 3.1 — Measure FFmpeg Sub-Stream Decode Cost:**
   Measure CPU % and RSS memory for decoding `640x360 @ 10 FPS` and `1280x720 @ 10 FPS` H.264 streams at `1`, `4`, and `8` concurrent streams. Save raw JSON to `docs/benchmarks/raw/decode_bench.json`.
2. **Step 3.2 — Measure ONNX Runtime Detector Latency:**
   Verify candidate detector license in `docs/ai/MODEL_REGISTER.md` (e.g., YOLOX-Nano / YOLOX-Tiny Apache-2.0 ONNX FP32), run `300` warmup + `1000` timed iterations (batch 1) on CPU (`4` threads and `6` threads) and optional CUDA (only if Quadro P600 CUDA provider works without error). Record `p50`, `p95`, `p99` ms to `docs/benchmarks/raw/detector_latency.json`.
3. **Step 3.3 — Measure End-to-End Worker & 30-Minute Soak Test:**
   Run the full worker pipeline (`decode -> 2 FPS sampler -> ONNX detector -> ByteTrack tracker -> polygon rule`) for `1`, `2`, `4`, and `6` simulated cameras, plus a **30-minute soak test at 4 cameras**, recording RSS at minutes `1, 10, 20, 30` (verify RSS growth `< 10%`).
4. **Step 3.4 — Write Capacity Formula & Update `WORKSTATION_PROFILE.md`:**
   Write `docs/benchmarks/SPK-02_LOCAL_RESULT.md` with exact commands, raw JSON links, and `max_cameras_on_this_box = min(CPU_limited, GPU_limited, RAM_limited)`. Separate any 200-camera projection under an explicit `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` header. Update `docs/governance/WORKSTATION_PROFILE.md` §2 with measured container RAM from `docker stats --no-stream`. Output the WP-3 Execution Report and **STOP**.

## PHASE WP-4 — VERTICAL SLICE #1 (RESTRICTED-AREA ENTRY) + 6 MANDATORY SECURITY FIXES
**Branch:** `wp-4-slice-restricted`
**Scope:** End-to-end implementation of Restricted-Area Entry (`FR-AI-002`, `FR-AI-009`, `FR-ALT-001/002/003/006/008`, `FR-SITE-003/005/008`, `NFR-SEC-001/002`, `NFR-REL-002`, `NFR-OBS-002`).

> **CRITICAL FOR FLASH 3.8:** You MUST implement the following 6 security blueprints verbatim. Do not simplify or weaken any of them.

### Step 4.1 — Blueprint #1: Bulletproof PostgreSQL 16 Schema, Composite FKs & Forced RLS
In `backend/internal/infrastructure/postgres/migrations/00001_initial_schema.sql`:
1. Create tables `sites`, `users`, `user_site_roles`, `cameras`, `zones`, `events` (monthly partitioned `PARTITION BY RANGE (occurred_at_utc)`), `event_evidence`, `outbox`, `notifications`, `delivery_attempts`, `dead_letters`, `audit_log`, and `ws_tickets`.
2. **Composite Foreign Keys (Anti-Cross-Site Injection):**
   - `cameras` MUST have `UNIQUE (site_id, id)`.
   - `zones` MUST have `UNIQUE (site_id, id)` and `FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, id)`.
   - `events` MUST have `FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, id)` and `FOREIGN KEY (site_id, zone_id) REFERENCES zones(site_id, id)`.
   - This makes it mathematically impossible at the database layer to link a `BNF` event or zone to an `RNF` camera!
3. **Forced Row-Level Security (Anti-Owner-Bypass):**
   For every operational table (`cameras`, `zones`, `events`, `event_evidence`, `outbox`, `notifications`, `delivery_attempts`, `dead_letters`, `audit_log`, `ws_tickets`), execute:
   ```sql
   ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;
   ALTER TABLE <table_name> FORCE ROW LEVEL SECURITY;

   CREATE POLICY site_isolation_policy ON <table_name>
     USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid)
     WITH CHECK (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid);
   ```
4. **Go Transaction Wrapper (`WithSiteTx`):**
   Every repository method in Go MUST execute inside a helper `WithSiteTx(ctx, siteID, func(tx *sql.Tx) error)` that runs `SELECT set_config('app.site_id', $1, true)` as the first statement of the transaction using the non-superuser `app_runtime` role. Any query executed without setting `app.site_id` returns `0` rows automatically!

### Step 4.2 — Blueprint #2: Single-Use Site-Bound WebSocket Tickets & Active Revocation
To prevent JWT leakage in query strings and cross-site WebSocket bleed:
1. Implement `POST /api/v1/sites/{site_id}/ws-ticket` (authenticated via `Authorization: Bearer <access_jwt>`):
   - Verifies the user is authorized for `{site_id}`.
   - Generates a 32-byte cryptographically random hex ticket, inserts it into `ws_tickets (ticket_hash, user_id, site_id, session_exp_utc, expires_at_utc, consumed)` with a **30-second TTL**, and returns `{"ticket": "<raw_ticket>"}`.
2. Implement `GET /ws/alerts?site_id={site_id}&ticket={raw_ticket}`:
   - Atomically marks the ticket `consumed = true` (`UPDATE ws_tickets SET consumed = true WHERE ticket_hash = $1 AND site_id = $2 AND consumed = false AND expires_at_utc > NOW() RETURNING user_id, session_exp_utc`).
   - Registers the WebSocket connection in the Hub **strictly under `(site_id, user_id)`**.
   - Starts a server-side timer that closes the WebSocket with code `4001 (Session Expired)` at `session_exp_utc`, and immediately disconnects the socket if the user switches sites or logs out.

### Step 4.3 — Blueprint #3: Hardened Python 3.11 AI Worker (`ADR-012`)
In `ai-workers/worker/`:
1. **RTSP URL Validator & Credential Scrubber (`decoder.py`):**
   - Reject any stream URL not matching `^rtsps?://[A-Za-z0-9._~:/?#\[\]@!$&'()*+,;=%-]+$`. Explicitly reject any string containing whitespace, `;`, `|`, `file:`, `concat:`, `subfile:`, or `lavfi`.
   - Spawn `ffmpeg` strictly with `subprocess.Popen([...], shell=False, stderr=subprocess.PIPE)`.
   - Wrap all log messages and exceptions with `scrub_credentials(msg)` (`re.sub(r'(rtsps?://)([^/\s:@]+:[^/\s@]+@)', r'\1***:***@', msg)`). Write a unit test proving that a simulated RTSP failure never prints the password in logs.
2. **Bounded Ring Queue & Drop Counter:**
   - Maintain a per-camera `collections.deque(maxlen=2)` for decoded frames. Increment a thread-safe `dropped_frames` counter whenever a full queue overwrites an older frame, and report `dropped_frames` in `SendHeartbeat`.
3. **Deterministic Event ID & Site-Jailed Snapshot Writer:**
   - Compute deterministic `event_id = uuid5(NAMESPACE_DNS, f"{site_id}:{camera_id}:{zone_id}:{rule_id}:{time_bucket_5s}")` so retries never duplicate events.
   - Write evidence snapshot only to `<evidence_root>/<site_id>/<yyyy>/<mm>/<dd>/<event_id>.jpg` after validating that `os.path.realpath(target)` starts with `os.path.realpath(os.path.join(evidence_root, site_id))`.
4. **Authenticated gRPC Client:**
   - Attach header `x-edge-worker-token: <shared_secret_from_env>` on every `SubmitEvent` and `SendHeartbeat` gRPC call; verify in Go gRPC unary interceptor using `hmac.Equal`.

### Step 4.4 — Blueprint #4: Crash-Safe Lease-Based Outbox & Unthrottled Fire Fast-Path (`ADR-013`)
In `backend/internal/infrastructure/outbox/`:
1. **Atomic Event + Outbox Persistence:**
   When `SubmitEvent` receives a valid event over gRPC, inside one `WithSiteTx` transaction:
   - Insert into `events` (`ON CONFLICT (site_id, idempotency_key) DO NOTHING`). If duplicate, return `accepted=true, duplicate=true` immediately.
   - Resolve target recipients strictly per `security/05_SECURITY_PRIVACY_AND_ACCESS.md` §3 (`BNF` ordinary events go ONLY to `BNF` factory manager + authorized company management + security managers; NEVER to `RNF` factory manager).
   - Insert one row into `outbox` and per-recipient rows into `notifications` with `UNIQUE (site_id, event_id, recipient_user_id, channel)`.
   - If `severity == 'CRITICAL_FIRE'` (and fire test mode is enabled for `TEST` recipients), execute `NOTIFY outbox_fire, '<site_id>:<outbox_id>'`; otherwise execute `NOTIFY outbox_ordinary, '<site_id>:<outbox_id>'`.
2. **Lease-Based Claiming (Zero Lost Events on `SIGKILL`):**
   - Claim rows using:
     ```sql
     UPDATE outbox
     SET status = 'PROCESSING',
         attempts = attempts + 1,
         locked_until = NOW() + INTERVAL '15 seconds'
     WHERE id IN (
       SELECT id FROM outbox
       WHERE site_id = $1
         AND (status = 'PENDING' OR (status = 'PROCESSING' AND locked_until < NOW()))
         AND next_attempt_at <= NOW()
       ORDER BY priority DESC, created_at ASC
       LIMIT 20
       FOR UPDATE SKIP LOCKED
     )
     RETURNING *;
     ```
   - For each recipient notification, check `status != 'DELIVERED'` before sending, record the attempt in `delivery_attempts`, and mark `notifications.status = 'DELIVERED'` immediately upon delivery ACK. If `edged` is killed (`kill -9`) mid-loop, any undelivered recipient row is automatically recovered after 15 seconds when `locked_until` expires, while already-delivered recipients are skipped via the idempotency check!
   - After `5` failed attempts (`1s, 2s, 4s, 8s, 16s` exponential backoff), move the row atomically to `dead_letters` and expose via `GET /api/v1/sites/{site_id}/dead-letters`.

### Step 4.5 — Blueprint #5: Zero-Trust `go2rtc` SDP Proxy (`FR-VID-004/006`, `D-011`)
In `backend/internal/infrastructure/go2rtc/`:
1. `POST /api/v1/sites/{site_id}/cameras/{camera_id}/live-grant`:
   - Enforce server-side RBAC: ONLY `security_manager` and `senior_management` roles are permitted (`factory_manager` MUST receive `403 Forbidden` even if they can switch sites!).
   - Verify camera belongs to `{site_id}` via RLS.
   - Write an immutable `audit_log` entry (`action = 'video.live.grant.issued'`).
   - Issue a 60-second HMAC-SHA256 signed token bound to `(user_id, site_id, camera_id, jti, exp)`.
2. `POST /api/v1/sites/{site_id}/cameras/{camera_id}/webrtc`:
   - Validate and consume the 60-second grant token (`jti` single-use check).
   - Forward the client's WebRTC SDP Offer over the internal Docker network to `http://go2rtc:1984/api/webrtc?src={internal_stream_key}` and return the SDP Answer to the client. Never return RTSP URLs or NVR credentials in any API response.

### Step 4.6 — Blueprint #6: Coverage-Lost Watchdog (`NFR-OBS-002` & `ADR-017`)
In `backend/internal/application/watchdog/`:
- Run a background ticker every `5 seconds` checking `last_heartbeat_utc` per AI worker and `last_frame_utc` per active camera.
- If any camera stream or worker heartbeat is older than `configurable_timeout` (default `15s` in local-dev), create an auditable operational event (`event_type = 'system.coverage.lost'`, `severity = 'WARNING'`) in PostgreSQL and dispatch it through the outbox to configured site administrators (deduplicated per outage episode until recovery `system.coverage.restored`).

### Step 4.7 — Mandatory Automated Test Suite for WP-4
Write and run automated tests covering all 5 required categories:
1. **Unit Tests:** Polygon point-in-polygon geometry, deterministic `event_id` deduplication, `FR-ALT-008` state machine transitions (`NEW -> ACKNOWLEDGED -> RESOLVED | DISMISSED(reason)`; reject invalid transitions and empty dismissal reasons), RTSP credential scrubber.
2. **Site-Isolation Negative Tests (Mandatory):**
   - `BNF` user token querying `RNF` events, cameras, zones, alerts, or dead-letters via REST -> `403 Forbidden` / `0` rows.
   - `BNF` user attempting to open a WebSocket for `RNF` -> `403 Forbidden`.
   - Direct PostgreSQL RLS test as `app_runtime` proving a transaction with `app.site_id = BNF` cannot `SELECT`, `UPDATE`, or `DELETE` `RNF` rows, nor insert a `BNF` event referencing an `RNF` `camera_id`.
   - Ordinary `BNF` alert dispatch test proving `RNF` factory manager receives `0` notifications.
   - `factory_manager` requesting `/live-grant` -> `403 Forbidden` (`D-011` enforcement).
3. **Chaos / Crash-Recovery Tests:**
   - Kill `ai-worker` mid-stream -> REST API stays `200 OK`, `NFR-OBS-002` coverage-lost alert fires, worker restarts and resumes without duplicate events.
   - Kill `edged` mid-outbox dispatch -> after restart, lease recovery delivers remaining notifications with **zero lost** and **zero duplicate** notifications.
   - Pause PostgreSQL container for `10s` -> `edged` and `ai-worker` recover cleanly without crashing.
4. **Latency Benchmark (`N=500`):**
   - Measure `event_created -> websocket_received` latency across 500 events on the workstation and record `p50`, `p95`, `p99` ms to `docs/benchmarks/raw/ws_latency.json`.
5. **End-to-End Scripted Demo (`make demo`):**
   - Simulated person enters restricted polygon in `camsim` -> `ai-worker` detects & saves JPEG snapshot -> sends gRPC event to `edged` -> PostgreSQL outbox dispatches -> WebSocket client receives alert + downloads evidence snapshot via authenticated endpoint.

Run `make test`, `make ci`, and `make demo`. Output the WP-4 Execution Report and **STOP**.

## PHASE WP-5 — UNIFIED FLUTTER CLIENT MVP (ANDROID + FLUTTER WEB, `ADR-014`)
**Branch:** `wp-5-flutter`
**Scope:** Build the single-codebase Flutter client (`mobile-app/`) targeting both Android handhelds and desktop browsers (Flutter Web), connected strictly to the real `edged` backend APIs.

### Step 5.1 — Package & Design Token Setup (`Doc 33` WCAG AA Compliance)
1. Check `flutter --version` on the host and set `environment: sdk:` in `mobile-app/pubspec.yaml` to match the installed Dart SDK. Verify licenses of `flutter_bloc`, `dio`, `web_socket_channel`, `flutter_secure_storage`, `go_router`, `fl_chart`, `flutter_webrtc` against Appendix B (`MIT` / `BSD-3-Clause` only) and record in `docs/governance/SBOM_AND_LICENSES.md`.
2. Implement `lib/core/theme/app_tokens.dart` strictly following `docs/discovery/33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md`:
   - Dark Canvas: `#0B111E`, Dark Container: `#161F30`, Primary Text: `#F8F9FA`, Secondary Text: `#94A3B8`.
   - **CRITICAL WCAG FIX:** Never use `#0D9488` (Teal 600, contrast `4.41:1` FAIL) for body text on `#161F30` containers! Use `#2DD4BF` (`teal-400`, contrast `9.49:1` AAA) for dark-mode colored text/links, and restrict `#0D9488` strictly to 2px borders, focus rings, and large button fills.
   - Light Canvas: `#F8F9FA`, Light Container: `#FFFFFF`, Light Primary Text: `#0F172A`, Light Accent Text: `#115E59` (`teal-800`).

### Step 5.2 — Implement Core Features & Explicit Site-Context Guardrails
1. **Authentication & Session Expiry (`FR-APP-005`):** Login screen, token refresh interceptor, automatic redirect + clear stale banner when session expires or network drops.
2. **Two-Tap Site Switcher & Persistent Site Banner (`FR-SITE-004/005`, `NFR-UX-001`):**
   - Always-visible top banner displaying active site (`BNF — SIMULATED` or `RNF — SIMULATED`).
   - Switching sites requires an explicit two-tap confirmation dialog (`"Switch active operational context from BNF to RNF?"`), tears down the old site's WebSocket connection, obtains a new single-use WebSocket ticket for the target site, and reloads all state Cubits.
3. **Alert Inbox, Client Deduplication & `FR-ALT-008` Triage:**
   - Real-time WebSocket stream with client-side `Set<String>` / local storage `event_id` deduplication so network retries never ring twice (`Doc 30` §3).
   - Alert detail view displaying metadata (`model_id`, `model_version`, `confidence`, `camera_id`, `zone_id`, UTC + `Africa/Cairo` timestamps, `SIMULATED` badge), authenticated evidence snapshot, and state transitions (`ACKNOWLEDGE`, `RESOLVE`, `DISMISS` with mandatory non-empty reason dialog).
4. **Role-Gated Live Video (`FR-APP-003`, `D-011`) & Zone Polygon Editor (`FR-WEB-003`):**
   - Hide Live Video controls unless user role has explicit `video.live.view` permission (`security_manager` or `senior_management`); connect WebRTC via the `edged` Zero-Trust SDP Proxy (`POST /api/v1/sites/{site_id}/cameras/{camera_id}/webrtc`).
   - Implement `CustomPainter` interactive polygon zone editor for Flutter Web allowing admins to draw/edit restricted-zone vertices and save to `PUT /api/v1/sites/{site_id}/zones/{zone_id}`.
5. **In-App Scheduled Reports (`FR-REP-001..007`, `Doc 31`):**
   - Daily, weekly (closing Thursday `23:59:59 Africa/Cairo`), and monthly counts by event category and site using native `fl_chart` vector charts. No invented KPIs.

### Step 5.3 — Verification & Physical Device Test
- Run `flutter analyze` (0 issues), `flutter test` (unit + Cubit + widget tests for two-tap site switch, role-hidden video tab, and alert dismissal reason validation), and `flutter build web`.
- If a physical Android phone is connected over USB (`flutter devices`), install the APK and run the 30-minute screen-off background delivery test per `ADR-017`; if no physical phone is plugged in during the automated run, record `BLOCKED: Physical Android phone not connected over USB` with `flutter devices` output while ensuring `flutter test` and `flutter build web` pass 100%.
- Output the WP-5 Execution Report and **STOP**.

## PHASE WP-6 — SHADOW-MODE AI USE CASES & ON-PREM DATASET PLAN
**Branch:** `wp-6-shadow-ai`
**Scope:** Implement additional AI capabilities strictly in **Shadow Mode** (persisting events with `shadow_mode = true` and `routing_suppressed = true` until owner approves measured precision/recall) or produce the on-prem CVAT dataset collection plan where pretrained models are absent in `MODEL_REGISTER.md`.

### Step 6.1 — Fall Detection Candidate Pipeline (`FR-AI-003`, Shadow Mode Only)
- Verify `RTMPose` (`Apache-2.0`, COCO keypoints only) in `docs/ai/MODEL_REGISTER.md`.
- Implement temporal keypoint/bounding-box rule evaluation in `ai-workers/worker/fall_detector.py` with all thresholds exposed in versioned config (`config/fall_rules.yaml`, labeled `EXPERIMENTAL_UNVALIDATED`).
- Enforce `shadow_mode = true` so fall events are stored in PostgreSQL for evaluation without triggering production notifications.

### Step 6.2 — On-Prem CVAT Dataset Collection & Labeling Protocol for Unassigned Models (`PPE`, `Fire/Smoke`, `Phone-Use`, `Object Movement`)
- Because `docs/ai/MODEL_REGISTER.md` marks `PPE`, `Fire/Smoke`, and `Phone-Use` as `NO MODEL IDENTIFIED` and the workstation (`Quadro P600 4GB`) cannot train models while factory footage cannot leave the premises, generate `docs/ai/ON_PREM_CVAT_COLLECTION_AND_TRAINING_PROTOCOL.md` specifying:
  1. On-prem CVAT container setup for labeling factory camera crops per site (`BNF` and `RNF`).
  2. Required class taxonomy inputs from the owner (`OQ-015` PPE matrix, `OQ-017` product/material taxonomy).
  3. Hold-out validation split protocol (day/night, camera angles, occlusion) required before any model exits shadow mode.

### Step 6.3 — Final Local MVP Definition-of-Done Verification
- Run `make up && make ci && make test` and `make licenses`.
- Verify all 9 Local MVP Definition-of-Done gates from `CTO_DIRECTIVES_EN.md` §6 and record the final evidence table in `PROJECT_HANDOFF.md` §H.
- Output the WP-6 Execution Report and **STOP**.

## 8. MANDATORY EXECUTION REPORT FORMAT (OUTPUT AT THE END OF EVERY PHASE)

```text
STATUS: PASS | FAIL | BLOCKED — <one-sentence summary>
PHASE: <WP-0.5 | WP-1 | WP-2 | WP-3 | WP-4 | WP-5 | WP-6>
REQUIREMENTS TOUCHED: <exact SRS / ADR / VULN IDs>
COMPLETED STEPS:
  - <Step ID>: DONE | BLOCKED(<exact reason>)
VERIFICATION EVIDENCE:
  - Command: <exact command run>
  - Output: <exact pass/fail counts and last 15 lines>
FILES CHANGED:
  - <path> — <concise reason>
SECURITY & ISOLATION CHECKS:
  - <confirmation of RLS / Outbox / Credential Scrubbing / Manifest integrity>
NEXT AUTHORIZED COMMAND: "awaiting owner command: continue <next WP>"
```