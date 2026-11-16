# Security, Privacy, and Access Control Specification

**Document ID:** SEC-001  
**Status:** Mandatory design constraints; legal details and final role matrix require owner/legal approval.  

## 1. Security objectives

Protect factory operations, employee personal/biometric data, video footage, credentials, and management workflows. Enforce site isolation at every backend boundary, not merely through UI filters.

## 2. Access model

Use RBAC plus site/capability scope. A role name alone is insufficient; every permission must be explicit.

| Capability | Factory manager | Company management | Security manager | Senior management | Platform admin |
|---|---:|---:|---:|---:|---:|
| Switch BNF/RNF context | Yes, per stakeholder decision | Yes | Yes, if manager role | Yes | TBD |
| View site dashboard | Authorized manager scope | Both sites | Authorized scope | Both sites | TBD |
| Receive ordinary alerts | Relevant factory | Both/authorized company scope | Both/authorized scope | TBD | No by default |
| View live video | No by default | Only if also senior management or explicitly granted | Yes | Yes | TBD; no implicit access |
| View recordings | No by default | Only if also senior management or explicitly granted | Yes | Yes | TBD; no implicit access |
| View employee identity details | Minimum required; exact policy TBD | Minimum required; exact policy TBD | Investigation need, scoped | Minimum required; exact policy TBD | No implicit access |
| Manage zones/model policies | TBD | TBD | TBD | TBD | Operationally required but approval needed |

This table intentionally distinguishes the ability to switch sites from permission to view video. Exact role membership and administrative permissions are open decisions.

## 3. Alert routing matrix

| Event class | Recipients | Dispatch behavior |
|---|---|---|
| PPE violation | Manager of affected factory + company management + security managers | Automatic in-app routing |
| Phone use | Manager of affected factory + company management + security managers | Automatic in-app routing |
| Restricted-area entry | Manager of affected factory + company management + security managers | Automatic in-app routing |
| Suspected theft/object movement | Manager of affected factory + company management + security managers | Automatic in-app routing; wording remains “suspected” |
| Fall/accident | Manager of affected factory + company management + security managers | Automatic in-app routing |
| Fire/smoke | Responsible recipients at affected factory | Immediate, no human confirmation gate |

Ordinary site alerts must not be sent to the other factory's ordinary manager group. Cross-site company management and authorized security recipients are the explicit exception. Fire alerts remain factory-specific unless the owner later approves otherwise.

## 4. Mandatory controls

- Server-side authorization on every API, query, stream session, playback request, report, and export.
- Site scope included in every operational request and enforced in repositories/queries.
- Site-specific secrets, database credentials, NVR accounts, and queues.
- TLS for network communication; encryption at rest for sensitive data and backups.
- Secret manager or protected deployment secret store; no credentials committed to code.
- Short-lived, revocable video access sessions.
- Audit logging for login, site switching, video access, employee identity lookups, policy changes, model changes, and administrative operations.
- Rate limiting and abuse controls on authentication and sensitive query endpoints.
- Secure Android token storage and session expiration.
- No sensitive biometric images in ordinary logs, analytics payloads, crash reports, or test fixtures.
- Signed and verified application/API builds; dependency and container scanning.
- Backup/restore tests per factory.

## 5. Biometric and employee data safeguards

Before face recognition or continuous employee movement tracking is enabled in production:

1. Obtain legal/privacy review under applicable Egyptian requirements and company policy.
2. Document the purpose, lawful basis, necessity, proportionality, employee notice, and access rights.
3. Define who can search an employee and why.
4. Define storage location, encryption, retention, refresh, deletion, and revocation for source images and derived embeddings.
5. Assess whether less intrusive person detection without identity can satisfy some use cases.
6. Keep identity confidence and evidence visible to authorized reviewers.
7. Prevent automatic disciplinary action based solely on model output.

This document is an engineering control baseline, not a legal opinion.

## 6. Threat model starter

| Threat | Control |
|---|---|
| BNF user sees RNF event data | Site-scoped authorization, DB boundaries, isolation tests |
| Mobile client leaks NVR credentials | Backend-issued short-lived session, no stored NVR admin password |
| Compromised NVR account exposes cameras | Per-device least privilege, network segmentation, credential rotation |
| Face image/embedding exfiltration | Encryption, restricted service access, audit, retention/deletion |
| Forged or replayed event/notification | Authenticated service communication, signed/validated messages, idempotency |
| Alert delivery silently fails | Durable outbox/queue, retries, dead-letter queue, health monitoring |
| AI model produces false accusation | “Suspected” semantics, confidence/evidence, human investigation, no auto-discipline |
| Cross-site outage stops both factories | Independent site planes and local buffering |
| Malicious/inadvertent policy change | Least privilege, approval workflow TBD, audit, versioning |

## 7. Incident response and audit

Define operational runbooks for stolen credentials, camera/NVR compromise, biometric data exposure, ransomware, event backlog, notification outages, and model regression. Retain an immutable or tamper-evident audit trail. Exact retention periods and incident response ownership are TBD.

## 8. Security acceptance gates

No production release without:

- Site isolation penetration/negative tests.
- Role and permission matrix tests.
- Video authorization tests for allowed and denied users.
- Secret scanning and dependency vulnerability review.
- Backup/restore evidence.
- Audit event verification.
- Biometric privacy/legal sign-off for any enabled identity feature.
