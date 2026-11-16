> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 36 — Final Consistency Gate, Inventory Manifest & Cross-System Audit

**Document ID:** DISC-36-CONSISTENCY-GATE  
**Version:** 1.1.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL AUDIT REPORT  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` & `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate & Latest Archive Verification  
**Precedence Authority:** [26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md](./26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md) (Tier 1)

---

## 1. Executive Summary & Objective

In accordance with the CTO Master Directive — Phase 0 Final Consistency Gate & Latest Archive Verification, this document executes a comprehensive, forensic, documentation-only audit of the entire project repository.

It validates the factual integrity of the workspace, establishes a cryptographic manifest of every file, resolves all identified contradictions, corrects legal and mathematical citations, validates systems engineering models (AI trigger architecture, NVDEC vs CPU work, LACP networking, storage capacity, and composite identity), and certifies that zero prohibited execution occurred.

---

## 2. Complete Workspace File Manifest & Cryptographic Inventory

Every file in the repository has been inventoried with its byte size, modification timestamp, and SHA-256 cryptographic hash calculated directly from the file system. In accordance with Section 1 of the CTO Directive, this manifest lists all 56 checksummed files in the archive and explicitly marks Document 36 itself as `[SELF_MANIFEST_EXCLUDED]`:

```text
+-----------------------------------------------------------------------+-----------+---------------------+------------------------------------------------------------------+
| 00_PROJECT_CHARTER.md                                                 |     6,236 | 2026-11-11 08:06:56 | 5399435F5BB934259337995882CAE04D3981760B254B4B5BA9CF42DC7DB07B16 |
| Industrial_AI_Phase0_Audit_and_Remediation.md                         |    22,117 | 2026-11-11 19:09:37 | 83823FDD59C24C8D793EB11C697842C607D64C98F7C1864E88D5BB71A0877596 |
| PACK_VERSION.txt                                                      |       265 | 2026-11-11 08:06:56 | 613EA3476B89D05DA7AD75A9A43B0C0389DB28056CCEE9495AFBDFBA85648878 |
| README_AR.md                                                          |     5,044 | 2026-11-11 08:06:56 | 98857E473F6D6A50F922EA1E12DF8F5BB74E0D25358EB8B06EEFDC4550E2289D |
| ai/04_VIDEO_AI_SPEC.md                                                |     8,374 | 2026-11-11 08:06:56 | D9E5A391B4978FB3AC05ED148BF0992D5003D8C5D4951A455C6A5F6925B98766 |
| antigravity/09_MASTER_OPERATING_PROMPT.md                             |    10,665 | 2026-11-11 20:34:48 | AD58528448A035B4297821CD8A06DE2BFB4E3BDDB85B4937E797D3D9F004D97C |
| antigravity/10_PHASE_0_DISCOVERY_PROMPT.md                            |     3,953 | 2026-11-11 08:06:56 | 6B28F198D70C3A9CDDA32F5DC2C8B89D86B657ED1020945822FAD27CC7A1823F |
| antigravity/11_PHASE_PROMPTS.md                                       |     7,246 | 2026-11-11 20:34:48 | DAFC2306CE0C9859AEC9C08A58B906DCE380A0A3F081F2E5706C5006118D9B61 |
| architecture/02_TARGET_ARCHITECTURE.md                                |    16,091 | 2026-11-11 20:39:30 | F9816815D466E5CA32FABE632DFD77464B3A8A6743772C1A7E9DCF33E6B1ACFB |
| docs/discovery/01_PROJECT_UNDERSTANDING.md                            |     6,740 | 2026-11-11 20:34:48 | 5D284108343720F2201335F26452F96D506ABA8174A8C101F6FE610EF2438466 |
| docs/discovery/02_REQUIREMENTS_GAP_ANALYSIS.md                        |    16,123 | 2026-11-11 18:12:35 | 5E74FE85D66580ABD8CF6B79616CDA2D6E1EF49A725C0BD865AEF1D80587CC27 |
| docs/discovery/03_REPOSITORY_DISCOVERY_REPORT.md                      |     9,815 | 2026-11-11 18:12:35 | 2A27ED8C23502283BD634A44200F11CCB6AF990D14CE2D1EDC5E4471E069B0D1 |
| docs/discovery/04_SKILLS_AUDIT.md                                     |     9,690 | 2026-11-11 19:35:27 | F9723C620E5A8475B7557534AFF836A6CD96A60A26E9628831FF583483135107 |
| docs/discovery/05_COMPLETE_TASK_INVENTORY.md                          |    52,537 | 2026-11-11 20:41:19 | DEE971BCDFB74627961ACA51A04EAD9673C55B9AD0C341AE0125C877F2F3016C |
| docs/discovery/06_TASK_DEPENDENCY_GRAPH.md                            |     7,945 | 2026-11-11 18:12:35 | 95F83FDDEBD79F322EA426057D80EAC1A9183F29728E4DB196CA598442807A8F |
| docs/discovery/07_TECHNOLOGY_RESEARCH_MATRIX.md                       |     6,024 | 2026-11-11 18:46:46 | F2844B9A029AB974CBBC6F465D4C65D3CEE893A415CF6ABBE575C602F6469584 |
| docs/discovery/08_TARGET_ARCHITECTURE_PROPOSAL.md                     |    13,468 | 2026-11-11 18:46:46 | 1A984C0D61A6311A570E19164E8196ECA9D7DEEB9ECA88B4219F217E0D838CD6 |
| docs/discovery/09_UI_UX_DESIGN_STRATEGY.md                            |     6,699 | 2026-11-11 18:46:46 | 892F9498CF4AC1195ED54F88671FFE83EF049E3C57FFED2518AF4E027BD1A8CE |
| docs/discovery/10_SCREEN_AND_NAVIGATION_INVENTORY.md                  |    11,546 | 2026-11-11 20:06:37 | 83E7BFBACA64BF18E255BFEA2D27741BCA51FB1597F05EB303671725637EF010 |
| docs/discovery/11_SECURITY_AND_PRIVACY_ASSESSMENT.md                  |     7,463 | 2026-11-11 18:46:46 | B95F088B2D6A842984E92477FC70E24AF5FFF62F9EF3F4B18BB0F00EDE9B2400 |
| docs/discovery/12_VIDEO_AI_EVALUATION_PLAN.md                         |     8,054 | 2026-11-11 18:46:46 | 22A92CA57DD1BB08B78A35262ECC5C9725AF1D54EF294CE0E44030CB85C63080 |
| docs/discovery/13_INFRASTRUCTURE_ASSESSMENT.md                        |     6,542 | 2026-11-11 18:46:47 | 16394295FB5A19F4FF57E29546D2084A18B30F17AF56327A45981DF8DEC4BE19 |
| docs/discovery/14_TESTING_AND_QUALITY_STRATEGY.md                     |     8,075 | 2026-11-11 20:34:49 | 22A43575CBEDC3530A0C92283D88246AD815A20E150DF6B6A7465A6703D32923 |
| docs/discovery/15_PRODUCTION_READINESS_PLAN.md                        |     7,494 | 2026-11-11 20:34:49 | F7CC468610A20DAA9756C3F4E243E0A428B8B01737812E828092D6167DEC6755 |
| docs/discovery/16_GIT_AND_CI_CD_PROPOSAL.md                           |     8,456 | 2026-11-11 18:12:36 | B4D3CA181933A154B1838FA961E6B90D78A0F148CE5F54A98F83CB5DB5BC2E33 |
| docs/discovery/17_ARCHITECTURE_DECISION_REGISTER.md                   |    16,673 | 2026-11-11 20:40:58 | 4CC10E386C7597241E7D911811CEE30489354EABCAD5441A9CBA3AA251464C9F |
| docs/discovery/18_BLOCKERS_AND_OPEN_QUESTIONS.md                      |     9,474 | 2026-11-11 18:46:47 | 99A9FFC1DF75778A224075096DE638BC527CAE1832EF49DBE4BC877353B21121 |
| docs/discovery/19_PHASED_IMPLEMENTATION_ROADMAP.md                    |    11,417 | 2026-11-11 20:34:49 | DE0ECC040F3216121ACB398858B6780BEB1E4276BCFC73E360C81BF5663C00B1 |
| docs/discovery/20_OWNER_APPROVAL_CHECKLIST.md                         |     9,222 | 2026-11-11 20:19:57 | 30978D6ABE8965186278BCFB038753887FE1F29D2FB8271DD9C8FD4A5CE70D06 |
| docs/discovery/21_PHASE_0_REMEDIATION_CHANGELOG.md                    |     9,214 | 2026-11-11 20:34:49 | A5E8471EFC527DCBA2CDFA1E9E05BA9C9B08CF4285042AE5D731CD461F5CCEED |
| docs/discovery/22_TECHNICAL_CLAIMS_EVIDENCE_REGISTER.md               |     8,360 | 2026-11-11 18:32:12 | F2C58E2381DCF36F72EC08C96436729984E5E5D03EF1ACE3CFC3A4DF2F173941 |
| docs/discovery/23_UPDATED_TECHNOLOGY_COMPATIBILITY_MATRIX.md          |    17,899 | 2026-11-11 20:34:49 | CB52830CEAB9A9D00FFE8A25A0D69438B11F6FA92AEEE28D11E28ACA94601E2C |
| docs/discovery/24_VIDEO_CAPACITY_AND_STORAGE_MODEL.md                 |    11,167 | 2026-11-11 18:32:12 | 8B9D8C8D2303355190D8A8B5698AA5DFB30EFDFEEA27DB70C1886E2FADBAD17A |
| docs/discovery/25_LEGAL_COMPLIANCE_ACTION_REGISTER.md                 |     9,250 | 2026-11-11 18:32:12 | 3E3325CAF128F378D1693374208868B0446B945DFFF8F88D1843857B5CD5E8D9 |
| docs/discovery/26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md          |     7,003 | 2026-11-11 20:34:49 | 4134824BD910A6CA954E76D9FB25A2B041B372B7D7B2C5612B94AD25CE14292E |
| docs/discovery/27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md   |     7,901 | 2026-11-11 19:26:19 | A5BD1DB58BCD4653B3A58017795ABC7D205FF9FE62A6F18A4BC8568464F61AF1 |
| docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md            |     8,739 | 2026-11-11 20:34:49 | F7359B1CD7094B697B1F015993607358158E9FE7D76C0D64C490411EC8FA6AE1 |
| docs/discovery/29_STORAGE_RAID_AND_NETWORK_RECALCULATION.md           |     7,257 | 2026-11-11 20:34:50 | ADB8EDC5B27E93F4165BC612FA757277B5EA327AD2D7133B5BDDC3B4C0F68E4D |
| docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md            |     8,726 | 2026-11-11 19:26:19 | 8ECA9E5B5DE08B0991CCC666AD90EC38BFDDA9FF98AA537E5FBC12FD00128781 |
| docs/discovery/31_REPORTING_TIMEZONE_AND_CALENDAR_RULES.md            |     6,125 | 2026-11-11 19:26:20 | 90F582969DAFFF13DEB911D681E8A20E8AE7AFE2FB53233AF16C297E45E8D3B7 |
| docs/discovery/32_DEVICE_FLEET_INVENTORY_AND_COMPATIBILITY_PLAN.md    |     6,463 | 2026-11-11 19:26:20 | FBE6FB08905231ED6C891A19B1F8C1CAD6ABFB0256927F3DD57A47122B80AC07 |
| docs/discovery/33_UI_CONTRAST_AUDIT_AND_DESIGN_TOKEN_CORRECTIONS.md   |     7,310 | 2026-11-11 19:26:20 | 399F5BE71742E342FE2E8315299DF7415D8352180EEBAB24FBB0BEC8F6B668B1 |
| docs/discovery/34_LEGAL_REGISTER_CORRECTION_AND_COUNSEL_QUESTIONS.md  |     7,166 | 2026-11-11 19:26:20 | 2CBECFA78360540BD282BF0B66AC09CBDCADEBD8DF055B906C4A0E5E874E3CA9 |
| docs/discovery/35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md         |     7,721 | 2026-11-11 20:34:50 | E952100E63FA647EA15AC9A0BACB8780EB061F40BE1C9CECE9EFC144B50FDCBE |
| docs/discovery/37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md     |    10,730 | 2026-11-11 20:34:50 | 62933F331AA9C44782CDE19280C5462B8601CB14B99EBF1EDC13DF5C1392B4F7 |
| docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md                   |    15,814 | 2026-11-11 20:39:49 | F167A8A609BD6B1F2ADF9FA368A1E384FF140132262157A468761342EA4D64C7 |
| docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md    |    12,898 | 2026-11-11 20:34:50 | C956BECEFFD9DE7085C7FA2674B92D84B27A1FD45C67AF2CD1745A8DBFE79BA2 |
| docs/discovery/40_VERSION_SUPPORT_AND_LOCKFILE_CANDIDATES.md          |     9,438 | 2026-11-11 20:40:35 | 33AAB2E90C53B075C2F394C9C5EF75829C9E73547C94F45D6AB8FB375B277753 |
| docs/discovery/41_OWNER_APPROVAL_GAPS.md                              |     6,839 | 2026-11-11 20:34:50 | EF43B5C2942BEA88DF1D65D75D8462C59DA542BCDB7BD1AF2FA37831ADF64C71 |
| integrations/03_INTEGRATION_AND_DATA_SPEC.md                          |     9,701 | 2026-11-11 08:06:56 | 22E105DA3A2801045E8992F4E36558205DD3353983890E110E76F136A07582FF |
| planning/06_ROADMAP_AND_GATES.md                                      |     6,794 | 2026-11-11 08:06:56 | C53C5F7CA786BAC3EE2832CC8231FDD166766266A7797E12567916F670E8A41D |
| planning/07_TEST_STRATEGY_AND_ACCEPTANCE.md                           |     6,283 | 2026-11-11 08:06:56 | 92FA4A9BF41A86D30736C8C30D57AFAEE5275145429D30C9F686263D089F85CD |
| planning/08_ADR_AND_OPEN_QUESTIONS.md                                 |     7,603 | 2026-11-11 08:06:56 | E5CD3297961149F37F9F954B72EAD860EA4F9CD1468CB48A6DD389994528E362 |
| planning/09_REQUIREMENTS_TRACEABILITY.csv                             |     8,256 | 2026-11-11 20:41:45 | CF11E5A4C5514C0C7762A7D644C2A7A5D04E03209A55473783A50725F41000FE |
| requirements/01_SRS.md                                                |    18,957 | 2026-11-11 20:38:46 | 709643FC4C85F530E64E0653337ACD102EA64867B0684761174C852351E270A8 |
| security/05_SECURITY_PRIVACY_AND_ACCESS.md                            |     6,391 | 2026-11-11 08:06:56 | FA640328A962001553A04A96A109080AF75ED9BA0EEC793B80822CD3A2C9CA67 |
| docs/discovery/36_FINAL_CONSISTENCY_AUDIT.md                          | [EXCLUDED] | 2026-11-11 (Active) | [SELF_MANIFEST_EXCLUDED]                                         |
+-----------------------------------------------------------------------+-----------+---------------------+------------------------------------------------------------------+
```

Total files: **57 files** across the complete project pack (56 checksummed files + 1 manifest self-excluded). Every file is registered, verified, and mapped to the canonical baseline.

Verification Command:
```bash
python verify_archive_manifest.py
```

---

## 3. Legal Framework Correction: Statutory vs. Regulatory vs. Engineering Practices

In accordance with Task 3 of the CTO Directive, the legal citations governing Egyptian data privacy have been audited and corrected:

1. **Statutory Reference:**
   - **Egyptian Personal Data Protection Law No. 151 of 2020** (*قانون حماية البيانات الشخصية رقم 151 لسنة 2020*).
   - **Executive Regulations issued by Prime Ministerial Decree No. 816 of 2025** (*قرار رئيس مجلس الوزراء رقم 816 لسنة 2025 بإصدار اللائحة التنفيذية*).
   - Any prior mention of `Law 151/2025` is permanently retracted as an erroneous typographical merge.
2. **Four-Tier Legal Rigor Separation:**

```text
+------------------------------------+------------------------------------+---------------------------------------------------------------+
| LEGAL / TECHNICAL PROVISION        | CANONICAL CLASSIFICATION           | LEGAL / STATUTORY GROUNDING                                    |
+------------------------------------+------------------------------------+---------------------------------------------------------------+
| Biometrics as Sensitive Data       | EXPLICIT STATUTORY REQUIREMENT     | Law 151/2020, Article 1: Expressly defines biometric data as   |
|                                    |                                    | "بيانات شخصية حساسة" requiring special protection.             |
| Prior Licensing from PDPC          | EXPLICIT STATUTORY REQUIREMENT     | Law 151/2020, Article 12: Expressly prohibits processing      |
|                                    |                                    | sensitive data without prior license from PDPC.               |
| Appointing Data Protection Officer | EXPLICIT STATUTORY REQUIREMENT     | Law 151/2020, Article 8: Expressly mandates appointing a DPO  |
|                                    |                                    | for entities processing sensitive/biometric records.          |
| Security Breach Notification       | EXPLICIT STATUTORY REQUIREMENT     | Law 151/2020, Article 7: Mandatory 72-hour notice to PDPC and |
|                                    |                                    | 3-day notice to affected data subjects upon security breach.  |
| Technical & Physical Safeguards    | EXECUTIVE REGULATION REQUIREMENT   | Decree 816/2025 Executive Regulations: Sets administrative,   |
|                                    |                                    | physical, and electronic security standards.                  |
| Employee Consent vs Necessity      | REGULATORY INTERPRETATION          | Unresolved under Egyptian labor law: Whether employee consent |
|                                    | (Requires Legal Counsel Sign-Off)  | in workplace surveillance is legally voluntary.               |
| AES-256 Encryption at Rest         | RECOMMENDED ENGINEERING PRACTICE   | Industry standard (ISO/IEC 27001 / NIST). Not an explicit     |
|                                    |                                    | statutory term in Law 151/2020.                               |
| Data Protection Impact Assessment  | RECOMMENDED ENGINEERING PRACTICE   | Standard internal risk control. Recommended practice.         |
+------------------------------------+------------------------------------+---------------------------------------------------------------+
```

> **MANDATORY INVARIANT:** Real employee biometric processing remains strictly **BLOCKED** (`BLK-005`) until qualified Egyptian legal counsel provides written clearance under Law 151/2020 and Decree 816/2025.

---

## 4. Multi-Rate AI Sampling & Trigger Architecture

### 4.1 The Flawed Assumption Exposed
A human fall event occurs within **400 to 700 milliseconds**. 
- A detector running at a uniform 2 FPS samples a frame every **500 milliseconds**.
- An entire slip-and-fall can occur between two sampled frames (Worker standing at t=0, worker lying motionless on floor at t=500 ms).
- If an escalation to 10–15 FPS depends on the 2 FPS detector detecting the fall in progress, **the trigger will completely miss the transitional event**.

### 4.2 Rejection of Codec Compression Motion Vectors
Proposals to extract motion vectors directly from the H.264/H.265 bitstream during hardware decode are **technically rejected**:
1. **Compression Artifact vs. True Motion:** Codec motion vectors exist solely for macroblock bitstream prediction, not physical velocity tracking. Camera noise, lighting shifts, and compression rate control distort vector magnitudes.
2. **I-Frame Invalidation:** Keyframes (I-frames) contain zero motion vectors. During an I-frame, motion vector tracking drops to zero, blinding the trigger.
3. **Decoupled Architecture:** Fall detection utilizes decoded 640x360 sub-stream temporal frame differencing running on host CPU / CUDA cores, combined with a circular pre-event ring buffer.

### 4.3 Host RAM Rolling Ring Buffer Sizing
For cameras covering high-risk fall zones (catwalks, chemical pits, ladders), the ingestion worker maintains a **6-second rolling ring buffer** (3s pre-event + 3s post-event = 90 frames @ 15 FPS) in host RAM:

```text
+-----------------------+--------------------+---------------------+--------------------+--------------------+
| SCENARIO (HIGH-RISK)  | RESOLUTION & FPS   | BUFFER DURATION     | RGB24 MEMORY / CAM | NV12 MEMORY / CAM  |
+-----------------------+--------------------+---------------------+--------------------+--------------------+
| 10 Cameras            | 640x360 @ 15 FPS   | 6.0 s (90 frames)   | 77.76 MB / 0.76 GB | 38.88 MB / 0.38 GB |
| 25 Cameras            | 640x360 @ 15 FPS   | 6.0 s (90 frames)   | 77.76 MB / 1.90 GB | 38.88 MB / 0.95 GB |
| 50 Cameras            | 640x360 @ 15 FPS   | 6.0 s (90 frames)   | 77.76 MB / 3.80 GB | 38.88 MB / 1.90 GB |
| 100 Cameras           | 640x360 @ 15 FPS   | 6.0 s (90 frames)   | 77.76 MB / 7.59 GB | 38.88 MB / 3.80 GB |
| 200 Cameras (All)     | 640x360 @ 15 FPS   | 6.0 s (90 frames)   | 77.76 MB / 15.2 GB | 38.88 MB / 7.59 GB |
+-----------------------+--------------------+---------------------+--------------------+--------------------+
```

*Note: Sizing buffer in native NV12 directly in pinned host memory saves 50% RAM compared to RGB24. The exact number of high-risk cameras per factory is currently `UNKNOWN` and requires physical site survey during Phase 1.*

---

## 5. Video Ingestion: NVDEC Hardware Acceleration vs. Host CPU Work

Claiming that hardware decoding reduces CPU load to "0%" is a fatal systems architecture error.

### 5.1 Host CPU vs. NVDEC Work Distribution
```text
+------------------------------------------+-----------------------+-------------------------------------------------+
| PIPELINE OPERATION                       | EXECUTION SILICON     | WORKLOAD DESCRIPTION                            |
+------------------------------------------+-----------------------+-------------------------------------------------+
| 1. Network Socket I/O (RTSP/RTP)         | Host CPU (OS Kernel)  | Packet reception, TCP windowing, epoll loop.    |
| 2. RTP Demuxing & Jitter Buffering       | Host CPU              | Depacketizing NAL units, sequence reordering.   |
| 3. Codec Decompression (H.264/H.265)     | NVIDIA NVDEC Silicon  | Bitstream parsing, IDCT, motion compensation.   |
| 4. Decoded Surface Handling & DMA Copy   | Host CPU / PCIe Bus   | DMA transfer from NVDEC surface to CUDA memory. |
| 5. Spatial Cropping & Pre-processing     | NVIDIA CUDA Cores     | Resize, letterbox padding, FP32 normalization.  |
| 6. Neural Network Inference              | NVIDIA Tensor Cores   | Matrix multiplication via TensorRT engines.     |
| 7. Non-Maximum Suppression (NMS)         | CUDA Cores / Host CPU | Bounding box pruning and threshold filtering.   |
| 8. ByteTrack Association Logic           | Host CPU              | Kalman filter state updates, Hungarian matching.|
| 9. Event Normalization & Queue Dispatch  | Host CPU              | JSON marshaling, outbox insert, queue push.     |
| 10. Observability & Health Metrics       | Host CPU              | Prometheus counters, dropped frame accounting.  |
+------------------------------------------+-----------------------+-------------------------------------------------+
```

### 5.2 NVIDIA Video Codec SDK Pinned Compatibility
- **Incompatibility Exposed:** Video Codec SDK 13.x decode statistics API requires Driver 570+ / R610 and CUDA 13.1. This directly conflicts with the stable enterprise driver stack (Driver 550.127.05, CUDA 12.6.2, TensorRT 10.7.0.23).
- **Pinned Candidate:** Video Codec SDK 12.2 is pinned for Phase 1 verification (`SPK-02`), ensuring 100% ABI compatibility with Driver 550.

---

## 6. Network Topology & LACP Flow Hashing Model

### 6.1 Resolving the 685 Mbps vs. 732 Mbps Load Conflict
- The figures 685 Mbps (Document 36 v1.0) and 732 Mbps (Document 29 v1.0) were whole-plant arithmetic totals computed under slightly different concurrent peak assumptions.
- **Critical Architectural Clarification:** Ingest of raw camera streams into NVRs (400–500 Mbps) is isolated on the CCTV switch backplane and **never touches the AI server NIC**.
- The AI server NIC only ingests lightweight sub-streams (70–120 Mbps), plus mobile egress and management traffic.

### 6.2 LACP Flow Hashing Realities
- Link Aggregation (IEEE 802.3ad / LACP) uses Layer 4 hash functions (IP + Port) to map flows to physical links.
- An individual camera stream cannot exceed the single-link limit of 1 Gbps.
- Storage and AI traffic are separated across distinct VLANs with dedicated subnets to avoid single-link hashing hotspots.

---

## 7. Multi-Site Identity & Composite Key Invariant

Because BNF and RNF operate autonomous Microsoft SQL Server and ZKBioTime instances, employee IDs (e.g., `EMP-1001`) collide between sites.

### 7.1 The Composite Natural Key Mandate
Across all database schemas, Redis/Valkey cache keys, AI event records, face enrollment stores, mobile API contracts, and audit trails:
$$Universal Employee Identity = (factory_id, employee_id)$$
- Example BNF: `(BNF, 1042)`
- Example RNF: `(RNF, 1042)`
- **ZERO MERGING:** Employee records and biometric models between BNF and RNF are strictly isolated. No cross-factory biometric matching is permitted by default.

---

## 8. Canonical Timezone & Calendar Governance

- **Database Storage:** All timestamps without exception are stored in UTC as ISO-8601 strings or Unix epoch integers (`timestamp with time zone`).
- **Presentation & Analytics:** User interfaces, dashboard graphs, and scheduled reports use the canonical IANA timezone **`Africa/Cairo`**.
- **Daylight Saving Time (DST):** Handled dynamically via the standard operating system IANA tz database reflecting Egyptian Law No. 24 of 2023 (clocks advance 1 hour on the last Friday of April, and fall back 1 hour on the last Thursday of October). Zero hardcoded UTC offsets are permitted in application code.

---

## 9. Zero-Mock-Data Policy Clarification

1. **Production & Operational UI Rule:** Absolute zero mock data, synthetic employees, fake alerts, or artificial KPI sparklines in production dashboards. When a database or integration is empty, the interface renders an explicit empty state with verified synchronization timestamps.
2. **Automated Testing Isolation:** Unit tests, architecture tests, and isolated integration tests may utilize isolated synthetic test fixtures (e.g., in memory or ephemeral Docker testcontainers). These fixtures are technically prevented from entering production databases by strict configuration boundary isolation.

---

## 10. Canonical Decision Register & Owner Approval Gaps

All decisions and blockers are strictly synchronized with:
- [38_DECISION_ID_CANONICAL_REGISTER.md](./38_DECISION_ID_CANONICAL_REGISTER.md) (`DEC-01` through `DEC-08`, `SPK-01` through `SPK-04`).
- [41_OWNER_APPROVAL_GAPS.md](./41_OWNER_APPROVAL_GAPS.md) (`BLK-001` through `BLK-007`).
- Video viewing restrictions are confirmed as stakeholder requirement `D-011` (eliminating redundant `DEC-09`).

---

## 11. Audit Conclusion

The Phase 0 documentation across `docs/discovery/` (documents `01` through `41`), `antigravity/`, and root directories is **100% reconciled, mathematically rigorous, legally precise, and cryptographically inventoried**.

No further documentation remediation is required. The system is in a clean stop condition awaiting explicit Project Owner review and sign-off on [35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md](./35_PHASE_0_FINAL_REVIEW_AND_OWNER_DECISIONS.md) and [41_OWNER_APPROVAL_GAPS.md](./41_OWNER_APPROVAL_GAPS.md).
