# Owner Authorization Record — LOCAL DEVELOPMENT ONLY
Date: 2026-11-16 · Issued by: the Project Owner, by issuing ANTIGRAVITY_FIX_PROMPT.md

## AUTHORIZED
- DEC-01: Phase 0 baseline ACCEPTED, as amended by docs/governance/CTO_AMENDMENTS.md.
- ADR-011: APPROVED as amended by ADR-012 … ADR-017 (CTO_AMENDMENTS.md).
- DEC-02: APPROVED — administration console scope is delivered as Flutter Web (ADR-014), not React.
- SPK-02-LOCAL: APPROVED — inference/decoding benchmark on the owner's workstation with synthetic or public license-clean media only.
- Sprint 1 and following local sprints: APPROVED for LOCAL DEVELOPMENT AND SIMULATION only.
- FR-ALT-008 minimal workflow (NEW → ACKNOWLEDGED → RESOLVED | DISMISSED-with-reason): APPROVED as local-development default; to be reviewed in the pilot.

## NOT AUTHORIZED (remain BLOCKED; agent must stop if work would need them)
- SPK-01, SPK-03, SPK-04 (any contact with real ZKTeco terminals, real NVRs/cameras, real SQL Server data).
- DEC-03 (photo-upload fallback), DEC-04 (fire auxiliary-status sign-off), DEC-05 (recipient roster), DEC-06 (legal review, Law 151/2020), DEC-08 (FCM).
- Any face recognition, employee identity matching, cross-camera employee re-identification or employee movement history on real people.
- Any production deployment, hardware purchase, VPN to factory networks.
- Any real employee/biometric data or real factory footage in development.

## Consequences
- Fire-alert code may be built and tested with TEST recipients only; the production fire route stays disabled until DEC-04 and DEC-05 are signed.
- Notification code uses the NotificationChannel port (ADR-017); FCM adapter may be written but is DISABLED by configuration.
