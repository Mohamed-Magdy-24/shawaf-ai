# 01 — Project Understanding Report: Industrial AI Surveillance Platform (Remediated Rev 1.2)

**Document ID:** DISC-01-UNDERSTANDING  
**Version:** 1.2.0-remediated  
**Date:** 2026-11-11  
**Status:** CANONICAL PROJECT BASELINE  
**Classification:** Governed by [`27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md`](27_UPDATED_OWNER_FACTS_AND_REQUIREMENT_PROVENANCE.md)  
**Precedence Authority:** [`26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md`](26_SOURCE_OF_TRUTH_AND_DOCUMENT_PRECEDENCE.md)  

---

## 1. Executive Summary & Objective

The objective of this project is to architect, evaluate, and eventually deploy a production-grade **Industrial AI Surveillance & Safety Platform** for two major manufacturing facilities: **BNF** and **RNF**.

The platform is designed to interface with existing CCTV cameras, NVRs, and biometric attendance infrastructure, providing factory managers, corporate executive management, and security personnel with operational visibility, safety monitoring (PPE, restricted zones, falls, fire early warning), and in-app reporting.

### Core Architectural Priorities:
1. **Correctness** — Probabilistic observations are never presented as certified facts or automatic disciplinary proof.
2. **Reliability** — Complete edge data plane autonomy at each factory; zero operational outage during WAN disconnects.
3. **Security & Privacy** — Strict tenant isolation, zero-trust tokenized video access, and compliance with Egyptian Personal Data Protection Law No. 151/2020.
4. **Data Integrity** — Strict NO-MOCK-DATA policy; empty states displayed when physical records do not exist.
5. **Architectural Simplicity** — Modular monolith core with decoupled edge video workers; avoidance of premature microservice meshes.

---

## 2. Factory Operational Topology & Provenance-Tagged Baseline

Every requirement and environmental parameter below has been reclassified in strict accordance with Document 27:

| Item ID | Operational Parameter / Scope | Canonical Classification | Provenance & Source |
|---|---|---|---|
| **D-001** | BNF and RNF are treated as operationally independent factories in systems, data, and access. | `OWNER_CONFIRMED_REQUIREMENT` | Project Charter Section 2; confirmed by owner directive. |
| **D-002** | Each factory maintains its own separate, dedicated Microsoft SQL Server instance. | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; schema and read-only access to be verified. |
| **D-003** | Both factories use the ZKTeco ZKBioTime product family; each site runs an independent instance. | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; exact version, build, and API licensing remain `UNKNOWN`. |
| **D-004** | Approximately 200+ cameras installed at BNF and approximately 200+ at RNF; counts may grow. | `OWNER_REPORTED_ENVIRONMENT_FACT` | **Approximate estimate.** Sizing models must treat as variable $N_c$. |
| **D-005** | Approximately 18+ mixed-model fingerprint/face terminals per factory; expanding estate. | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; physical model inventory required. |
| **D-006** | Stable Employee ID exists in attendance and SQL Server records. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed natural key linking attendance and surveillance sightings. |
| **D-007** | Employee face images currently exist only inside biometric terminals/ZKBioTime; no central photo store. | `OWNER_REPORTED_ENVIRONMENT_FACT` & `BLOCKED` | Extraction feasibility is `UNKNOWN` and blocks face recognition until tested. |
| **D-008** | Video retention requirement is 30 days. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed business requirement; physical storage sizing is `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`. |
| **D-009** | Client application platform is Android exclusively. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed by owner; iOS and desktop native apps are out of scope. |
| **D-010** | Authorized managers can switch context between BNF and RNF within the application. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed workflow; server-side entitlement check is `PROPOSED`. |
| **D-011** | Live and recorded video streaming is restricted strictly to Security Managers and Senior Management. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed access boundary; tokenized stream authorization is `PROPOSED`. |
| **D-012** | Ordinary alerts are routed to affected Factory Manager, Company Management, and Security Managers. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed alert distribution matrix. |
| **D-013** | Fire alerts dispatch immediately to responsible safety/operational personnel at affected factory. | `OWNER_CONFIRMED_REQUIREMENT` | Auxiliary visual warning channel; emergency roster remains `UNKNOWN`. |
| **D-014** | Fire alert dispatch does not wait for manual human confirmation or triage gate. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed fast-path dispatch policy. |
| **D-015** | Daily, weekly, and monthly reports with charts, KPIs, and percentages generated in-app. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed functional requirement. |
| **D-016** | No Power BI integration, subscriptions, or external reporting dependencies. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed architectural constraint. |
| **D-017** | No email, SMS, or WhatsApp report delivery; all reports live inside the application. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed notification delivery scope. |
| **D-018** | AI detection scope includes PPE, restricted zones, falls, phones, fire, theft/object movement. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed functional scope; model pipelines are `PROPOSED`. |
| **D-019** | Maintain time-ordered history of employee sightings across cameras with location and timestamp. | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed desired capability; technical feasibility is `UNKNOWN`. |

---

## 3. Strict Prohibitions & Operating Truths

1. **Zero Mock Operational Data:** All user-facing dashboards, charts, tables, camera statuses, and reports must originate from real connected physical sources. If data is unavailable, display verified empty states with last-sync timestamps.
2. **Auxiliary Fire Role:** Video AI fire/smoke detection is strictly an auxiliary visual warning tool. It does **NOT** replace certified building fire alarm systems under NFPA 72 / EN 54.
3. **Hardware Sizing Truth:** Sizing models based on 200 streams @ 2 FPS (400 FPS per factory / 800 FPS total) are planning formulations only. Final hardware procurement is frozen until empirical benchmarks are executed on isolated test rigs.
4. **Biometric Privacy Safeguards:** No real employee face images or biometric representations may be processed until formal legal certification under Egyptian Law No. 151/2020 is issued by corporate counsel.
