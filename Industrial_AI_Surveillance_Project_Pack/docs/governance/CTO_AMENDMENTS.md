# CTO Amendments & Baseline Governance

Date: 2026-11-16 · Issued by: CTO · Status: ACTIVE BASELINE

## 1. Pack Defects Identified by CTO Audit (§2.4)

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

## 2. ADR texts: see WP-1
