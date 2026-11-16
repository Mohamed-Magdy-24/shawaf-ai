# ANTIGRAVITY EXECUTION PROMPT — Industrial AI Surveillance (BNF/RNF)
**Issued by:** CTO · **Date:** 2026-11-16 · **Mode:** APPLY EXACTLY — DO NOT IMPROVISE
**Goal:** a zero-license-cost, locally-runnable, measurable MVP on the owner's workstation, built on a repaired documentation pack.

> **BINDING DIRECTIVE.** Every instruction in this file is a mandatory order. Every "create", "replace", "run", "must", "stop" is to be executed exactly as written, in the stated order. Items are not suggestions and are not optional. The only permitted alternative to executing an item is to mark it `BLOCKED: <evidence>` as defined in rule R1. Companion document: `CTO_DIRECTIVES_EN.md` (the reasoning behind these orders).

---

## 0. HOW TO RUN THIS FILE (owner reads this part, agent skips it)

1. Copy the pack folder `Industrial_AI_Surveillance_Project_Pack/` into the repo root. Put this file next to it.
2. Send Antigravity ONLY this kickoff message:

> Read `ANTIGRAVITY_FIX_PROMPT.md` fully. Execute **WP-0 only**. Do not read any other file in the pack unless WP-0 names it. Stop when WP-0 is done and send the report in the format of §7. Wait for me to say "continue WP-1".

3. After each report, review it, then reply `continue WP-n`. Never ask it to run two WPs at once.
4. Sending this file IS the owner authorization described in §3 (local development only). Nothing in it authorizes touching real factory devices, real employee data, or production.

---

## 1. ROLE AND HARD RULES (agent: obey literally)

You are a disciplined implementation agent. The CTO has already made the decisions listed in this file. **You apply them; you do not re-decide, extend, or "improve" them.**

R1. Do exactly what each item says. If an item is impossible or ambiguous, mark it `BLOCKED: <reason>` and continue to the next item. Never substitute your own design.
R2. Never invent: files, APIs, library functions, versions, licenses, benchmark numbers, test results. Before pinning any version or license, open the official source (registry page, `LICENSE` file, release page) and record the URL and what you saw. If you cannot reach it → `UNVERIFIED`.
R3. Never claim a command passed unless you ran it. Report the exact command and the last 20 lines of output (or the pass/fail counts).
R4. **Token economy** (this runs on a free quota): do not load the whole pack. Read only the "Active Set" (§2.3) plus files a WP names. Use `rg`/`grep` and `sed -n` for slices. Never print files > 80 lines into the chat; write them to disk instead.
R5. Real data prohibition: no real employee data, no biometric data, no real factory video, no production credentials, no connection to any real NVR/camera/ZKTeco/SQL Server. Development uses only synthetic or license-clean public media recorded in `data/SOURCES.md` (file, URL, license, SHA-256).
R6. No paid software, no SaaS, no cloud upload of project data. License allow/deny list: Appendix B.
R7. Small commits. One WP = one branch `wp-N-<slug>`; commit message `WPn: <what>`. Do not rewrite history. Do not touch files outside the WP scope.
R8. After each WP: stop, report (§7). Do not start the next WP.
R9. A timebox applies to every environment problem: **2 attempts per problem**, then record `BLOCKED` with logs and move on (or stop if nothing else is possible).

---

## 2. VERIFIED CONTEXT (from the CTO's audit of the pack — do not re-audit)

### 2.1 What the pack is
Documentation only (104 files, ~142k words). **No application code exists.** Requirements baseline: **96 requirements (78 FR + 18 NFR)** in `requirements/01_SRS.md`, matched 1:1 by `planning/09_REQUIREMENTS_TRACEABILITY.csv`.

### 2.2 Owner's workstation (source: `cto_readiness_audit_reports/07_HARDWARE_COMPATIBILITY_AUDIT.md` §1; re-measure in WP-2)
Windows 10 Pro 19045 · Xeon E-2236 6C/12T AVX2 · 16 GB RAM (≈5.7 GB free at idle) · Quadro P600 4 GB (Pascal SM 6.1, driver 552.55, no Tensor cores) · C: 35 GB free · D: 128 GB free · Docker Desktop 29.8 + WSL2 · Python 3.14.4 on host · Node 24 · Flutter 3.44.7 · Go NOT installed.

### 2.3 ACTIVE SET (the only files that define the project)
```
00_PROJECT_CHARTER.md
requirements/01_SRS.md
planning/09_REQUIREMENTS_TRACEABILITY.csv
planning/08_ADR_AND_OPEN_QUESTIONS.md
architecture/02_TARGET_ARCHITECTURE.md
integrations/03_INTEGRATION_AND_DATA_SPEC.md
ai/04_VIDEO_AI_SPEC.md
security/05_SECURITY_PRIVACY_AND_ACCESS.md
docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md
docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md
docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md
docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md
antigravity/09_MASTER_OPERATING_PROMPT.md        (amended in WP-0)
antigravity/11_PHASE_PROMPTS.md                  (amended in WP-0)
+ new: 00_READ_ME_FIRST.md, docs/governance/*  (created in WP-0)
```
Everything else is REFERENCE-ONLY. Do not load it unless a WP names it.

### 2.4 Defects found by the CTO (the reason WP-0 exists)
| # | Defect | Evidence |
|---|---|---|
| D1 | Agent is forbidden to write code: "Sprint 1 STRICTLY NOT AUTHORIZED", "zero installs" | `antigravity/09_MASTER_OPERATING_PROMPT.md` §3.1; `PROJECT_HANDOFF.md` §B |
| D2 | `verify_archive_manifest.py` currently FAILS (uncataloged `PROJECT_HANDOFF.md`) although HANDOFF claims 102/102 PASS | run `python3 -I verify_archive_manifest.py` |
| D3 | Contradictory numbers: 42 FR/13 NFR/55 reqs (audit reports) vs 96 (SRS); 16×18 TB/198.9 TB (master prompt) vs 16×16 TB/162 TB (AUDIT-09); 400 FPS/site (Doc 24) vs 250 FPS/site (AUDIT-09); WSL cap 4 GB vs 6 GB | audit 01, 09, 12; master prompt §3; Doc 24 |
| D4 | Banned tech (YOLOv8, TensorRT, DeepStream, RTX-4000-Ada TensorRT-INT8 sizing, MinIO) still used as active recommendations in ~30 files | `rg -il "YOLOv8\|TensorRT\|DeepStream"` |
| D5 | `VERIFIED_BY_EXECUTION` labels on numbers never executed (Go RAM, 50 ms latency, P600 CUDA) — Go is not installed and SPK-02 was never run | AUDIT-12 table, AUDIT-09 §5.1 |
| D6 | Local plan needs 5.8 GB RAM vs 5.7 GB free; PyTorch inside the runtime container | AUDIT-12 §3 |
| D7 | No owner of video decoding: architecture makes Go dispatch frames but Go has no native video decoder | `architecture/02_TARGET_ARCHITECTURE.md` §7 backpressure section |
| D8 | "Go 1.22.6 LTS" — Go has no LTS and 1.22 is out of support | AUDIT-08 |
| D9 | Docker Desktop is not free for larger companies; Windows 10 is past end of support | AUDIT-07/08/14 |
| D10 | Model gaps/errors: RT-DETR listed for fall/posture; InsightFace/ArcFace listed as Apache-2.0 without weights/dataset license check; no model identified for PPE, fire/smoke, phone, pose | `supplementary_license_audit/AI_MODELS_AND_DATASETS_LICENSE_AUDIT.md` |
| D11 | AUDIT-13 "proposed patches" invent thresholds (2.0 m/s etc.) and "siren silenced" semantics that contradict the SRS | `13_REQUIRED_DOCUMENTATION_CORRECTIONS.md` |
| D12 | 4 languages + ~9 services (Go, Python, React, Flutter, PG, TimescaleDB, Valkey, go2rtc, WireGuard) for a one-person test machine | `ADR-011` |
| D13 | Broken links (`docs/discovery/26_…` → `../antigravity/…`; HANDOFF `file:///d:/…`; HANDOFF cites `architecture/03_INTEGRATION…` which lives in `integrations/`) | link check script in WP-0 |

---

## 3. OWNER AUTHORIZATION RECORD (write verbatim in WP-0 to `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`)

```markdown
# Owner Authorization Record — LOCAL DEVELOPMENT ONLY
Date: 2026-11-16 · Issued by: the Project Owner, by issuing ANTIGRAVITY_FIX_PROMPT.md

## AUTHORIZED
- DEC-01: Phase 0 baseline ACCEPTED, as amended by docs/governance/CTO_AMENDMENTS.md.
- ADR-011: APPROVED as amended by ADR-012 … ADR-017 (CTO_AMENDMENTS.md).
- DEC-02: APPROVED — administration console scope is delivered as Flutter Web (ADR-014), not React.
- SPK-02-LOCAL: APPROVED — inference/decoding benchmark on the owner's workstation with synthetic or public license-clean media only.
- Sprint 1 and following local sprints: APPROVED for LOCAL DEVELOPMENT AND SIMULATION only.
- FR-ALT-008 minimal workflow (NEW → ACKNOWLEDGED → RESOLVED | DISMISSED-with-reason): APPROVED as local-development default; to be reviewed in the pilot.

## NOT AUTHORIZED (remain BLOCKED; agent must stop if work would need them)
- SPK-01, SPK-03, SPK-04 (any contact with real ZKTeco terminals, real NVRs/cameras, real SQL Server data).
- DEC-03 (photo-upload fallback), DEC-04 (fire auxiliary-status sign-off), DEC-05 (recipient roster), DEC-06 (legal review, Law 151/2020), DEC-08 (FCM).
- Any face recognition, employee identity matching, cross-camera employee re-identification or employee movement history on real people.
- Any production deployment, hardware purchase, VPN to factory networks.
- Any real employee/biometric data or real factory footage in development.

## Consequences
- Fire-alert code may be built and tested with TEST recipients only; the production fire route stays disabled until DEC-04 and DEC-05 are signed.
- Notification code uses the NotificationChannel port (ADR-017); FCM adapter may be written but is DISABLED by configuration.
```

---

## WP-0 — REPAIR THE PACK (documentation only; no installs, no code)

Branch: `wp-0-pack-repair`. Work in this order.

**P-01 Authorization + amendments files**
- Create `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md` = §3 block verbatim.
- Create `docs/governance/CTO_AMENDMENTS.md` containing: the 13 defects table (§2.4) and the six ADR texts of WP-1 (copy verbatim after WP-1 is approved; for now create the file with the defects table and the heading "ADR texts: see WP-1").

**P-02 Read-me-first**
Create `00_READ_ME_FIRST.md` (≤ 60 lines): one paragraph of project purpose; the Active Set (§2.3); the rule "everything else is reference-only and may contradict the Active Set — the Active Set wins"; the precedence: `OWNER_AUTHORIZATION_LOCAL_DEV.md` > `CTO_AMENDMENTS.md` > SRS > Architecture > rest.

**P-03 Banner on stale documents**
Prepend this exact banner (first lines of file, then a blank line) to every file below:
```
> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.
```
Files: `cto_readiness_audit_reports/01_…, 03_…, 04_…, 05_…, 06_…, 08_…, 09_…, 12_…, 13_…, 14_…`.
Additionally for each other file in the pack that matches `rg -il "YOLOv8|TensorRT|DeepStream|MinIO"`: open the matching lines; if the term appears as a **recommended/active** component (not inside an exclusion/ban statement) → add the same banner. List every file you bannered and every file you skipped (with one-line reason) in the report. Do not banner Active Set files; fix them by edit instead (P-06).

**P-04 Workstation profile**
Create `docs/governance/WORKSTATION_PROFILE.md`: copy ONLY the hardware/OS facts from AUDIT-07 §1 table, each tagged `OWNER_REPORTED_ENVIRONMENT_FACT (2026-11-12, to be re-measured in WP-2)`. Add a section "Resource footprints" that is empty except the line "Filled by WP-2/WP-3 with MEASURED values; no estimates allowed here."

**P-05 Canonical numbers**
Create `docs/governance/CANONICAL_NUMBERS.md` with exactly this table (and nothing invented):
| Item | Value | Provenance |
|---|---|---|
| Requirements | 96 = 78 FR + 18 NFR | SRS + CSV (verified by script) |
| Cameras | ~200+/site, may grow | D-004 |
| Biometric terminals | 18+/site, mixed | D-005 |
| Video retention | 30 days — **on the existing NVRs** (charter §4 excludes replacing NVR recording). Platform stores only event clips/snapshots/metadata. | D-008 + Charter |
| Platform storage | Sized from MEASURED event-clip rate; not 162 TB. The 162 TB / 16-disk figure is an NVR-side capacity check, not a platform purchase | CTO_AMENDMENTS |
| AI sampling rates | candidate variables in Doc 28; not approved | Doc 28 |
| Hardware BOM | NOT approved; derived after WP-3 + real NVR inventory | Doc 24 |
Then in `antigravity/09_MASTER_OPERATING_PROMPT.md` §3 replace the bullet starting "Video retention baseline: 30 days continuous storage. Sizing requires 16x 18TB…" with: `Video retention baseline: 30 days, held by the existing NVRs (see docs/governance/CANONICAL_NUMBERS.md). The platform stores event evidence only.`

**P-06 Amend the master prompt**
In `antigravity/09_MASTER_OPERATING_PROMPT.md`:
1. §1: replace "The 41 deliverables in docs/discovery/ (01 through 41) constitute the sole verified technical foundation." with "The Active Set listed in 00_READ_ME_FIRST.md is the sole technical foundation. All other files are reference-only."
2. §3.1: replace the final line "No implementation gate is approved. Sprint 1 remains STRICTLY NOT AUTHORIZED." and the DEC/SPK status list with: "Authorization state is defined ONLY by docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md. Local development on synthetic data is authorized; every item under its NOT AUTHORIZED heading remains BLOCKED."
3. §4: replace the "Key infrastructure candidates" list with the amended baseline of ADR-012…ADR-017 (one line each, pointing to CTO_AMENDMENTS.md).
4. Append §11 "Token economy": copy rules R4, R7, R9 from this file.
Keep all anti-hallucination rules, site-isolation rules, AI/biometric rules unchanged.

**P-07 Amend phase prompts**
In `antigravity/11_PHASE_PROMPTS.md` add, directly under the title, a block "LOCAL-DEV MODE": phases 1–7 may be executed against simulated sources (MediaMTX RTSP loops, mock ZKBioTime server clearly named `*_simulator`, synthetic SQL Server schema in PostgreSQL labeled SIMULATED) **provided** every capability matrix, report and UI label says `SIMULATED`, and no gate marked in OWNER_AUTHORIZATION "NOT AUTHORIZED" is bypassed. Production gates in each phase text are not removed.

**P-08 SRS / CSV amendments (minimal)**
- `requirements/01_SRS.md` row FR-ALT-008: keep the original text and append: `Amended 2026-11-16 (local-dev default, pilot review required): states NEW, ACKNOWLEDGED, RESOLVED, DISMISSED (reason mandatory); each transition audited with user and UTC time. No siren-silencing behavior. No other states.`
- `planning/09_REQUIREMENTS_TRACEABILITY.csv` row FR-ALT-008: set Status to `AMENDED_LOCAL_DEV_PENDING_PILOT` and keep the CSV valid (96 rows, same columns).
- Do NOT apply any patch from `13_REQUIRED_DOCUMENTATION_CORRECTIONS.md` (it invents thresholds).

**P-09 Model register (research only, no downloads of weights)**
Create `docs/ai/MODEL_REGISTER.md` with columns: Role · Candidate · Code license · Weights license · Training-data provenance/license · Source URL + commit/tag · Status. Seed rows (status `UNVERIFIED` until you open and quote the real LICENSE text):
- Detector: YOLOX (Megvii), RT-DETR (PaddleDetection/Baidu or another official implementation).
- Tracker: ByteTrack.
- Pose (for fall logic): RTMPose via MMPose (candidate to verify; Apache-2.0 expected).
- Face detect/recognition (ONLY for future DEC-06-gated work): OpenCV Zoo YuNet + SFace (candidate to verify). **InsightFace/ArcFace: record that pretrained model packs are stated by the project as non-commercial/research-only — verify in its README and mark `NOT APPROVED` if confirmed.**
- PPE, fire/smoke, phone-use: `NO MODEL IDENTIFIED` — row must say so. Do not invent a model.
- Remove "RT-DETR" as a fall/posture model from the register (it is a detector, not a pose/fall model).
For every row you fill: quote the license sentence and give the URL. If you cannot open it → `UNVERIFIED`.

**P-10 Versions**
Create `docs/governance/TOOLCHAIN_PINS.md`: for Go, Python 3.11, PostgreSQL 16, ONNX Runtime, go2rtc, MediaMTX, ffmpeg, Flutter/Dart, golang-migrate or goose, buf/protoc: record the exact version you will use, the date checked, the source URL and its support status. Rules: Go = latest supported stable release listed on go.dev/dl (there is no "LTS"; do not write 1.22); PostgreSQL = latest 16.x minor. Python 3.11 only for the worker. Do not pin by memory.

**P-11 Fix links and manifest (do this LAST in WP-0)**
1. Fix: `docs/discovery/26_…` links to `../antigravity/…` → `../../antigravity/…`; in `PROJECT_HANDOFF.md` replace `file:///d:/Project-CRM/Industrial_AI_Surveillance_Project_Pack/<path>` with the relative `<path>`; replace `architecture/03_INTEGRATION_AND_DATA_SPEC.md` with `integrations/03_INTEGRATION_AND_DATA_SPEC.md`.
2. Update `PROJECT_HANDOFF.md` §B/§C/§G: status line becomes "Phase 0 CLOSED with amendments. Local-dev sprints AUTHORIZED per OWNER_AUTHORIZATION_LOCAL_DEV.md. Production blocked per its NOT AUTHORIZED list." Append (never edit) a §H history entry for 2026-11-16 listing what WP-0 changed. Replace the claim "102/102 verified" with the real output of step 4.
3. Regenerate `MANIFEST.sha256` for every file except itself, and update `docs/discovery/44_…` counts to the real numbers. Update `PACK_VERSION.txt` to `1.1.0-local-dev-authorized`.
4. Run `python3 -I verify_archive_manifest.py` → must end with PASSED and exit 0. If it fails, fix the cause (not the script's check) and re-run.
5. Link check — run this and require `broken 0`:
```python
import re,os,glob
bad=[]
for f in glob.glob('**/*.md',recursive=True):
    for m in re.finditer(r'\]\(([^)#\s]+\.(?:md|csv|py))',open(f,encoding='utf8').read()):
        p=m.group(1)
        if p.startswith('http'): continue
        if p.startswith('file:') or not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f),p))): bad.append((f,p))
print('broken',len(bad)); [print(b) for b in bad]
```
6. CSV check: 96 data rows, 96 unique IDs, IDs equal the SRS IDs (`^\| ((?:N?FR)-[A-Z]+-\d+)`).

**WP-0 acceptance:** manifest PASSED; link check `broken 0`; CSV check OK; `rg -n "STRICTLY NOT AUTHORIZED" antigravity/` returns nothing in the Active Set; `00_READ_ME_FIRST.md` exists; banner list reported. **STOP.**

---

## WP-1 — ARCHITECTURE AMENDMENTS (documentation only)

Branch `wp-1-adr-amendments`. Append the following ADRs **verbatim** to `planning/08_ADR_AND_OPEN_QUESTIONS.md` and `docs/governance/CTO_AMENDMENTS.md`; then edit `architecture/02_TARGET_ARCHITECTURE.md` only where it contradicts them (list each edit in the report). Mark ADR-011 `APPROVED AS AMENDED`; ADR-012…017 `APPROVED (local-dev)`.

**ADR-012 — The AI worker owns video decode and inference.**
Context: Go has no native production video decoder; sending raw frames Go→Python over gRPC costs CPU/RAM and bandwidth. Decision: the Go core never decodes video. The Python worker pulls each camera's *sub-stream* (credentials supplied by Go at config time, never logged), decodes it with an ffmpeg subprocess (or PyAV), applies a fixed-rate sampler, keeps a **bounded latest-frame queue (size 1–2, drops counted)** per camera, runs ONNX inference, tracking and rule evaluation, and sends **only events + a JPEG evidence snapshot reference** to Go via versioned gRPC (idempotency key per event). Go owns camera/zone/policy configuration, scheduling, health, persistence, alerts. Transport: gRPC over TCP 127.0.0.1 (works identically in WSL2, Docker and Linux; no Unix sockets). Consequences: Go↔Python traffic is tiny; one worker process serves N cameras where N is MEASURED in WP-3; the "proto" file must contain no frame/pixel message.

**ADR-013 — Minimal data plane.**
Decision: PostgreSQL 16 only. Outbox = table with `priority`, `status`, `attempts`, `next_attempt_at`, unique `idempotency_key`; dispatch with `FOR UPDATE SKIP LOCKED` + `LISTEN/NOTIFY`. Fire-priority rows are served by a dedicated goroutine with its own connection and no batching/throttling. Events table uses native monthly partitioning. **Valkey and TimescaleDB are removed from the baseline** (re-introduce only through a new ADR citing a measured limit). Consequences: two fewer services, no Timescale License question, lower RAM.

**ADR-014 — One client codebase.**
Decision: Flutter (Dart) for the Android manager app AND the administration console (Flutter Web build, desktop browser). React/Vite is removed from the baseline. Cubit/Bloc (`flutter_bloc`) for state. Zone editor = CustomPainter polygon editor. Live view = WebRTC via go2rtc (`flutter_webrtc` after license check). Charts = in-app vector charts (`fl_chart` after license check). Consequences: 3 languages total (Go, Python, Dart).

**ADR-015 — Runtime environment.**
Decision: develop inside WSL2 Ubuntu LTS; run containers with Docker Engine (docker-ce, Apache-2.0) inside WSL2, **not Docker Desktop**, unless the owner confirms the company qualifies for the free tier. `%USERPROFILE%\.wslconfig`: `memory=5GB`, `processors=6`, `swap=6GB` with the swap file on D:. Keep project files and volumes inside the WSL2 ext4 filesystem (not `/mnt/d`). Production target: Ubuntu Server LTS. Windows 10 is past end of support: treat the workstation as a dev box only; never expose it to the factory network. The Android emulator is forbidden; use a physical phone over USB.

**ADR-016 — Inference runtime.**
Decision: the deployed worker image contains ONNX Runtime + OpenCV/NumPy only (no PyTorch). Models are exported to ONNX in a separate offline "model-export" environment; every model artifact is stored with source commit, SHA-256 and a MODEL_REGISTER row. CPU is the mandatory baseline; `onnxruntime-gpu` (CUDA) is optional and enabled only if WP-3 proves it works on the P600 with the pinned driver/CUDA/cuDNN — otherwise CPU only. TensorRT, DeepStream, Ultralytics, pyzk, MinIO stay excluded. Models use FP32 on the P600.

**ADR-017 — Notification channel port.**
Decision: `NotificationChannel` port with adapters: (1) `WebSocketChannel` (in-app, default), (2) `FcmChannel` (implemented, **disabled** until DEC-08; payload = event id + generic text only: no names, no images, no site-sensitive details), (3) `NtfyChannel` (self-hosted ntfy/UnifiedPush, Apache-2.0/GPL-check required before use — if its server license is copyleft, run it only as a separate unmodified process and record the legal note) as a Google-free fallback candidate. Android client: foreground service for the socket plus a documented battery-optimization exemption step; test on the physical phone with screen off for 30 min. Additionally the platform MUST raise an **operational alert ("coverage lost")** to configured admins when a camera stream or a worker heartbeat is missing for a configurable time — a silent blind spot is a safety defect. (New requirement NFR-OBS-002 — add to SRS and CSV as `PROPOSED_LOCAL_DEV`; CSV then has 97 rows; update CANONICAL_NUMBERS.md accordingly.)

**WP-1 acceptance:** ADR texts present exactly once in each file; ADR-011 status changed; list of edits in 02_TARGET_ARCHITECTURE; manifest and link check re-run → PASSED / 0. **STOP.**

---

## WP-2 — WORKSTATION + REPO SKELETON (installs allowed from here, free tools only)

Branch `wp-2-skeleton`. Timebox rule R9 applies.

1. **Measure the workstation** (PowerShell/WSL): total & free RAM, `nvidia-smi`, free disk C:/D:, Windows version, WSL version, Docker version. Write to `docs/governance/WORKSTATION_PROFILE.md` as `MEASURED` (date + command).
2. **WSL2 setup per ADR-015**: Ubuntu LTS distro; `.wslconfig`; Docker Engine inside WSL; `docker run hello-world`. If Docker Desktop is the only option that works, record `BLOCKED` + the licensing note and continue with it for dev only.
3. **GPU check (optional, max 2 attempts):** `nvidia-smi` inside WSL; if a CUDA container test fails → record "CPU baseline only" and move on.
4. **Toolchains** exactly per `TOOLCHAIN_PINS.md`: Go, Python 3.11 venv (`uv`/`venv`; two envs: `runtime`, `model-export`), `buf` or `protoc`, ffmpeg. Flutter is already installed (verify `flutter doctor -v`; ignore Android-emulator warnings).
5. **Repo skeleton** (structure from architecture §11 with ADR-014 applied — no `web-admin/`): `proto/`, `backend/{cmd,internal/{domain,application,infrastructure,presentation}}`, `ai-workers/`, `mobile-app/`, `deploy/`, `tests/`, `data/`, `docs/`. Add `Makefile` (or `justfile`) targets: `up`, `down`, `test`, `lint`, `proto`, `bench`, `licenses`, `mem` (prints `docker stats --no-stream`).
6. **`deploy/docker-compose.local.yml`** with these services and hard `mem_limit` values: `postgres:16` (512m, `shared_buffers=128MB`), `go2rtc` (pinned tag, 128m, not published to host), `mediamtx` (pinned, 128m), `camsim` (ffmpeg looping local MP4s into mediamtx; 1 container, up to 6 streams, 512m), `edged` (Go, 256m), `ai-worker` (1536m). Every image pinned by tag AND digest (resolve digests; do not invent). All secrets from `.env` (git-ignored; `.env.example` committed with placeholders).
7. **Synthetic media**: create `data/` clips with ffmpeg `testsrc`/`lavfi` and/or license-clean public clips; each listed in `data/SOURCES.md` (URL, license text quote, SHA-256). Large files git-ignored.
8. **CI script** `make ci` runs: format check, lint, unit tests, `proto` generation check, license scan (Appendix B), secret scan (gitleaks, MIT) — all must run locally.
9. **Architecture tests**: Go test (or `go-arch-lint`/script) failing if `domain` imports `infrastructure`/`presentation`, or any package imports a vendor SDK from `domain`/`application`.

**Acceptance:** `make up` starts all services; `make mem` output is saved; `make ci` passes on the empty skeleton (report exact output); with all services idle, total WSL RAM < 3 GB (report real number). **STOP.**

---

## WP-3 — SPK-02-LOCAL BENCHMARK (measure, do not guess)

Branch `wp-3-bench`. Follow `docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md` for method; ignore any number in it as "approved". Use only synthetic/public media.

Measure and write raw results to `docs/benchmarks/SPK-02_LOCAL_RESULT.md` + `docs/benchmarks/raw/*.json` (commands included):
1. **Decode cost:** ffmpeg decode of a 640×360 @10 fps H.264 sub-stream and of a 1280×720 @ 10 fps one: CPU % of one core and RSS per stream, at 1, 4, 8 concurrent streams (from MediaMTX/`camsim`).
2. **Detector latency:** one candidate detector in ONNX FP32 (YOLOX-Tiny and YOLOX-S if their licenses are verified; RT-DETR only if it loads in < 3 GB RAM): p50/p95/p99 latency, batch 1, input per the model's native size, on **CPU (4 and 6 threads)** and **CUDA** (only if ADR-016 conditions hold). 300 warm + 1000 timed iterations.
3. **End-to-end worker** (one camera → decode → sampler → detector → tracker → zone rule): sustained FPS and CPU/RSS for 1, 2, 4, 6 cameras at the configured sampling rate (start with 2 FPS; also try 5 FPS), **30-minute soak at 4 cameras**: RSS at minute 1/10/20/30 (growth > 10 % = defect).
4. **Capacity statement:** compute `max_cameras_on_this_box = min(CPU-limited, GPU-limited, RAM-limited)` from the measured numbers and show the formula. A projection to 200 cameras/site may be written ONLY as `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` with the assumptions listed (sampling rate, number of models per frame, decode share, motion duty cycle). It must be clearly separated from measured data. No BOM.
5. Fill the "Resource footprints" section of `WORKSTATION_PROFILE.md` with MEASURED values (container RAM from `docker stats`).

**Acceptance:** every number in the result has the command and raw file behind it. **STOP.**

---

## WP-4 — VERTICAL SLICE #1: RESTRICTED-AREA ENTRY (end to end, simulated cameras)

Branch `wp-4-slice-restricted`. Requirements: FR-AI-002, FR-AI-009, FR-ALT-001/002/003/006, FR-SITE-003/005/008, NFR-SEC-001/002, NFR-REL-002. Why this slice first: it needs only a person detector + polygon logic (no PPE/fire/pose dataset).

**4.1 Database (Go migrations; tool per TOOLCHAIN_PINS):** tables `sites`, `users`, `user_site_roles`, `cameras`, `zones` (polygon JSON, rule_version), `events` (monthly partitions), `event_evidence`, `outbox`, `notifications`, `delivery_attempts`, `dead_letters`, `audit_log`. Every operational table has `site_id NOT NULL`. **Row-Level Security** with `SET LOCAL app.site_id` per transaction; the application DB role is NOT superuser and has NOT `BYPASSRLS`. Seed two sites BNF and RNF with TEST data only.
**4.2 API (Go, REST+WebSocket):** login (argon2id, short-lived access + rotating refresh), site switch, camera/zone CRUD, event list (paginated), alert inbox, acknowledge/resolve/dismiss per the amended FR-ALT-008, WebSocket alerts. Every handler resolves `site_id` from an authorized context; no mutable global "current site". Idempotency keys on commands.
**4.3 Worker (Python 3.11, ADR-012):** pipeline per §WP-3.3; reconnect with exponential backoff + jitter; per-camera failure isolation; zone dwell/entry logic with polygon point-in-polygon; every event carries `model_id, model_version, rule_id, rule_version, confidence, camera_id, zone_id, occurred_at_utc, received_at_utc, evidence snapshot ref`; deterministic event id for idempotency. Camera credentials never logged.
**4.4 Outbox + alert routing:** as ADR-013; ordinary routing per `security/05` §3; **fire path exists as code but stays disabled by config and only targets TEST recipients**; dead-letter visibility endpoint.
**4.5 Video access:** go2rtc reachable only from the Go service/internal network; clients get short-lived, signed, per-camera session grants after server-side role check (only security managers and senior management). Read go2rtc docs and record how the grant is enforced; if go2rtc cannot be fronted this way, record `BLOCKED` with evidence and stop this item.
**4.6 Observability:** structured JSON logs, `/healthz`, `/metrics` (Prometheus text), worker heartbeat + camera-offline detection → "coverage lost" operational alert (NFR-OBS-002).

**Tests that must exist and pass (report counts):**
- unit: zone geometry, dedup, state machine transitions (illegal transitions rejected), idempotent event ingest;
- **site isolation negatives:** BNF user cannot read/ack/stream RNF events/cameras via API, WebSocket, SQL (RLS) and cache keys; ordinary BNF alert never reaches RNF-only recipients; company-management cross-site exception works only where the matrix allows;
- **reliability:** kill the worker mid-stream → API healthy, no event lost/duplicated after restart; kill `edged` during dispatch → after restart each notification delivered exactly once from the receiver's view; stop PostgreSQL 20 s → no crash, recovery;
- **latency:** measure event-created → WebSocket-received (p50/p95/p99, N=500) and report as MEASURED on this box;
- architecture tests from WP-2 still pass.

**Acceptance:** `make test` and `make ci` green with real output attached; a 2-minute scripted demo (`make demo`) where a simulated person crosses a zone in `camsim` and the alert reaches a WebSocket test client. **STOP.**

---

## WP-5 — FLUTTER CLIENT MVP (Android app + Flutter Web console, ADR-014)

Branch `wp-5-flutter`. Follow `docs/discovery/09_UI_UX_DESIGN_STRATEGY.md`, `10_SCREEN_AND_NAVIGATION_INVENTORY.md`, `33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md` (read only these three; take colors/tokens from 33).
- Structure: feature-first (`core/`, `features/{auth,site_switch,alerts,incidents,cameras,live,zones,reports}`), Cubit per feature, repository + data-source layers, DTO→domain mapping, `dio` with interceptors, `web_socket_channel`, `flutter_secure_storage` (Android token storage), `go_router`. License-check every package (Appendix B) before adding.
- Screens (real API only, no hard-coded production-looking data): login · site switch with **explicit two-tap confirmation and always-visible active-site banner** · alert inbox · alert detail with evidence snapshot and acknowledge/resolve/dismiss · cameras list/health · live view (hidden unless the role has video permission; WebRTC via the signed grant) · zone editor (CustomPainter polygon; Flutter Web) · daily/weekly/monthly counts by event type and site, Africa/Cairo day boundaries per `docs/discovery/31_…` (only metrics approved there; do not invent KPIs).
- States: loading/empty/error/offline/stale for every list; expired-session handling (FR-APP-005).
- Tests: Cubit unit tests, repository tests with fakes, widget tests for site switch + alert detail, one integration test on the physical Android phone (`flutter run -d <device>`). **No emulator.** Gradle: `org.gradle.jvmargs=-Xmx1536m`, `org.gradle.daemon=false` while benchmarks run.
- Android background delivery test per ADR-017 (screen off 30 min; record whether alerts arrive; report honestly).

**Acceptance:** `flutter analyze` clean, `flutter test` green, APK installs on the phone and shows a live alert from the WP-4 demo; `flutter build web` succeeds. **STOP.**

---

## WP-6 — NEXT AI USE CASES (one per run; each needs its own owner "continue")

Order and prerequisites (do not start a use case whose prerequisite is missing; write `BLOCKED` instead):
1. **Fire/smoke (shadow mode):** needs a verified model + license-clean dataset in MODEL_REGISTER. Production route stays disabled (DEC-04/05).
2. **Fall (pose + temporal rules):** needs a verified pose model; thresholds are NOT invented — expose as versioned config and report measured precision/recall on a labeled synthetic/public set only.
3. **PPE per zone:** needs a labeled dataset; training on this workstation is not feasible (4 GB VRAM) and factory footage must not leave the premises → produce a *data-collection and labeling plan with CVAT run on-prem* instead of a model if no verified pretrained model exists.
4. **Phone use, object/material movement/handoff:** same rule; events are always worded "suspected".
5. **Face recognition / person re-identification / employee tracking:** **do not start** (DEC-06 + SPK-01 not authorized).
Every use case ships in **shadow mode** (events recorded, no alert routing) until the owner approves measured results.

---

## 5. DEFINITION OF DONE FOR "LOCAL MVP" (all measurable)

| # | Check | Evidence required |
|---|---|---|
| 1 | `make up && make ci && make test` green from a clean clone | real output |
| 2 | Idle stack < 3 GB WSL RAM; 4 simulated cameras under load < 5 GB; 30-min soak shows < 10 % RSS growth | `docker stats` raw files |
| 3 | Site-isolation negative tests (API, WS, RLS, queue/cache keys) all pass | test report |
| 4 | Kill/restart tests: no lost, no duplicated notifications | test report |
| 5 | Event→WebSocket latency p50/p95/p99 measured and reported (no target claimed) | raw JSON |
| 6 | License scan: zero GPL/AGPL/SSPL/BUSL/non-commercial components in the shipped baseline | `make licenses` output + SBOM |
| 7 | Every AI number in docs is MEASURED with a command, or labeled CALCULATED/UNKNOWN | grep report |
| 8 | Real phone receives alert; screen-off background result documented | notes + screenshot |
| 9 | Nothing in the repo contains real employee data, real footage or real credentials | secret scan + `data/SOURCES.md` |

Not claimable by this MVP (must appear in the final report as limitations): detection accuracy on real factory footage; 200-camera capacity; NVR/ZKTeco compatibility; legal compliance; fire-system certification.

---

## 6. OWNER-ONLY TASKS (agent must list them, not do them)
DEC-03/04/05/06/08 · SPK-01/03/04 on real devices (needs a bench terminal, a test NVR + 2 cameras, a restored SQL backup) · confirm company eligibility for Docker Desktop free tier (or keep Docker Engine) · supply product/material taxonomy, restricted-zone maps, PPE matrix, recipient rosters · engage Egyptian counsel for Law 151/2020.

---

## 7. REPORT FORMAT AFTER EVERY WP (≤ 60 lines)

```
STATUS: PASS | FAIL | BLOCKED  — one sentence
SCOPE: WP id, requirement IDs touched
DONE: bullet per item P-xx / step, each marked DONE | BLOCKED(reason) | SKIPPED(reason)
EVIDENCE: exact commands + last lines of output / counts
FILES CHANGED: path — reason
DEVIATIONS: anything you did differently from this file and why (should be empty)
UNVERIFIED / ASSUMPTIONS: list
RISKS + ROLLBACK: one line each
NEXT: "awaiting: continue WP-n"
```
Do not add marketing language or accuracy claims. Never mark a gate PASS that you did not execute.

---

## APPENDIX A — RAM BUDGET (estimates; WP-2/WP-3 replace them with measurements)
| Where | Component | Limit |
|---|---|---|
| WSL2 (cap 5 GB) | postgres 512m · go2rtc 128m · mediamtx 128m · camsim 512m · edged 256m · ai-worker 1536m | 3.0 GB containers + ~1 GB OS/cache |
| Windows | IDE ~1.2 GB · browser ~0.6 GB · Gradle ≤ 1.5 GB (only while building) | do not build the APK during benchmarks |
| Rule | If free RAM < 1 GB: stop camsim to 2 streams, close the browser, never start an emulator | |

## APPENDIX B — LICENSE POLICY
Allowed: MIT, BSD-2/3, Apache-2.0, ISC, PostgreSQL License, Python-2.0/PSF, MPL-2.0 (unmodified, file-level; note it).
Deny/stop-and-report: GPL, AGPL, SSPL, BUSL, Elastic, Timescale License, Commons Clause, CC-BY-NC, any "non-commercial/research only" model or dataset terms, unknown license.
LGPL: allowed only as an unmodified dynamically-linked external process/library; record the note.
Tools: `go-licenses`, `pip-licenses`, `dart pub deps --json` + manual check of each package page; output saved to `docs/governance/SBOM_AND_LICENSES.md` by `make licenses`.
