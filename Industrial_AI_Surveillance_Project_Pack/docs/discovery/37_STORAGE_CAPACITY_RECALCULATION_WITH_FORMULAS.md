> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 37 — Storage Capacity Recalculation from First Principles (Mathematical Model)

**Document ID:** DISC-37-STORAGE-MATH  
**Version:** 1.1.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL MATHEMATICAL SPECIFICATION (Sizing Model, Not a Procurement BOM)  
**Classification:** `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` (CTO Audit Remediation)  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Section 7  

---

## 1. Executive Summary & Purpose

This document establishes the rigorous, first-principles mathematical storage model for the Industrial AI Surveillance Platform. It explicitly resolves previous arithmetic ambiguities by:
1. Enforcing strict unit separation between decimal Terabytes ($1\text{ TB} = 10^{12}\text{ bytes}$) and binary Tebibytes ($1\text{ TiB} = 2^{40}\text{ bytes} = 1,099,511,627,776\text{ bytes}$).
2. Deriving the exact RAID-6 usable data capacity formula before filesystem formatting.
3. Defining explicit deduction order and denominators for filesystem overhead and operational reserves.
4. Reclassifying unverified baseline assumptions (e.g. NVR local storage vs. centralized storage duplication).
5. Modeling multi-scale capacity scenarios across 200, 225, 250, and 300 cameras.
6. **Explicit Disclaimer:** This document provides a sizing model only. **No production hardware procurement bill of materials (BOM) is authorized.**

---

## 2. Unit Standards & Conversion Constants

Hard disk drive (HDD) manufacturers sell and specify drives in **decimal (base-10)** units. Operating systems, filesystems, and volume managers allocate storage in **binary (base-2)** units.

```text
1 Kilobyte (KB)  = 1,000 Bytes           | 1 Kibibyte (KiB)  = 1,024 Bytes (2^10)
1 Megabyte (MB)  = 1,000,000 Bytes       | 1 Mebibyte (MiB)  = 1,048,576 Bytes (2^20)
1 Gigabyte (GB)  = 1,000,000,000 Bytes   | 1 Gibibyte (GiB)  = 1,073,741,824 Bytes (2^30)
1 Terabyte (TB)  = 10^12 Bytes           | 1 Tebibyte (TiB)  = 2^40 Bytes (1,099,511,627,776 Bytes)
```

Conversion factor:
$$\text{TiB} = \frac{\text{Bytes}}{1,099,511,627,776} = \frac{\text{TB} \times 10^{12}}{1,099,511,627,776} \approx \text{TB} \times 0.9094947$$

---

## 3. Storage Demand Parameters & Unverified Operational Assumptions

### 3.1 Unverified Operational Architecture Assumptions (`UNKNOWN` / `PROPOSED`)
Before sizing physical hardware, the following architectural boundaries must be verified during the Phase 1 physical site inventory:
1. **NVR Primary Storage vs. Central Storage Duplication (`UNKNOWN`):** Do the installed NVRs already house physical hard drives providing the 30-day continuous retention? If so, central storage is only required for AI incident evidence clips and metadata. If central storage must ingest and record all continuous video directly, it acts as a secondary or primary storage cluster.
2. **Sub-stream Recording Policy (`PROPOSED`):** Sub-streams (360p) are utilized for real-time mobile display and AI worker ingestion. Storing sub-streams continuously alongside main streams is redundant; the recommended baseline records **main stream only** continuously.
3. **Audio Recording Policy (`UNKNOWN`):** Factory floor cameras rarely record audio due to high ambient industrial acoustic noise and worker privacy constraints under Egyptian Law 151/2020.
4. **VBR Peak Behavior (`ESTIMATED`):** Camera bitrate varies with scene motion and lighting. A $+15\%$ headroom multiplier is modeled.

### 3.2 Baseline Stream Parameters (Main Stream Continuous Ingest)
- **Retention Period ($T$):** 30 calendar days = $30 \times 24 \times 3,600 = 2,592,000\text{ seconds}$.
- **Case A (Main Stream Only — Recommended):**
  - Resolution: 1080p (1920×1080), 15–20 FPS, H.264/H.265.
  - Nominal Bitrate: $2.000\text{ Mbps} = 2,000,000\text{ bps}$.
  - Effective Bitrate with $+15\%$ VBR Uplift: $R_{\text{eff}} = 2.000 \times 1.15 = 2.300\text{ Mbps} = 2,300,000\text{ bps}$.
- **Case B (Main + Audio + Sub-stream — Conservative Sizing):**
  - Nominal Bitrate: $2.400\text{ Mbps} = 2,400,000\text{ bps}$.
  - Effective Bitrate with $+15\%$ VBR Uplift: $R_{\text{eff}} = 2.400 \times 1.15 = 2.760\text{ Mbps} = 2,760,000\text{ bps}$.

### 3.3 AI Evidence Clip & Snapshot Storage Pool (`PROPOSED`)
- **Clip Specification:** 15 seconds total (7.5s pre-event + 7.5s post-event buffer) MP4 at 4.0 Mbps $= 7.50\text{ MB/clip}$.
- **Snapshot Specification:** 2 high-resolution JPEG crops per incident $= 1.00\text{ MB/incident}$.
- **Assumed Frequency:** 500 validated incidents per day per factory (`PROPOSED`, subject to site calibration).
- **Evidence Retention Period:** 90 calendar days (`PROPOSED`, subject to corporate legal retention policy).
- **Daily Volume:** $500 \times 8.50\text{ MB} = 4,250\text{ MB/day} = 4.25\text{ GB/day}$.
- **90-Day Evidence Pool:** $90 \times 4.25\text{ GB} = 382.5\text{ GB} \approx 0.383\text{ TB decimal} (0.348\text{ TiB binary})$.

---

## 4. Hardware Storage Array Supply Model: 16 × 18 TB RAID-6

### 4.1 Step 1: Raw Installed Physical Capacity ($C_{\text{raw}}$)
- 16 enterprise SATA/SAS drives, each rated at 18 TB decimal ($18 \times 10^{12}\text{ bytes}$):
  $$C_{\text{raw}} = 16 \times 18 \times 10^{12}\text{ bytes} = 288,000,000,000,000\text{ bytes}$$
  $$\mathbf{C_{\text{raw}} = 288.000\text{ TB (Decimal)}} \quad | \quad \mathbf{C_{\text{raw}} = 261.934\text{ TiB (Binary)}}$$

### 4.2 Step 2: RAID-6 Usable Data Capacity before Filesystem ($C_{\text{raid6}}$)
RAID-6 requires exactly 2 parity drives for $P + Q$ Reed-Solomon redundancy:
$$N_{\text{data}} = N_{\text{total}} - 2 = 16 - 2 = 14\text{ data drives}$$
$$C_{\text{raid6}} = 14 \times 18 \times 10^{12}\text{ bytes} = 252,000,000,000,000\text{ bytes}$$
$$\mathbf{C_{\text{raid6}} = 252.000\text{ TB (Decimal)}} \quad | \quad \mathbf{C_{\text{raid6}} = 229.193\text{ TiB (Binary)}}$$

### 4.3 Step 3: Formatted Filesystem Capacity ($C_{\text{fmt}}$)
Filesystems (XFS with 4 KB block size, allocation groups, and inode structures) consume a small percentage of raw block capacity:
- Deduction: **2.0%** of $C_{\text{raid6}}$ ($252.000\text{ TB}$ denominator):
  $$\text{Deduction}_{\text{fs}} = 252.000 \times 0.02 = 5.040\text{ TB decimal} (4.584\text{ TiB binary})$$
  $$C_{\text{fmt}} = 252.000 \times 0.98 = 246.960,000,000,000\text{ bytes}$$
  $$\mathbf{C_{\text{fmt}} = 246.960\text{ TB (Decimal)}} \quad | \quad \mathbf{C_{\text{fmt}} = 224.609\text{ TiB (Binary)}}$$

### 4.4 Step 4: Capacity Withheld for Operational Reserves ($C_{\text{withheld}}$)
- **Operational Free-Space Reserve (15.0% of $C_{\text{fmt}}$):** Required to prevent XFS block allocation fragmentation and ensure sustained sequential write throughput during continuous 200-camera ingest and background RAID rebuilds.
  $$\text{Reserve}_{\text{op}} = 246.960 \times 0.15 = 37.044\text{ TB decimal} (33.691\text{ TiB binary})$$
- **Local Snapshot & Volume Reserve (3.0% of $C_{\text{fmt}}$):** Accommodates point-in-time storage metadata snapshots and temporary index rebuilds.
  $$\text{Reserve}_{\text{snap}} = 246.960 \times 0.03 = 7.409\text{ TB decimal} (6.738\text{ TiB binary})$$
- **CRITICAL ARCHITECTURAL DISTINCTION:** Local snapshots reside on the same physical array and do **NOT** constitute independent disaster-recovery backups. Offsite DR backups must be stored on independent secondary infrastructure.
- Total Withheld Capacity ($15\% + 3\% = 18\%$ of $C_{\text{fmt}}$):
  $$C_{\text{withheld}} = 246.960 \times 0.18 = 44.453\text{ TB decimal} (40.430\text{ TiB binary})$$

### 4.5 Step 5: Net Capacity Available for Retained Video Storage ($C_{\text{avail}}$)
$$C_{\text{avail}} = C_{\text{fmt}} - C_{\text{withheld}} = 246.960 - 44.453 = 202.507,000,000,000\text{ bytes}$$
$$\mathbf{C_{\text{avail}} = 202.507\text{ TB (Decimal)}} \quad | \quad \mathbf{C_{\text{avail}} = 184.179\text{ TiB (Binary)}}$$

---

## 5. Multi-Scale Camera Capacity Scenarios (30-Day Retention Target)

The table below evaluates the 16 × 18 TB RAID-6 array ($C_{\text{avail}} = 202.507\text{ TB}$) across camera fleet scales:

```text
+----------+------------------------------------+--------------------+------------------------------------+--------------------+
| CAMERA   | CASE A: MAIN STREAM ONLY           | REMAINING MARGIN   | CASE B: MAIN + SUBSTREAM + AUDIO   | REMAINING MARGIN   |
| COUNT    | (2.30 Mbps Effective)              | OVER CASE A DEMAND | (2.76 Mbps Effective)              | OVER CASE B DEMAND |
+----------+------------------------------------+--------------------+------------------------------------+--------------------+
| 200 Cams | 149.040 TB (135.551 TiB)           | +53.47 TB (+35.9%) | 178.848 TB (162.661 TiB)           | +23.66 TB (+13.2%) |
| 225 Cams | 167.670 TB (152.495 TiB)           | +34.84 TB (+20.8%) | 201.204 TB (182.994 TiB)           |  +1.30 TB ( +0.6%) |
| 250 Cams | 186.300 TB (169.439 TiB)           | +16.21 TB ( +8.7%) | 223.560 TB (203.327 TiB)           | -21.05 TB ( -9.4%) |
| 300 Cams | 223.560 TB (203.327 TiB)           | -21.05 TB ( -9.4%) | 268.272 TB (243.992 TiB)           | -65.76 TB (-24.5%) |
+----------+------------------------------------+--------------------+------------------------------------+--------------------+
```

### 5.1 Scenario Analysis Findings
1. **At 200 Cameras:** The 16 × 18 TB array comfortably supports 30 days of continuous recording under both Case A (+35.9% margin) and Case B (+13.2% margin).
2. **At 225 Cameras:** Case B reaches array saturation (+0.6% margin), leaving zero buffer for bitrate spikes. Case A retains a safe +20.8% headroom.
3. **At 250 Cameras:** Case A remains viable (+8.7% margin), but Case B requires additional drives.
4. **At 300 Cameras:** The single 16-drive array experiences severe storage deficit under all configurations (-9.4% to -24.5%). Scaling to 300 cameras requires a secondary 16-drive JBOD expansion chassis.

---

## 6. RAID-6 Degradation, Rebuild Dynamics & Hot-Spare Trade-Off

- **Fault Tolerance:** RAID-6 tolerates 2 concurrent drive failures without data loss.
- **Drive Rebuild Duration:** Rebuilding an 18 TB drive at a throttled $150\text{ MB/s}$ write rate requires $\approx 33.3\text{ hours}$. Because RAID-6 retains a second parity drive during rebuild, data remains protected against Unrecoverable Read Errors (URE).
- **Dedicated Hot-Spare Trade-off:** Allocating 1 dedicated hot spare (13 Data + 2 Parity + 1 Spare) reduces $C_{\text{avail}}$ to **$188.042\text{ TB decimal} (171.024\text{ TiB binary})$**. Under Case B at 200 cameras, this shrinks the surplus margin to $+9.19\text{ TB}$ (+5.1%). Maintaining **cold standby replacement drives on site** is the recommended baseline over burning an active drive slot as an idle hot spare.
