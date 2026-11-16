# 44 — Current Package Inventory & Cryptographic SHA-256 Manifest
## Industrial AI Surveillance Platform — BNF & RNF
**Document ID:** DISC-44-PACKAGE-MANIFEST  
**Classification:** Canonical Package Inventory & Cryptographic Authority  
**Status:** CANONICAL INVENTORY & MANIFEST BASELINE  
**Package Version:** `1.1.0-local-dev-authorized`  
**Generation Date:** 2026-11-16  
**Payload files covered by MANIFEST.sha256:** 110  
**Root-level MANIFEST.sha256 file:** 1  
**Total regular files in extracted package:** 111  
**Subdirectories excluding project root:** 16  

---

## 1. EXECUTIVE MANIFEST & INVENTORY SUMMARY

This document establishes the verified cryptographic inventory of all **110 regular payload files** and **16 subdirectories** comprising the remediated `Industrial_AI_Surveillance_Project_Pack`.

Every regular payload file has been hashed directly from raw disk bytes using the standard SHA-256 algorithm. The complete list of 110 checksums is mirrored in the root-level machine-readable verification file `MANIFEST.sha256`.

```text
Payload files covered by MANIFEST.sha256: 110
Root-level MANIFEST.sha256 file: 1
Total regular files in extracted package: 111
Subdirectories excluding project root: 16
```

### 1.1 Manifest Self-Exclusion Rule
In accordance with standard cryptographic manifest practices, the root file `MANIFEST.sha256` is self-excluded from its own listing to prevent circular dependency and recursive hash corruption.

---

## 2. NEW FILES ADDED IN v1.1.0 (WP-0)

The following 7 new files were created as part of the WP-0 pack repair:

| Path | Purpose |
|---|---|
| `00_READ_ME_FIRST.md` | Active Set definition and document precedence rules |
| `docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md` | Owner authorization record for local development |
| `docs/governance/CTO_AMENDMENTS.md` | CTO-identified pack defects and amendment pointers |
| `docs/governance/WORKSTATION_PROFILE.md` | Owner-reported workstation hardware baseline |
| `docs/governance/CANONICAL_NUMBERS.md` | Authoritative project capacity numbers |
| `docs/governance/TOOLCHAIN_PINS.md` | Pinned toolchain and runtime versions |
| `docs/ai/MODEL_REGISTER.md` | AI model candidate register with verified licenses |

---

## 3. TECHNOLOGY EXCLUSIONS (UNCHANGED)

- Ultralytics YOLOv8, TensorRT, DeepStream, MinIO, and pyzk are strictly excluded.
- InsightFace/ArcFace pretrained model packs are NOT APPROVED (non-commercial research only).
- Valkey and TimescaleDB are removed from the baseline per ADR-013.
- React/Vite is removed from the baseline per ADR-014.

---

## 4. VERIFICATION

```text
python verify_archive_manifest.py
→ Verified Checksums OK: 110
→ VERIFICATION RESULT: PASSED (100% Cryptographic Integrity Confirmed)
```
