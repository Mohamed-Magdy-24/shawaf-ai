> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 40 — Proposed Version Candidates & Dependency Governance Study (Historical Archive)

> **SUPERSEDED — HISTORICAL CANDIDATE TECHNOLOGY RESEARCH — NOT A CURRENT IMPLEMENTATION AUTHORITY**
>
> This document contains historical technology evaluations and version candidates that predate the current SRS/SDD licensing and runtime remediation.
>
> Do not use its TensorRT, YOLOv8, SeaweedFS, MinIO, or S3 recommendations as approved or current implementation instructions.
>
> The current proposed runtime and storage baseline is described in:
> - `architecture/02_TARGET_ARCHITECTURE.md`
> - `planning/08_ADR_AND_OPEN_QUESTIONS.md` (ADR-011)
> - `docs/compliance/THIRD_PARTY_LICENSE_REGISTER.md`
>
> ADR-011 remains PROPOSED — PENDING OWNER APPROVAL. No candidate technology becomes an approved dependency until its exact version, license, compatibility, and owner approval requirements are satisfied.

**Document ID:** DISC-40-TECH-VERSIONS  
**Version:** 1.2.0-superseded  
**Date:** 2026-11-16  
**Status:** SUPERSEDED — HISTORICAL CANDIDATE RESEARCH  
**Classification:** HISTORICAL REFERENCE ONLY / SUPERSEDED BY ADR-011  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Sections 4 & 8  

---

## 1. Executive Summary: Candidate Study vs. Production Lockfile

In strict accordance with CTO Operating Principles:
> **The versions listed in this document represent a rigorously analyzed PROPOSED VERSION CANDIDATE STUDY. They do NOT constitute an approved, immutable production lockfile.**
> A production lockfile can only be certified and committed during Phase 2 after the Phase 1 technical spikes empirically validate compiler flags, driver bindings, transitive dependencies, and container runtime stability.

Open-ended version specifications such as `PostgreSQL 16.6+`, `Valkey 8.0.2+`, or `Flutter 3.27+` are strictly eliminated. Every component is evaluated against official vendor documentation, active support status, and open-source licensing.

---

## 2. Technology Matrix: Research Baselines vs. Local Development Verified Stack

In strict accordance with the CTO Directive on Canonical Technology Stack:
- **Research Baselines:** Represent forward-looking evaluation targets identified by the CTO.
- **Local Dev Verified Lockfiles:** Represent the immediate, battle-tested stable releases pinned for local developer environment validation on the Project Owner's workstation before hardware procurement.

```text
+-----------------------+------------------------+------------------------+--------------------+------------------------------------+
| SUBSYSTEM / COMPONENT | RESEARCH BASELINE      | LOCAL DEV VERIFIED     | LICENSE TYPE       | TARGET OS / ARCHITECTURE           |
+-----------------------+------------------------+------------------------+--------------------+------------------------------------+
| 1. Core Backend       | Go 1.27.4 (Future/Eval)| Go 1.23.6 / 1.24       | BSD-3-Clause       | Linux static binary / Win developer|
| 2. AI Vision Runtimes | Python 3.14.10 (Eval)  | Python 3.12 LTS        | PSF License        | Linux Container / venv isolated    |
| 3. Web Admin Console  | React 19.3 (Eval)      | React 18.3 / 19.0+Vite | MIT License        | Desktop Chrome / Edge (Chromium)   |
| 4. Mobile Manager App | Flutter 3.47.0 (Eval)  | Flutter 3.27.4+Dart 3.6| BSD-3-Clause       | Android API 26+ (SDK 34/35)        |
| 5. Primary Database   | PostgreSQL 18.6 (Eval) | PostgreSQL 16.8        | PostgreSQL License | Ubuntu 22.04 LTS / Docker          |
|    - TimeSeries Ext.  | TimescaleDB 2.31.0(Eval| TimescaleDB 2.17.2    | Timescale License  | PostgreSQL extension (selective)   |
| 6. High-Speed Broker  | Valkey 9.1.3 (Eval)    | Valkey 8.0.2           | BSD-3-Clause       | Linux Container (Alpine/Debian)    |
| 7. Video Gateway Hub  | go2rtc 1.9.15 (Eval)   | go2rtc 1.9.8           | MIT License        | Linux Container / local binary     |
| 8. Object Storage S3  | SeaweedFS 4.53 (Eval)  | SeaweedFS 3.80         | Apache-2.0         | Linux Container / local S3         |
| 9. AI Tensor Engine   | TensorRT 11.4.1 (Eval) | TensorRT 10.7.0.23     | NVIDIA TensorRT SLA| Ubuntu 22.04 LTS (x86_64)          |
|    - Model Interchange| ONNX Runtime 1.31.1    | ONNX Runtime 1.20.1    | MIT License        | Python / C++ Execution Provider    |
|    - CUDA Toolkit     | CUDA 13.4 Update 1     | CUDA 12.6.2            | NVIDIA CUDA EULA   | Compatible with host GPU driver    |
|    - Host GPU Driver  | Driver R580+ (for TRT11| Driver 550.127.05      | NVIDIA Driver Lic. | Compatible with host workstation   |
|    - Video Codec SDK  | Video Codec 13.x (R580)| Video Codec 12.2       | NVIDIA Video Codec | Compatible with Driver 550 / 12.6  |
+-----------------------+------------------------+------------------------+--------------------+------------------------------------+
```

---

## 3. Critical NVIDIA Stack Compatibility Analysis: Video Codec SDK vs. Driver vs. TensorRT

### 3.1 The Architecture Conflict Exposed
Earlier proposals suggested utilizing hardware-extracted macroblock motion vectors from the video decoder silicon to trigger fall detection bursts.
- **NVIDIA Video Codec SDK 13.x Requirements:** Exposing detailed decode statistics / motion vector surfaces requires **Video Codec SDK 13.0/13.1**, which strictly requires **NVIDIA Driver 570+ / R610** and **CUDA 13.1**.
- **Existing Hardened Production Stack:** The candidate architecture is pinned to **Driver 550.127.05**, **CUDA 12.6.2**, and **TensorRT 10.7.0.23**.
- **Incompatibility Verdict:** Driver 550.x and CUDA 12.6 are **physically incompatible** with Video Codec SDK 13.1. Arbitrarily upgrading the NVIDIA driver to unverified 570/610 branches would break TensorRT 10.7, destabilize the Ubuntu 22.04 LTS kernel, and introduce bleeding-edge driver regressions.

### 3.2 Selected Resolution: Pin Video Codec SDK 12.2 and Decouple Trigger Logic
1. **Pinned Codec SDK:** Pin to **NVIDIA Video Codec SDK 12.2**, which natively supports Driver 550.x and CUDA 12.6 on NVIDIA Ada Lovelace / Ampere GPUs.
2. **Standard NVDEC Hardware Decoding:** NVDEC handles standard bitstream decompression (H.264/H.265) directly into NV12 decoded memory surfaces.
3. **Decoupled Trigger Architecture:** Because Video Codec SDK 12.2 does not provide advanced macroblock vector statistics (and compression motion vectors are noisy, lossy compression artifacts rather than true physical optical flow), the system **rejects relying on codec-level compression vectors**. Instead, the fall trigger is implemented via:
   - Temporal frame differencing and centroid vertical velocity on the decoded 640×360 sub-stream, OR
   - Camera-side ONVIF Profile T motion/loitering analytics, paired with the 3-second pre-event rolling ring buffer.

### 3.3 TensorRT 11.4.1 vs. TensorRT 10.7 Evaluation
In accordance with Section 3 of the CTO Directive:
- **TensorRT 11.4.1 (Research Baseline):** Requires NVIDIA Driver R580+ (580.xx) and CUDA 13.4 Update 1. Its documented python wheels officially support Python 3.10 through 3.14 (Python 3.15 is explicitly rejected as unvalidated).
- **TensorRT 10.7.0.23 (Local Dev Lockfile):** Operates on Driver 550.127.05 and CUDA 12.6.2, which matches current production Linux server stability and local developer workstation availability.
- **Operational Rule:** Local development commences on TensorRT 10.7 / CUDA 12.6; migration to TensorRT 11.4.1 / Driver R580 will occur only if production GPU benchmarks during `SPK-02` demonstrate measurable throughput superiority under verified enterprise stability.

---

## 4. Deep-Dive Component Specifications & Compatibility Rationales

### 4.1 Relational Database: PostgreSQL 16.8 + TimescaleDB 2.17.2
- **Official Source:** PostgreSQL Official Release 16.8 / TimescaleDB Release 2.17.2.
- **Security Check:** PostgreSQL 16.8 resolves CVE-2025-1094.
- **Evaluation of PG 17 & 18:** PostgreSQL 18 is unreleased. PostgreSQL 17 support in enterprise extensions is nascent; PostgreSQL 16.8 provides the most battle-tested extension stability for TimescaleDB on Ubuntu 22.04.
- **License:** Liberal PostgreSQL License / Timescale License (Community Edition). Free for single-node on-premise industrial use.
- **Rollback Path:** Point-in-time recovery via WAL archiving; downgrade to PostgreSQL 16.7 via apt pinning.

### 4.2 Cache & High-Priority Broker: Valkey 8.0.2
- **Official Source:** Valkey GitHub Release 8.0.2.
- **Why Valkey over Redis:** Redis shifted to non-open-source dual RSALv2 / SSPLv1 licenses. Valkey is the community-governed Linux Foundation open-source fork under BSD-3-Clause.
- **CVE Status:** Zero known critical vulnerabilities on 8.0.2.
- **Rollback Path:** Seamless fallback to Valkey 7.2.7 LTS.

### 4.3 Video Streaming Proxy: go2rtc 1.9.8
- **Official Source:** go2rtc GitHub Release v1.9.8.
- **License:** MIT License.
- **Operational Reality:** Ingests RTSP sub-streams and serves WebRTC / MSE without host CPU transcoding. Passes H.264/H.265 NAL units directly into WebRTC RTP packets.
- **Interoperability Requirement:** Physical testing on actual site NVRs is required in `SPK-03` to verify Profile G seek and RTSP authentication compatibility.

### 4.4 Object Storage: SeaweedFS 3.80
- **Official Source:** SeaweedFS GitHub Release 3.80.
- **License:** Apache-2.0 (Clean enterprise license; avoids MinIO AGPLv3 infectious license risks).
- **Architecture:** Haystack O(1) disk lookup optimized for billions of video chunks and image crops without inode exhaustion.

### 4.5 Mobile Client: Flutter 3.27.4 + Dart 3.6.2
- **Official Source:** Flutter 3.27.4 Stable Release.
- **License:** BSD-3-Clause.
- **Platform:** Android API Level 26 (Android 8.0) through API Level 34/35. Uses Impeller Vulkan backend with fallback to Skia on older devices.

---

## 5. Lockfile Governance Protocol for Phase 2

1. **Docker Container Digest Pinning:** All production services will be pinned by immutable SHA-256 image digests (e.g., `image: postgres:16.8@sha256:...`).
2. **Cryptographic Package Lockfiles:** `go.sum` and `pubspec.lock` will be strictly enforced in CI via `--enforce-lockfile`.
3. **Automated Vulnerability Scanning:** Automated scanning with Trivy and Grype during CI builds.
