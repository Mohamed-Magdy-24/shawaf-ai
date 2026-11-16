> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 04 — Comprehensive Skills Audit & Capabilities Report (Remediated Rev 1.2)

**Document ID:** DISC-04-SKILLS-AUDIT  
**Version:** 1.2.0-remediated  
**Date:** 2026-11-11  
**Status:** CANONICAL SKILLS AUDIT  
**Classification:** `OBSERVED_IN_REPOSITORY` & `VERIFIED_OFFICIAL_SOURCE`  
**Directive Reference:** Finding P1-06 & Section 11 of CTO Review  

---

## 1. Executive Discovery & Skill Verification Protocol

In strict accordance with Finding P1-06 of the CTO Review:
- All local absolute paths have been **sanitized** (removing local usernames and host machine paths).
- The complete inventory of **37 verified skills** (29 registered in the system environment + 8 local workspace skills) is fully enumerated and accounted for.
- **Packaged Skill vs. Technical Capability:** A missing packaged skill is **NOT** proof that a technical capability is unavailable. Advanced capabilities (e.g., ONVIF Profile G streaming, TensorRT optimization, ZKTeco protocol adapters) are engineered directly using standard software libraries and official vendor documentation.
- **Read Status vs. Task Invocation:** Reading a skill during discovery establishes awareness; a skill is only considered "invoked" when its specific instructions are actively applied during a task.

---

## 2. Exhaustive Audit of All 37 Verified Skills

### 2.1 Workspace Engineering Skills (`<workspace>/skills/`)

| # | Exact Registered Skill Name | Sanitized Disk Location | Read? | Core Capabilities & Tooling | Applicable Project Tasks | Priority |
|---|---|---|---|---|---|---|
| 1 | `flutter-clean-code` | `<workspace>/skills/flutter-clean-code/SKILL.md` | **YES** | Domain-Driven Design in Flutter; isolates presentation widgets from data sources via abstract repositories. | T-FEA-001, T-AND-001–004 | **MANDATORY** |
| 2 | `flutter-cubit` | `<workspace>/skills/flutter-cubit/SKILL.md` | **YES** | Deterministic, immutable state management using Bloc/Cubit; avoids unnecessary widget rebuilds. | T-FEA-002, T-AND-001, T-AND-003 | **MANDATORY** |
| 3 | `flutter-design-patterns` | `<workspace>/skills/flutter-design-patterns/SKILL.md` | **YES** | Creational/structural patterns in Dart (Adapter, Factory, Repository, Strategy). | T-FEA-001, T-AND-002 | **MANDATORY** |
| 4 | `flutter-ux-architecture` | `<workspace>/skills/flutter-ux-architecture/SKILL.md` | **YES** | High-contrast industrial mobile UX, navigation hierarchy, error/empty state patterns, ergonomics. | T-DS-001, T-DS-002, T-AND-001 | **MANDATORY** |
| 5 | `flutter-code-review` | `<workspace>/skills/flutter-code-review/SKILL.md` | **YES** | Review checklist for Dart code: memory leaks, stream cancellation, layout performance. | T-DEV-001, T-QA-001 | **RECOMMENDED** |
| 6 | `flutter-oop` | `<workspace>/skills/flutter-oop/SKILL.md` | **YES** | SOLID principles, interface segregation, strongly typed domain contracts. | T-FEA-001, T-AND-002 | **RECOMMENDED** |
| 7 | `flutter-pragmatic` | `<workspace>/skills/flutter-pragmatic/SKILL.md` | **YES** | Anti-overengineering discipline; balances clean architecture with delivery velocity. | T-FEA-001–004 | **RECOMMENDED** |
| 8 | `flutter-pr` | `<workspace>/skills/flutter-pr/SKILL.md` | **YES** | Pull request review and quality gate standards for Flutter/Dart codebases. | T-DEV-001 | **RECOMMENDED** |

### 2.2 System Registered Mandatory & Operational Skills (`<configDir>/skills/` & `<builtinDir>/skills/`)

| # | Exact Registered Skill Name | Sanitized Disk Location | Read? | Core Capabilities & Tooling | Applicable Project Tasks | Priority |
|---|---|---|---|---|---|---|
| 9 | `accidental-data-loss-prevention` | `<configDir>/skills/accidental-data-loss-prevention/SKILL.md` | **YES** | Intercepts destructive SQL commands (DROP, TRUNCATE, broad DELETE) and storage deletions. | T-DBA-001, T-DBA-002, T-SQL-001 | **MANDATORY** |
| 10 | `ml-best-practices` | `<configDir>/skills/ml-best-practices/SKILL.md` | **YES** | Machine learning evaluation standards: held-out test sets, confidence calibration, data leakage prevention. | T-AI-001–012, T-QA-002 | **MANDATORY** |
| 11 | `managing-python-dependencies` | `<configDir>/skills/managing-python-dependencies/SKILL.md` | **YES** | Virtual environments (venv/poetry); avoids global `pip install`; pins deterministic packages. | T-CV-001, T-TRK-001, T-PPE-001 | **MANDATORY** |
| 12 | `generative_ui` | `<builtinDir>/skills/generative_ui/SKILL.md` | **YES** | Renders interactive HTML/CSS widgets, diagrams, and inline visual prototypes. | T-REP-001, T-UI-005 | **OPTIONAL** |
| 13 | `automation` | `<builtinDir>/skills/automation/SKILL.md` | **YES** | Designing scheduled background cron tasks and monitoring jobs. | T-REP-002 | **OPTIONAL** |
| 14 | `notebook-guidance` | `<configDir>/skills/notebook-guidance/SKILL.md` | **YES** | Jupyter notebook execution guidelines, data exploration, and visualization standards. | T-AI-001, T-AI-012 | **OPTIONAL** |
| 15 | `building-data-apps` | `<configDir>/skills/building-data-apps/SKILL.md` | **YES** | Rapid data dashboard construction using Vite/React or Streamlit. | T-WEB-001, T-WEB-002 | **OPTIONAL** |
| 16 | `agy-customizations` | `<builtinDir>/skills/agy-customizations/SKILL.md` | **YES** | Guide for authoring Antigravity rules, hooks, skills, and subagents. | T-DEV-003 | **OPTIONAL** |
| 17 | `antigravity-guide` | `<builtinDir>/skills/antigravity_guide/SKILL.md` | **YES** | Quick reference and operational guidelines for Antigravity environment operations. | General | **OPTIONAL** |
| 18 | `swarm` | `<builtinDir>/skills/native_swarm/SKILL.md` | **YES** | Multi-agent swarm orchestration over shared message boards. | Phase 1 Spikes | **OPTIONAL** |
| 19 | `swarm_monitor` | `<builtinDir>/skills/swarm_monitor/SKILL.md` | **YES** | Monitoring daemon for multi-agent swarms. | Phase 1 Spikes | **OPTIONAL** |
| 20 | `ui-plugin-navigation` | `<builtinDir>/skills/ui-plugin-navigation/SKILL.md` | **YES** | Discovers and toggles UI plugin panels in IDE. | General | **OPTIONAL** |
| 21 | `plugin` | `<builtinDir>/skills/plugin/SKILL.md` | **YES** | Managing and creating Antigravity plugins. | General | **OPTIONAL** |
| 22 | `skill-repair` | `<configDir>/skills/skill-repair/SKILL.md` | **YES** | Fixes and reinstalls failed skill manifests. | General | **OPTIONAL** |
| 23 | `migrate-agent-settings` | `<builtinDir>/skills/migrate-agent-settings/SKILL.md` | **YES** | Migrates settings from Claude Code / Cursor / Gemini CLI. | None | **OPTIONAL** |
| 24 | `migrate-workflows` | `<builtinDir>/skills/migrate-workflows/SKILL.md` | **YES** | Migrates legacy workflows to modern skills. | None | **OPTIONAL** |

### 2.3 Excluded Cloud-Specific Skills (Strictly Inapplicable to On-Premise Core)

| # | Exact Registered Skill Name | Sanitized Disk Location | Evaluation & Architectural Rationale |
|---|---|---|---|
| 25 | `discovering-gcp-data-assets` | `<configDir>/skills/discovering-gcp-data-assets/SKILL.md` | **EXCLUDED:** Surveillance data assets reside 100% on-premise (SQL Server & PostgreSQL). |
| 26 | `bigquery-data-transfer-service` | `<configDir>/skills/bigquery-data-transfer-service/SKILL.md` | **EXCLUDED:** Cloud ingestion pipeline irrelevant to local NVR/camera streams. |
| 27 | `data-autocleaning` | `<configDir>/skills/data-autocleaning/SKILL.md` | **EXCLUDED:** Targets Cloud Storage / BigQuery; inapplicable to real-time on-premise video. |
| 28 | `dataform-bigquery` | `<configDir>/skills/dataform-bigquery/SKILL.md` | **EXCLUDED:** Inapplicable to local operational PostgreSQL event stores. |
| 29 | `dbt-bigquery` | `<configDir>/skills/dbt-bigquery/SKILL.md` | **EXCLUDED:** Inapplicable to local operational PostgreSQL event stores. |
| 30 | `developing-with-bigquery` | `<configDir>/skills/developing-with-bigquery/SKILL.md` | **EXCLUDED:** Inapplicable to local operational PostgreSQL event stores. |
| 31 | `gcloud-auth-verification` | `<configDir>/skills/gcloud-auth-verification/SKILL.md` | **EXCLUDED:** No GCP cloud authentication required for on-premise servers. |
| 32 | `gcp-composer-troubleshooting` | `<configDir>/skills/gcp-composer-troubleshooting/SKILL.md` | **EXCLUDED:** Apache Airflow on Cloud Composer is not utilized. |
| 33 | `gcp-data-pipelines` | `<configDir>/skills/gcp-data-pipelines/SKILL.md` | **EXCLUDED:** Inapplicable to on-premise industrial surveillance platform. |
| 34 | `gcp-dataflow` | `<configDir>/skills/gcp-dataflow/SKILL.md` | **EXCLUDED:** Inapplicable to on-premise industrial surveillance platform. |
| 35 | `gcp-pipeline-orchestration` | `<configDir>/skills/gcp-pipeline-orchestration/SKILL.md` | **EXCLUDED:** Inapplicable to on-premise industrial surveillance platform. |
| 36 | `gcp-pipeline-resource-provisioning`| `<configDir>/skills/gcp-pipeline-resource-provisioning/SKILL.md` | **EXCLUDED:** Inapplicable to on-premise industrial surveillance platform. |
| 37 | `gcp-spark` | `<configDir>/skills/gcp-spark/SKILL.md` | **EXCLUDED:** Inapplicable to on-premise industrial surveillance platform. |

---

## 3. Evaluation of Permitted Google Services (Firebase Cloud Messaging)

- **Service:** **Google Firebase Cloud Messaging (FCM)**.
- **Evaluation:** Mobile push delivery to Android devices when the manager application is backgrounded or the phone is locked.
- **Privacy & Security Constraint:** FCM is permitted **strictly as an auxiliary push delivery pipe carrying non-sensitive opaque event IDs** (Document 30). Zero biometric data, employee names, or camera snapshots are transmitted through Google FCM servers.

---

## 4. Skills Audit Sign-Off

- **Status:** CANONICAL SKILLS AUDIT (37 of 37 Skills Accounted For).
- **Next Step:** All paths sanitized; required skills locked for Phase 1.
