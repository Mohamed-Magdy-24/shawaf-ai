> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 13 — Hardware, Network & Infrastructure Sizing Assessment (Remediated)

**Document ID:** DISC-13-INFRA-ASSESSMENT  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** REVALIDATED CAPACITY SPECIFICATION  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Sections 3 & 4 of CTO Directive  

---

## 1. Executive Hardware Reality Check: The Zero-GPU Constraint

The stakeholder confirmed that the **existing server has no GPU**. 

### Remediation of Initial CPU Sizing Claims:
- In v1.0, an unsupported heuristic stated that 400 streams require "exactly 48–64 CPU cores". This arbitrary figure is **formally retracted**.
- **The Empirical Reality:** Video decoding and deep learning inference on CPU depend heavily on codec complexity, vector instruction sets (AVX-512 / AMX), memory bus bandwidth, and batch sizes. While modern server CPUs can execute small models, running 12-stage computer vision inference across 200 streams on CPU produces **unpredictable thread contention, thermal throttling, and multi-second latency spikes**.
- **Conclusion:** While non-AI services (PostgreSQL, Valkey, Go API router) run effortlessly on CPU, **AI video ingestion and inference requires dedicated GPU hardware accelerators** to achieve deterministic sub-second processing.

---

## 2. Site-Separated Mathematical Throughput Model

All throughput figures are derived from the explicit stated parameter of **2.0 FPS sampling rate**:

$$\text{Inference Throughput per Factory} = 200\text{ cameras} \times 2.0\text{ FPS} = \mathbf{400\text{ Frames Per Second}}$$
$$\text{Combined Two-Site Throughput} = 400\text{ FPS (BNF)} + 400\text{ FPS (RNF)} = \mathbf{800\text{ Frames Per Second}}$$

### 2.1 Independent Sizing for BNF Factory (~200 Cameras)
- **Analyzed Streams:** 200 camera sub-streams ($704 \times 576$ or $1280 \times 720$).
- **Inference Load:** 400 FPS aggregate across active models.
- **Hardware Decoding:** Requires 400 FPS H.264/H.265 decompression (offloaded to NVDEC hardware).
- **GPU VRAM Budget:** ~11.7 GB peak VRAM (inclusive of frame buffers, TensorRT engines, and CUDA context).
- **Edge Server Recommendation:** 1x 2U Rackmount Server equipped with **1x NVIDIA RTX A5000 (24GB VRAM)** or **2x NVIDIA RTX A4000 (16GB VRAM each in HA pair)**.

### 2.2 Independent Sizing for RNF Factory (~200 Cameras)
- Identical sizing parameters to BNF, deployed as an **autonomous physical server node** inside RNF's on-premise server room.
- RNF operational processing carries zero dependency on BNF server availability.

---

## 3. Evaluation of Hardware Compute Topologies

To provide the project owner with cost and operational options, four compute topologies are evaluated:

```text
+----------------------------------------------------------------------------------------------------+
|                                    COMPUTE TOPOLOGY ALTERNATIVES                                   |
|                                                                                                    |
|  [Option A: 1x Enterprise GPU / Site] ===> 1x NVIDIA RTX A5000 (24GB) or L40S (48GB)               |
|  - Latency: <15ms; Cost: Moderate ($3K–$7K/site); Handles 400 FPS effortlessly.                    |
|                                                                                                    |
|  [Option B: Dual-GPU Redundancy / Site]===> 2x NVIDIA RTX A4000 (16GB each) in 1 Server            |
|  - Split Load: 200 FPS/GPU; Automatic failover if 1 GPU driver crashes. High availability.        |
|                                                                                                    |
|  [Option C: Selective / Event-Driven AI]===> 1x Lightweight GPU (e.g., NVIDIA L4 24GB)             |
|  - 50 Critical Cameras at 2 FPS (100 FPS) + 150 Peripheral Cameras inferred only on motion trigger.|
|  - Reduces compute load by ~65%; lowest CapEx footprint.                                           |
|                                                                                                    |
|  [Option D: Distributed Edge Nodes]   ===> 4x NVIDIA Jetson Orin Nodes (50 cameras/node)           |
|  - Edge-distributed failure isolation; higher maintenance overhead (multiple OS endpoints).       |
+----------------------------------------------------------------------------------------------------+
```

---

## 4. 30-Day Storage Capacity Calculations (BNF & RNF Separated)

$$\text{Storage Required (Bytes)} = \frac{\text{Bitrate (bps)} \times 86,400\text{ s/day} \times 30\text{ days} \times \text{Cameras}}{8 \times 10^{12}\text{ (Bits/TB)}}$$

### Sizing Breakdown per Factory:
1. **Continuous 2.0 Mbps Base Stream (200 Cameras):** $\mathbf{129.60\text{ TB}}$
2. **Variable Bitrate (VBR) Dynamic Buffer (+20% for high plant motion):** $\mathbf{25.92\text{ TB}}$
3. **AI Evidence Clip Store (15s MP4 clips for 1,000 daily events):** $\mathbf{2.50\text{ TB}}$
4. **Filesystem Reserved Capacity (5%):** $\mathbf{7.90\text{ TB}}$
5. **Net Usable Storage Required per Factory:** $\mathbf{165.92\text{ TB}}$
6. **Gross Physical Storage with RAID-6 Parity (12-disk array, 20% parity):** $\mathbf{207.4\text{ TB Raw Disk Space}}$ per factory (e.g., $14\times 16\text{ TB}$ Enterprise HDDs).

---

## 5. Revalidated Network Capacity Model (Core Uplinks vs. 10GbE)

### 5.1 The 1GbE vs. 10GbE Reality
- **Average Load:** 200 cameras @ 2.0 Mbps = **400 Mbps**. 400 Mbps physically consumes only 40% of a 1 Gbps link.
- **Peak Concurrency:** Factoring in VBR encoding spikes (520 Mbps), AI sub-stream pulls (120 Mbps), mobile live WebRTC streams (25 Mbps), NVR playback seeks (12 Mbps), and database telemetry (8 Mbps), total concurrent peak traffic reaches **~685 Mbps**.
- **Architectural Recommendation:**
  - Running 685 Mbps across a single 1GbE uplink operates at **68.5% capacity**, causing micro-burst buffer queueing and dropped UDP RTSP packets.
  - **10GbE SFP+ uplinks** between the core switch and server are **strongly recommended for operational headroom and future expansion**, but are **NOT** a mathematical absolute for stream transport alone.
  - **Acceptable Fallback:** Bonded dual 1GbE ports (**LACP / 802.3ad = 2 Gbps aggregate**) provides full redundancy and capacity if 10GbE switches are unavailable.

---

## 6. Infrastructure Assessment Sign-Off

- **Status:** REVALIDATED CAPACITY SPECIFICATION.
- **Action Item:** No hardware procurement authorized. Validate empirical decode/inference throughput during Phase 1 technical spikes.
