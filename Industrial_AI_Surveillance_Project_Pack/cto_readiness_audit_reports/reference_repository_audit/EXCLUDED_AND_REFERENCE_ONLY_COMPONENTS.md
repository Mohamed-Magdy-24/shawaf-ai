> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## PART 8.5: EXCLUDED AND REFERENCE-ONLY COMPONENTS REGISTRY
### Antigravity Flash 3.8 — CTO Engineering Audit
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** AUDIT-REF-05  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\reference_repository_audit\EXCLUDED_AND_REFERENCE_ONLY_COMPONENTS.md`  
**Audit Date:** 2026-11-12  

---

## 1. PURPOSE & ENFORCEMENT RULES

This document serves as the formal architectural exclusion list and quarantine register for the BNF and RNF Industrial AI Surveillance Platform. 

Any component listed in this registry is either **STRICTLY PROHIBITED** from entering the codebase, or **QUARANTINED AS CONCEPTUAL REFERENCE ONLY**. Any pull request, automated dependency upgrade, or code snippet that attempts to introduce an excluded component will be immediately rejected at code review and CI/CD validation gates.

---

## 2. CATEGORY C: FORMALLY EXCLUDED FROM PRODUCTION & CODEBASE

### 2.1 NVIDIA DeepStream SDK & Reference Apps
- **Declared License:** Proprietary NVIDIA DeepStream SDK EULA / BSD 3-Clause (Sample apps only).
- **Status:** **PERMANENTLY EXCLUDED FROM INITIAL ARCHITECTURE**.
- **Technical & Architectural Autopsy:**
  1. *Hardware Incompatibility with Workstation:* The Project Owner's development workstation is equipped with an NVIDIA Quadro P600 GPU based on the **Pascal architecture (Compute Capability SM 6.1)**. DeepStream 6.4/7.0+ officially dropped support for Pascal GPUs and requires Turing (SM 7.5), Ampere (SM 8.6), or Ada Lovelace architectures. Compiling or running DeepStream on the development machine results in immediate CUDA initialization failures.
  2. *Proprietary Vendor Lock-in & EULA:* DeepStream SDK is proprietary software owned by NVIDIA. It cannot run on non-NVIDIA edge hardware (e.g. Intel NUCs with OpenVINO or AMD CPUs), violating our hardware flexibility mandate.
  3. *Excessive System Complexity:* DeepStream requires building custom GStreamer C/C++ plugins, managing GLib main loops, and debugging low-level memory buffer pointers (`NvBufSurface`). A memory leak or pointer corruption inside a GStreamer pad crashes the entire multi-camera pipeline.
- **Approved Permissive Replacement:** Microsoft ONNX Runtime (MIT License) with CUDA / CPU execution providers, executed within isolated worker processes orchestrated by Go.

---

### 2.2 pyzk (`fananimi/pyzk`)
- **Declared License:** LGPL-3.0 / GPL.
- **Status:** **STRICTLY PROHIBITED FROM RUNNING IN PRODUCTION**.
- **Technical & Architectural Autopsy:**
  1. *Microcontroller Lockup Hazard:* `pyzk` communicates directly with ZKTeco attendance devices over raw UDP port 4370. The internal network stack of ZKTeco standalone terminals uses a single-threaded embedded microcontroller. If two connection attempts occur simultaneously or packets are dropped during an attendance pull (`CMD_ATTLOG_RRQ`), the device crashes and freezes completely. In an active industrial factory with 200+ employees clocking in during shift change, freezing the physical clocks requires a manual hardware power-cycle, causing severe operational disruption.
  2. *Unmaintained Abandonware:* The repository has sporadic community pull requests and lacks automated integration tests against modern ZKTeco Linux-based biometric terminals (e.g. SilkBio, GreenLabel, MB560).
  3. *Copyleft Risk:* Contains ambiguous LGPL/GPL licensing declarations that create intellectual property friction.
- **Approved Production Replacement:** Direct integration with the existing factory attendance infrastructure via the official **ZKBioTime REST API** (`/api/v2/transactions`) or scheduled read-only queries against the centralized Microsoft SQL Server attendance database view.

---

### 2.3 Ultralytics YOLO (v8 and v11)
- **Declared License:** GNU AGPL-3.0 / Ultralytics Commercial Enterprise License.
- **Status:** **STRICTLY PROHIBITED FROM CODEBASE AND CONTAINER BUILDS**.
- **Technical & Architectural Autopsy:**
  1. *The AGPL-3.0 Legal Trap:* Ultralytics moved from GPL to AGPL-3.0. Under AGPL-3.0 Section 13, deploying an application that interacts with users over a network (such as our web dashboard or mobile app) legally obligates the organization to make its complete proprietary source code publicly downloadable.
  2. *Aggressive Commercial Pricing:* Ultralytics requires organizations that do not wish to open-source their commercial or enterprise software to purchase a commercial license, which costs thousands of dollars per year. This directly violates the Project Owner's mandate of **$0.00 software licensing costs**.
- **Approved Permissive Replacement:** **YOLOX** (Megvii, Apache-2.0) and **RT-DETR** (Baidu, Apache-2.0), converted to standard ONNX models and executed via Microsoft ONNX Runtime.

---

### 2.4 Redis (Versions 7.4 and Newer)
- **Declared License:** Dual RSALv2 / SSPLv1 (Source-Available / Non-Open-Source).
- **Status:** **EXCLUDED IN FAVOR OF VALKEY OR NATIVE CHANNELS**.
- **Technical & Architectural Autopsy:**
  1. *License Termination:* On March 20, 2024, Redis Ltd. abandoned the BSD-3-Clause license. New versions cannot be used in commercial SaaS or commercial deployments without scrutiny under SSPL copyleft provisions.
- **Approved Permissive Replacement:** Native **Go channels and sync primitives** for internal messaging; **Valkey 7.x** (Linux Foundation, BSD-3-Clause) if a distributed in-memory cache is ever required.

---

### 2.5 MinIO Object Storage
- **Declared License:** GNU AGPL-3.0.
- **Status:** **EXCLUDED IN FAVOR OF LOCAL POSIX STORAGE**.
- **Technical & Architectural Autopsy:**
  1. *AGPL Contamination Risk:* MinIO's transition to AGPL-3.0 has made integrating its SDKs or REST endpoints a common source of legal dispute for private commercial software.
  2. *Unnecessary Resource Consumption:* Running MinIO consumes 1.5-2.5 GB of RAM per edge node simply to store video segments.
- **Approved Permissive Replacement:** Direct **Linux ext4/XFS local filesystem storage** using structured folder hierarchies, zero extra containers, zero extra memory footprint, and zero licensing friction.

---

## 3. CATEGORY B: STRICTLY QUARANTINED ARCHITECTURAL REFERENCES

The following repositories contain valuable design principles but carry copyleft licenses that forbid code borrowing:

### 3.1 Viseron (`roflcoopter/viseron`)
- **Declared License:** GNU GPL-3.0-only.
- **Quarantine Policy:** **STRICT CONCEPTUAL STUDY ONLY**.
- **What is Approved for Reference:**
  - Studying its tiered storage retention logic and automated segment pruning heuristics.
  - Studying its component lifecycle state machines.
- **What is Strictly Forbidden:**
  - Copying or translating any Python classes, methods, or helper utilities.
  - Linking Viseron as a library or Python package.

---

### 3.2 ZoneMinder (`ZoneMinder/zoneminder`)
- **Declared License:** GNU GPL-2.0-or-later.
- **Quarantine Policy:** **STRICT CONCEPTUAL STUDY ONLY**.
- **What is Approved for Reference:**
  - Polygon exclusion and motion alarm zone intersection algorithms.
- **What is Strictly Forbidden:**
  - Copying any C++ daemon code (`zmc.cpp`, `zma.cpp`).
  - Adopting ZoneMinder's fatal anti-pattern of writing individual JPEG images to disk per frame (which destroys disk IOPS).

---

### 3.3 Grafana OSS
- **Declared License:** GNU AGPL-3.0.
- **Quarantine Policy:** **SEPARATE STANDALONE NETWORK TOOL ONLY**.
- **Rules of Use:**
  - If used for internal hardware metrics visualization during development, it must run as an independent, unmodified container.
  - It must never be embedded via iframes into the customer-facing UI.
  - In production, system observability will use Prometheus with an embedded native Go administrative metrics dashboard.

---

## 4. AUDIT & CI/CD ENFORCEMENT SUMMARY

| Prohibited Component | Prohibited Pattern | Automated CI/CD Detection Rule |
| :--- | :--- | :--- |
| `ultralytics` | Python package / import | `grep -rn "ultralytics" requirements.txt src/` -> Fail Build |
| `pyzk` | Python package / import | `grep -rn "pyzk" requirements.txt src/` -> Fail Build |
| `deepstream` | SDK includes / GStreamer nv* | `grep -rn "pyds\|nvinfer\|nvstreammux" src/` -> Fail Build |
| `minio` | S3 client / MinIO SDK | `grep -rn "github.com/minio/minio-go" go.mod` -> Fail Build |
| `viseron` / `zoneminder` | Direct code inclusion | AST and token similarity scanners (Trivy / Syft) |

