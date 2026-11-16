> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# REQUIRED DOCUMENTATION CORRECTIONS & PROPOSED PATCHES
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-13 | Classification: AUDIT REMEDIATION PROPOSAL
### Status: PROPOSED PATCHES ONLY | DIRECTIVE: DO NOT APPLY AUTOMATICALLY TO ORIGINAL FILES

---

## 1. CHANGE CONTROL & AUDIT NOTICE

In accordance with strict change control directives:
> **The auditor is NOT authorized to modify existing documentation files in `Industrial_AI_Surveillance_Project_Pack/`. All corrections proposed below are documented strictly in this external audit register. They must be formally reviewed and applied by the project maintainers only after Owner approval.**

---

## 2. REQUIRED CORRECTIONS IN `requirements/01_SRS.md`

### Correction SRS-01: Clarification of Material Movement / Theft (`FR-AI-006` & `FR-AI-007`)
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/requirements/01_SRS.md`
- **Location**: Section 4.4, Table rows for `FR-AI-006` and `FR-AI-007` (Lines 94–95).
- **Current Text**:
  ```markdown
  | FR-AI-006 | Detect and track configured product/material/packaging classes. | MUST |
  | FR-AI-007 | Detect suspicious movement of objects out of production/storage areas and possible transfers between people. | MUST |
  ```
- **Reason for Change**: Computer vision models cannot legally or technically infer "theft" or "suspicious intent". Without a defined object taxonomy and spatial transfer zone rules, this requirement is unverifiable.
- **Proposed Replacement Text**:
  ```markdown
  | FR-AI-006 | Detect and track configured factory material classes (cartons, bulk raw material sacks, metal component pallets) within designated production zones based on an approved client taxonomy. | MUST |
  | FR-AI-007 | Detect transfer of tracked material classes across defined Material Transfer Geofences during unauthorized time windows or when handed off between unverified individuals. | MUST |
  ```

---

### Correction SRS-02: Definition of Incident Review State Machine (`FR-ALT-008`)
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/requirements/01_SRS.md`
- **Location**: Section 4.5, Table row for `FR-ALT-008` (Line 117).
- **Current Text**:
  ```markdown
  | FR-ALT-008 | Alert acknowledgement, rejection, and incident workflow states are not finalized and shall not be invented by the implementation agent. | TBD |
  ```
- **Reason for Change**: Leaving the core alert state machine as "TBD" blocks UI development in Flutter and Web Admin.
- **Proposed Replacement Text**:
  ```markdown
  | FR-ALT-008 | Alert and incident workflow shall enforce a deterministic state machine: `NEW` (dispatched, unread), `ACKNOWLEDGED` (viewed by operator, siren silenced), `IN_REVIEW` (investigation in progress), `RESOLVED` (incident confirmed and documented), or `DISMISSED` (false alarm logged with reason). State transitions shall be auditable with user identity and timestamp. | MUST |
  ```

---

### Correction SRS-03: Quantitative Criteria for Fall Detection (`FR-AI-003`)
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/requirements/01_SRS.md`
- **Location**: Section 4.4, Table row for `FR-AI-003` (Line 91).
- **Current Text**:
  ```markdown
  | FR-AI-003 | Detect falls and configured accident indicators. | MUST |
  ```
- **Reason for Change**: Lacks quantitative biomechanical criteria, risking false alarms whenever a worker sits or bends.
- **Proposed Replacement Text**:
  ```markdown
  | FR-AI-003 | Detect human falls within 2.0 seconds of occurrence, defined by: (a) vertical downward velocity of torso keypoint $> 2.0\text{ m/s}$, (b) bounding box aspect ratio inversion ($\text{width} / \text{height} > 1.8$), and (c) sustained floor immobility $\ge 3.0$ seconds. Trigger high-priority safety notification with pre-fall 3s and post-fall 3s video clip metadata. | MUST |
  ```

---

## 3. REQUIRED CORRECTIONS IN `architecture/02_TARGET_ARCHITECTURE.md`

### Correction SDD-01: Disambiguation of DeepStream on Local Workstation
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/architecture/02_TARGET_ARCHITECTURE.md`
- **Location**: Section 3.2, AI Pipeline Runtime Specification.
- **Current Text**:
  ```markdown
  The AI inference pipeline supports NVIDIA DeepStream SDK 7.0 with TensorRT 10 INT8 execution providers alongside Python gRPC workers.
  ```
- **Reason for Change**: Physical impossibility on host workstation Quadro P600 GPU (Pascal SM 6.1). Causes implementers to attempt building unsupported TensorRT engines.
- **Proposed Replacement Text**:
  ```markdown
  The AI inference pipeline implements a two-tier deployment architecture:
  1. Local Development & PoC Baseline: Decoupled Python gRPC worker utilizing ONNX Runtime (FP32 CUDA / AVX2 CPU Fallback) and PyTorch 2.4, compatible with the developer's Pascal Quadro P600 workstation GPU.
  2. Production Factory Server Target: High-density NVIDIA DeepStream SDK 7.0 and TensorRT INT8 pipeline, reserved for procurement on dedicated factory edge servers equipped with NVIDIA Ampere or Ada Lovelace GPUs (RTX 4000 Ada).
  ```

---

### Correction SDD-02: Addition of AI Worker Backpressure Policy
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/architecture/02_TARGET_ARCHITECTURE.md`
- **Location**: Section 4.1, Inter-Process Communication Specification.
- **Reason for Change**: Prevents unbounded queue growth in RAM when camera frame rate exceeds GPU inference speed.
- **Proposed Text to Append**:
  ```markdown
  ### 4.1.3 Frame Ingestion Backpressure & Drop Policy
  To prevent memory leaks and queue latency buildup, the Go edge daemon enforces a non-blocking Leaky Bucket ring buffer of size 2 per camera stream for AI frame dispatch:
  - If the Python AI worker is currently executing inference, new incoming sub-frames overwrite the unread buffer.
  - Under no circumstances shall incoming video frames queue in host memory waiting for AI inference.
  - If inference latency exceeds 200ms for 5 consecutive frames, the daemon emits an observability alert (`AI_WORKER_FRAME_DROPPING`).
  ```

---

## 4. REQUIRED CORRECTIONS IN `planning/08_ADR_AND_OPEN_QUESTIONS.md`

### Correction ADR-01: Incorporate ADR-011 into Canonical ADR Log
- **Target File**: `Industrial_AI_Surveillance_Project_Pack/planning/08_ADR_AND_OPEN_QUESTIONS.md`
- **Location**: Section 2, after `ADR-005`.
- **Proposed Text to Append**:
  ```markdown
  ### ADR-011 — Unified Edge & AI Technology Baseline
  - Status: APPROVED (Canonical)
  - Edge Core Daemon: Go (Golang 1.22 LTS)
  - Video Streaming Sidecar: go2rtc (Pure Go Binary, WebRTC/MSE)
  - Local AI Worker: Python 3.11 with ONNX Runtime (CUDA FP32 / CPU Fallback) & PyTorch
  - Target Production AI: NVIDIA DeepStream SDK (Post-procurement on Ampere/Ada servers)
  - Persistence: PostgreSQL 16 + TimescaleDB (Hypertables + RLS Multi-Tenancy)
  - Client Consoles: Flutter (Android Mobile) + React/Vite (Desktop Web Admin Console)
  - Network Mesh: WireGuard Point-to-Point VPN Tunneling
  ```

---
**Audited By:** Principal Software Architect & Requirements Lead  
**Change Control Standard:** Strict Non-Invasive Documentation Audit

