> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## SUPPLEMENTARY AUDIT DOCUMENT 04
### AI MODELS AND DATASETS FORENSIC LICENSE AUDIT
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** SUPP-AUDIT-04  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\supplementary_license_audit\AI_MODELS_AND_DATASETS_LICENSE_AUDIT.md`  
**Audit Date:** 2026-11-16  
**Auditor:** Principal AI Engineer / Enterprise Solution Architect / CTO Advisory  

---

## 1. EXECUTIVE SUMMARY & OBJECTIVE

This document provides a forensic audit of the licensing, copyright, patent grants, and commercial restrictions governing every artificial intelligence (AI) model and training dataset proposed for the BNF and RNF Multi-Factory Industrial AI Surveillance Platform.

Under the Project Owner's explicit directive, **all models and datasets must be 100% free of commercial subscription fees, free of mandatory licensing royalties, free of non-commercial research clauses, and free of AGPL copyleft triggers that could force source code disclosure.**

---

## 2. THE ULTRALYTICS YOLOV8N FORENSIC AUTOPSY

The original discovery documents proposed deploying `YOLOv8n` for edge person and object detection. A deep forensic audit of Ultralytics licensing reveals severe commercial and intellectual property risks:

```
+---------------------------------------------------------------------------------------------------+
|                            THE ULTRALYTICS AGPL-3.0 COMMERCIAL EXPOSURE                           |
+---------------------------------------------------------------------------------------------------+
|  1. Source Code License: GNU Affero General Public License v3.0 (AGPL-3.0)                        |
|  2. Pretrained Weights License: Bound to AGPL-3.0 (Derivative of AGPL codebase & training loop)    |
|  3. Section 13 Network Trigger: Running YOLOv8 on an edge server accessed by web browsers or     |
|     mobile apps legally obligates the operator to release the COMPLETE host application source!   |
|  4. Commercial Buy-Out: Ultralytics charges $5,000 to $15,000+ per year for an Enterprise License |
+---------------------------------------------------------------------------------------------------+
```

### Forensic Breakdown of YOLOv8n Rights:
1. **Model Source Code License:** GNU AGPL-3.0.
2. **Pretrained Weights License:** AGPL-3.0. Ultralytics asserts copyright over official `.pt` weight files published in their GitHub releases.
3. **Training Dataset:** Trained primarily on MS-COCO (`CC BY 4.0`), but model architecture, loss functions, and weight tensors are copyrighted under AGPL-3.0.
4. **Fine-Tuning Rights:** Permitted, but resulting fine-tuned weights inherit AGPL-3.0 copyleft obligations as derivative works.
5. **Commercial Use Rights:** Strictly conditioned on open-sourcing the entire software stack under AGPL-3.0, or purchasing an Ultralytics Commercial Enterprise License.
6. **Redistribution & Embedded Deployment:** Prohibited in proprietary closed-source commercial appliances without an enterprise contract.
7. **Verdict:** **PERMANENTLY BANNED FROM THE ARCHITECTURE**. Using YOLOv8n violates the zero-cost mandate and creates immediate legal exposure.

---

## 3. PERMISSIVE OPEN-SOURCE MODEL ECOSYSTEMS (APACHE-2.0 / BSD)

To replace Ultralytics models while maintaining high accuracy and real-time inference speeds, the following permissive model architectures were audited:

### 3.1 YOLOX (`Megvii-BaseDetection/YOLOX`)
- **Official License:** Apache License 2.0 (`SPDX-License-Identifier: Apache-2.0`). [`VERIFIED_BY_OFFICIAL_LICENSE`]
- **Origin:** Megvii Technology.
- **Architecture Highlights:** Anchor-free object detector, decoupled detection head, SimOTA dynamic label assignment.
- **Commercial Rights:** Fully permitted for commercial use. Grants explicit patent licenses. Allows proprietary sublicensing and closed-source redistribution.
- **Pretrained Weights:** Official weights (`yolox_nano.onnx`, `yolox_tiny.onnx`, `yolox_s.onnx`) released under Apache-2.0.
- **Benchmark:** `YOLOX-Nano` (0.91M parameters, 26.1% mAP on COCO, $< 10$ms on CPU). Ideal for multi-stream edge inference.

### 3.2 RT-DETR (`PaddlePaddle/PaddleDetection` / Real-Time DETR)
- **Official License:** Apache License 2.0 (`SPDX-License-Identifier: Apache-2.0`). [`VERIFIED_BY_OFFICIAL_LICENSE`]
- **Origin:** Baidu Inc.
- **Architecture Highlights:** Real-time Detection Transformer. Completely eliminates Non-Maximum Suppression (NMS) post-processing, preventing CPU bottlenecks during multi-person factory crowd scenes.
- **Commercial Rights:** Fully permitted for commercial and enterprise deployment with zero royalties.
- **Benchmark:** Outperforms YOLOv8 at identical latency, executing seamlessly via ONNX Runtime on CUDA or CPU.

### 3.3 Torchvision / PyTorch Model Zoo
- **Official License:** BSD 3-Clause (`SPDX-License-Identifier: BSD-3-Clause`). [`VERIFIED_BY_OFFICIAL_LICENSE`]
- **Origin:** PyTorch Foundation / Linux Foundation.
- **Candidates:**
  - `MobileNetV3-Large-SSD`: Apache/BSD, ultra-fast person detector.
  - `ResNet-50` / `EfficientNet-B0`: Standard classification backbones for secondary PPE compliance checks.

---

## 4. USE-CASE BY USE-CASE MODEL SELECTION MATRIX

Every target surveillance capability is mapped to an audited, permissively licensed model architecture:

| Surveillance Capability | Primary Model Candidate | License | Runtime Format | Execution Provider | Hardware Target |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Person Detection** | **YOLOX-Tiny** | Apache-2.0 | ONNX | ONNX Runtime (CUDA / CPU)| Local Quadro P600 / Server |
| **PPE Compliance (Hard Hat / Vest)**| **YOLOX-S (Fine-Tuned)** | Apache-2.0 | ONNX | ONNX Runtime (CUDA / CPU)| Server GPU / Workstation |
| **Forklift / Vehicle Detection**| **YOLOX-Tiny** | Apache-2.0 | ONNX | ONNX Runtime (CUDA / CPU)| Local Quadro P600 / Server |
| **Worker Fall & Posture Detection**| **RT-DETR-R18 / ResNet-50**| Apache-2.0 / BSD| ONNX | ONNX Runtime (CUDA / CPU)| Server GPU / Workstation |
| **Fire & Smoke Detection** | **Dual-Stream CNN (PyTorch)**| Apache-2.0 | ONNX | ONNX Runtime (CPU / CUDA)| Server / Edge CPU |
| **Multi-Object Tracking** | **ByteTrack (Math Clean-Room)**| MIT | Native C++/Go| In-Process CPU | Host CPU ($< 2$ms/frame) |
| **Face Recognition (If Authorized)**| **ArcFace (InsightFace Apache)**| Apache-2.0 | ONNX | ONNX Runtime (CUDA) | Dedicated Secure Server |
| **Re-Identification (Re-ID)** | **ELIMINATED** (Spatial IoU)| N/A | Math Matrix | CPU Algorithm | Zero GPU Overhead |

---

## 5. TRAINING DATASET LICENSES & PRODUCTION DEPLOYMENT BOUNDARIES

```
+---------------------------------------------------------------------------------------------------+
|                                 DATASET LEGAL COMPLIANCE SUMMARY                                  |
+---------------------------------------------------------------------------------------------------+
|  1. MS-COCO (Common Objects in Context):                                                          |
|     - License: Creative Commons Attribution 4.0 International (CC BY 4.0)                         |
|     - Commercial Status: APPROVED. Commercial use permitted with attribution in NOTICE file.       |
|                                                                                                   |
|  2. CrowdHuman Dataset:                                                                           |
|     - License: Non-Commercial Research Use Only.                                                  |
|     - Commercial Status: STRICTLY BANNED. Models trained on CrowdHuman CANNOT be deployed.       |
|                                                                                                   |
|  3. Pascal VOC:                                                                                   |
|     - License: Open research access. Permitted, but COCO is legally cleaner.                      |
|                                                                                                   |
|  4. In-House Factory Datasets (Annotated via Self-Hosted CVAT):                                   |
|     - License: 100% Proprietary Property of BNF and RNF.                                         |
|     - Commercial Status: APPROVED. Zero external copyright, zero third-party claims.              |
+---------------------------------------------------------------------------------------------------+
```

---

## 6. AI LICENSING COMPLIANCE ACTION PLAN

1. **Purge YOLOv8 Dependencies:** Remove all imports of `ultralytics` and delete any downloaded `yolov8*.pt` weights from development machines.
2. **Standardize on ONNX Weights:** Export all model weights into standard, versioned `.onnx` files stored in a dedicated models directory (`/data/models/`).
3. **Preserve Model Notices:** Include Megvii (YOLOX) and Baidu (RT-DETR) Apache-2.0 copyright notices in the system documentation.
4. **Zero AI Licensing Spend:** By executing YOLOX and RT-DETR via ONNX Runtime, total recurring AI model license fees equal **$0.00**.

