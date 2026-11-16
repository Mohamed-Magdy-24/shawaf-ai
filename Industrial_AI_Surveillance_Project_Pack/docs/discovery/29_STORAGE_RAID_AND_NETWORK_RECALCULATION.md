# 29 — Storage RAID-6 Mathematical Derivation & Network Interface Topology Model

**Document ID:** DISC-29-STORAGE-NET  
**Version:** 1.1.0-canonical  
**Date:** 2026-11-11  
**Status:** CANONICAL ENGINEERING SIZING SPECIFICATION  
**Classification:** `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` (CTO Audit Remediation)  
**Traceability Reference:** CTO Directive — Phase 0 Final Consistency Gate, Sections 6 & 7, Document 37  

---

## 1. Executive Summary & Problem Resolution

Earlier architectural baselines contained two serious flaws:
1. **Conflicting Network Throughput Claims:** Conflicting estimates of 685 Mbps and 732 Mbps were cited as single-uplink traffic demands without separating the physical network paths, switches, or interfaces.
2. **Conflated Storage Sizing:** Sizing models mixed decimal and binary units and conflated raw array capacity with usable video capacity.

This document resolves these issues by:
- Establishing a per-interface, topology-aware network traffic model.
- Documenting LACP (802.3ad) flow hashing realities, link failover, and bandwidth limitations.
- Reconciling RAID-6 storage sizing with the first-principles mathematical model in [`./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md`](./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md).

---

## 2. Per-Interface Network Traffic Decomposition (Per Factory Site)

Summing all video, AI, and storage traffic into a single 685 Mbps or 732 Mbps uplink demand is an architectural error. In an industrial enterprise architecture, traffic is segmented across dedicated physical interfaces and VLANs:

```text
+-----------------------------------+--------------------+------------------------+------------------------------------+---------------------------------------+
| TRAFFIC PATH                      | SEGMENT / VLAN     | NOMINAL LOAD           | PEAK / BURST LOAD                  | PHYSICAL NETWORK INTERFACE ROUTING    |
+-----------------------------------+--------------------+------------------------+------------------------------------+---------------------------------------+
| 1. Cameras to NVRs                | VLAN 10 (CCTV LAN) | 400.0 Mbps (200 @ 2M)  | 500.0 Mbps (+25% VBR)              | Access Switch Backplane (Isolated)    |
| 2. NVRs/Cams to AI Workers        | VLAN 20 (AI Ingest)|  70.0 Mbps (200 @ 350k)| 105.0 Mbps (Burst 15 FPS sub)      | Server Dedicated Ingest NIC (eth1)    |
| 3. Continuous Video Storage Ingest| VLAN 30 (Storage)  | 400.0 Mbps             | 500.0 Mbps (+25% VBR)              | Storage Node Dedicated Ingest (eth2)  |
| 4. Client Live WebRTC Egress      | VLAN 40 (Mgmt/LAN) |  15.0 Mbps (6 @ 2.5M)  |  37.5 Mbps (15 concurrent clients) | Server Egress NIC (eth0)              |
| 5. Historical Timeline Playback   | VLAN 40 (Mgmt/LAN) |  16.0 Mbps (4 @ 4M)    |  40.0 Mbps (10 concurrent playback)| Storage Egress NIC (eth0)             |
| 6. Database & Broker Traffic      | Local Host Bridge  |   5.0 Mbps (IPC/TCP)   |  15.0 Mbps (Event spikes)          | Linux Loopback / Virtual Bridge       |
| 7. Offsite WAN Disaster Backup    | WAN Gateway Uplink |   0.0 Mbps (Daytime)   |  30.0 Mbps (Throttled Night Sync)  | Router WAN SFP Interface              |
+-----------------------------------+--------------------+------------------------+------------------------------------+---------------------------------------+
```

### 2.1 Critical Topology Insights
1. **Camera-to-NVR Isolation:** The 400–500 Mbps continuous video streams traverse the CCTV access switches directly into the NVRs. This traffic does **NOT** touch the AI server uplink.
2. **AI Server Ingestion:** The AI server ingests **sub-streams only** (360p @ 2–15 FPS), consuming only **70–105 Mbps** on its ingest interface (`eth1`).
3. **Single Uplink Fallacy:** The previous 685 Mbps and 732 Mbps figures represented the theoretical arithmetic sum of all flows across the entire factory plant, not the load on a single server port.

---

## 3. LACP (802.3ad) Link Aggregation & Flow Hashing Realities

Earlier documents suggested that bonding two 1 GbE links via LACP provides a single 2 Gbps pipe that easily absorbs peak loads.

**[NETWORKING REALITY CHECK]:**
1. **Flow Hashing Pinned to Single Link:** LACP uses a hashing algorithm (Layer 2 `Src/Dst MAC`, Layer 3 `Src/Dst IP`, or Layer 4 `Src/Dst Port`) to assign individual TCP/UDP flows to a physical member link.
   - An individual RTSP camera stream or WebRTC client playback session is **pinned to a single physical 1 Gbps link**.
   - A single flow can never exceed the physical bandwidth of one member link (1 Gbps).
2. **Hash Distribution Imbalance:** If 150 camera streams hash to Link 1 and only 50 streams hash to Link 2 due to IP address distribution, Link 1 can saturate and drop packets while Link 2 sits underutilized.
3. **Member Link Failure Degradation:** If 1 link of an LACP 2×1GbE bond fails, the total bandwidth instantly drops from 2 Gbps to 1 Gbps. If peak aggregate traffic on that bond exceeds 1 Gbps (e.g., during combined storage ingest and multiple playback sessions), buffer overruns and frame drops will occur.
4. **Engineering Recommendation:** 
   - Deploy **10GbE SFP+ uplinks** between the core switch and the central storage/AI server where available.
   - If restricted to 1 GbE interfaces, use **Layer 4 (IP + Port) hashing** (`xmit_hash_policy=layer3+4` in Linux bonding) to maximize entropy across camera streams.

---

## 4. Reconciled Storage Model (16 × 18 TB RAID-6)

Governed by the first-principles derivations in [`./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md`](./37_STORAGE_CAPACITY_RECALCULATION_WITH_FORMULAS.md):

```text
====================================================================================================
                        RECONCILED STORAGE CAPACITY PER FACTORY SITE
====================================================================================================
1. Raw Physical Drive Capacity (16 drives x 18 TB)       = 288.000 TB decimal (261.934 TiB binary)
2. RAID-6 Usable Data Capacity (14 data drives x 18 TB)  = 252.000 TB decimal (229.193 TiB binary)
3. Formatted Capacity (less 2.0% XFS metadata)           = 246.960 TB decimal (224.609 TiB binary)
4. Operational & Snapshot Reserves (18.0% of Formatted)  =  44.453 TB decimal ( 40.430 TiB binary)
5. Net Capacity Available for Retained Video             = 202.507 TB decimal (184.179 TiB binary)
----------------------------------------------------------------------------------------------------
Calculated 30-Day Demand (200 cameras, Main Stream VBR)  = 149.040 TB decimal (135.551 TiB binary)
Net Remaining Surplus Headroom                           = +53.467 TB decimal (+48.628 TiB / +35.9%)
====================================================================================================
```

### 4.1 Rebuild Dynamics Reality
- Rebuilding a failed 18 TB drive across 15 active drives under continuous write loads requires approximately **33 to 48 hours**.
- During this window, RAID-6 maintains full data protection via its second parity drive.
- Sizing provides sufficient headroom for camera growth up to 225–250 cameras, but fleet expansion to 300 cameras will require an external JBOD storage chassis.
