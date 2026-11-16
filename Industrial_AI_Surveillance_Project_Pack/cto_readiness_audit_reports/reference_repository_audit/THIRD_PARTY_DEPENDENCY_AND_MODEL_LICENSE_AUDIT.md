# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## PART 8.3: THIRD-PARTY DEPENDENCY AND AI MODEL LICENSE AUDIT
### Antigravity Flash 3.8 — CTO Engineering Audit
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** AUDIT-REF-03  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\reference_repository_audit\THIRD_PARTY_DEPENDENCY_AND_MODEL_LICENSE_AUDIT.md`  
**Audit Date:** 2026-11-12  

---

## 1. PRETRAINED AI MODEL WEIGHTS & RUNTIME LICENSING AUDIT

### 1.1 The Ultralytics YOLO Licensing Trap (AGPL-3.0 vs. Commercial Enterprise)
A critical risk discovered during this forensic audit concerns the planned use of Ultralytics YOLO models (YOLOv8 and YOLOv11).
- **License Model:** Ultralytics distributes its codebase and official pretrained model weights under the **GNU Affero General Public License v3.0 (AGPL-3.0)**, supplemented by a commercial enterprise license.
- **The AGPL Network Trigger (Section 13):** The AGPL-3.0 states that if a modified or integrated software program is executed on a server and accessed by users over a computer network (even internal company networks or web browsers), the operator **must provide the complete corresponding source code to all network users**.
- **Ultralytics Commercial Position:** Ultralytics explicitly states that using YOLOv8/v11 in any proprietary, closed-source, or commercial system without making the entire software solution open-source requires purchasing an **Ultralytics Commercial Enterprise License** (starting at thousands of dollars per camera/server annually).
- **Engineering Verdict:** Building our platform upon Ultralytics YOLO directly violates the Project Owner's mandate of **$0 software subscription and licensing cost**. If deployed without a paid license, it exposes BNF and RNF to copyleft source disclosure demands.

### 1.2 Zero-Cost Permissive Model Alternatives (Apache-2.0)
To achieve complete compliance with zero licensing fees, the AI pipeline will standardize exclusively on permissive open-source model architectures:

| Model Architecture | Organization / Origin | Official License | SPDX ID | Runtime Format | Industrial Applicability |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **YOLOX** | Megvii Technology | Apache License 2.0 | `Apache-2.0` | ONNX / TensorRT | Primary Person & Object Detector; anchor-free; native companion to ByteTrack; zero royalties |
| **RT-DETR** | Baidu (PaddleDetection) | Apache License 2.0 | `Apache-2.0` | ONNX / TensorRT | Real-Time Detection Transformer; eliminates NMS post-processing; superior edge accuracy |
| **MobileNetV3-SSD** | Google / ONNX Model Zoo | Apache License 2.0 | `Apache-2.0` | ONNX | Ultra-lightweight fallback for edge nodes with restricted CPU |
| **ResNet-50 / EfficientNet**| PyTorch / torchvision | BSD 3-Clause | `BSD-3-Clause` | ONNX | Secondary classifiers for PPE compliance and fall posture verification |

**Decision:** Formally ban Ultralytics YOLOv8/v11 from both development and production. Standardize on **YOLOX** and **RT-DETR** converted to open ONNX formats executed via Microsoft ONNX Runtime.

---

## 2. TRAINING DATASET LICENSES & PRODUCTION DEPLOYMENT IMPLICATIONS

Any model deployed in a commercial factory environment inherits legal restrictions from the datasets used during its training:

1. **COCO (Common Objects in Context):**
   - *License:* Creative Commons Attribution 4.0 International (`CC BY 4.0`).
   - *Commercial Status:* Fully permitted for commercial use. Requires attribution in system documentation and third-party notices.
2. **CrowdHuman Dataset:**
   - *License:* Non-Commercial Research Use Only.
   - *Risk Analysis:* Pretrained weights initialized on CrowdHuman must NOT be bundled or deployed into commercial factory systems. Weights must be trained solely on COCO or proprietary factory-annotated datasets created in CVAT.
3. **Pascal VOC:**
   - *License:* Open access for research. Pretrained backbones generally permissible, but COCO pre-training is legally safer.
4. **Proprietary Factory Training Data:**
   - Datasets created internally using our self-hosted CVAT instance (capturing non-biometric synthetic/anonymized factory floor imagery) remain 100% the proprietary property of BNF and RNF with zero external licensing claims.

---

## 3. CORE RUNTIME DEPENDENCIES & LIBRARIES

### 3.1 OpenCV Core Runtime
- **License:** Apache License 2.0 (`Apache-2.0`).
- **Compliance Requirement:** Must be compiled or installed without patent-encumbered proprietary algorithms:
  - Set `OPENCV_ENABLE_NONFREE=OFF` during C++ builds.
  - Excludes patented SURF/SIFT implementations. Our pipeline relies strictly on standard matrix operations, Gaussian blur, and grayscale frame differencing (`cv2.absdiff`), which are completely non-infringing.

### 3.2 FFmpeg Streaming & Decoding Runtime
- **License Boundary:** FFmpeg is distributed under **LGPL-2.1-or-later** by default. However, enabling certain third-party libraries (e.g. `libx264`, `libx265`) converts the resulting FFmpeg binary into a **GPL-2.0 / GPL-3.0** binary.
- **Compliance Architecture:**
  - *Option A (System Package Dynamic Linking):* Rely on dynamically linked system-installed FFmpeg binaries invoked via standard OS processes. Under established copyright law, invoking CLI sub-processes (`exec.Command("ffmpeg", ...)`) across standard OS process boundaries does not trigger GPL copyleft contamination of the host application.
  - *Option B (Zero-Transcode Video Streaming):* Ingestion via `go2rtc` performs zero transcoding for H.264 camera streams, completely bypassing FFmpeg encoding libraries for browser delivery.

### 3.3 Microsoft ONNX Runtime
- **License:** MIT License (`MIT`).
- **Commercial Status:** 100% free and open-source. Provides cross-platform hardware acceleration on both CPU (OpenMP / oneDNN) and GPU (CUDA / TensorRT execution providers) without proprietary runtime licensing costs.

### 3.4 Go & Python Package Ecosystems

| Package | Language | Declared License | Compatibility Ruling |
| :--- | :--- | :--- | :--- |
| `github.com/pion/webrtc` | Go | MIT | **Approved** (Pure Go WebRTC stack) |
| `github.com/gin-gonic/gin` | Go | MIT | **Approved** (High-throughput REST API) |
| `github.com/jackc/pgx` | Go | MIT | **Approved** (Pure Go PostgreSQL driver) |
| `numpy` | Python | BSD 3-Clause | **Approved** (Matrix manipulation) |
| `scipy` | Python | BSD 3-Clause | **Approved** (Linear sum assignment solver) |
| `torch` / `torchvision` | Python | BSD 3-Clause | **Approved** (PyTorch execution runtime) |
| `pydantic` | Python | MIT | **Approved** (Data validation) |

---

## 4. DATABASE & INFRASTRUCTURE LICENSING FORENSICS

### 4.1 PostgreSQL
- **License:** PostgreSQL License (similar to MIT / BSD).
- **Commercial Status:** Completely free, open-source, and permissive. Zero subscription costs. Unrestricted multi-node factory deployment.

### 4.2 Redis vs. Valkey vs. In-Process Channels
- **The Redis Licensing Shift:** In March 2024, Redis transitioned from BSD-3-Clause to dual **RSALv2 / SSPLv1** non-open-source source-available licenses, terminating its pure open-source status.
- **Architectural Mitigation:**
  - For inter-thread/inter-process coordination within our Go backend, we rely primarily on native **Go channels and sync primitives**.
  - Where a high-performance in-memory cache is required, we use **Valkey** (the official Linux Foundation pure BSD-3-Clause fork of Redis supported by AWS, Google, and Red Hat), guaranteeing $0 licensing exposure.

### 4.3 MinIO vs. Local POSIX Filesystem Storage
- **The MinIO AGPL Risk:** MinIO shifted to AGPL-3.0. If an application integrates with MinIO over certain SDKs or networks, AGPL compliance audits often challenge the boundary.
- **Zero-Cost Architectural Decision:** Video clips, camera snapshots, and incident recordings will be stored directly on **local NVMe/SATA enterprise storage using standard Linux POSIX filesystem calls** and served via authenticated Go HTTP file handlers. This eliminates MinIO entirely, saving RAM, compute overhead, and avoiding AGPL scrutiny.

---

## 5. SUMMARY OF LICENSING SAFEGUARDS

1. **NO Ultralytics YOLO:** Replaced with Apache-2.0 YOLOX and RT-DETR.
2. **NO Proprietary DeepStream SDK:** Replaced with ONNX Runtime on CUDA/CPU.
3. **NO Unsafe pyzk:** Replaced with ZKBioTime REST API and direct database queries.
4. **NO Redis SSPL / MinIO AGPL:** Replaced with Valkey (BSD) and standard POSIX filesystem storage.
5. **Result:** Total recurring software licensing fees = **$0.00**.

