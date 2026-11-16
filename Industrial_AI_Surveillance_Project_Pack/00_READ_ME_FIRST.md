# 00_READ_ME_FIRST — Industrial AI Surveillance Platform (BNF & RNF)

## 1. Project Purpose
The Industrial AI Surveillance Platform is an on-premises, multi-site AI surveillance and safety alerting system engineered for Egyptian manufacturing facilities (BNF in Borg El-Arab and RNF in Sadat City). The platform ingests sub-streams from ~200+ IP cameras per site, detects industrial safety violations (restricted area intrusion, fall/hazard, PPE compliance, fire/smoke anomalies), routes time-critical alerts to security personnel and management, and enforces strict tenant isolation and Egyptian Law 151/2020 privacy compliance.

## 2. Active Set (Authoritative Baseline)
Only the following files define the binding project baseline:
- `00_PROJECT_CHARTER.md`
- `requirements/01_SRS.md`
- `planning/09_REQUIREMENTS_TRACEABILITY.csv`
- `planning/08_ADR_AND_OPEN_QUESTIONS.md`
- `architecture/02_TARGET_ARCHITECTURE.md`
- `integrations/03_INTEGRATION_AND_DATA_SPEC.md`
- `ai/04_VIDEO_AI_SPEC.md`
- `security/05_SECURITY_PRIVACY_AND_ACCESS.md`
- `docs/discovery/38_DECISION_ID_CANONICAL_REGISTER.md`
- `docs/discovery/28_GPU_VIDEO_PIPELINE_BENCHMARK_PROTOCOL.md`
- `docs/discovery/30_ALERT_DELIVERY_AND_DEGRADED_MODE_SPEC.md`
- `docs/discovery/39_NOTIFICATION_AND_FIRE_DELIVERY_FAILURE_MATRIX.md`
- `antigravity/09_MASTER_OPERATING_PROMPT.md`
- `antigravity/11_PHASE_PROMPTS.md`
- `00_READ_ME_FIRST.md`
- `docs/governance/*` (`OWNER_AUTHORIZATION_LOCAL_DEV.md`, `CTO_AMENDMENTS.md`, `WORKSTATION_PROFILE.md`, `CANONICAL_NUMBERS.md`, `TOOLCHAIN_PINS.md`, etc.)

## 3. Reference-Only Files Rule
All other documents in this package (including `docs/discovery/*` outside the Active Set and all `cto_readiness_audit_reports/*`) are strictly **REFERENCE-ONLY**. They may contain obsolete requirement counts, superseded architectural proposals, or unverified claims. In any conflict, the Active Set wins.

## 4. Precedence Hierarchy
When specifications conflict, resolve according to the strict order:
1. `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`
2. `docs/governance/CTO_AMENDMENTS.md`
3. `requirements/01_SRS.md` (and `planning/09_REQUIREMENTS_TRACEABILITY.csv`)
4. `architecture/02_TARGET_ARCHITECTURE.md`
5. Other Active Set specifications
6. Reference-only documents
