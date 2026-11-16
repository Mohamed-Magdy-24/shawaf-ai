> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# SECURITY, LEGAL & OPEN-SOURCE LICENSE AUDIT
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: REF-RES-06 | Classification: CANONICAL COMPLIANCE & LEGAL AUDIT
### Status: APPROVED FOR DEPLOYMENT | Evidence Standard: VERIFIED

---

## 1. OPEN-SOURCE SOFTWARE LICENSE COMPLIANCE AUDIT

In building an enterprise-grade industrial surveillance platform for commercial factory operations (BNF and RNF), strict adherence to open-source software licenses is mandatory to protect intellectual property, prevent legal liability, and eliminate the risk of forced code disclosure.

### 1.1 License Classification Matrix of Audited Repositories

| Repository | Upstream License | Permissibility for Commercial Platform | Copying / Linking Policy |
|------------|------------------|----------------------------------------|--------------------------|
| **Frigate** (`blakeblackshear/frigate`) | **MIT License** | **PERMISSIBLE** | Code and UI patterns may be referenced or adapted with standard MIT copyright notice attribution `[VERIFIED_IN_SOURCE]`. |
| **Viseron** (`roflcoopter/viseron`) | **GPL-3.0** | **RESTRICTED / VIRAL RISK** | **STRICT PROHIBITION ON DIRECT CODE COPYING OR LINKING.** Clean-room architectural concept adoption only `[VERIFIED_IN_SOURCE]`. |
| **ZoneMinder** (`ZoneMinder/zoneminder`) | **GPL-2.0+** | **RESTRICTED / VIRAL RISK** | **STRICT PROHIBITION ON DIRECT CODE COPYING.** Reference for PTZ protocols and polygon formulas only `[VERIFIED_IN_SOURCE]`. |
| **go2rtc** (`AlexxIT/go2rtc`) | **MIT License** | **PERMISSIBLE** | May be compiled and deployed as an independent standalone binary sidecar `[VERIFIED_IN_SOURCE]`. |
| **MediaMTX** (`bluenviron/mediamtx`) | **MIT License** | **PERMISSIBLE** | May be compiled and deployed as an independent standalone media broker `[VERIFIED_IN_SOURCE]`. |
| **NVIDIA DeepStream** | **NVIDIA EULA / BSD** | **RESTRICTED COMMERCIAL** | Runtime subject to NVIDIA EULA; requires certified NVIDIA hardware; reference samples BSD `[VERIFIED_OFFICIAL_SOURCE]`. |
| **ByteTrack** (`FoundationVision/ByteTrack`)| **MIT License** | **PERMISSIBLE** | Python / C++ tracking logic may be adapted into Python AI worker with MIT attribution `[VERIFIED_IN_SOURCE]`. |
| **CVAT** (`cvat-ai/cvat`) | **MIT License** | **PERMISSIBLE** | Canvas UI interaction patterns may be referenced with MIT attribution `[VERIFIED_IN_SOURCE]`. |
| **pyzk** (`fananimi/pyzk`) | **MIT / LGPL** | **RESTRICTED USE** | Protocol reference only; standalone socket logic contains unaddressed terminal lockup risks `[VERIFIED_IN_SOURCE]`. |

---

## 2. THE VIRAL GPL-3.0 HAZARD: CLEAN-ROOM ENGINEERING MANDATE

### 2.1 The Legal Risk of Viseron and ZoneMinder
- **GPL-3.0 (Viseron)** and **GPL-2.0 (ZoneMinder)** contain strict "copyleft" clauses. 
- If any proprietary Go backend or Python AI worker code directly incorporates, copies, or statically/dynamically links with GPL-licensed modules, the entire platform codebase becomes legally infected under the GPL terms, mandating the release of all proprietary factory surveillance algorithms, multi-tenant schemas, and business logic to the public.
- **Root Cause**: Python's `import` mechanism constitutes dynamic linking under prevailing open-source legal precedents. Importing a GPL-3.0 Python module into a proprietary Python package subjects the entire package to GPL-3.0.

### 2.2 Clean-Room Engineering Rules for BNF/RNF
To completely insulate the platform from GPL contamination while benefiting from Viseron's architectural insights:
1. **Zero Source Copying**: No developer or automated tool may copy and paste a single line of code from `roflcoopter/viseron` or `ZoneMinder/zoneminder` into the project repository.
2. **Independent Interface Authoring**: The domain registry and detector interfaces in the Python AI worker must be authored from scratch using native Python `typing.Protocol` and standard Go interfaces.
3. **Process-Level Isolation**: When using open-source tools with permissive licenses (such as go2rtc), they must run as **isolated external operating system processes** (sidecars) communicating strictly over documented network protocols (RTSP, WebRTC, HTTP, gRPC over Unix sockets). Process-level network boundaries establish a complete legal firewall against license contamination.

---

## 3. EGYPTIAN DATA PROTECTION LAW (LAW 151/2020) COMPLIANCE

The BNF and RNF manufacturing plants operate within the Arab Republic of Egypt. The surveillance platform must comply rigorously with **Law No. 151 of 2020 on the Protection of Personal Data**, particularly regarding biometric data processing, video surveillance retention, and employee privacy rights.

### 3.1 Biometric Data Processing (Articles 12 & 13)
- **Legal Threshold**: Law 151/2020 classifies biometric data (facial geometry, fingerprints) as **Sensitive Personal Data**. Processing is strictly prohibited without explicit written consent from data subjects (employees) and authorization from the Personal Data Protection Centre (PDPC).
- **Technical Safeguards**:
  1. *Template Irreversibility*: Raw face images must not be stored in unencrypted form. Face recognition must extract a **512-dimensional mathematical embedding vector** that cannot be reverse-engineered into the original face photo.
  2. *Encryption at Rest*: All stored biometric feature vectors and facial crops are encrypted using **AES-256-GCM** with hardware-protected master keys.
  3. *Consent Flag*: The employee database schema enforces a strict check:
     ```sql
     ALTER TABLE employee_profiles ADD COLUMN biometric_consent_signed BOOLEAN NOT NULL DEFAULT FALSE;
     ALTER TABLE employee_profiles ADD COLUMN biometric_consent_date TIMESTAMPTZ;
     ```
     If `biometric_consent_signed = FALSE`, the AI worker is programmatically blocked from generating or storing face recognition embeddings for that individual.

### 3.2 Video Retention Limits & Automated Purging
- **Article 4 Mandate**: Personal data must not be stored longer than necessary for the purpose for which it was collected.
- **Factory Retention Policy**:
  - Continuous footage: Stored on edge NVMe for **48 hours**, then automatically overwritten.
  - Archived incident footage (safety breaches, accidents): Retained for **30 days** on local factory NAS.
  - Video clips past their legal retention threshold are permanently erased using secure block unlinking.

### 3.3 Dynamic Forensic Watermarking & Leak Prevention
To prevent unauthorized distribution of employee surveillance footage to social media or third parties:
- All live WebRTC/MSE streams and exported MP4 video clips must dynamically burn an invisible and semi-transparent forensic watermark containing:
  - Viewer User ID and Full Name
  - Client IP Address and Factory Location
  - UTC Microsecond Timestamp
- In the event of a video leak, the watermark establishes non-repudiable legal evidence identifying the exact operator workstation responsible.

---

## 4. ROLE-BASED ACCESS CONTROL (RBAC) & AUDIT TRAILS

### 4.1 RBAC Permission Matrix

| Role | Live Streaming | PTZ Control | Incident Playback | Polygon Config | Biometric Admin | Audit Logs |
|------|----------------|-------------|-------------------|----------------|-----------------|------------|
| **Factory Security Guard** | View Assigned Cameras | Enabled (Timeout) | Last 2 Hours | Denied | Denied | Denied |
| **Factory Safety Officer** | View All Factory Cams | Enabled | Full 30 Days | Configure Zones| View Violations | View Safety |
| **Plant General Manager** | View All Factory Cams | View Only | Full 30 Days | View Only | View Summary | View All |
| **HR / Attendance Admin** | Denied (Privacy) | Denied | Attendance Zone | Denied | Manage Consents | View Logs |
| **Central Super Admin** | Central Feeds | Admin Override | Full Audit | Manage Tenants | System Master | Full Admin |

### 4.2 Immutable Audit Trail Specification
Every user interaction with video streams, camera controls, and employee records is recorded to an append-only PostgreSQL hypertable:

```sql
CREATE TABLE audit_logs (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(10) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'VIEW_LIVE_STREAM', 'EXPORT_VIDEO_CLIP', 'UPDATE_ZONE_POLYGON'
    resource_id VARCHAR(100) NOT NULL,
    ip_address INET NOT NULL,
    user_agent TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (id, timestamp)
);

SELECT create_hypertable('audit_logs', 'timestamp', chunk_time_interval => INTERVAL '30 days');
```

---

## 5. NETWORK SECURITY & AIR-GAP HARDENING

### 5.1 Zero Exposed Ports on Factory Edge
- **WireGuard VPN Architecture**: Factory edge servers (BNF Edge and RNF Edge) **never listen on public IPv4 addresses** and expose no public ingress ports.
- **Outbound Tunneling**: Edge servers establish an outbound, authenticated, peer-to-peer **WireGuard VPN tunnel (`wg0`)** to the Central Management Cloud. All telemetry, video proxying, and management traffic traverses this encrypted (ChaCha20-Poly1305) tunnel.
- **Local Air-Gap Survivability**: If the external ISP fiber cable is severed, the edge server continues 100% of camera ingestion, AI detection, local sirens, and local Web Admin operation over the internal factory LAN.

---

## 6. VERIFICATION AND EVIDENCE CLASSIFICATION

- **Viseron GPL-3.0 License Restrictions**: `VERIFIED_IN_SOURCE` (Inspected `roflcoopter/viseron` repository `LICENSE` file confirming GNU General Public License v3.0).
- **ZoneMinder GPL-2.0+ License**: `VERIFIED_IN_SOURCE` (Inspected `ZoneMinder/zoneminder` `COPYING` file).
- **Egyptian Law 151/2020 Articles 4, 12, 13**: `VERIFIED_OFFICIAL_SOURCE` (Official Gazette of Egypt, Law No. 151 of 2020 on Personal Data Protection).
- **WireGuard Peer-to-Peer Encryption**: `VERIFIED_OFFICIAL_SOURCE` (WireGuard Technical Whitepaper, Jason A. Donenfeld).

---
**Authored By:** Principal AI Engineer / CTO & Enterprise Security Architect  
**Approved For Deployment:** 2026-11-12

