# 19 — Phased Implementation Roadmap & Milestone Gates

**Document ID:** DISC-19-ROADMAP  
**Version:** 1.1.0-remediated  
**Status:** PROPOSED ROADMAP (Awaiting Owner Review & Gate 0 Sign-Off)  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Traceability Reference:** PLAN-001, SRS-001, Documents 26–41  

---

## 1. Roadmap Architecture: Gated Discipline

The implementation of the BNF and RNF Industrial AI Surveillance Platform is structured across **8 Strictly Gated Phases**.

In accordance with the CTO Master Directive:
> **One phase at a time. A phase is complete only when its empirical evidence is reviewed, its gate is passed, and explicit stakeholder sign-off is obtained. No code generation or premature implementation is permitted for future phases.**

```mermaid
gantt
    title Industrial AI Surveillance Platform Roadmap
    dateFormat  YYYY-MM-DD
    section Discovery & Proof
    Phase 0: Discovery, Remediation & Consistency (Current) :active, p0, 2026-11-11, 2026-11-18
    Gate 0 Review & Approval (Documents 35 & 41)         :crit, g0, after p0, 2d
    Phase 1: Hardware & Integration Spikes               :p1, after g0, 14d
    Gate 1 Spike Verification                             :crit, g1, after p1, 2d
    section Engineering Core
    Phase 2: Foundation, CI & Clean Arch                  :p2, after g1, 14d
    Gate 2 Architecture & Test Gate                       :crit, g2, after p2, 2d
    Phase 3: Site Adapters & Identity Sync                :p3, after g2, 18d
    Gate 3 Integration Isolation Gate                     :crit, g3, after p3, 2d
    section Video, AI & Mobile
    Phase 4: Video Pipeline & Vision Models               :p4, after g3, 28d
    Gate 4 Model Accuracy Gate                            :crit, g4, after p4, 3d
    Phase 5: Event Engine & Urgent Fire Outbox            :p5, after g4, 14d
    Gate 5 Alert Routing Resilience Gate                  :crit, g5, after p5, 2d
    Phase 6: Android Manager Client App                   :p6, after g5, 21d
    Gate 6 Mobile Ergonomics Gate                         :crit, g6, after p6, 3d
    section Pilot & Cutover
    Phase 7: Hardening, Reporting & 2-Site Pilot          :p7, after g6, 28d
    Gate 7 Production Readiness Sign-Off                  :crit, g7, after p7, 5d
    Phase 8: Scale & Continuous Improvement               :p8, after g7, 60d
```

---

## 2. Phase-by-Phase Execution Plan & Mandatory Gate Criteria

### Phase 0: Discovery, Skills Audit & Execution Blueprint (CURRENT PHASE)
- **Primary Goal:** Establish factual baseline, audit workspace, analyze requirements gaps, catalogue 35-discipline task inventory, and author the 41 Phase 0 deliverables (`docs/discovery/01` through `41`).
- **Scope & Constraints:** Strictly read-only discovery; zero application code written; zero dependencies installed; zero Git operations; zero live biometrics.
- **Key Deliverables:** 41 Discovery, Remediation & Consistency Deliverables in `docs/discovery/` governed by Documents 26, 36, 38, and 41.
- **GATE 0 CRITERIA (Owner Sign-Off):**
  - [x] Complete project understanding and requirements gap matrix authored.
  - [x] Zero application files modified or created during discovery.
  - [x] Complete task inventory (A to AI) and critical path mapped.
  - [x] 21 new remediation & consistency deliverables (`21` to `41`) authored resolving hardware arithmetic, storage models, legal frameworks, decision ID registers, and contrast tokens.
  - [ ] Project Owner signs off on Documents 35 and 41 and authorizes Phase 1 spikes.

---

### Phase 1: Architecture Decisions & Technical Spikes (Duration: 2 Weeks)
- **Primary Goal:** Prove the riskiest external dependencies and hardware assumptions before committing to production architecture.
- **Key Tasks:**
  1. *Spike 1 (BLK-001):* ZKBioTime photo extraction test on representative biometric terminals.
  2. *Spike 2 (BLK-002):* Benchmark candidate YOLOX / RT-DETR and ByteTrack models using ONNX Runtime CPU inference baseline, evaluating optional CUDA execution only upon established hardware compatibility (test rig per Document 28).
  3. *Spike 3 (BLK-003):* RTSP stream stability and WebRTC low-latency streaming spike using `go2rtc`.
  4. *Spike 4 (OQ-005):* SQL Server read-only schema discovery and sample data mapping.
- **Key Deliverables:** 4 Technical Spike Reports, Capability Matrices, Measured Hardware BOM, Approved ADRs.
- **GATE 1 CRITERIA (Spike Verification Gate):**
  - [ ] Proven photo retrieval path (or explicit approval of administrative photo portal fallback DEC-03).
  - [ ] Enterprise GPU server procurement released by management based on empirical benchmark results.
  - [ ] Successful low-latency WebRTC video streaming from test NVR channel.
  - [ ] Formal sign-off on Architecture Decision Records ADR-001 to ADR-010.

---

### Phase 2: Engineering Foundation, CI/CD & Clean Architecture (Duration: 2 Weeks)
- **Primary Goal:** Establish rock-solid software engineering discipline, repository structure, and automated quality gates.
- **Key Tasks:**
  1. Initialize private Git repository and trunk-based branching model.
  2. Implement Clean Architecture folder scaffolding for Modular Monolith backend and Flutter client.
  3. Configure GitHub Actions CI: `golangci-lint`, `flutter analyze`, `gitleaks`, and `trivy`.
  4. Establish unit/contract test harnesses and architecture boundary linters.
  5. Configure secrets management, structured logging, and Prometheus metric exporters.
- **Key Deliverables:** Compilable foundation, automated CI pipelines, architecture tests, secure config templates.
- **GATE 2 CRITERIA (Foundation Gate):**
  - [ ] Clean build and 100% passing architecture boundary tests in CI.
  - [ ] Automated pre-commit secret scanning verified.
  - [ ] Zero fake vendor integrations in production paths.

---

### Phase 3: Site Identity, Device Registry & Integrations (Duration: 2.5 Weeks)
- **Primary Goal:** Connect validated site sources through site-isolated Clean Architecture adapters.
- **Key Tasks:**
  1. Implement BNF and RNF site-isolated configuration and database migrations.
  2. Implement read-only SQL Server attendance and employee profile synchronizer.
  3. Implement ZKBioTime REST API client with pagination, retry, and circuit breakers.
  4. Implement camera and NVR device registry with automated health watchdogs.
- **Key Deliverables:** Verified read-only connectors, reconciliation reports, negative site isolation tests.
- **GATE 3 CRITERIA (Integration Isolation Gate):**
  - [ ] 100% pass rate on Site Isolation Penetration Tests (`T-QA-001`).
  - [ ] Idempotent employee synchronization proven across both factories.
  - [ ] Face recognition remains disabled if photo extraction gate was not passed.

---

### Phase 4: Video Ingestion & Video AI Proof of Value (Duration: 4 Weeks)
- **Primary Goal:** Build the high-throughput video pipeline and train/evaluate computer vision models one capability at a time.
- **Execution Sequence:**
  1. *Step 4A:* `go2rtc` stream ingestion, frame sampling (2–5 FPS baseline, dynamic burst), and spatial ROI masking.
  2. *Step 4B:* Person Detection & ByteTrack tracking.
  3. *Step 4C:* Restricted Area Geofencing ray-casting.
  4. *Step 4D:* Zone-Specific PPE Detection (Hard hat, vest, glasses).
  5. *Step 4E:* Urgent Fire & Smoke Temporal Detection.
  6. *Step 4F:* Fall/Accident (10–15 FPS burst) & Phone Use Behavior Classifiers.
  7. *Step 4G:* Object Classification & Suspicious Movement Handoff.
- **Key Deliverables:** Model evaluation reports, ONNX model validation checkpoints, held-out validation benchmarks.
- **GATE 4 CRITERIA (Model Calibration Gate):**
  - [ ] Precision and recall targets met on held-out site validation video.
  - [ ] Empirical per-frame inference latency measured and validated against owner-approved candidate targets.
  - [ ] Zero uncalibrated or fabricated accuracy claims.

---

### Phase 5: Event Normalization, Outbox Engine & Urgent Fire Routing (Duration: 2 Weeks)
- **Primary Goal:** Normalize AI observations, execute business policy specifications, and guarantee reliable alert delivery.
- **Key Tasks:**
  1. Implement canonical Event Envelope normalization with confidence and evidence locators.
  2. Implement Transactional Outbox pattern in PostgreSQL for atomic persistence.
  3. Implement dedicated Valkey priority queue for sub-second Urgent Fire Alert dispatch.
  4. Implement ordinary alert routing engine enforcing strict BNF/RNF recipient isolation.
- **Key Deliverables:** Outbox worker, notification dispatch engine, delivery audit logs, retry/dead-letter queues.
- **GATE 5 CRITERIA (Alert Resilience Gate):**
  - [ ] Urgent fire alert server dispatch latency measured and evaluated against candidate target (<500ms server dispatch target per Document 39).
  - [ ] Zero cross-site alert leakage proven under negative test scenarios.
  - [ ] Zero lost alerts during simulated broker disconnects.

---

### Phase 6: Android Manager Client Application (Duration: 3 Weeks)
- **Primary Goal:** Deliver the manager-facing Android experience adhering to the Premium Industrial Intelligence design system.
- **Key Tasks:**
  1. Scaffold Flutter app using `flutter-clean-code` and `flutter-cubit`.
  2. Implement visual Factory Switcher header with explicit two-tap confirmation.
  3. Implement low-latency WebRTC video player with tokenized security checks.
  4. Implement real-time reactive Alert Inbox with audio/haptic feedback on fire events.
  5. Implement embedded in-app reporting screens with native vector charts (Africa/Cairo timezone).
- **Key Deliverables:** Production Android APK, golden UI tests, usability review report.
- **GATE 6 CRITERIA (Mobile Ergonomics Gate):**
  - [ ] Zero video stream access for users lacking explicit video roles.
  - [ ] Smooth 60 FPS UI rendering; WebRTC stream latency measured against candidate targets.
  - [ ] Graceful handling of network disconnects and verified empty states (zero mock data).

---

### Phase 7: Reporting, Hardening & 2-Site Operational Pilot (Duration: 4 Weeks)
- **Primary Goal:** Execute scheduled reporting rollups, complete security hardening, and conduct 14-day production pilots at BNF and RNF.
- **Key Tasks:**
  1. Automate daily, weekly, and monthly report snapshots via scheduled rollup jobs (Cairo midnight boundary).
  2. Execute 14-day uninterrupted operational pilot on 10 cameras at BNF Factory.
  3. Execute 14-day operational pilot at RNF Factory; calibrate site-specific differences.
  4. Conduct cold-standby disaster recovery drill measuring RTO (<2h) and RPO (<15m).
  5. Author Master Operational Runbooks and conduct IT staff training.
- **Key Deliverables:** Pilot performance report, disaster recovery certification, production runbooks.
- **GATE 7 CRITERIA (Production Readiness Sign-Off):**
  - [ ] All 18 Production Readiness Dimensions satisfied.
  - [ ] Written operational sign-off from BNF and RNF Factory Managers.
  - [ ] Formal legal sign-off on employee biometric privacy compliance under Law 151/2020.

---

### Phase 8: Scale & Continuous Improvement (Post-Cutover)
- Expand camera coverage from initial 10 pilot cameras to full 200+ camera fleet per factory in controlled 25-camera batches.
- Continuously monitor model drift, queue lag, and false-positive rates; execute canary rollouts for improved model versions.

---

## 3. Implementation Roadmap Sign-Off

- **Status:** PROPOSED ROADMAP (v1.2.0-canonical).
- **Next Step:** Present Gate 0 deliverables (Documents 35 & 41) to Project Owner for review and approval to initiate Phase 1.
