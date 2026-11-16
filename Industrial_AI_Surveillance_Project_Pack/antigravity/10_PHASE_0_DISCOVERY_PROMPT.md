> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# PHASE 0 PROMPT — READ-ONLY DISCOVERY, NO CODING

Read the complete project documentation pack first. Your task is **Phase 0 only**: inspect the existing workspace/repository and produce an evidence-based discovery report. Do not implement features, alter business logic, install packages, rewrite architecture, or modify application code in this phase.

## Strict constraints

- You may create documentation/report files only in a new `docs/discovery/` folder, unless the owner explicitly approves a different location.
- Do not modify source files, lockfiles, build files, CI, secrets, databases, or deployment configurations.
- Do not connect to production systems or devices.
- Do not guess missing device/network/API/schema information.
- Do not mark a feature implemented because a screen, mock, stub, or interface exists.
- Cite exact repository paths and exact command outputs for all claims.
- If the repository is empty/new, say so and provide a proposed initial structure without generating the application yet.

## Work to perform

1. Inspect the workspace tree and identify application roots, modules, languages, frameworks, build tools, test tools, CI, deployment files, and documentation.
2. Determine whether this is an existing codebase or a new project. Identify the current commit/version if available.
3. Run only safe read-only discovery commands first. You may run existing build/test commands only if they do not change production data or install/upgrade dependencies. Report command and result exactly.
4. Map current modules and dependencies. Identify violations of the proposed Clean Architecture boundaries.
5. Classify existing functionality as:
   - Verified implementation
   - Partial implementation
   - Mock/stub/demo only
   - Broken/unverified
   - Not present
6. Inspect dependency versions and check for obvious unsupported/outdated packages. Do not upgrade anything.
7. Compare the actual repository against the SRS. Create a requirements gap matrix by requirement ID.
8. Create a technology/deployment inventory. Unknown values must remain TBD.
9. Create an integration discovery checklist for BNF and RNF covering ZKBioTime, SQL Server, biometric terminals, NVRs/cameras, network, and server/GPU capacity.
10. Identify architectural and delivery risks, especially:
    - Two independent site data planes and cross-site manager access.
    - 200+ cameras per site and resource sizing.
    - Mixed NVR models and verified live/playback access.
    - Face-image retrieval from mixed biometric terminal models.
    - No GPU in current server.
    - Fire alert priority and routing.
    - Site isolation across database/API/queue/cache/notifications/video.
    - Biometric and employee-tracking privacy/legal approval.
11. Draft ADRs for the most important unresolved architecture choices. Mark all recommendations PROPOSED.
12. Recommend a minimal Phase 1 proof-of-concept plan that resolves the riskiest unknowns before implementation.

## Required output files

Create:
- `docs/discovery/00_REPOSITORY_INVENTORY.md`
- `docs/discovery/01_CURRENT_ARCHITECTURE.md`
- `docs/discovery/02_REQUIREMENTS_GAP_MATRIX.md`
- `docs/discovery/03_INTEGRATION_DISCOVERY_CHECKLIST.md`
- `docs/discovery/04_RISKS_AND_BLOCKERS.md`
- `docs/discovery/05_PHASE_1_POC_PLAN.md`
- `docs/discovery/06_ADR_DRAFTS.md`

If there is no repository yet, adapt the first two files to document that fact and propose a minimal workspace layout. Do not create application code.

## Final response format

1. Status: PASS / FAIL / BLOCKED.
2. Workspace type: existing codebase or new/empty.
3. Verified facts with exact paths/commands.
4. Unknowns and blockers.
5. Requirements gap summary.
6. Architecture risks.
7. Proposed ADR decisions.
8. Phase 1 POC recommendation.
9. Exact files created.
10. Confirmation that no source/application files were modified.

Do not proceed to Phase 1 automatically. Stop and present the report for owner review.
