# 32 — Device Fleet Inventory, Multi-Vendor Tiering & Compatibility Plan

**Document ID:** DISC-32-FLEET-PLAN  
**Version:** 1.0.0  
**Date:** 2026-11-11  
**Status:** CANONICAL INTEROPERABILITY & INVENTORY PLAN  
**Classification:** `PROPOSED` (Device Governance Strategy)  
**Directive Reference:** Findings P1-02 & P1-02A of CTO Review  

---

## 1. Executive Correction: The Multi-Device Fleet Reality

In accordance with Finding P1-02 of the CTO Review:
> **Testing a single test NVR and one biometric terminal is useful for initial protocol proof, but is INSUFFICIENT to validate a mixed fleet of 400+ cameras, multiple NVR models, and 36+ biometric terminals.**
> The platform must establish a formal **3-Tier Compatibility Architecture**. Devices are classified into explicit tiers based on demonstrated empirical capabilities. Unsupported or legacy hardware must remain explicitly flagged as unsupported rather than silently assumed functional.

In accordance with Finding P1-02A:
> **Practical Biometric Image Rule:** The project does not assert sweeping mathematical claims about every proprietary template format in existence. Instead, the firm engineering rule is: **Only vendor-documented, officially supported export APIs returning verified standard image files (JPEG/PNG) count as an acceptable enrollment photo source for this project.** Proprietary template blobs remain unsupported unless the manufacturer provides an officially documented, legally compliant image reconstruction SDK.

---

## 2. Multi-Vendor Device Compatibility Tiers

```text
+----------------------------------------------------------------------------------------------------+
|                                    DEVICE COMPATIBILITY TIERS                                      |
|                                                                                                    |
|  TIER 1: FULLY CERTIFIED & TESTED                                                                  |
|  - Tested in Phase 1 PoC; verified firmware version; RTSP sub-streams stable;                      |
|    historical playback API working; full integration with AI pipeline.                             |
|                                                                                                    |
|  TIER 2: COMPATIBLE WITH CONSTRAINTS (DEGRADED CAPABILITY)                                         |
|  - RTSP video streaming verified; remote playback API unsupported or unstable.                     |
|    Supported for: Live video viewing & AI safety inference.                                        |
|    Unsupported for: Historical 30-day in-app playback seek (requires manual NVR console access).    |
|                                                                                                    |
|  TIER 3: UNSUPPORTED / LEGACY QUARANTINE                                                           |
|  - Proprietary analog/coaxial streams; legacy non-ONVIF codecs; devices failing connection tests.  |
|    Flagged as `UNSUPPORTED_DEVICE` in UI; zero operational dependence.                             |
+----------------------------------------------------------------------------------------------------+
```

---

## 3. Physical Inventory Collection Protocol (BNF & RNF)

Before Phase 2 architecture code is frozen, the factory IT and security maintenance contractors must execute the physical device inventory using the standardized schema below:

### 3.1 NVR & Camera Fleet Discovery Schema
For every installed NVR unit:
1. **Hardware & Firmware Profile:** Manufacturer (Hikvision, Dahua, Uniview, Tiandy, etc.), exact Model Number, installed Firmware Build Number, serial number.
2. **Channel Mapping:** Total channel capacity, active connected camera count, IP address, switch port ID.
3. **Stream Properties per Channel:**
   - Main Stream: Resolution ($1920\times 1080$, $4\text{MP}$, etc.), Video Codec (H.264 / H.264+ / H.265 / H.265+), Frame Rate (FPS), Bitrate (kbps), Encoding Mode (CBR vs. VBR).
   - Sub-Stream: Availability (Enabled/Disabled), Resolution (D1, CIF, 720p), FPS, Bitrate.
4. **Protocol Support:** ONVIF conformance (Profile S, Profile G, Profile T), native ISAPI/CGI enablement.
5. **Session Capacity:** Maximum concurrent RTSP connections permitted by NVR hardware before stream drop (e.g., 16, 32, 64 concurrent streams).

### 3.2 Biometric Terminal Fleet Discovery Schema
For each of the ~18+ terminals per factory:
1. **Device Identification:** Terminal Name, Location (e.g., Gate 1, Plant 2 Entrance), IP, MAC, Model (e.g., ZKTeco uFace 800, SpeedFace V5L, ProFace X, K40).
2. **Firmware Version:** Firmware build number, Biometric Algorithm Version (e.g., ZKFinger VX10.0, ZKFace VX5.8/VX7.0).
3. **Data Communication Protocol:** Standalone Push Protocol vs. Pull SDK vs. ZKBioTime Direct API.
4. **Photo Storage Verification:**
   - Does the terminal store actual visible-light RGB photos in onboard flash memory? (Yes / No).
   - Does ZKBioTime contain a synchronized `.jpg` photo for employees enrolled on this terminal? (Yes / No / Template Blob).

---

## 4. Progressive Representative Hardware Testing Strategy (Phase 1 Spikes)

To validate the mixed fleet efficiently without testing all 400 cameras individually in Phase 1:
1. **Cluster by Hardware Family:** Group the discovered NVRs and cameras into representative "Device Families" (e.g., Hikvision NVR Family A, Dahua NVR Family B, Generic RTSP Family C).
2. **Representative Testing:** Select **one physical unit from each major family** representing at least 80% of the installed camera volume.
3. **Rigorous Test Battery (per Representative Family):**
   - 24-hour continuous RTSP stream stability via `go2rtc`.
   - WebRTC low-latency streaming to mobile client.
   - Profile G historical playback range seek.
   - Reconnect behavior following physical Ethernet cable disconnect and NVR reboot.
   - Maximum concurrent session stress test (measuring at what connection count the NVR throttles).
4. **Explicit Capability Matrix:** If a specific family passes live streaming but fails remote playback, it is classified as **Tier 2**, and remote playback is cleanly disabled in the software adapter for that device family with zero unhandled exceptions.

---

## 5. Device Fleet Plan Sign-Off

- **Status:** CANONICAL INVENTORY & INTEROPERABILITY SPECIFICATION.
- **Action Item:** Transmit inventory schema to BNF and RNF IT teams upon Gate 0 approval.

