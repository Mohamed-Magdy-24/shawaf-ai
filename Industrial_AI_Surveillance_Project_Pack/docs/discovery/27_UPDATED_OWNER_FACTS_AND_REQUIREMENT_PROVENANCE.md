# 27 — Updated Owner Facts & Requirement Provenance Register

**Document ID:** DISC-27-PROVENANCE  
**Version:** 1.0.0  
**Date:** 2026-11-11  
**Status:** CANONICAL PROVENANCE REGISTER  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` (CTO Audit & Governance)  
**Directive Reference:** Finding P0-01 of CTO Review  

---

## 1. Revised 9-Tier Evidence Taxonomy

In accordance with Finding P0-01 of the CTO Audit, the previous evidence classification has been corrected. Information provided by the project owner is properly distinguished from external official standards and technical observations.

The 9 canonical classifications are:

1. `OWNER_CONFIRMED_REQUIREMENT`: Explicit business, scope, or operational requirement mandated by the project owner.
2. `OWNER_REPORTED_ENVIRONMENT_FACT`: Environmental or infrastructure parameter reported by the owner (e.g., approximate camera count, device types), requiring technical verification before final engineering sizing.
3. `OBSERVED_IN_REPOSITORY`: Directly inspected in local files, scripts, manifests, or command outputs.
4. `VERIFIED_OFFICIAL_SOURCE`: Grounded in official documentation, RFC standards, vendor hardware manuals, or published statutory law.
5. `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`: Mathematically derived from explicitly stated baseline parameters.
6. `MEASURED_IN_POC`: Empirically validated through executed, recorded benchmark or spike tests.
7. `PROPOSED`: Architectural or technical recommendation requiring owner review and gate sign-off.
8. `UNKNOWN`: Factual information required for production that is currently missing.
9. `BLOCKED`: Work that cannot proceed until a prerequisite dependency or approval is secured.

---

## 2. Reclassified Baseline Register (Decisions D-001 to D-019)

| Item ID | Baseline Parameter / Statement | Original (Flawed) Tag | Corrected Canonical Classification | Provenance & Evidence Verification Basis |
|---|---|---|---|---|
| **D-001** | BNF and RNF are treated as operationally independent factories in systems, data, and access. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Project Charter Section 2; confirmed by owner directive. |
| **D-002** | Each factory maintains its own separate, dedicated Microsoft SQL Server instance. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; requires IT schema/connection verification. |
| **D-003** | Both factories use the ZKTeco ZKBioTime product family; each site runs an independent instance. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; exact version, build, and API licensing remain `UNKNOWN`. |
| **D-004** | Approximately 200+ cameras installed at BNF and approximately 200+ at RNF; counts may grow. | `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` | `OWNER_REPORTED_ENVIRONMENT_FACT` | **Approximate estimate only.** Must NOT be treated as an exact count until physical channel audit. |
| **D-005** | Approximately 18+ mixed-model fingerprint/face terminals per factory; expanding estate. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_REPORTED_ENVIRONMENT_FACT` | Reported by owner; exact models, firmware, and photo exportability remain `UNKNOWN`. |
| **D-006** | Stable Employee ID exists in attendance and SQL Server records. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed by owner as canonical cross-system natural key. |
| **D-007** | Employee face images currently exist only inside biometric terminals/ZKBioTime; no external photo repository. | `UNKNOWN` / `BLOCKED` | `OWNER_REPORTED_ENVIRONMENT_FACT` & `BLOCKED` | Reported fact; extraction feasibility is `UNKNOWN` and blocks face recognition until tested. |
| **D-008** | Video retention requirement is 30 days. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed business requirement; physical storage sizing is `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS`. |
| **D-009** | Client application platform is Android exclusively. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed by owner; iOS and desktop native apps are out of scope. |
| **D-010** | Authorized managers can switch context between BNF and RNF within the application. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed business workflow; server-side enforcement is `PROPOSED`. |
| **D-011** | Live and recorded video streaming is restricted strictly to Security Managers and Senior Management. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed access boundary; tokenized stream authorization is `PROPOSED`. |
| **D-012** | Ordinary alerts are routed to affected Factory Manager, Company Management, and Security Managers. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed alert distribution matrix. |
| **D-013** | Fire alerts dispatch immediately to responsible safety/operational personnel at affected factory. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed early visual notification channel; emergency roster remains `UNKNOWN`. |
| **D-014** | Fire alert dispatch does not wait for manual human confirmation or triage gate. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed fast-path dispatch policy. |
| **D-015** | Daily, weekly, and monthly reports with charts, KPIs, and percentages generated in-app. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed functional requirement. |
| **D-016** | No Power BI integration, subscriptions, or external reporting dependencies. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed architectural constraint. |
| **D-017** | No email, SMS, or WhatsApp report delivery; all reports live inside the application. | `VERIFIED_OFFICIAL_SOURCE` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed notification delivery scope. |
| **D-018** | AI detection scope includes PPE, restricted zones, falls, phones, fire, theft/object movement. | `PROPOSED` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed functional scope; individual model feasibility and calibration are `PROPOSED`. |
| **D-019** | Maintain time-ordered history of employee sightings across cameras with location and timestamp. | `PROPOSED` | `OWNER_CONFIRMED_REQUIREMENT` | Confirmed desired capability; technical feasibility is `UNKNOWN` (depends on Re-ID and photo export). |

---

## 3. Approximate vs. Exact Operational Parameters

To prevent mathematical compounding of unverified assumptions, all sizing models must explicitly distinguish between approximate planning inputs and measured facts:

```text
+----------------------------------------------------------------------------------------------------+
| PARAMETER                      REPORTED VALUE         STATUS          GOVERNANCE RULE              |
+----------------------------------------------------------------------------------------------------+
| BNF Camera Fleet Count         "~200+ cameras"        APPROXIMATE     Do not use as fixed 200.0.   |
| RNF Camera Fleet Count         "~200+ cameras"        APPROXIMATE     Do not use as fixed 200.0.   |
| Total Cameras Across Sites     "~400+ cameras"        APPROXIMATE     Model as N_c with +/- 20%.   |
| Terminal Count per Site        "~18+ terminals"       APPROXIMATE     Requires physical inventory. |
| Existing Server Specifications "Server has no GPU"    VERIFIED FACT   CPU, RAM, storage UNKNOWN.   |
| Video Retention Window         30 Days                CONFIRMED REQ   Legal/policy baseline.       |
| Factory Operating Timezone     Egypt (UTC+2 / UTC+3)  VERIFIED FACT   Africa/Cairo canonical zone. |
+----------------------------------------------------------------------------------------------------+
```

---

## 4. Provenance Sign-Off

- **Status:** CANONICAL PROVENANCE BASELINE.
- **Next Step:** All dependent discovery documents must reference this provenance register.

