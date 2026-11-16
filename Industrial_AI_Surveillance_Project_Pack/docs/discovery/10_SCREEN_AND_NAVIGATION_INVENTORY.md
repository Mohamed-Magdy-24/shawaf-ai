# 10 — Screen & Navigation Inventory across Platforms

**Document ID:** DISC-10-SCREEN-INVENTORY  
**Version:** 1.1.0-remediated  
**Status:** PROPOSED INFORMATION ARCHITECTURE (Awaiting Owner DEC-02 Approval for Web Admin)  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Traceability Reference:** SRS-001 Section 4, CTO Directive Section 6, Documents 26, 35 & 38  

---

## 1. Multi-Platform Screen Mapping Matrix

To maintain operational clarity and prevent mobile interface overcrowding, screens are explicitly assigned to their appropriate client form factor:
- **Android Mobile App (`OWNER_CONFIRMED_REQUIREMENT`):** Primary handheld interface for Factory Managers, Security Heads, and Corporate Executives. Optimized for rapid situational awareness, alert response, tokenized video viewing, and scheduled reports.
- **Web Administration Console (`PROPOSED` — Subject to Owner Decision DEC-02):** Dedicated administrative console for Safety Directors, Security Administrators, and IT Engineers. Optimized for complex spatial polygon mapping, camera channel inventory, policy rule authoring, and audit log analysis.

| Screen ID | Screen Name | Target Platform | Governance Status | Primary User Roles | Core Functionality & Access Rule |
|---|---|---|---|---|---|
| **SCR-01** | Secure Login & MFA | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | All Users | Authenticates credentials, verifies MFA token, mints scoped JWT. |
| **SCR-02** | Factory Selection Modal | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | All Multi-Site Users | Explicit modal switching context between BNF and RNF with clear visual isolation. |
| **SCR-03** | Main Operational Dashboard | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | All Authorized Managers | Active site KPIs, hourly event sparklines, active camera health count. Verified empty state when 0 events. |
| **SCR-04** | Factory Overview & Topology | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | All Authorized Managers | Map/schematic view of factory zones, camera placement, active shifts. |
| **SCR-05** | Camera Monitoring Grid | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Security & Senior Mgmt Only | Multi-channel live video grid (2x2 / 3x3) with stream health indicators. Role-gated. |
| **SCR-06** | Live Fullscreen Camera View | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Security & Senior Mgmt Only | Full-resolution WebRTC player, PTZ controls (if supported), audio/HUD overlay. |
| **SCR-07** | Recording Playback & Seek | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Security & Senior Mgmt Only | 30-day timeline scrubber, motion markers, clip export request. |
| **SCR-08** | Alerts Center / Inbox | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Factory, Company & Security Mgmt | Real-time reactive stream of events, severity filter, acknowledge triage. |
| **SCR-09** | Incident Details & Evidence | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Factory, Company & Security Mgmt | Full event context: clip snapshot, 15s MP4, confidence score, model version. |
| **SCR-10** | Employee Directory | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | HR, Factory & Security Mgmt | Site-scoped roster synced from SQL Server/ZKBioTime; stable Employee IDs. |
| **SCR-11** | Employee Profile & Attendance | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | HR & Factory Managers | Shift history, attendance punch records, assigned department. Read-only. |
| **SCR-12** | Employee Image Import / Enroll | Web Admin | `PROPOSED` (DEC-02 / DEC-03) | Safety & HR Admins Only | Administrative photo upload and validation tool (Fallback for BLK-001). |
| **SCR-13** | Face Enrollment Status Matrix | Web Admin | `PROPOSED` (DEC-02) | Safety & Security Admins | Audit view showing which employees have verified face models vs missing photos. |
| **SCR-14** | Employee Movement History | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Security & Senior Mgmt Only | Chronological timeline of discrete camera sightings with location and Cairo timestamps. |
| **SCR-15** | Restricted Zones Manager | Web Admin | `PROPOSED` (DEC-02) | Safety Directors & Admins | Interactive desktop canvas for drawing and adjusting restricted polygon geofences. |
| **SCR-16** | PPE Rule Matrix Editor | Web Admin | `PROPOSED` (DEC-02) | Safety Directors & Admins | Matrix assigning required PPE items to specific zones and work shifts. |
| **SCR-17** | Camera Fleet Management | Web Admin | `PROPOSED` (DEC-02) | IT & Security Engineers | Channel registry, IP assignments, RTSP sub-stream configuration, FPS caps. |
| **SCR-18** | NVR Fleet Management | Web Admin | `PROPOSED` (DEC-02) | IT & Security Engineers | NVR device inventory, firmware version, credentials, storage volume status. |
| **SCR-19** | Device & Stream Health Center| Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | IT & Security Engineers | Real-time monitoring of RTSP drop rates, inference latency, worker health. |
| **SCR-20** | In-App Reports & Analytics | Android & Web | `OWNER_CONFIRMED_REQUIREMENT` | Factory & Company Mgmt | Scheduled daily, weekly, monthly reports; vector charts and percentages (Africa/Cairo time). |
| **SCR-21** | User Management & Identity | Web Admin | `PROPOSED` (DEC-02) | Platform Administrators | Creation of manager accounts, role assignment, password policies. |
| **SCR-22** | Permissions & Role Policies | Web Admin | `PROPOSED` (DEC-02) | Platform Administrators | Granular capability assignment (e.g., granting video access to specific roles). |
| **SCR-23** | System & Model Settings | Web Admin | `PROPOSED` (DEC-02) | System Administrators | AI confidence threshold tuning, model canary deployment, retention rules. |
| **SCR-24** | Integration Health Dashboard | Web Admin | `PROPOSED` (DEC-02) | IT & System Engineers | Connection status for SQL Server, ZKBioTime APIs, Valkey, and S3 Storage (SeaweedFS). |
| **SCR-25** | Tamper-Evident Audit Logs | Web Admin | `PROPOSED` (DEC-02) | Security & Compliance Officers | Immutable audit trail of every login, video stream session, and policy change. |

---

## 2. Android Manager Mobile Application Navigation Architecture

```mermaid
flowchart TD
    classDef auth fill:#1E293B,stroke:#F59E0B,stroke-width:2px,color:#F8F9FA;
    classDef nav fill:#161F30,stroke:#0EA5E9,stroke-width:2px,color:#F8F9FA;
    classDef screen fill:#0B111E,stroke:#10B981,stroke-width:2px,color:#F8F9FA;
    classDef restricted fill:#2D1515,stroke:#EF4444,stroke-width:2px,color:#EF4444;

    LOGIN["SCR-01: Login & MFA Screen"]:::auth --> CONTEXT["SCR-02: Site Context Switcher (BNF / RNF)"]:::auth
    
    CONTEXT --> TAB_BAR["Bottom Navigation Bar (Active Site Scoped)"]:::nav
    
    TAB_BAR --> TAB_DASH["Tab 1: Dashboard"]:::nav
    TAB_BAR --> TAB_ALERTS["Tab 2: Alerts Inbox"]:::nav
    TAB_BAR --> TAB_CAMERAS["Tab 3: Cameras (Role-Gated)"]:::nav
    TAB_BAR --> TAB_REPORTS["Tab 4: Reports & KPIs"]:::nav
    TAB_BAR --> TAB_MORE["Tab 5: Settings / Health"]:::nav

    %% Dashboard Sub-flow
    TAB_DASH --> SCR_03["SCR-03: Main Dashboard"]:::screen
    SCR_03 --> SCR_04["SCR-04: Factory Overview & Zones"]:::screen

    %% Alerts Sub-flow
    TAB_ALERTS --> SCR_08["SCR-08: Real-Time Alerts Inbox"]:::screen
    SCR_08 --> SCR_09["SCR-09: Incident Detail & Evidence"]:::screen
    SCR_09 --> SCR_07["SCR-07: 15s Evidence Clip Player"]:::restricted

    %% Cameras Sub-flow (Restricted)
    TAB_CAMERAS --> CHECK_ROLE{"Has Video Role?"}
    CHECK_ROLE -->|YES| SCR_05["SCR-05: Live Camera Grid"]:::restricted
    CHECK_ROLE -->|NO| DENIED["Access Denied Screen<br/>(Security Clearance Required)"]:::auth
    SCR_05 --> SCR_06["SCR-06: Fullscreen WebRTC Player"]:::restricted
    SCR_06 --> SCR_07["SCR-07: Historical Playback Scrubber"]:::restricted

    %% Reports Sub-flow
    TAB_REPORTS --> SCR_20["SCR-20: In-App Analytics & Rollups"]:::screen
    SCR_20 --> SCR_10["SCR-10: Employee Directory View"]:::screen
    SCR_10 --> SCR_14["SCR-14: Movement Sightings Timeline"]:::restricted

    %% More Sub-flow
    TAB_MORE --> SCR_19["SCR-19: Device Health Watchdog"]:::screen
    TAB_MORE --> LOGOUT["Logout & Flush Session"]:::auth
```

---

## 3. Web Administration Console Navigation Architecture

```mermaid
flowchart LR
    classDef menu fill:#161F30,stroke:#0EA5E9,stroke-width:2px,color:#F8F9FA;
    classDef view fill:#0B111E,stroke:#10B981,stroke-width:1px,color:#F8F9FA;

    SIDEBAR["Admin Left Sidebar"]:::menu --> M_SEC["1. Security & Cameras"]:::menu
    SIDEBAR --> M_POL["2. Safety & AI Policies"]:::menu
    SIDEBAR --> M_HR["3. Employee & Biometrics"]:::menu
    SIDEBAR --> M_SYS["4. System & Integration"]:::menu

    M_SEC --> SCR_17["SCR-17: Camera Fleet Registry"]:::view
    M_SEC --> SCR_18["SCR-18: NVR Fleet Management"]:::view
    M_SEC --> SCR_05_W["SCR-05: Multi-View Video Matrix"]:::view

    M_POL --> SCR_15["SCR-15: Polygon Zone Geofence Editor"]:::view
    M_POL --> SCR_16["SCR-16: PPE Shift Policy Editor"]:::view
    M_POL --> SCR_23["SCR-23: Model Confidence Thresholds"]:::view

    M_HR --> SCR_10_W["SCR-10: Employee Master List"]:::view
    M_HR --> SCR_12["SCR-12: Photo Enrollment Studio"]:::view
    M_HR --> SCR_13["SCR-13: Face Model Verification Status"]:::view

    M_SYS --> SCR_24["SCR-24: Integration Health Watchdog"]:::view
    M_SYS --> SCR_21["SCR-21: User & RBAC Management"]:::view
    M_SYS --> SCR_25["SCR-25: Immutable Audit Log Browser"]:::view
```

---

## 4. State Handling Protocol Across All Screens

Every screen across Android and Web must implement explicit, deterministic handlers for the five universal application states:

```text
+-------------------+---------------------------------------------------------------------------------+
| UI STATE          | MANDATORY RENDERING BEHAVIOR (ZERO MOCK DATA RULE)                              |
+-------------------+---------------------------------------------------------------------------------+
| 1. LOADING        | High-contrast skeleton shimmer matching exact card proportions. No spinners.    |
+-------------------+---------------------------------------------------------------------------------+
| 2. VERIFIED EMPTY | Explicit empty card: "Zero incidents recorded for BNF in this shift.           |
|                   | Database connection healthy. Last sync: 21:45:00 Cairo (19:45:00 UTC)."        |
|                   | Zero invented records. No placeholder data.                                    |
+-------------------+---------------------------------------------------------------------------------+
| 3. ACTIVE DATA    | High-density data rendering with explicit UTC & Cairo timestamps, IDs, conf.   |
+-------------------+---------------------------------------------------------------------------------+
| 4. STALE / OFFLINE| Persistent amber banner: "Network disconnected. Displaying cached data from     |
|                   | 21:30:00 Cairo (19:30:00 UTC). Live streaming and real-time alerts paused."     |
+-------------------+---------------------------------------------------------------------------------+
| 5. ERROR / DENIED | Explicit error card explaining root cause (e.g., HTTP 403 Forbidden, NVR       |
|                   | timeout) with Retry button and direct diagnostic error code.                    |
+-------------------+---------------------------------------------------------------------------------+
```

---

## 5. Screen Inventory Sign-Off

- **Status:** PROPOSED.
- **Next Step:** Owner review and approval to proceed with Phase 1 technical spikes.

