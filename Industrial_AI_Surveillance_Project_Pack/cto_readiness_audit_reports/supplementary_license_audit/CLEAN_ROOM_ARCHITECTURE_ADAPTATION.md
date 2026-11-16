# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## SUPPLEMENTARY AUDIT DOCUMENT 07
### CLEAN-ROOM ARCHITECTURE ADAPTATION BLUEPRINT
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** SUPP-AUDIT-07  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\supplementary_license_audit\CLEAN_ROOM_ARCHITECTURE_ADAPTATION.md`  
**Audit Date:** 2026-11-16  
**Auditor:** Principal AI Engineer / Enterprise Solution Architect / CTO Advisory  

---

## 1. PURPOSE & LEGAL FOUNDATION

Under US, European, and international copyright law (*Computer Associates v. Altai*, 982 F.2d 693; *Oracle v. Google*, 141 S. Ct. 1183), copyright protects the specific creative expression of software code, but explicitly does **not** protect:
- Ideas, concepts, or system architectures.
- Mathematical algorithms and formulas.
- Functional interfaces and data flow patterns.
- Hardware efficiency techniques dictated by physical reality.

The Project Owner's objective is to study proven open-source surveillance architectures (such as Frigate, Viseron, and ByteTrack) and independently author an enterprise-grade industrial surveillance platform. This document establishes the **Clean-Room Engineering Protocol** ensuring complete intellectual independence.

---

## 2. THE TWO-PHASE CLEAN-ROOM PROCESS

```
+---------------------------------------------------------------------------------------------------+
|                            PHASE 1: AUDIT & SPECIFICATION (CURRENT STATUS)                        |
|  - Inspect reference repositories to extract functional behavior, mathematical models, and edge  |
|    case handling.                                                                                 |
|  - Document architectural patterns, state machines, and failure modes in pure technical prose.   |
|  - Output: Functional Specifications & Interface Blueprints (Zero third-party code).              |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|                            PHASE 2: INDEPENDENT CLEAN-ROOM IMPLEMENTATION                         |
|  - Software Engineers author application code strictly from Phase 1 functional specifications.    |
|  - Author in different programming languages (Go instead of Python/C++) where appropriate.        |
|  - Zero copy-pasting of source files, variable naming schemes, or proprietary structures.         |
|  - Automated CI/CD AST similarity scanners verify intellectual independence.                     |
+---------------------------------------------------------------------------------------------------+
```

---

## 3. CONCRETE RE-IMPLEMENTATION BLUEPRINTS

### 3.1 Adapting Frigate's Motion-First Architecture into Go
- **Proven Pattern Observed in Frigate:** Continuous object detection on 30 high-resolution camera feeds saturates GPUs. Frigate solves this by running lightweight frame differencing on low-resolution sub-streams at 5 FPS to trigger AI inference only when motion occurs.
- **Our Clean-Room Go Implementation:**
  1. Go Core connects to camera sub-stream (`rtsp://camera/sub`) via `go2rtc`.
  2. A dedicated Go worker decodes low-res frames (320x240) into a ring buffer.
  3. A pure-Go or OpenCV grayscale differencing algorithm calculates pixel variance:
     $$\Delta(x, y) = |I_t(x, y) - I_{t-1}(x, y)|$$
  4. If the count of pixels exceeding threshold $\tau$ is greater than minimum area $A_{min}$, Go emits a motion event to the AI worker pool.
  5. *Clean-Room Distinction:* Authored entirely in Go with native goroutines, channels, and atomic memory counters, completely independent of Frigate's Python `multiprocessing.Process` code.

---

### 3.2 Adapting ByteTrack's Multi-Object Tracking into Independent Code
- **Mathematical Foundation Observed in ByteTrack:** Two-stage association of high-score and low-score bounding boxes using an 8-state Kalman Filter and Hungarian linear assignment.
- **Our Clean-Room Implementation:**
  1. *Kalman Filter State:* Implement standard 8-dimensional linear state vector:
     $$\mathbf{x} = [x, y, a, h, \dot{x}, \dot{y}, \dot{a}, \dot{h}]^T$$
     where $(x, y)$ is bounding box center, $a$ is aspect ratio, $h$ is height, and $(\dot{x}, \dot{y}, \dot{a}, \dot{h})$ are respective velocities.
  2. *Matching Matrix:* Compute Intersection-over-Union (IoU) distance matrix:
     $$\text{Cost}(i, j) = 1 - \text{IoU}(\text{Tracklet}_i, \text{Detection}_j)$$
  3. *Assignment Solver:* Solve bipartite matching using SciPy's standard `linear_sum_assignment` (BSD-3-Clause) or a clean C++ Munkres algorithm.
  4. *Clean-Room Distinction:* Implemented directly from the academic paper equations (Zhang et al., ECCV 2022) without copying `yolox/tracker/byte_tracker.py`.

---

### 3.3 Adapting Viseron's Tiered Storage Policies into Go
- **Proven Pattern Observed in Viseron:** Automated segment lifecycle pruning based on storage tiers and disk space thresholds.
- **Our Clean-Room Go Implementation:**
  1. A background Go goroutine (`storage/maintainer.go`) periodically evaluates disk mounts via Linux `statfs` syscalls.
  2. Hot Storage Tier: Local NVMe SSD maintains uncompressed 1-minute fMP4 segments for 48 hours.
  3. Cold Storage Tier: Segments older than 48 hours without associated safety incidents are moved to high-capacity SATA RAID storage or deleted after 30 days.
  4. *Clean-Room Distinction:* Authored as a native Go filesystem supervisor using `os.Remove` and PostgreSQL status updates, completely free of Viseron's Python code.

---

## 4. STRICT PROHIBITIONS FOR IMPLEMENTATION SPRINT

When implementation is formally authorized, the following rules are non-negotiable:
1. **NO Direct Copying:** Never copy-paste blocks of code, variable names, or internal comments from Frigate, Viseron, ZoneMinder, or pyzk.
2. **NO Mechanical Translation:** Do not run automated code translators (e.g. Python-to-Go transpilers) on third-party code.
3. **NO Asset Borrowing:** Never reuse icons, web layouts, CSS styles, or documentation text from reference projects.
4. **Enforce Clean Git Commit Histories:** All code commits must be authored directly from specification documents with clear commit messages referencing internal functional requirements.

