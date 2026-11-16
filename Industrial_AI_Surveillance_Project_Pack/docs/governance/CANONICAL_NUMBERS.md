# Canonical Numbers & Capacity Baseline

Date: 2026-11-16 · Status: ACTIVE GOVERNANCE BASELINE

| Item | Value | Provenance |
|---|---|---|
| Requirements | 97 = 78 FR + 19 NFR | SRS + CSV (verified by script, includes NFR-OBS-002 per ADR-017) |
| Cameras | ~200+/site, may grow | D-004 |
| Biometric terminals | 18+/site, mixed | D-005 |
| Video retention | 30 days — **on the existing NVRs** (charter §4 excludes replacing NVR recording). Platform stores only event clips/snapshots/metadata. | D-008 + Charter |
| Platform storage | Sized from MEASURED event-clip rate; not 162 TB. The 162 TB / 16-disk figure is an NVR-side capacity check, not a platform purchase | CTO_AMENDMENTS |
| AI sampling rates | candidate variables in Doc 28; not approved | Doc 28 |
| Hardware BOM | NOT approved; derived after WP-3 + real NVR inventory | Doc 24 |
