# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## SUPPLEMENTARY AUDIT DOCUMENT 06
### PROPRIETARY CORE LICENSE COMPATIBILITY & BOUNDARY ARCHITECTURE
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** SUPP-AUDIT-06  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\supplementary_license_audit\PROPRIETARY_CORE_LICENSE_COMPATIBILITY.md`  
**Audit Date:** 2026-11-16  
**Auditor:** Principal AI Engineer / Enterprise Solution Architect / CTO Advisory  

---

## 1. STRATEGIC OBJECTIVE

The Project Owner intends to retain full intellectual property ownership, commercialization freedom, and copyright control over the BNF and RNF Industrial AI Surveillance Platform.

This document establishes the exact architectural and legal boundaries that ensure **the complete core application remains 100% proprietary and closed-source**, unencumbered by copyleft contamination (GPL/AGPL) and compliant with all upstream open-source license obligations.

---

## 2. BOUNDARY ARCHITECTURE & ISOLATION TIERS

```
+---------------------------------------------------------------------------------------------------+
|                        PROPRIETARY APPLICATION CODE (CLOSED SOURCE)                               |
|  - All Go backend packages (auth, alerts, cameras, rules, ptz, analytics, biometrics)             |
|  - All Flutter Android client source code & custom UI widgets                                     |
|  - All React Web Admin dashboard components & application business logic                          |
|  - Copyright (c) 2026 BNF / RNF Industrial AI Surveillance. All Rights Reserved.                  |
+---------------------------------------------------------------------------------------------------+
                                                  |
           =======================================|=======================================
           BOUNDARY 1: PERMISSIVE GO MODULE LINKING (MIT / Apache-2.0 / BSD)
           =======================================|=======================================
                                                  v
+---------------------------------------------------------------------------------------------------+
|                     CATEGORY A: PERMISSIVE OPEN-SOURCE LIBRARIES                                  |
|  - gin-gonic/gin, jackc/pgx, pion/webrtc, google/protobuf, golang.org/x/*                         |
|  - Legal Right: Permitted to be compiled directly into proprietary binaries without source        |
|    disclosure. Only requires copyright attribution in THIRD_PARTY_NOTICES.md.                     |
+---------------------------------------------------------------------------------------------------+
                                                  |
           =======================================|=======================================
           BOUNDARY 2: IPC & NETWORK PROCESS BOUNDARY (gRPC / REST / Unix Sockets)
           =======================================|=======================================
                                                  v
+---------------------------------------------------------------------------------------------------+
|                     STANDALONE AI INFERENCE WORKERS (PYTHON / ONNX RUNTIME)                       |
|  - Communicates with Go Core exclusively via loopback gRPC sockets or Protobuf IPC               |
|  - Uses permissively licensed YOLOX (Apache-2.0) and Microsoft ONNX Runtime (MIT)                 |
|  - Strict Process Isolation: No direct memory linking with Go Core                               |
+---------------------------------------------------------------------------------------------------+
                                                  |
           =======================================|=======================================
           BOUNDARY 3: OS SUBPROCESS CLI EXECUTION (exec.Command)
           =======================================|=======================================
                                                  v
+---------------------------------------------------------------------------------------------------+
|                     STANDALONE UTILITIES & MEDIA GATEWAY                                          |
|  - go2rtc: Independent daemon communicating over HTTP / RTSP / WebRTC protocols                   |
|  - FFmpeg: Spawned as external OS CLI process for recording segmentation                          |
|  - Legal Protection: Invoking CLI tools across OS process boundaries does not create a derivative |
|    work under copyright law. No C-header linking or shared object binding (`libavcodec.so`).      |
+---------------------------------------------------------------------------------------------------+
```

---

## 3. RIGOROUS ANALYSIS OF LEGAL BOUNDARIES

### 3.1 Permissive Library Linking (MIT, BSD, Apache-2.0)
- **The Legal Mechanism:** The proprietary Go application imports open-source libraries such as `github.com/gin-gonic/gin` (MIT) and `github.com/jackc/pgx` (MIT). 
- **Copyright Implications:** The MIT and BSD licenses explicitly state:
  > *"Permission is hereby granted... to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software..."*
  These licenses do **not** contain copyleft provisions. Compiling them statically into the proprietary Go binary does not obligate the author to disclose the proprietary source code. The sole obligation is preserving the original copyright notice in documentation.
- **Apache-2.0 Patent Grant:** Section 3 of the Apache-2.0 License provides an explicit, perpetual, royalty-free patent grant from contributors, protecting the platform from patent ambush.

### 3.2 The LGPL-2.1 Subprocess Boundary (FFmpeg)
- **The Risk:** If a proprietary program dynamically links against LGPL C shared libraries (`libavcodec.so`), Section 6 of LGPL-2.1 requires that recipients must be provided with object code or source code enabling them to re-link the application against modified versions of the LGPL library.
- **The Architectural Solution:** We completely bypass C-library linking. The application interacts with FFmpeg exclusively via standard operating system subprocess calls:
  ```go
  cmd := exec.Command("ffmpeg", "-i", rtspUrl, "-c", "copy", "-f", "segment", ...)
  ```
  Established legal consensus (Free Software Foundation FAQ on subprocess invocation, Ninth Circuit *Sega v. Accolade*) confirms that executing an independent CLI utility via standard OS pipes and arguments does not make the calling program a derivative work of the CLI tool.

### 3.3 Prevention of AGPL-3.0 Network Contamination
- **The AGPL Network Trigger:** Section 13 of AGPL-3.0 triggers source disclosure if a work interacts with users over a network.
- **The Safeguards:**
  1. Ultralytics YOLO is **completely excluded**; replaced with Apache-2.0 YOLOX and RT-DETR.
  2. MinIO is **completely excluded**; replaced with local Linux POSIX storage.
  3. Grafana OSS (if run internally for developer telemetry) is deployed as an unmodified third-party container on a separate internal port, strictly behind a reverse proxy, and never embedded within customer-facing pages.

---

## 4. INTELLECTUAL PROPERTY & TRADE SECRET PROTECTION

To ensure BNF and RNF retain absolute ownership of their technological assets:

1. **Proprietary Copyright Header:** Every source code file authored for this platform must contain the official proprietary notice:
   ```go
   // Copyright (c) 2026 BNF / RNF Industrial AI Surveillance.
   // All rights reserved.
   //
   // This software contains valuable trade secrets and proprietary information
   // of BNF and RNF. Unauthorized reverse engineering, decompilation, copying,
   // or distribution of this code is strictly prohibited.
   ```
2. **Attribution File (`THIRD_PARTY_NOTICES.md`):** A machine-generated notices file will accompany all binary distributions, satisfying upstream MIT, BSD, and Apache attribution requirements without exposing proprietary code.
3. **No GPL/AGPL in Core Repository:** Automated CI/CD scanners will immediately block any commit introducing GPL or AGPL dependencies into the core Go modules or Python workers.

---

## 5. COMPATIBILITY RULING

The proposed architecture fully protects the proprietary nature of the core application. By enforcing process isolation and selecting exclusively Category A permissive dependencies, **the complete core application can remain 100% closed-source, proprietary, and commercializable**.

