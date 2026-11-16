> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 11 — Comprehensive Security, Privacy & Threat Assessment (Remediated)

**Document ID:** DISC-11-SECURITY-PRIVACY  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** REVALIDATED MANDATORY SECURITY SPECIFICATION  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Regulatory Standards:** Egyptian Personal Data Protection Law No. 151/2020 & Executive Regulations Decree No. 816/2025; NIST FIPS 197; OWASP Top 10  
**Directive Reference:** Section 8 of CTO Directive  

---

## 1. Executive Security & Privacy Posture

The BNF/RNF Industrial AI Surveillance Platform operates in a sensitive cyber-physical environment handling live and recorded visual feeds of manufacturing plants, employee personal attendance, identification keys, and facial biometric representations.

Security is implemented through a **Zero-Trust Defense-in-Depth** architecture where every network packet, API invocation, video stream request, and database query must prove identity, site scope, and authorization.

---

## 2. Cryptographic Token & Video Access Architecture (HMAC Correction)

In strict accordance with Section 8 of the CTO Directive:
> **HMAC (Hash-based Message Authentication Code) is an authentication and data integrity mechanism, NOT an encryption algorithm. Video stream confidentiality is achieved via transport-layer encryption (TLS 1.3 / SRTP), while HMAC guarantees cryptographic tamper-proofing of access claims.**

```text
+----------------------------------------------------------------------------------------------------+
|                                    ZERO-TRUST VIDEO SESSION FLOW                                   |
|                                                                                                    |
|  1. Client Authentication (TLS 1.3):                                                               |
|     Mobile Client requests stream token from Management API using User JWT.                        |
|                                                                                                    |
|  2. Server-Side Capability Evaluation:                                                             |
|     API verifies: Has User explicit `video:stream:live` permission for Camera CAM-BNF-012?         |
|     (Switching factory context from BNF to RNF NEVER escalates video viewing rights).              |
|                                                                                                    |
|  3. Scoped Short-Lived Signed Token Minting:                                                       |
|     Claims = { "user": "usr_99", "site": "BNF", "cam": "CAM-012", "exp": <Now + 60s> }             |
|     Signature = HMAC-SHA256(Claims, Rotating_Secret_Key_K1)                                        |
|     Token = Base64URL(Claims) + "." + Base64URL(Signature)                                         |
|                                                                                                    |
|  4. WebRTC Video Ingestion (DTLS / SRTP):                                                          |
|     Client connects to go2rtc proxy: wss://gateway/stream?token=<Token>                            |
|     go2rtc validates HMAC signature and expiration timestamp locally.                              |
|     If valid: Negotiates encrypted SRTP stream. Permanent NVR passwords NEVER reach mobile.        |
+----------------------------------------------------------------------------------------------------+
```

### Video Access Security Guardrails:
1. **Camera-Level Authorization:** Access tokens are scoped to individual physical camera channels (`camera_id`), preventing a user with access to Camera 1 from accessing Camera 2.
2. **Short Token Expiration:** Token lifetime is hard-capped at **60 seconds** for connection handshake.
3. **Instant Stream Revocation:** If a security clearance is revoked, the backend pushes a revocation event to Valkey, immediately terminating active WebRTC streams.
4. **Key Rotation:** HMAC signing secrets rotate every 24 hours with a 10-minute overlap grace period.
5. **Session Auditing:** Every stream request writes an immutable audit record: `(timestamp, user_id, site_id, camera_id, client_ip, token_id)`.

---

## 3. Statutory Compliance: Egyptian Personal Data Protection Law No. 151/2020

### 3.1 Biometric Classification & Regulatory Framework
- **Sensitive Personal Data (Article 1):** Facial images, biometric representations, and movement tracking profiles are classified as Sensitive Personal Data.
- **Regulatory Licensing (Article 12 & Decree 816/2025):** The enterprise **must** secure a formal operating license/permit from the **Personal Data Protection Center (PDPC - مركز حماية البيانات الشخصية)** prior to activating facial recognition in production.
- **Lawful Basis:** Processing must be justified under explicit workplace health, safety, and physical security mandates, accompanied by clear written notices to personnel.

### 3.2 Technical Safeguards Clarification (AES-256 vs. Statutory Text)
- **Statutory Provision:** Article 3 and Article 12 of Law 151/2020 mandate that controllers implement "appropriate technical and organizational measures" to prevent unauthorized disclosure, leakage, or alteration of personal data. **The law does not name specific proprietary algorithms like AES-256.**
- **Engineering Standard Adopted:** To satisfy the statutory requirement for "appropriate technical measures", the platform implements **AES-256-GCM envelope encryption** for stored biometric vector embeddings and **TLS 1.3** for all network communication based on recognized international cybersecurity standards (NIST FIPS 197 / ISO 27001).

### 3.3 Employee Rights Enforcement
- **Right to Know & Access (Article 2):** Clear Arabic/English signage at plant entrances and employee handbook disclosures explaining CCTV safety monitoring.
- **Anti-Automated Disciplinary Guarantee (Article 2):** AI detection events (e.g., suspected PPE violation or fall) are strictly advisory observations. Disciplinary or punitive actions based solely on automated AI scoring are legally prohibited.

---

## 4. Threat Model & Mitigation Summary (STRIDE)

| Threat | Impact | Technical Control Enforced |
|---|---|---|
| **Spoofing** | Forged user claims access to private streams. | RS256 JWT signing + short-lived HMAC stream tokens; verified on every handshake. |
| **Tampering** | Deletion of safety violation records. | Append-only database tables with cryptographic hash-chaining; read-only service accounts. |
| **Repudiation** | Denial of video stream inspection. | Tamper-evident audit log capturing user ID, camera channel, and exact timestamp. |
| **Information Disclosure** | Cross-factory data leakage (BNF to RNF). | Strict site-scoped tenant isolation enforced at repository and query levels (`site_id`). |
| **Denial of Service** | Flooding NVRs with stream requests. | `go2rtc` stream multiplexing (single pull from NVR distributes to all clients); rate limiting. |
| **Elevation of Privilege** | Manager accesses video without clearance. | Server-side RBAC evaluating `video:stream:live` capability independent of site switching. |

---

## 5. Security & Privacy Assessment Sign-Off

- **Status:** REVALIDATED MANDATORY SPECIFICATION.
- **Action Item:** Submit compliance action plan to Corporate Legal Counsel for execution of PDPC licensing before Phase 7 cutover.
