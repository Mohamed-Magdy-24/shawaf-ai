# PROPOSED PRODUCT UX/UI BLUEPRINT
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Design System & User Experience Specification  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & UI/UX Architect  
**Governing Standard:** Section 15 of Ultimate Master Directive (`Prompt.md`), `ui-ux-pro-max`, `taste-skill`, and `design-system`  
**Date:** 2026-11-18  

---

## 1. Design Philosophy & Industrial Operating Context

The Industrial AI Surveillance Platform is an mission-critical operational cockpit designed for industrial plant safety supervisors, security operators, and executive plant managers in high-pressure manufacturing environments.

### Core Design Tenets:
1. **Utility Over Decoration (Anti-Slop Standard):** Every pixel must communicate functional status. No decorative gradients, gratuitous 3D meshes, floating sparkles, or pseudo-futuristic glowing cards.
2. **High Information Density with Visual Calm:** Operators monitor 200+ camera streams across BNF and RNF. The interface must maximize screen real estate, minimize wasted whitespace, and maintain a calm, dark-mode baseline that prevents operator eye fatigue during 12-hour shifts.
3. **Instantaneous State Clarity (10 Mandatory UI States):** Operators must never guess whether a camera stream or KPI is current. The UI strictly and explicitly distinguishes:
   - `LOADING` — Active data retrieval in progress (subtle skeletal shimmer).
   - `LIVE` — Real-time telemetry actively streaming (< 1s latency).
   - `DELAYED` — Stream active but latency exceeds nominal threshold (> 2s).
   - `STALE` — No heartbeat received in > 10s; values dimmed with warning badge.
   - `OFFLINE` — Device/connection severed; high-contrast warning indicator.
   - `EMPTY` — Zero events match current filter; clear neutral explanation.
   - `ERROR` — Socket or query failure; explicit error code and retry action.
   - `UNAUTHORIZED` — Operator role lacks permission for this camera or site.
   - `PERMISSION_DENIED` — Action rejected by server RBAC (`D-011`).
   - `PARTIALLY_AVAILABLE` — Degraded mode; sub-stream only, AI worker degraded.
4. **Sub-Second Urgent Triage:** Emergency alerts (fire, restricted zone breach, worker fall) take precedence over all analytical views, triggering audible cues and unambiguous modal triage cards without blocking the underlying telemetry.

---

## 2. Industrial Design System Specification

### 2.1 Color Token Architecture (Primitive -> Semantic -> Component)

The platform employs a deeply contrast-tested industrial dark theme (`#0B0F17` canvas) engineered to comply with WCAG 2.1 AA (contrast ratio >= 4.5:1 for body text, >= 3:1 for graphical elements).

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ INDUSTRIAL SURVEILLANCE COLOR TOKEN PALETTE                                            │
├────────────────────┬───────────┬───────────────────────────────────────────────────────┤
│ Token Name         │ Hex Value │ Semantic Usage                                        │
├────────────────────┼───────────┼───────────────────────────────────────────────────────┤
│ surface-canvas     │ #0B0F17   │ Root application background; deepest black/slate.     │
│ surface-panel      │ #111827   │ Card, modal, and drawer backgrounds (elevation 1).     │
│ surface-raised     │ #1F2937   │ Interactive cards, table rows, headers (elevation 2).  │
│ border-subtle      │ #1E293B   │ Low-contrast structural dividing lines.                │
│ border-strong      │ #334155   │ Focused inputs, active container borders.              │
│ text-primary       │ #F8FAFC   │ Primary labels, camera titles, critical metrics.       │
│ text-secondary     │ #94A3B8   │ Timestamps, secondary metadata, table headers.         │
│ text-disabled      │ #475569   │ Inactive controls, placeholder text.                   │
├────────────────────┼───────────┼───────────────────────────────────────────────────────┤
│ status-critical    │ #EF4444   │ CRITICAL FIRE, restricted zone breach, camera OFFLINE. │
│ status-warning     │ #F59E0B   │ PPE violation, worker fall anomaly, stream DELAYED.   │
│ status-normal      │ #10B981   │ Camera LIVE, AI worker healthy, normal attendance.     │
│ status-info        │ #3B82F6   │ System sync, audit log events, informational notices.  │
│ status-stale       │ #64748B   │ Telemetry stale, connection degraded.                  │
└────────────────────┴───────────┴───────────────────────────────────────────────────────┘
```

### 2.2 Typography Scale (Inter / JetBrains Mono)
- **Primary Typeface:** `Inter`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `Roboto`.
- **Monospace Telemetry Typeface:** `JetBrains Mono`, `Roboto Mono`, `Courier New` (used for IP addresses, timestamps, stream bitrates, confidence scores, and bounding-box coordinates).
- **Scale:**
  - `Display / KPI`: 28px (Bold, line-height 32px)
  - `Heading 1 / Screen Title`: 20px (SemiBold, line-height 26px)
  - `Heading 2 / Section Header`: 16px (SemiBold, line-height 22px)
  - `Body Regular`: 14px (Regular, line-height 20px)
  - `Caption / Metadata`: 12px (Medium, line-height 16px)
  - `Badge / Pill`: 11px (Bold, uppercase, letter-spacing 0.05em)

### 2.3 Layout, Spacing & Breakpoints
- **Base Grid:** 4px baseline, 8px layout rhythm.
- **Responsive Breakpoints (Flutter):**
  - `Mobile Handheld (Android)`: 360px – 599px (Single column, bottom navigation, full-width cards).
  - `Tablet / Field Console`: 600px – 1023px (2-column grid, collapsible side navigation).
  - `Desktop Web Admin`: 1024px – 1439px (Multi-column dashboard, 2×2 / 3×3 camera walls).
  - `Command Center Wall`: 1440px – 2560px+ (High-density 4×4 / 6×6 camera matrix, persistent event rail).

---

## 3. Web Administration Console — Screen Inventory (18 Screens)

Pursuant to Section 15.2 of the Master Directive, every required administrative screen is specified with exact layout, controls, data sources, and operational behaviors:

### Screen W-01: Secure Login & Multi-Factor Session Gateway
- **Layout:** Centered security card with industrial styling and site identity banner.
- **Controls:** Username/Email input, password input, TOTP / hardware key field, Site Selection dropdown (`BNF`, `RNF`, or `CENTRAL_MANAGEMENT`).
- **Behavior:** Validates credentials against Go `/api/v1/auth/login`. Returns JWT + HTTP-only session cookie. Enforces rate limiting (5 failed attempts locks for 15 minutes).

### Screen W-02: Operational Command Overview (Executive Cockpit)
- **Layout:** 3-column dashboard: Left = Site selector & critical KPI cards; Center = Mini-wall of priority cameras (high-risk areas); Right = Real-time incident stream.
- **KPI Metrics:**
  - Active Cameras (e.g. `204/208 Online`)
  - AI Inference Throughput (`24.2 FPS avg, latency 42ms`)
  - Active Unresolved Incidents (`3 Warning, 0 Critical`)
  - Attendance Punch Sync (`Last sync: 2m ago, 842 checked-in`)
- **Behavior:** Powered by WebSocket connection `/api/v1/sites/{site_id}/ws-events`. Zero page refreshes.

### Screen W-03: Live Multi-Camera Wall (The Grid)
- **Layout:** High-density video matrix supporting 1×1, 2×2, 3×3, 4×4, and custom asymmetric layouts (1 large primary + 5 peripheral thumbnails).
- **Controls:** Camera group filter (Zone, Building, Floor), stream quality toggle (`Sub-Stream 360p` vs `Main-Stream 1080p`), full-screen toggle, stream pause/resume.
- **Behavior:** Low-latency WebRTC streams connected via authenticated Go SDP proxy. Streams automatically throttle or drop to keyframes when hidden from viewport (virtualized rendering).

### Screen W-04: Individual Camera Detail & PTZ Inspection
- **Layout:** Large 1080p WebRTC viewport with floating overlay HUD for telemetry and PTZ control overlay.
- **Controls:** 8-direction PTZ joystick, digital zoom (1x–8x), preset selection buttons, manual snapshot capture, AI detection overlay toggle (draws bounding boxes and labels).
- **Behavior:** PTZ commands dispatch to `/api/v1/sites/{site_id}/cameras/{camera_id}/ptz` with automatic release timeouts to prevent runaway movements.

### Screen W-05: Real-Time Incident & Alert Center
- **Layout:** Split view: Left = Filterable tabular incident feed; Right = Incident detail inspector with synchronized video clip player.
- **Incident Severity Badges:**
  - `CRITICAL_FIRE` (Red pulsate, auxiliary dispatch)
  - `INTRUSION_RESTRICTED` (Red solid)
  - `HAZARD_FALL` (Amber solid)
  - `SAFETY_PPE` (Amber outline)
  - `COVERAGE_LOST` (Purple solid, `NFR-OBS-002`)
- **Actions:** Acknowledge alert, assign investigator, dismiss (requires mandatory dropdown reason), export clip.

### Screen W-06: Incident Investigation & Forensic Timeline
- **Layout:** Synchronized multi-camera playback timeline with scrubber bar, speed control (0.25x to 4x), and detection event markers.
- **Controls:** Time scrubber, frame-by-frame stepper, camera sync toggle, evidence package builder (bundles 30s pre/post video, high-res snapshot, model version metadata, audit log).
- **Behavior:** Pulls recording chunks from NVR RTSP playback or local edge storage.

### Screen W-07: AI Detection Details & Bounding Box Inspector
- **Layout:** Raw frame viewer displaying inference results with toggleable layers.
- **Telemetry HUD:** Detection class, confidence score (`92.4%`), bounding box coordinates `[x1, y1, x2, y2]`, model artifact version (`yolox_s_v1.onnx`), inference execution provider (`CUDA Execution Provider`).

### Screen W-08: Attendance & Biometric Status Dashboard
- **Layout:** Real-time attendance punch monitor connected to local ZKTeco staging sync.
- **Data Display:** Employee ID, name, department, terminal ID, punch timestamp, verification status (`VERIFIED_TERMINAL`).
- **Privacy Compliance:** In accordance with `DEC-06` and Egyptian Law 151/2020, zero unapproved facial recognition tracking is displayed.

### Screen W-09: Material Movement & Forklift Fleet Monitor
- **Layout:** Zone diagram showing material staging bays and transit corridors.
- **Events:** Staging bay occupancy, blocked fire exit warnings, forklift speeding/restricted lane alerts (`FR-AI-004`).

### Screen W-10: Device & NVR Fleet Health
- **Layout:** Hierarchical tree table of all physical infrastructure: Switches -> NVRs -> IP Cameras -> Edge Servers.
- **Columns:** Device Name, IP, Manufacturer (Dahua/Hikvision/Tiandy), Firmware, RTSP Sub-stream URL, Connection Uptime, Packet Loss %, Frame Rate.
- **Alerting:** Automatically triggers `NFR-OBS-002` Coverage Lost alert if stream disconnects for > 15s.

### Screen W-11: Edge Server & Storage Quota Monitor
- **Layout:** Gauges and time-series graphs for host infrastructure.
- **Metrics:** CPU utilization, RAM usage (WSL / Docker allocation), GPU VRAM usage (`Quadro P600`), Local SSD storage watermark (`/var/lib/surveillance/snapshots`, 30-day retention).

### Screen W-12: Alert Routing Rules & Recipient Rosters
- **Layout:** Rule configuration matrix for safety escalation.
- **Controls:** Severity threshold slider, notification channels (WebSocket, local siren, SMS relay, FCM disabled), recipient group assignment (Security Desk, Plant Manager, Safety Officer).
- **Protection:** Changes to recipient rosters require `security_admin` role and produce tamper-evident audit logs.

### Screen W-13: User Management & Role-Based Access Control (RBAC)
- **Layout:** User table with role assignment drawer.
- **Roles Enforced:**
  - `system_admin`: Full system configuration, edge server management.
  - `security_manager`: Camera viewing, PTZ control, incident resolution, roster management.
  - `operator`: Live camera wall viewing, incident acknowledgment.
  - `auditor`: Read-only access to audit logs, reports, and incident history.

### Screen W-14: Camera Provisioning & RTSP Configuration
- **Layout:** Camera creation/edit modal with network configuration testing.
- **Controls:** Site selector (`BNF` or `RNF`), Camera Name, RTSP Main URL, RTSP Sub URL, Username, Password (masked with credential scrubbing in logs), Detection Zones polygon editor.
- **Validation:** "Test Connection" button executes server-side ping and RTSP handshake before saving.

### Screen W-15: System Configuration & Feature Flags
- **Layout:** Tabbed settings panel: Multi-rate sampling configuration (0.5–2.0 FPS), edge retention rules, WireGuard VPN tunnel parameters, session timeouts.

### Screen W-16: Factory Audit Logs & Tamper-Evident History
- **Layout:** Append-only log table with cryptographic chain hashes.
- **Events Logged:** Logins, stream accesses, PTZ movements, incident status changes, user modifications, configuration updates. Immutable and exportable to CSV/JSON.

### Screen W-17: System Diagnostics & Health Probes
- **Layout:** Live connectivity graph showing latencies between Go `edged`, Python `py-worker`, PostgreSQL 16, `go2rtc`, and NVRs.
- **Diagnostics:** One-click ping, gRPC ping-pong probe, database connection pool statistics.

### Screen W-18: Offline Fallback & WAN Degraded Mode Status
- **Layout:** Visual banner and status map depicting site isolation health.
- **Indicators:** BNF Local Plane (Green / Autonomous), RNF Local Plane (Green / Autonomous), Central WireGuard Tunnel (Connected / Degraded). Confirms local recording and detection continue uninterrupted during WAN dropouts.

---

## 4. Android Handheld Application — Screen Inventory (8 Screens)

Designed specifically for on-duty security supervisors walking factory floors on Android rugged handhelds:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ ANDROID HANDHELD MOBILE APPLICATION FLOW                               │
│                                                                        │
│  [M-01: Biometric Login]                                               │
│            │                                                           │
│            ▼                                                           │
│  [M-02: Site Selector (BNF / RNF)]                                     │
│            │                                                           │
│            ▼                                                           │
│  [M-03: Active Incidents Feed] ◄────────┐ (Foreground Push Alert)       │
│            │                            │                              │
│            ▼                            │                              │
│  [M-04: Incident Action Sheet]          │                              │
│            │                            │                              │
│            ├──────► [M-05: Live WebRTC Stream Viewer]                  │
│            │                                                           │
│            ▼                                                           │
│  [M-06: Incident History & Search]                                     │
│  [M-07: Device & Camera Health Glance]                                 │
│  [M-08: Profile & Offline Session Status]                              │
└────────────────────────────────────────────────────────────────────────┘
```

### Screen M-01: Handheld Login & Biometric Unlock
- Simple numeric PIN pad or fingerprint biometric unlock for quick re-authentication during floor patrols.
- Supports offline PIN caching for localized shift operations during WiFi dead zones.

### Screen M-02: Site Selector (BNF / RNF)
- Segmented control selecting active plant facility. Automatically defaults to the connected local factory SSID.

### Screen M-03: Active Incidents Feed (The Operational Inbox)
- Reverse-chronological card list of unacknowledged and active safety alerts.
- Large color-coded touch targets (height >= 64px) for gloved thumb operation.
- High-contrast visual cards showing Camera Name, Zone, Violation Type, Snapshot thumbnail, and Elapsed Time.

### Screen M-04: Emergency Incident Action Sheet
- Swipe-up modal displayed upon tapping an active incident.
- Large tactile buttons:
  - `ACKNOWLEDGE` (Turns alert amber; assigns to current supervisor).
  - `RESOLVE` (Prompts for brief resolution code).
  - `DISMISS` (Requires selecting reason: False Positive, Test Drill, Authorized Worker).
  - `VIEW LIVE STREAM` (Navigates directly to Screen M-05).

### Screen M-05: Low-Latency WebRTC Stream Viewer
- Full-screen hardware-accelerated video player (Flutter WebRTC / surface view).
- Sub-500ms latency stream connecting directly to local factory edge server.
- Floating overlay displaying incident bounding box and camera name.

### Screen M-06: Incident History & Investigation
- Filterable past incident archive with search by date, zone, and violation type.

### Screen M-07: Camera & Edge Server Health Glance
- Quick status badge showing total online cameras and local server reachability.

### Screen M-08: User Profile & Shift Session Controls
- Current operator badge, shift duration, emergency phone dialer shortcut, logout.

---

## 5. Visual Consistency & Quality Gate (Anti-Slop Compliance)

To ensure strict compliance with `taste-skill` and prevent AI-generated visual clutter:
- **Zero Placeholder Charts:** No chart will render dummy wavy lines or simulated upward trends. If historical data is absent, the component displays an explicit `NO HISTORICAL DATA RECORDED` state.
- **Zero Fake Camera Feeds:** Video viewports never display static stock images of factory floors. Unconnected cameras show the high-contrast `OFFLINE — RTSP UNREACHABLE` slate with retry countdown.
- **Physical Button Sizing:** In accordance with `ui-ux-pro-max`, all mobile touch targets have a minimum dimension of **48×48 dp** with minimum 8 dp separation.
- **Predictable Transitions:** Modal animations and drawer slides have fixed durations (150ms–200ms ease-out) and respect the user's OS-level `prefers-reduced-motion` accessibility setting.
