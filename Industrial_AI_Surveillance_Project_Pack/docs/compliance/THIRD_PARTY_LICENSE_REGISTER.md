# THIRD-PARTY SOFTWARE AND COMPONENT LICENSE REGISTER
## Industrial AI Surveillance Platform — BNF & RNF
**Document ID:** COMPL-REG-001  
**Classification:** Canonical Licensing & Governance Register  
**Status:** ACTIVE GOVERNANCE REGISTER  
**Last Updated:** 2026-11-16  

---

## 1. COMPONENT REGISTER

| Component | Purpose | Exact Version/Commit | Repository | Source License | Model/Asset License | Distribution Obligations | Approved Status | Evidence |
|---|---|---|---|---|---|---|---|---|
| **Frigate** | Architectural reference for motion-first detection & shared memory | Commit `06d1365` (2026-11-11) | `https://github.com/blakeblackshear/frigate` | MIT | N/A (Source reference) | Include MIT copyright notice if binary/code used; no code integration without exact version/dependency review | CANDIDATE (Reference Only) | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Viseron** | Architectural reference for domain design & storage tiering | Commit `04640a0` (2026-11-11) | `https://github.com/roflcoopter/viseron` | MIT | N/A (Source reference) | Include MIT notice if used; previous GPL-3.0 classification corrected | CANDIDATE (Reference Only) | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **ZoneMinder** | Historical conceptual reference for polygon motion zones | Commit `cf0d054` (2026-11-11) | `https://github.com/ZoneMinder/zoneminder` | GPL-2.0-or-later | N/A | Reciprocal copyleft source disclosure if distributed/linked; excluded from core | EXCLUDED | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **go2rtc** | Isolated edge video streaming sidecar (WebRTC/MSE) | Version `v1.9.15` (`990f4de`) | `https://github.com/AlexxIT/go2rtc` | MIT | N/A | Include MIT notice and copyright in third-party notices | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **MediaMTX** | Alternative media router and streaming reference | Commit `63bd8da` (2026-11-11) | `https://github.com/bluenviron/mediamtx` | MIT | N/A | Include MIT notice if distributed | CANDIDATE (Alternative Component) | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **NVIDIA DeepStream** | High-density video analytics SDK (Proprietary) | SDK v7.1 / Reference Apps | `https://developer.nvidia.com/deepstream-sdk` | Apache-2.0 (Apps only) | Proprietary NVIDIA EULA (SDK runtime) | Hardware-bound (NVIDIA Turing+); incompatible with Pascal Quadro P600; excluded from approved baseline | EXCLUDED | `VERIFIED_IN_SOURCE` |
| **ByteTrack** | Multi-object tracking algorithmic baseline | Commit `d1bf019` (2022-12-11) | `https://github.com/FoundationVision/ByteTrack` | MIT | N/A (Mathematical tracker) | Include MIT notice; verify exact release and dependencies before code integration | CANDIDATE (Clean-Room Baseline) | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **CVAT Community** | Internal offline dataset annotation platform | Version `v2.82.0` (`f9cb186`) | `https://github.com/cvat-ai/cvat` | MIT | N/A (Tooling) | Preserved MIT notice; isolated internal tooling only, never bundled in factory runtime | CANDIDATE (Internal Tooling Only) | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **pyzk** | Unofficial ZKTeco standalone terminal protocol parser | Commit `1af361a` (2026-10-18) | `https://github.com/fananimi/pyzk` | GPL-2.0-only | N/A | Strong copyleft; operational risk hypothesis; excluded from proprietary baseline | EXCLUDED | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **MinIO** | S3-compatible object storage server (Historical candidate) | Version `RELEASE.2024-11-07` | `https://github.com/minio/minio` | AGPL-3.0 | N/A | Network copyleft obligations; excluded from baseline in favor of local POSIX storage | EXCLUDED | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **ONNX Runtime** | Hardware-accelerated AI model inference engine | Version `v1.19.2` | `https://github.com/microsoft/onnxruntime` | MIT | N/A (Execution runtime) | Include Microsoft MIT notice; verify execution-provider dependencies (CUDA/CPU) | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **YOLOX** | Candidate real-time object detection model family | Version `v0.3.0` | `https://github.com/Megvii-BaseDetection/YOLOX` | Apache-2.0 | NOT VERIFIED — EXACT MODEL ARTIFACT NOT PINNED | Include Apache-2.0 notice; exact model weight file, SHA-256, and training dataset provenance unpinned | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **RT-DETR** | Candidate real-time detection transformer model family | Version `v2.0` | `https://github.com/PaddlePaddle/PaddleDetection` | Apache-2.0 | NOT VERIFIED — EXACT MODEL ARTIFACT NOT PINNED | Include Apache-2.0 notice; exact model weight file, SHA-256, and training dataset provenance unpinned | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Valkey** | In-memory cache and ephemeral queue store | Version `7.2.6` | `https://github.com/valkey-io/valkey` | BSD-3-Clause | N/A | Retain BSD 3-Clause copyright notices in binary distributions | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **PostgreSQL** | Primary relational and event metadata database | Version `16.4` | `https://www.postgresql.org/` | PostgreSQL License | N/A | Preserve standard PostgreSQL copyright notice; verify extensions separately | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **TimescaleDB** | Time-series data extension for high-frequency metrics | Version candidate `2.16.x` | `https://github.com/timescale/timescaledb` | Apache-2.0 / Timescale License (TSL) | N/A | Do not approve until exact version, license split, and deployment obligations are verified | NOT VERIFIED (Unapproved) | `DOCUMENTED_ONLY` |
| **React** | Web Administration Console UI framework | Version candidate `18.3.x` | `https://github.com/facebook/react` | MIT | N/A | Retain Facebook MIT notice in web client bundles | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Vite** | Web Administration Console build and bundling tool | Version candidate `5.4.x` | `https://github.com/vitejs/vite` | MIT | N/A | Retain Vite MIT notice; development and bundling tooling | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Flutter** | Multi-platform mobile UI framework (Android client) | Version candidate `3.24.x` | `https://github.com/flutter/flutter` | BSD-3-Clause | N/A | Retain Google BSD-3-Clause copyright notice in mobile APK distributions | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Dart** | Programming language for Flutter client | Version candidate `3.5.x` | `https://github.com/dart-lang/sdk` | BSD-3-Clause | N/A | Retain BSD-3-Clause copyright notices | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Go** | Programming language for sidecars and networking utilities | Version candidate `1.23.x` | `https://github.com/golang/go` | BSD-3-Clause | N/A | Retain Google BSD-3-Clause copyright notices in compiled binaries | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Python** | Runtime language for backend AI pipeline services | Version candidate `3.11.x` | `https://www.python.org/` | PSF License | N/A | Retain Python Software Foundation notices; verify bundled C-extensions | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **gRPC & Protobuf** | Inter-process communication and protocol serialisation | Version candidate `v1.66.x` | `https://github.com/grpc/grpc` | Apache-2.0 / BSD-3-Clause | N/A | Retain Apache-2.0 and BSD notices in generated code and runtimes | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **WireGuard** | Secure site-to-site VPN tunnel infrastructure | Kernel module / `wireguard-tools` | `https://git.zx2c4.com/wireguard-tools/` | GPL-2.0 (Kernel) / MIT / BSD | N/A | Infrastructure OS networking boundary; no linking with proprietary application code | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |
| **Trivy** | Container and filesystem license/security scanner | Version `v0.56.2` | `https://github.com/aquasecurity/trivy` | Apache-2.0 | N/A (DevOps Tool) | Include Apache-2.0 notice; internal CI/CD tool, not distributed in runtime images | CANDIDATE — NOT APPROVED FOR INTEGRATION | `VERIFIED_BY_OFFICIAL_LICENSE` |

---

## 2. MODEL ARTIFACT & WEIGHT PROVENANCE REGISTER

A permissive source-code repository license (e.g. Apache-2.0 or MIT) does **not** automatically grant commercial rights to pre-trained model weights, fine-tuning checkpoints, or underlying training datasets. The following register tracks candidate model artifacts and documents outstanding provenance gaps:

| Model Architecture | Candidate Artifact File | Download Source / URL | SHA-256 Hash | Training Dataset | Dataset License | Commercial Clearance Status | Provenance Gap & Required Action |
|---|---|---|---|---|---|---|---|
| **YOLOX-S / YOLOX-M** | `yolox_s.onnx` / `yolox_m.onnx` | `UNPINNED` (Official Megvii releases pending pin) | `NOT VERIFIED` | MS COCO 2017 (Standard) | CC BY 4.0 (COCO Images: Flickr terms apply) | `NOT VERIFIED — EXACT ARTIFACT NOT PINNED` | Download URL and exact release tag not pinned; SHA-256 hash not computed; verify pre-training dataset licenses before commercial deployment. |
| **RT-DETR-R18 / R50** | `rtdetr_r18vd.onnx` | `UNPINNED` (PaddleDetection releases pending pin) | `NOT VERIFIED` | MS COCO 2017 / Objects365 | Objects365 carries non-commercial research restrictions | `BLOCKED — SUSPECT DATASET RESTRICTIONS` | Standard pre-trained weights trained on Objects365 are strictly non-commercial. Clean-room fine-tuning from COCO-only or custom factory dataset required. |
| **ByteTrack (Re-ID Feature)** | Mathematical Tracker (Kalman + Hungarian) | N/A (Pure algorithmic state tracker) | N/A | None (No weights required for standard ByteTrack) | N/A | `CLEARED (Clean-Room Implementation)` | Standard ByteTrack tracking logic requires no weights; any integrated Re-ID feature extractor must be independently pinned and audited. |

---

## 3. LICENSE GOVERNANCE RULES

1. **Maintain a Pinned Dependency Inventory:** Every direct and transitive dependency must be recorded with its exact repository, release version, or commit hash. Floating versions (`latest`) are strictly prohibited.
2. **Generate an SBOM for Every Release:** Every production or test release build shall generate an automated Software Bill of Materials (SBOM) using standard tooling (e.g. Syft/Trivy) in SPDX 2.3 or CycloneDX format.
3. **Scan Direct and Transitive Dependencies:** Continuous integration pipelines must scan direct and transitive dependencies for reciprocal copyleft (GPL, AGPL, SSPL) licenses. Any unapproved license triggers an immediate build block.
4. **Preserve Copyright and Attribution Notices:** All upstream permissive license texts (MIT, Apache-2.0, BSD-3-Clause, PostgreSQL) and copyright headers must be compiled and distributed in a top-level `THIRD_PARTY_NOTICES.md` file.
5. **Review Model Weights and Datasets Separately from Source Code:** A permissive source-code license does not imply that model weights or training datasets are permissively licensed. Model weights, pretraining checkpoints, and dataset licenses must be verified and recorded independently.
6. **Record License Changes Between Releases:** Dependency upgrades must be audited for upstream license shifts (e.g. BSD to SSPL/RSAL transitions) prior to updating lockfiles.
7. **Require Explicit Approval for Outside Components:** Any third-party component, library, model, or tool outside the permitted permissive license policy requires an explicit documented legal review and formal owner approval.
8. **Do Not Claim Zero Legal Risk:** No software engineering endeavor is legally risk-free. Compliance is maintained through continuous verification, clean-room authoring, and strict adherence to documented license obligations.

