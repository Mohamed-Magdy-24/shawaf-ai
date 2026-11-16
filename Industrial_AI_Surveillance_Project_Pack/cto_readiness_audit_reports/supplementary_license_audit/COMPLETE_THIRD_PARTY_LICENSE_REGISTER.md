> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## SUPPLEMENTARY AUDIT DOCUMENT 03
### COMPLETE THIRD-PARTY LICENSE REGISTER & SBOM STRATEGY
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** SUPP-AUDIT-03  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\supplementary_license_audit\COMPLETE_THIRD_PARTY_LICENSE_REGISTER.md`  
**Audit Date:** 2026-11-16  
**Auditor:** Principal AI Engineer / Enterprise Solution Architect / CTO Advisory  

---

## 1. COMPREHENSIVE THIRD-PARTY INVENTORY & CLASSIFICATION

Every external library, runtime binary, database, framework, and tool evaluated for the BNF and RNF Industrial AI Surveillance Platform is categorized under the following five-tier framework:

- **CATEGORY A: PERMISSIVE — APPROVED IN PRINCIPLE** (MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, PostgreSQL License).
- **CATEGORY B: CONDITIONAL — LEGAL REVIEW REQUIRED** (LGPL, MPL, EPL). Permitted only as dynamically linked system libraries or standalone CLI executables.
- **CATEGORY C: COPYLEFT — EXCLUDED FROM THE PROPRIETARY CORE** (GPL, AGPL, SSPL). Prohibited from being embedded, statically linked, or included within proprietary application source code.
- **CATEGORY D: PROPRIETARY / COMMERCIAL — EXCLUDED** (Paid SDKs, mandatory SaaS subscriptions, restrictive hardware EULAs).
- **CATEGORY E: UNKNOWN / AMBIGUOUS — BLOCKED** (Unlicensed or conflicting declarations).

---

## 2. MASTER DEPENDENCY REGISTER

| Component / Library | Origin / Ecosystem | Declared License | SPDX Identifier | Category | Allowed Production Role | Compliance Action Required |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **go2rtc** | Go Binary | MIT License | `MIT` | **Cat A** | Edge Video Streaming Gateway | Include MIT notice in `THIRD_PARTY_NOTICES.md` |
| **Microsoft ONNX Runtime**| C++ / Python Engine | MIT License | `MIT` | **Cat A** | Hardware-Accelerated AI Inference | Include Microsoft MIT notice |
| **YOLOX** | Python / ONNX | Apache License 2.0 | `Apache-2.0` | **Cat A** | Primary Person & Safety Object Detector | Include Apache-2.0 notice & Megvii attribution |
| **RT-DETR** | Python / ONNX | Apache License 2.0 | `Apache-2.0` | **Cat A** | Secondary Real-Time Detection Transformer | Include Apache-2.0 notice & Baidu attribution |
| **ByteTrack** | Python / C++ | MIT License | `MIT` | **Cat A** | Multi-Object Tracking Baseline | Clean-room re-implementation; cite paper & MIT |
| **PostgreSQL 16** | Database Engine | PostgreSQL License | `PostgreSQL` | **Cat A** | Relational & Event Telemetry Database | Standard PostgreSQL copyright notice |
| **OpenCV Core** | C++ / Python Lib | Apache License 2.0 | `Apache-2.0` | **Cat A** | Grayscale Frame Differencing & Preprocessing | Compile with `OPENCV_ENABLE_NONFREE=OFF` |
| **PyTorch Core** | Python ML Runtime | BSD 3-Clause | `BSD-3-Clause` | **Cat A** | Model Export & Conversion Runtime | Standard BSD notice |
| **Pion WebRTC** | Go Module | MIT License | `MIT` | **Cat A** | WebRTC PeerConnection Protocol | Standard MIT notice |
| **Gin Web Framework** | Go Module | MIT License | `MIT` | **Cat A** | High-Throughput REST API Server | Standard MIT notice |
| **pgx** | Go Module | MIT License | `MIT` | **Cat A** | High-Performance PostgreSQL Driver | Standard MIT notice |
| **Valkey 7.x** | In-Memory Cache | BSD 3-Clause | `BSD-3-Clause` | **Cat A** | Distributed In-Memory Cache (Redis fork) | Standard BSD notice |
| **Flutter SDK** | Mobile Framework | BSD 3-Clause | `BSD-3-Clause` | **Cat A** | Cross-Platform Operator Mobile Client | Standard BSD notices bundled automatically |
| **React 18 / Vite** | Web Frontend | MIT License | `MIT` | **Cat A** | Web Admin Management Dashboard | Standard MIT notice |
| **Tailwind CSS** | CSS Framework | MIT License | `MIT` | **Cat A** | UI Styling System | Standard MIT notice |
| **Prometheus Core** | Monitoring Server | Apache License 2.0 | `Apache-2.0` | **Cat A** | System Metrics Collection & Alerting | Standard Apache-2.0 notice |
| **CVAT Community** | Annotation Suite | MIT License | `MIT` | **Cat A** | Internal Tooling Only (Offline Annotation) | Quarantined from production factory images |
| **FFmpeg (CLI Process)**| Media Utility | LGPL-2.1 / GPL-2.0+ | `LGPL-2.1-or-later` | **Cat B** | Video Segment Slicing via CLI Spawn | Invoke via OS `exec.Command`; do not link C code |
| **Viseron (Source Code)**| Python NVR | MIT License | `MIT` | **Cat A** | Architectural Reference Only | Clean-room authoring; zero code copying |
| **ZoneMinder** | C++ / PHP NVR | GNU GPL v2.0+ | `GPL-2.0-or-later` | **Cat C** | Historical Concept Study Only | Strictly quarantined; zero code reuse |
| **Grafana OSS** | Dashboard Engine | GNU AGPL v3.0 | `AGPL-3.0-only` | **Cat C** | Standalone Network Tool Behind Proxy Only | Do not embed in proprietary UI; no code modification |
| **MinIO** | Object Storage | GNU AGPL v3.0 | `AGPL-3.0-only` | **Cat C** | EXCLUDED from Architecture | Replaced with Local POSIX Filesystem Storage |
| **Ultralytics YOLO** | AI Models (v8/v11)| GNU AGPL v3.0 / Paid | `AGPL-3.0-only` | **Cat C** | EXCLUDED from Architecture | Replaced with Apache-2.0 YOLOX & RT-DETR |
| **pyzk** | Biometric Library | GNU GPL v2.0 | `GPL-2.0-only` | **Cat C** | EXCLUDED from Production | Replaced with ZKBioTime REST API / SQL Sync |
| **NVIDIA DeepStream SDK**| Vision SDK | Proprietary EULA | `NVIDIA-Proprietary`| **Cat D** | EXCLUDED from Initial Architecture | Replaced with ONNX Runtime on CUDA/CPU |
| **Redis (v7.4+)** | In-Memory Cache | Dual RSALv2 / SSPL | `SSPL-1.0` | **Cat D** | EXCLUDED from Architecture | Replaced with Valkey (BSD-3-Clause) |

---

## 3. DEEP-DIVE RUNTIME & DISTRIBUTION LICENSING

### 3.1 FFmpeg Licensing Boundary Management
- **The Core Risk:** FFmpeg can be compiled under either LGPL-2.1 or GPL-2.0/GPL-3.0 depending on build flags. Enabling libraries like `libx264` (GPL), `libx265` (GPL), or `libfdk-aac` (non-free) turns the entire compiled binary into a GPL or non-distributable binary.
- **Architectural Safeguard:**
  1. *Subprocess Isolation:* The proprietary Go backend never links against FFmpeg C shared libraries (`libavcodec.so`, `libavformat.so`). FFmpeg is invoked strictly as an external operating system process (`exec.Command("ffmpeg", "-i", ...)`). Under established legal precedent, running a separate GPL/LGPL CLI utility via standard OS pipes and arguments does not create a derivative work of the host application.
  2. *Zero-Transcode Streaming:* `go2rtc` multiplexes H.264/H.265 RTSP streams to WebRTC and MSE using native pure-Go parsers, completely eliminating the need for FFmpeg during live browser streaming.

### 3.2 OpenCV Build Configuration
- **The Core Risk:** OpenCV includes patented algorithms in `opencv_contrib` (e.g. SIFT, SURF) that require commercial patent licenses if enabled.
- **Architectural Safeguard:** OpenCV is consumed via standard headless distributions (`opencv-python-headless`) or compiled with `OPENCV_ENABLE_NONFREE=OFF`. Our pipeline uses only standard mathematical matrix operations (`absdiff`, `threshold`, `dilate`), which are completely unencumbered by patents.

### 3.3 GStreamer Plugin Quarantine
- **The Core Risk:** GStreamer core is LGPL-2.1, but its plugin ecosystem is divided into "good", "bad", and "ugly". Plugins in `gst-plugins-ugly` (e.g. MP3, MPEG-2 decoders) carry patent or GPL licensing risks.
- **Architectural Safeguard:** GStreamer is completely excluded from our architecture in favor of pure-Go media routing via `go2rtc` and standalone Python/ONNX workers.

### 3.4 Docker Base Images & OS Utilities
- **Base OS Images:** Production containers will standardize on **Alpine Linux** or **Debian Bookworm Slim**.
- **OS Utility Licensing:** While base images contain system utilities licensed under GPL (e.g. `coreutils`, `bash`), shipping proprietary application binaries inside standard Linux distribution containers is universally recognized as independent distribution, provided the OS package sources remain available from standard distribution mirrors.

---

## 4. AUTOMATED SOFTWARE BILL OF MATERIALS (SBOM) STRATEGY

To ensure permanent licensing compliance with zero manual auditing overhead, the CI/CD pipeline will enforce automated SBOM generation and license scanning:

```
+---------------------------------------------------------------------------------------------------+
|                                  AUTOMATED CI/CD COMPLIANCE GATE                                  |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|  1. SBOM Generation (Syft):                                                                       |
|     syft dir:. -o cyclonedx-json=bom.json                                                         |
|     (Extracts complete graph of Go modules, Python wheels, npm packages, and system libraries)    |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|  2. License Vulnerability Scanning (Trivy):                                                       |
|     trivy fs --scanners license --severity HIGH,CRITICAL --ignored-licenses "MIT,Apache-2.0,BSD*"|
|     (Fails CI build if GPL-1.0/2.0/3.0, AGPL, SSPL, or proprietary licenses are detected in core)  |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|  3. Automated Attribution Bundle Generator:                                                       |
|     go-licenses report ./... > licenses.csv                                                       |
|     (Compiles all upstream copyright notices into top-level THIRD_PARTY_NOTICES.md)               |
+---------------------------------------------------------------------------------------------------+
```

---

## 5. LICENSING COMPLIANCE VERDICT

Every component approved for the proprietary core belongs to **Category A (Permissive)**. All Category B components are strictly isolated across OS process boundaries. All Category C, D, and E components are permanently banned from the production build pipeline.

