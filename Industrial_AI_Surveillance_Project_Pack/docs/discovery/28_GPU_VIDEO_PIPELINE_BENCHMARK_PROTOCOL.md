# 28 — GPU Video Pipeline Benchmark Protocol & Multi-Rate Inference Specification

**Document ID:** DISC-28-BENCHMARK  
**Version:** 1.2.0-remediated  
**Date:** 2026-11-16  
**Status:** PROPOSED — NOT APPROVED FOR EXECUTION  
**Classification:** PROPOSED SPK-02 BENCHMARK DESIGN — PENDING OWNER AUTHORIZATION AND TECHNICAL VALIDATION  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Sections 4 & 5; SPK-02 Remediation Directive  

> **DOCUMENT GOVERNANCE NOTICE:**
> This document is a proposed experimental protocol, not an approved production architecture or contractual performance specification. It defines candidate experimental methods for laboratory benchmarking under Phase 1 Spike `SPK-02`. `SPK-02` remains `AWAITING AUTHORIZATION`. No production hardware procurement, fixed runtime dependency, or production threshold is approved by this document.

---

## 1. Executive Summary & Problem Resolution

Earlier architectural baselines assumed a uniform 2 FPS sampling rate across all computer vision models and theoretical "0% CPU decoding" via hardware NVDEC.

**[ENGINEERING REALITY & EXPERIMENTAL SCOPE]:**
1. **Dynamic Event Nyquist Limits & Hypothesis Classification:**
   Fall-event duration, camera capture rate, sampling frequency, and the minimum observation window are variables to be measured using representative labeled footage.
   The 400–700ms duration currently appearing in historical research is an unvalidated working hypothesis, not a universal physical constant or approved system requirement.
   No fixed frame rate, buffer duration, or trigger threshold is approved by this document.
2. **Runtime & Codec Decoupling:** Ingestion must not rely on proprietary or unverified codec-level motion vectors. Furthermore, proprietary runtimes (TensorRT, DeepStream) and restrictive models (Ultralytics YOLOv8) are strictly eliminated from the proposed baseline.
3. **Decoupled Candidate Architecture:**
   - **Baseline Inference Runtime:** ONNX Runtime CPU is the mandatory compatibility baseline.
   - **Optional Acceleration:** ONNX Runtime CUDA is evaluated strictly as an optional experiment after the exact hardware, driver, CUDA, and ONNX Runtime compatibility chain is verified.
   - **Candidate Detectors:** YOLOX and RT-DETR serve as candidate object detector families, subject to exact artifact, checkpoint, weight license, and dataset provenance verification.
   - **Candidate Tracker:** ByteTrack serves as a candidate intra-camera tracking algorithm, subject to exact version and dependency verification.
   - **Pose & Fall Detection Model Separation:** Object detectors (such as YOLOX or RT-DETR) must not be assumed to provide pose/keypoint outputs. For fall detection, pose/keypoint inference is a separate model capability that remains unselected until an exact compatible and permissively licensed model artifact is verified.

---

## 2. Multi-Rate Frame Sampling Policy per Operational Task

> **CANDIDATE — NOT OWNER-APPROVED — NOT VALIDATED**
> The values below are initial experimental variables for benchmarking only. The actual production sampling policy must be derived from measured accuracy, event latency, throughput, CPU/GPU utilization, and camera-network limitations.

```text
+-----------------------------------+--------------------+-------------------+------------------------------------------+-----------------------------------------------------------+
| DETECTED HAZARD / USE CASE        | BASELINE RATE      | BURST RATE        | MINIMUM OBSERVATION WINDOW               | TRIGGER / ESCALATION MECHANISM                            |
+-----------------------------------+--------------------+-------------------+------------------------------------------+-----------------------------------------------------------+
| C-01 / C-02: Person Tracking      | 2.0 – 4.0 FPS      | N/A               | 10 frames (~2.5s)                        | Continuous sub-stream ingest; Kalman filter tracking.     |
| C-05: PPE Classification          | 1.0 – 2.0 FPS      | N/A               | 5 frames (~2.5s)                         | Periodic spatial crop; workers wear PPE continuously.     |
| C-06: Restricted Zone Entry       | 3.0 – 5.0 FPS      | N/A               | 6 frames (~1.5s)                         | Polygon ray-casting; triggered upon boundary approach.    |
| C-07: Fall & Accident Detection   | Candidate Ring Buf | Candidate Burst   | Experimental observation window          | Decoupled candidate trigger -> evaluation batch.          |
| C-08: Mobile Phone Use            | 5.0 – 8.0 FPS      | N/A               | 15 frames (~2.5s)                        | Sustained hand-to-ear or texting posture window.          |
| C-09: Fire & Smoke Detection      | 1.0 – 2.0 FPS      | N/A               | 10 frames (~5.0s)                        | Temporal smoke accumulation buffer.                       |
| C-10 / C-11: Object Tracking      | 4.0 – 6.0 FPS      | N/A               | 12 frames (~2.0s)                        | Multi-frame trajectory association.                       |
| C-12: Object Handover / Theft     | 2.0 FPS Baseline   | 8.0 – 10.0 FPS    | 20 frames (~2.0s)                        | Proximity trigger: 2 people intersect with moving object. |
+-----------------------------------+--------------------+-------------------+------------------------------------------+-----------------------------------------------------------+
```

---

## 3. Fall Detection Buffer Architecture & Host Memory Sizing

> **THEORETICAL CANDIDATE CALCULATION — NOT AN APPROVED DEPLOYMENT CONFIGURATION**
> The sizing models below are mathematical estimates of in-memory buffering. They do not constitute an approved deployment configuration. A theoretical NV12 or pinned-memory strategy cannot be claimed to support a specified camera count without an empirical benchmark measuring bus saturation, memory bandwidth, and operating system scheduling jitter.

### 3.1 Pre/Post Rolling Ring Buffer Mechanics (Illustrative Sizing)
For designated fall-risk camera channels (catwalks, liquid chemical areas, high-ladder zones):
- **Illustrative Ring Buffer Duration:** Candidate 3 seconds pre-event + 3 seconds post-event = **6 seconds total (90 frames at 15 FPS candidate rate)**.
- **Resolution:** Decoded sub-stream at $640 \times 360$ pixels ($230,400\text{ pixels/frame}$).
- **Pixel Format Memory Sizing (Theoretical):**
  - *RGB24 Format (3 bytes/pixel):* $640 \times 360 \times 3 = 691,200\text{ bytes/frame}$.
    6 seconds (90 frames) $= 62.208\text{ MB} (59.326\text{ MiB})$ base per stream.
    With 25% overhead for memory alignment, double-buffering, and pinned host-to-device staging: **$77.76\text{ MB} (74.16\text{ MiB})$ per stream**.
  - *Native NV12 Format (1.5 bytes/pixel — Theoretical Candidate):* $640 \times 360 \times 1.5 = 345,600\text{ bytes/frame}$.
    6 seconds (90 frames) $= 31.104\text{ MB} (29.663\text{ MiB})$ base per stream.
    With 25% memory overhead: **$38.88\text{ MB} (37.08\text{ MiB})$ per stream**.

### 3.2 Total Buffer Memory Allocation Across Fleet Scales (Illustrative Sizing)
The exact count of high-risk cameras requiring active ring buffering is **`UNKNOWN`** until physical zone mapping in Phase 1. The table below dimensions theoretical host RAM requirements:

```text
+----------+------------------------------------+------------------------------------+------------------------------------+------------------------------------+
| HIGH-RISK| RGB24 BASE BUFFER                  | RGB24 ALLOCATED (+25% OVERHEAD)    | NV12 BASE BUFFER (THEORETICAL)     | NV12 ALLOCATED (+25% OVERHEAD)     |
| CAMERAS  | (6s @ 15 FPS)                      | (Double-buffering + Pinned Memory) | (Theoretical NV12 Surface)         | (Double-buffering + Pinned Memory) |
+----------+------------------------------------+------------------------------------+------------------------------------+------------------------------------+
| 10 Cams  | 622.08 MB (593.26 MiB)             | 777.60 MB (741.58 MiB)             | 311.04 MB (296.63 MiB)             | 388.80 MB (370.79 MiB)             |
| 25 Cams  | 1,555.20 MB (1,483.15 MiB)         | 1,944.00 MB (1,853.94 MiB)         | 777.60 MB (741.58 MiB)             | 972.00 MB (926.97 MiB)             |
| 50 Cams  | 3,110.40 MB (2,966.31 MiB)         | 3,888.00 MB (3,707.89 MiB)         | 1,555.20 MB (1,483.15 MiB)         | 1,944.00 MB (1,853.94 MiB)         |
| 100 Cams | 6,220.80 MB (5,932.62 MiB)         | 7,776.00 MB (7415.77 MiB)         | 3,110.40 MB (2,966.31 MiB)         | 3,888.00 MB (3,707.89 MiB)         |
| 200 Cams | 12,441.60 MB (11,865.23 MiB)       | 15,552.00 MB (14,831.54 MiB)       | 6,220.80 MB (5,932.62 MiB)         | 7,776.00 MB (7,415.77 MiB)         |
+----------+------------------------------------+------------------------------------+------------------------------------+------------------------------------+
```

---

## 4. Trigger Algorithm & Candidate Evaluation Targets

### 4.1 Trigger Algorithm (Experimental Design)

The fall-detection trigger algorithm remains an experimental design.

Candidate variables include background differencing, person bounding-box movement, temporal posture change, and optional keypoint trajectories.

No numeric velocity threshold, bounding-box aspect-ratio threshold, frame batch size, or model output contract is approved.

Each candidate algorithm must be evaluated against labeled normal-activity and fall-event footage, including sitting, bending, kneeling, lying down, occlusion, and camera-angle variation.

Do not select a production trigger algorithm from theoretical assumptions alone.

### 4.2 Candidate Evaluation Targets — NOT OWNER-APPROVED — NOT VALIDATED

The following metrics represent proposed experimental research targets only:
- **Event-Level Recall Target:** $\ge 90.0\%$ (Proposed research target).
- **Event-Level Precision Target:** $\ge 85.0\%$ (Proposed research target).
- **False Positive Budget Target:** $< 1$ false trigger per camera per 24 hours (Proposed research target).
- **End-to-End Classification Latency Target:** $< 1.5\text{ seconds}$ from ground impact (Proposed research target).

> **CRITICAL GOVERNANCE CONSTRAINT:**
> These figures CANNOT be used as pass/fail criteria, implementation gates, or production SLOs until:
> 1. The owner approves the exact thresholds.
> 2. The evaluation dataset and labeling protocol are documented.
> 3. Relevant false-positive and false-negative scenarios are represented.
> 4. The benchmark is executed.
> 5. Measured results and reproducible evidence are recorded.
>
> Zero benchmark results are assumed or fabricated prior to execution.

---

## 5. Physical PoC Test Bench Rig Specification

The exact SPK-02 test rig is not yet selected or authorized.

Candidate hardware must be evaluated against the proposed ONNX Runtime CPU baseline and, where justified, the optional CUDA execution provider.

Exact GPU model, driver, CUDA version, ONNX Runtime version, operating system, memory, and model artifact must be recorded together.

The existing candidate RTX configurations are not procurement approvals.

OQ-011 remains unresolved. No production server or GPU procurement is authorized by this protocol.

SPK-02 remains AWAITING AUTHORIZATION until explicit owner authorization is recorded.

> **DATA GOVERNANCE CONSTRAINT:**
> Zero identifiable employee photos or real factory video may be uploaded to public cloud GPU services unless the required legal authorization is documented. Approved non-sensitive synthetic video loops and non-production test data must be utilized for laboratory benchmarking.
