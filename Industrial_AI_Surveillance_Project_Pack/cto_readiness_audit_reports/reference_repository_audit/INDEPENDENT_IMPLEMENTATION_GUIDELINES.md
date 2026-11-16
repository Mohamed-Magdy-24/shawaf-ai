# INDUSTRIAL AI SURVEILLANCE PLATFORM — BNF / RNF
## PART 8.6: INDEPENDENT IMPLEMENTATION & CLEAN-ROOM DEVELOPMENT GUIDELINES
### Antigravity Flash 3.8 — CTO Engineering Audit
**Operating Mode:** STRICT READ-ONLY AUDIT — ZERO IMPLEMENTATION  
**Deliverable ID:** AUDIT-REF-06  
**Target Path:** `D:\Project-CRM\cto_readiness_audit_reports\reference_repository_audit\INDEPENDENT_IMPLEMENTATION_GUIDELINES.md`  
**Audit Date:** 2026-11-12  

---

## 1. PURPOSE & PRINCIPLES

The Project Owner is developing the BNF and RNF Multi-Factory Industrial AI Surveillance Platform as an independent, proprietary industrial solution with AI assistance. To protect the intellectual property, commercial independence, and legal integrity of the project, all software development must strictly adhere to **Clean-Room Engineering Protocols**.

Under no circumstances will source code, comments, or non-public structures from third-party repositories be copy-pasted or mechanically translated into our codebase.

---

## 2. CLEAN-ROOM DEVELOPMENT PROTOCOL

```
+---------------------------------------------------------------------------------------------------+
|                                STAGE 1: SPECIFICATION & AUDIT (CURRENT)                           |
|  - Inspect reference repositories to extract functional requirements, algorithms, and math.     |
|  - Identify architectural anti-patterns and performance bottlenecks to avoid.                     |
|  - Produce written specifications and interface definitions without containing third-party code.   |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                STAGE 2: CLEAN-ROOM IMPLEMENTATION                                 |
|  - Implement solutions from functional specifications and first-principles mathematics.           |
|  - Author native Go, Python, and TypeScript code independently.                                   |
|  - Use public standard library APIs and approved Category A open-source dependencies.            |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                STAGE 3: AUTOMATED COMPLIANCE VERIFICATION                         |
|  - Run automated license checkers (FOSSA / Trivy / Syft) on every build.                          |
|  - Verify absence of GPL/AGPL copyleft dependencies.                                              |
|  - Generate dynamic Software Bill of Materials (SBOM) and THIRD_PARTY_NOTICES.md.                 |
+---------------------------------------------------------------------------------------------------+
```

### 2.1 The Rules of Independent Authoring
1. **No Direct Copy-Pasting:** Developers and AI assistants are strictly forbidden from copying functions, classes, or code blocks from Frigate, Viseron, ZoneMinder, or any other third-party repository.
2. **Algorithmic Re-implementation:** Where proven algorithms are utilized (e.g. ByteTrack's two-stage association, Kalman filtering, or grayscale motion differencing), they must be re-authored from published mathematical literature and papers, rather than adopting repository-specific source code.
3. **Language Separation:** While reference systems like Frigate and Viseron are predominantly Python-based monolithic applications, our core edge gateway and API backend are authored in **Go**, providing natural structural isolation and eliminating mechanical code copying.

---

## 3. SOFTWARE BILL OF MATERIALS (SBOM) & DEPENDENCY GOVERNANCE

### 3.1 Automated SBOM Generation
Every continuous integration (CI) build must generate a machine-readable Software Bill of Materials formatted in standard **CycloneDX JSON** or **SPDX 2.3**:
```bash
# Example SBOM generation using open-source Syft
syft packages dir:. -o cyclonedx-json=sbom.json
```

### 3.2 Automated License Compliance Gate
Before any binary or container is tagged for release, automated scans must enforce license boundaries:
```bash
# Automated license vulnerability and copyleft scanning via Trivy
trivy fs --scanners license --severity HIGH,CRITICAL .
```
- **Policy Enforcement:** Any detected dependency with license `GPL-1.0`, `GPL-2.0`, `GPL-3.0`, `AGPL-1.0`, `AGPL-3.0`, `SSPL`, or `Commons Clause` must trigger an immediate build failure.

---

## 4. THIRD-PARTY NOTICES & ATTRIBUTION POLICY

To satisfy the legal requirements of permissive open-source licenses (MIT, Apache-2.0, BSD-3-Clause), the project repository must maintain a top-level `THIRD_PARTY_NOTICES.md` file.

### 4.1 Notice Format Standard
Every included third-party library or bundled binary must have its copyright statement preserved:
```markdown
# THIRD-PARTY SOFTWARE NOTICES AND ATTRIBUTIONS

This project incorporates components from the following open-source projects:

--------------------------------------------------------------------------------
1. go2rtc
   Repository: https://github.com/AlexxIT/go2rtc
   License: MIT License
   Copyright (c) 2022-2026 AlexxIT
   [Full Text of MIT License]

--------------------------------------------------------------------------------
2. YOLOX
   Repository: https://github.com/Megvii-BaseDetection/YOLOX
   License: Apache License, Version 2.0
   Copyright (c) 2021-2026 Megvii Technology
   [Full Text of Apache-2.0 License]

--------------------------------------------------------------------------------
3. ONNX Runtime
   Repository: https://github.com/microsoft/onnxruntime
   License: MIT License
   Copyright (c) Microsoft Corporation
   [Full Text of MIT License]
```

---

## 5. REPOSITORY LICENSING & IP PROTECTION FOR BNF / RNF

1. **Proprietary Application Code:** All application source code authored for the BNF/RNF Industrial AI Surveillance Platform will carry the Project Owner's proprietary copyright header:
   ```
   Copyright (c) 2026 BNF / RNF Industrial AI Surveillance. All rights reserved.
   CONFIDENTIAL AND PROPRIETARY.
   ```
2. **Clean IP Boundary:** By exclusively selecting Category A permissive open-source components and executing clean-room re-implementation, the resulting software platform remains 100% unencumbered by copyleft restrictions, allowing the Project Owner to retain full ownership, control, and commercialization rights.

