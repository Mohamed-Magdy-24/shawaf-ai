# SKILL USAGE MATRIX
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Customization & Agent Skill Governance Matrix  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Staff+ Architect  
**Governing Standard:** Section 8, Section 9 & Section 10 of Ultimate Master Directive (`Prompt.md`)  
**Date:** 2026-11-18  

---

## 1. Skill Governance & Selection Principles

The project owner has provided a rich catalog of installed skills. Pursuant to the **Mandatory Skills Preflight & Global Skills Enforcement Rule** (`AGENTS.md`) and Section 8 of the Master Directive:
1. **No Fabricated Compliance:** A skill is never marked as activated unless its instructions in `SKILL.md` have been inspected directly and its specific workflows applied.
2. **Domain-Specific Assignment:** Skills are assigned strictly to their corresponding engineering workstream.
3. **Strict Exclusion of Incompatible Tooling:** Public cloud dependencies (GCP, BigQuery), multi-tenant SaaS patterns, unneeded database engines (ClickHouse), and incompatible hardware-specific tooling (Reolink) are formally **EXCLUDED** with documented technical justifications.

---

## 2. Complete Skill Inventory & Assignment Matrix

| Skill Name | Availability Verified | Capability Verified | Assigned Workstream | When to Use | Reason for Selection | Constraints / Exclusion Rationale | Usage Status |
|---|---|---|---|---|---|---|---|
| **`accidental-data-loss-prevention`** | YES | YES | All Workstreams | Before any destructive command (`rm`, `del`, `drop`, `truncate`, git clean). | Mandatory safety guard against unapproved file or data loss. | Applies project-wide. Hard stop if command is destructive. | **ACTIVE / ENFORCED** |
| **`verification-before-completion`** | YES | YES | Workstream G (QA) | Before claiming any task, fix, or phase is complete. | Requires running fresh verification commands and checking exit codes before claims. | Mandatory. No assertions without empirical evidence. | **ACTIVE / ENFORCED** |
| **`writing-plans`** | YES | YES | Workstream A (Product) | When structuring multi-step implementation plans. | Provides clear file breakdown, bite-sized tasks, and checkable steps. | Use for all task decompositions. | **ACTIVE / APPLIED** |
| **`work-state-and-delivery`** | YES | YES | Workstream A / Lead | When maintaining `PROJECT_HANDOFF.md`, registries, and commit coupling. | Unifies requirements, work state, and delivery evidence without duplicate ledgers. | Governs canonical status reporting. | **ACTIVE / APPLIED** |
| **`harness-engineering`** | YES | YES | Lead Architect | When establishing agent harnesses, environmental constraints, and feedback loops. | Enforces cybernetic control and boundary checks for autonomous agent operations. | Must prevent runaway agent loops. | **ACTIVE / APPLIED** |
| **`repo-harness-assessment`** | YES | YES | Lead Architect | Evaluating repository agent-readiness and reconciling entrypoints (`AGENTS.md`). | Aligns root operational instructions and memory surfaces. | Must respect file size caps (<20KB). | **ACTIVE / APPLIED** |
| **`ui-ux-pro-max`** | YES | YES | Workstream B (UX/UI) | Designing all Web Admin and Mobile screens, typography, colors, and layout tokens. | Provides deep industrial design intelligence, accessibility checks, and dark-mode tokens. | Must design for high-density operator environments. | **ACTIVE / APPLIED** |
| **`design-system`** | YES | YES | Workstream B (UX/UI) | Building the shared component library and design token architecture. | Enforces 3-layer tokens (primitive -> semantic -> component) in Flutter. | No arbitrary inline styling in UI components. | **ACTIVE / APPLIED** |
| **`taste-skill` (design-taste-frontend)** | YES | YES | Workstream B (UX/UI) | Styling Web Admin Console to avoid generic, AI-generated dashboard appearances. | Anti-slop frontend design: real UI density, calm telemetry, zero fake decorative widgets. | Avoid gratuitous 3D/glow effects in industrial tools. | **ACTIVE / APPLIED** |
| **`flutter-clean-code`** | YES | YES | Workstream E (Client) | Implementing Flutter Android and Flutter Web application code. | Clean code principles for Dart/Flutter; enforces separation of UI and business logic. | Mandatory for all `*.dart` files. | **ASSIGNED (Phase 5/WP-5)** |
| **`flutter-design-patterns`** | YES | YES | Workstream E (Client) | Structuring state management, repositories, and dependency injection in Flutter. | Implements BLoC/Cubit, Repository pattern, and service locator (`get_it`). | Architecture must remain testable with mock data. | **ASSIGNED (Phase 5/WP-5)** |
| **`flutter-ux-architecture`** | YES | YES | Workstream E (Client) | Mobile navigation, responsive breakpoints, and accessibility. | Ensures high-contrast readability under bright factory lighting. | Must handle touch targets >= 48px for gloved use. | **ASSIGNED (Phase 5/WP-5)** |
| **`clean-architecture`** | YES | YES | Workstream C (Backend) | Designing Go backend domain, application, and infrastructure layers. | Enforces strict dependency inversion: domain logic never imports database or HTTP packages. | Mandatory for `backend/cmd/edged/` and internal packages. | **ASSIGNED (Phase 2/WP-2)** |
| **`go-clean-architecture`** | YES | YES | Workstream C (Backend) | Structuring Go package layouts, interfaces, and database repositories. | Idiomatic Go Clean Architecture based on robust production templates. | Go standard package layout (`internal/domain/`, etc.). | **ASSIGNED (Phase 2/WP-2)** |
| **`backend-patterns`** | YES | YES | Workstream C (Backend) | API design, database connection pooling, idempotent handlers, and error formats. | Prevents resource leaks and establishes structured JSON error schemas. | Must enforce explicit error codes and request IDs. | **ASSIGNED (Phase 2/WP-2)** |
| **`test-driven-development`** | YES | YES | Workstream G (QA) | Developing Go domain logic, outbox dispatch, and event state machines. | Enforces red-green-refactor cycle and test coverage before implementation. | Unit tests must run without external network access. | **ASSIGNED (Phase 2/WP-2)** |
| **`systematic-debugging`** | YES | YES | Workstream G (QA) | Diagnosing test failures, socket disconnects, or pipeline bottlenecks. | Enforces root-cause analysis before proposing code changes. | Prohibits guessing or trial-and-error fixes. | **ACTIVE / READY** |
| **`ml-best-practices`** | YES | YES | Workstream D (AI/Video) | Evaluating candidate models (YOLOX, RT-DETR, ByteTrack, RTMPose). | Rigorous evaluation metrics, dataset separation, and false-positive risk analysis. | All models must be evaluated on labeled benchmarks. | **ASSIGNED (Phase 3/WP-3)** |
| **`onvif-surveillance-protocol`** | YES | YES | Workstream D (AI/Video) | Interfacing with IP cameras, NVR discovery, PTZ controls, and RTSP stream extraction. | Authoritative protocol engineering for ONVIF Profile S/T and RTSP authentication. | Must handle stream reconnection and socket drops safely. | **ASSIGNED (Phase 7/Spikes)** |
| **`webrtc-engineering`** | YES | YES | Workstream D / Client | Implementing low-latency live video streaming via `go2rtc` and WebRTC SDP proxy. | Real-time browser and mobile streaming with sub-500ms glass-to-glass latency. | WebRTC SDP exchange must be authenticated via Go. | **ASSIGNED (Phase 4/WP-4)** |
| **`managing-python-dependencies`** | YES | YES | Workstream D (AI/Video) | Installing and pinning dependencies for Python AI worker (`requirements.txt`). | Avoids global `pip install`; uses virtualenvs and pinned container dependencies. | Python dependencies must be pinned to exact versions. | **ACTIVE / APPLIED** |
| **`no-ai-slop`** | YES | YES | Workstream A (Docs) | Reviewing technical reports, documentation, and user-facing text. | Produces direct, sharp, professional prose free of AI clichés and superficial fluff. | Enforces high signal-to-noise ratio in all docs. | **ACTIVE / APPLIED** |
| **`coding-standards`** | YES | YES | All Workstreams | General code formatting, static analysis, and linting rules. | Universal standards for Go, Python, Dart, and SQL. | Linters must be integrated into `make ci`. | **ACTIVE / APPLIED** |
| **`eval-harness`** | YES | YES | Workstream G (QA) | Defining capability and regression evals for AI event generation. | Measures pass@k reliability and prevents regression in detection triggers. | Required for shadow-mode model evaluations. | **ASSIGNED (Phase 6/WP-6)** |
| **`validation-harness-design`** | YES | YES | Workstream G (QA) | Designing `make test`, test matrices, JUnit reports, and CI failure gates. | Standardizes test entrypoints across Docker, Go, and Flutter. | Must produce exit 0 on success, non-zero on failure. | **ASSIGNED (Phase 2/WP-2)** |
| **`plan-loop`** | YES | YES | Lead Architect | Decomposing engineering tasks into atomic, reviewable implementation plans. | Formalizes planning before execution. | Not for writing code directly; handoff to execution. | **ACTIVE / APPLIED** |
| **`swe-loop`** | YES | YES | Workstream C / E | Executing self-checking software loops (Engineer writes code, QA writes tests). | Disjoint scopes ensure objective quality verification. | Applies during implementation sprints. | **ASSIGNED (Phase 4/WP-4)** |
| **`human-in-the-loop`** | YES | YES | Lead Architect | Designing review and approval intervention gates for critical operations. | Ensures owner decisions (`DEC-01`..`08`) cannot be bypassed by automated agents. | Mandatory for all gated activities. | **ACTIVE / APPLIED** |
| **`accidental-data-loss-prevention`** | YES | YES | All Workstreams | Guarding against destructive database operations or workspace file deletions. | Enforces explicit owner confirmation before any irreversible change. | Mandatory across all tools and commands. | **ACTIVE / ENFORCED** |

---

## 3. Explicitly Excluded Skills Register

The following skills are installed in the global environment but are **STRICTLY EXCLUDED** from this project, with explicit technical and architectural justifications:

| Excluded Skill | Exclusion Category | Technical Justification for Exclusion |
|---|---|---|
| **`developing-with-bigquery`** | Cloud Dependency | **EXCLUDED.** The platform is 100% on-premises edge computing deployed locally in Egyptian factories. Public cloud data warehouses are strictly prohibited (`Prompt.md` §26, Egyptian Law 151/2020). |
| **`bigquery-data-transfer-service`** | Cloud Dependency | **EXCLUDED.** Factory surveillance video and attendance data must never be transferred to public cloud storage without owner and legal authorization. |
| **`gcp-composer-troubleshooting`** | Cloud Dependency | **EXCLUDED.** Apache Airflow on Cloud Composer is not part of this on-premises architecture. Internal task scheduling uses Go native cron/tickers. |
| **`gcp-spark`** | Cloud Dependency | **EXCLUDED.** Apache Spark / Dataproc is an oversized distributed analytics cluster completely unnecessary for local edge event processing. |
| **`gcp-dataflow`** | Cloud Dependency | **EXCLUDED.** Apache Beam / Google Dataflow requires Google Cloud infrastructure; violates the on-premises air-gapped architecture. |
| **`gcp-data-pipelines`** | Cloud Dependency | **EXCLUDED.** Orchestration of GCP cloud pipelines is irrelevant to on-premises PostgreSQL and edge container services. |
| **`gcloud-auth-verification`** | Cloud Dependency | **EXCLUDED.** No Google Cloud service accounts or ADC credentials exist or are permitted in this project. |
| **`gcp-pipeline-orchestration`** | Cloud Dependency | **EXCLUDED.** Cloud Composer orchestration is out of scope. |
| **`gcp-pipeline-resource-provisioning`** | Cloud Dependency | **EXCLUDED.** GCP cloud resource provisioning does not apply to local edge servers. |
| **`discovering-gcp-data-assets`** | Cloud Dependency | **EXCLUDED.** Data assets reside exclusively in local PostgreSQL 16 databases and local NVRs. |
| **`building-data-apps`** | Cloud Dependency | **EXCLUDED.** Skill assumes Streamlit / BigQuery; our UI is built natively on Flutter Web / Dart. |
| **`data-autocleaning`** | Cloud Dependency | **EXCLUDED.** Dataform / dbt / BigQuery pipelines are not used in this architecture. |
| **`dataform-bigquery`** | Cloud Dependency | **EXCLUDED.** Dataform BigQuery ELT is completely out of scope. |
| **`dbt-bigquery`** | Cloud Dependency | **EXCLUDED.** dbt BigQuery modeling is out of scope. |
| **`notebook-guidance`** | Data Science / IPYNB | **EXCLUDED.** Core application logic must be compiled Go and Python services, not exploratory Jupyter notebooks. |
| **`clickhouse-io`** | Architectural Simplification | **EXCLUDED.** Per `ADR-013`, ClickHouse is not justified for the current event volume. Standard PostgreSQL 16 handles all time-series event storage with native indexes. |
| **`saas-multi-tenant`** | Architectural Mismatch | **EXCLUDED.** Assumes public SaaS cloud multi-tenancy. This platform is an on-premises multi-factory edge deployment with physical network segregation. |
| **`postgres-rls`** | Tool Specificity | **EXCLUDED.** We implement PostgreSQL 16 Row-Level Security natively via custom SQL migrations with `FORCE ROW LEVEL SECURITY` per `ADR-013`, avoiding external SaaS RLS assumptions. |
| **`reolink-remote-backup`** | Hardware Specificity | **EXCLUDED.** The physical factory fleet consists of Dahua, Hikvision, and Tiandy NVRs/cameras; Reolink FTP/cloud backup patterns do not apply. |
| **`ipcam`** | Tool Redundancy | **EXCLUDED.** ONVIF and RTSP interactions are governed by `onvif-surveillance-protocol` and `webrtc-engineering` via `go2rtc`. |
| **`banner-design`** | Irrelevant Domain | **EXCLUDED.** Marketing and social media banners are completely irrelevant to an industrial safety surveillance application. |
| **`slides`** | Irrelevant Domain | **EXCLUDED.** Presentation slide generation is out of scope. |
| **`brand`** | Irrelevant Domain | **EXCLUDED.** Consumer brand marketing is out of scope. |
| **`gan-style-harness`** | Architectural Mismatch | **EXCLUDED.** Generative Adversarial Network harness patterns are not required for deterministic safety event detection and tracking. |
| **`caveman`** | Tone Violation | **EXCLUDED.** Informal terse communication violates the formal Principal AI Engineer operating standard and audit requirements. |
| **`langchain-build-agent`** | Technology Simplification | **EXCLUDED.** Deterministic computer vision pipelines do not use probabilistic LLM agent frameworks (LangChain/LangGraph) in the core video path. |
| **`langchain-agent-monitoring`** | Technology Simplification | **EXCLUDED.** Telemetry is monitored via standard Prometheus/Grafana metrics and Go health endpoints, not LangSmith. |
| **`langchain-agent-tracing`** | Technology Simplification | **EXCLUDED.** OpenTelemetry tracing in Go/Python is used instead of LangSmith LLM tracing. |
| **`langchain-eval-engineering`** | Technology Simplification | **EXCLUDED.** Computer vision model evaluation uses standard precision/recall/mAP metrics, not LLM-as-a-judge evaluators. |

---

## 4. Workstream-to-Skill Assignment Mapping

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ACTIVE SKILL MAPPING BY WORKSTREAM                                                                     │
├───────────────────────────────┬────────────────────────────────────────────────────────────────────────┤
│ Workstream                    │ Authoritative Active Skills Assigned                                   │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Lead Architect & Strategy     │ harness-engineering, repo-harness-assessment, plan-loop,               │
│                               │ human-in-the-loop, accidental-data-loss-prevention                     │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream A: Product & SRS   │ writing-plans, work-state-and-delivery, no-ai-slop                     │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream B: UX/UI Design    │ ui-ux-pro-max, design-system, taste-skill (design-taste-frontend)      │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream C: Backend & Data  │ clean-architecture, go-clean-architecture, backend-patterns            │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream D: AI & Video      │ ml-best-practices, onvif-surveillance-protocol, webrtc-engineering,    │
│                               │ managing-python-dependencies                                           │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream E: Unified Client  │ flutter-clean-code, flutter-design-patterns, flutter-ux-architecture   │
├───────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ Workstream G: QA & Testing    │ verification-before-completion, test-driven-development,               │
│                               │ systematic-debugging, validation-harness-design, eval-harness, swe-loop│
└───────────────────────────────┴────────────────────────────────────────────────────────────────────────┘
```
