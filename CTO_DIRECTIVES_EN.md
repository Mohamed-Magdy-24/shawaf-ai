# CTO DIRECTIVES — Industrial AI Surveillance Platform (BNF / RNF)
**Date:** 2026-11-16 · **Status:** BINDING. Every directive below MUST be executed. Companion to `ANTIGRAVITY_FIX_PROMPT.md`, which contains the step-by-step execution orders.
**Scope reviewed:** 104 files (~142k words). The pack contains documentation only; no application code exists.

## 1. Verdict
The project idea is sound. The pack is not executable as written: it contradicts itself, forbids all coding, and is too large for a free agent's quota. The pack MUST be repaired (WP-0), the architecture MUST be simplified (ADR-012…017), and delivery MUST proceed in small, measured work packages (WP-1…WP-6), each of which stops and waits for owner approval.

## 2. Reality constraints (must be stated in every report; must not be rephrased as promises)
1. "Free" means **zero software license cost**. Production for 200+ cameras per factory requires purchased hardware (server + GPU). No BOM may be written before WP-3 and a real NVR inventory.
2. The owner's workstation (Xeon E-2236 6C/12T, 16 GB RAM with ~5.7 GB free, Quadro P600 4 GB) is a **test machine for 4–8 simulated cameras**. No document may claim it handles 200 cameras.
3. No detection-accuracy figure may be claimed before it is measured on a labeled dataset. Accuracy on real factory footage cannot be measured in the local MVP.

## 3. Defects that MUST be fixed

### P0 — block the project from working at all
| # | Defect | Mandatory fix |
|---|---|---|
| 1 | Governance deadlock: master prompt §3.1 and HANDOFF forbid coding and installs ("Sprint 1 STRICTLY NOT AUTHORIZED"). | Create the Owner Authorization Record (local development, synthetic data only). Every real-device, legal, biometric and production item stays BLOCKED. |
| 2 | Context bloat: 104 files; master prompt names 41 documents as the sole source. | Create `00_READ_ME_FIRST.md` with a 14-file Active Set; all other files become reference-only. |
| 3 | Contradictory numbers: 42 FR/13 NFR/55 vs **96** requirements; 16×18 TB vs 16×16 TB; 400 FPS vs 250 FPS; WSL cap 4 GB vs 6 GB. | Create `CANONICAL_NUMBERS.md`; banner every stale file as SUPERSEDED. |
| 4 | `verify_archive_manifest.py` FAILS (uncataloged `PROJECT_HANDOFF.md`) while HANDOFF claims 102/102 PASS. | Regenerate the manifest after all edits; re-run until PASSED; replace the HANDOFF claim with real output. |
| 5 | No owner of video decoding (Go dispatches frames but has no mature decoder; raw frames over gRPC are costly). | **ADR-012:** the Python worker pulls the sub-stream, decodes, samples, infers, tracks; it sends only events + snapshot references to Go. Go never decodes video. |
| 6 | RAM plan needs 5.8 GB vs 5.7 GB free; PyTorch inside the runtime container. | ONNX Runtime only in runtime image; hard memory limit per container (Appendix A of the prompt); `.wslconfig` memory=5GB. |
| 7 | Evidence labels `VERIFIED_BY_EXECUTION` on numbers never executed (Go not installed; SPK-02 never run). | Every number is measured in WP-3 (command + raw file) or labeled CALCULATED/UNKNOWN. |

### P1 — break efficiency or the zero-cost claim
| # | Defect | Mandatory fix |
|---|---|---|
| 8 | Over-built stack: 4 languages, ~9 services. | **ADR-013:** PostgreSQL 16 only (outbox with `SKIP LOCKED` + `LISTEN/NOTIFY`); remove Valkey and TimescaleDB. **ADR-014:** Flutter for the Android app and the Web admin; remove React/Vite. Result: Go, Python, Dart. |
| 9 | Docker Desktop is not free for larger companies; Windows 10 is past end of support. | **ADR-015:** WSL2 + Docker Engine; workstation is dev-only; production is Linux. |
| 10 | "Go 1.22.6 LTS": Go has no LTS and 1.22 is unsupported. | Pin the latest supported Go release from go.dev/dl at execution time. |
| 11 | Model gaps: RT-DETR listed for falls (it is a detector); InsightFace/ArcFace licensed without checking weights/dataset terms; no model identified for PPE, fire/smoke, phone use; training impossible on 4 GB VRAM; factory footage must not leave the premises. | Create `MODEL_REGISTER.md` (status UNVERIFIED until the license text is quoted); on-prem CVAT labeling plan; no face model approved. |
| 12 | Android background delivery (Doze) with FCM unapproved and no Google-free fallback. | **ADR-017:** `NotificationChannel` port: WebSocket (default), FCM (implemented, disabled), self-hosted ntfy (candidate); foreground service; 30-minute screen-off test. |
| 13 | A dead camera or worker produces no alert (silent blind spot). | New requirement **NFR-OBS-002 "coverage lost"** alert. |
| 14 | Capacity model counts 162 TB as a platform purchase (contradicts the charter: NVRs are not replaced), uses TensorRT/YOLOv8 numbers, ignores decode CPU. | 30-day retention stays on the NVRs; the platform stores event evidence only; capacity derived from WP-3 measurements. |

### P2 — consistency
15. `13_REQUIRED_DOCUMENTATION_CORRECTIONS.md` MUST NOT be applied (invented thresholds, siren semantics). FR-ALT-008 is set to the minimal workflow `NEW → ACKNOWLEDGED → RESOLVED | DISMISSED(reason)` as a local-dev default.
16. Unix sockets vs gRPC conflict: use gRPC over TCP 127.0.0.1 only.
17. Fix the 4 broken links and all `file:///d:/…` links.

## 4. Owner-only items (the agent MUST list them and MUST NOT perform them)
DEC-03, DEC-04, DEC-05, DEC-06, DEC-08; SPK-01, SPK-03, SPK-04 on real devices; confirmation of Docker Desktop free-tier eligibility; supply of recipient rosters, restricted-zone maps, PPE matrix and material taxonomy; engagement of Egyptian counsel for Law 151/2020. Face recognition, employee identity matching, cross-camera employee re-identification and employee movement history on real people MUST NOT start.

## 5. Execution order (mandatory; one package at a time; stop after each)
WP-0 pack repair → WP-1 ADR amendments → WP-2 workstation + repo skeleton → WP-3 local benchmark → WP-4 vertical slice (restricted-area entry, simulated camera → event → outbox → alert) → WP-5 Flutter client → WP-6 further AI use cases, one per run, in shadow mode.

## 6. Definition of Done for the local MVP (all nine MUST pass with evidence)
1. `make up && make ci && make test` green from a clean clone.
2. Idle stack < 3 GB WSL RAM; 4 simulated cameras < 5 GB; 30-minute soak with < 10 % RSS growth.
3. Site-isolation negative tests pass (API, WebSocket, RLS, queue/cache keys).
4. Kill/restart tests show no lost and no duplicated notifications.
5. Event→WebSocket latency p50/p95/p99 measured and reported.
6. License scan shows no GPL/AGPL/SSPL/BUSL/non-commercial component in the shipped baseline.
7. Every AI number in the docs is MEASURED (with command) or labeled CALCULATED/UNKNOWN.
8. A physical Android phone receives an alert; the screen-off result is documented honestly.
9. The repository contains no real employee data, real footage or real credentials.

Not claimable by this MVP: accuracy on real footage, 200-camera capacity, NVR/ZKTeco compatibility, legal compliance, fire-system certification.
