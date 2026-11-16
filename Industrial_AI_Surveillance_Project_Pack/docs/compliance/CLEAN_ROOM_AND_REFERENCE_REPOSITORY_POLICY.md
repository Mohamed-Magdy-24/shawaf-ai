# CLEAN-ROOM DEVELOPMENT AND REFERENCE REPOSITORY POLICY
## Industrial AI Surveillance Platform — BNF & RNF
**Document ID:** COMPL-POL-001  
**Classification:** Canonical Intellectual Property Policy  
**Status:** MANDATORY ENGINEERING POLICY  
**Last Updated:** 2026-11-16  

---

## 1. PURPOSE & INTELLECTUAL PROPERTY FOUNDATION

This policy establishes the mandatory clean-room engineering rules governing the development of the BNF and RNF Industrial AI Surveillance Platform. The Project Owner is building an independent proprietary software platform. While established open-source projects provide valuable architectural patterns, technical benchmarks, and protocol standards, the proprietary codebase must remain legally and structurally independent.

Clean-room engineering principles separate functional analysis and specification from code authoring. **This policy does not state or imply that clean-room development guarantees absolute immunity from legal claims or disputes; rather, it establishes a rigorous engineering discipline to eliminate copyright infringement, license contamination, and intellectual property ambiguity.**

---

## 2. MANDATORY ENGINEERING RULES

1. **Architectural References Only:** Reference repositories (including Frigate, Viseron, go2rtc, MediaMTX, ByteTrack, and CVAT) are studied strictly as architectural, protocol, and technical references. Accessing a public repository does not grant permission to copy its source code, comments, or proprietary structures into our codebase.
2. **Prohibition of Incompatible Copyleft Code:** Software developers and AI assistants are strictly forbidden from copying, transplanting, or mechanically translating source code from GPL-2.0, GPL-3.0, AGPL-3.0, SSPL, or other reciprocal copyleft projects into the proprietary core application.
3. **Process Boundaries Do Not Automatically Cure License Violations:** Do not assume that moving reciprocal-licensed or copyleft code into a separate container or process boundary automatically eliminates legal licensing obligations. The nature of the interaction, contract, and distribution model must be evaluated individually.
4. **Maintain Component Provenance:** Record the source repository URL, exact release or commit hash, inspected files, and declared license for every third-party component adopted into the platform build.
5. **Prefer Independent Interfaces and Protocol Contracts:** All subsystem interactions, stream decoders, and camera integrations must be authored against documented public protocol contracts (e.g. RTSP RFC 2326, ONVIF Profile specifications, WHEP draft, gRPC protobufs) rather than internal third-party abstractions.
6. **Isolate Third-Party Components Behind Adapters:** Keep all external open-source runtimes, libraries, and utilities strictly isolated behind ports and adapters (Clean Architecture) or separate operating system process boundaries.
7. **Model Weights and Dataset Provenance:** Maintain verifiable provenance for all AI model architectures, pretrained model weights, fine-tuning checkpoints, and training datasets. Pretrained weights derived from non-commercial datasets (such as CrowdHuman) are prohibited from commercial factory deployments.
8. **Mandatory Legal Review for Ambiguous Licenses:** Whenever license compatibility, patent grants, or commercial distribution obligations are uncertain, work on that component is blocked pending formal legal review.
9. **Permanent Exclusion of ZoneMinder and pyzk:** ZoneMinder and pyzk are permanently excluded from the proprietary application baseline. ZoneMinder carries copyleft GPL-2.0 obligations and an obsolete multi-daemon design. Source inspection identifies a potential session-management and communication reliability risk in pyzk. The claimed physical terminal lockup has not been demonstrated by a documented reproducible hardware test in the supplied evidence. This operational concern must therefore remain an unverified risk hypothesis, not a confirmed hardware failure. pyzk remains excluded from the proprietary application baseline independently because of its GPL-2.0 license.
10. **Exclusion of NVIDIA DeepStream SDK:** NVIDIA DeepStream SDK is excluded from the proposed zero-mandatory-license-cost baseline due to its proprietary SDK runtime EULA and hardware vendor lock-in. While DeepStream sample applications carry an Apache-2.0 license, the required underlying runtime and execution libraries remain proprietary. Furthermore, workstation evaluation against the host NVIDIA Quadro P600 (Pascal architecture, Compute Capability 6.1) revealed specific TensorRT INT8 calibration and optimization incompatibilities; this observed failure in one INT8 benchmark must not be over-generalized to all Pascal execution modes. DeepStream is excluded primarily because of its proprietary licensing model, commercial runtime terms, and severe hardware dependency.

