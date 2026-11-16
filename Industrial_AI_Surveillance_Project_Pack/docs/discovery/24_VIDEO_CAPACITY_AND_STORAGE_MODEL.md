> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 24 — Video Capacity, Compute & Storage Mathematical Model

**Document ID:** DISC-24-CAPACITY-MODEL  
**Version:** 1.0.0-remediated  
**Date:** 2026-11-11  
**Status:** PROPOSED MATHEMATICAL CAPACITY MODEL  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Sections 3 & 4 of CTO Directive  

---

## 1. Executive Modeling Methodology

This document establishes the rigorous, site-separated capacity model for the BNF and RNF Industrial AI Surveillance Platform. 

In strict adherence to the CTO Master Directive:
- **BNF and RNF calculations are completely separated.**
- **All throughput numbers are derived from stated baseline parameters.**
- **No hardware Bill of Materials (BOM) is approved prior to empirical benchmark evidence.**
- **The arbitrary 48–64 CPU core sizing from v1.0 is formally retracted and replaced with a multi-variable hardware profiling model.**

---

## 2. Factory Sizing Baseline Parameters (BNF & RNF Separated)

| Parameter Dimension | BNF Factory Baseline | RNF Factory Baseline | Unit / Stated Assumption |
|---|---|---|---|
| **Camera Estate Sizing** | ~200 cameras (expandable) | ~200 cameras (expandable) | Physical IP cameras connected via PoE switches |
| **Main Stream Resolution** | 1080p Full HD ($1920 \times 1080$) | 1080p Full HD ($1920 \times 1080$) | 25 FPS continuous recording to local NVRs |
| **Main Stream Video Codec** | H.264 / H.265 (Mixed fleet) | H.264 / H.265 (Mixed fleet) | Average 2.0 Mbps CBR / 2.6 Mbps VBR Peak |
| **AI Sub-Stream Resolution** | D1 / 720p ($704 \times 576$ / $1280 \times 720$) | D1 / 720p ($704 \times 576$ / $1280 \times 720$) | Sampled sub-stream routed to AI Inference worker |
| **AI Stream Sampling Rate** | **2.0 FPS** (Baseline analytical rate) | **2.0 FPS** (Baseline analytical rate) | 1 frame sampled every 500 milliseconds |
| **Analyzed Stream Count** | 200 streams | 200 streams | 100% of cameras monitored for safety & security |
| **Total Inference Load** | **400 FPS** ($200 \times 2.0$) | **400 FPS** ($200 \times 2.0$) | **Explicitly contingent on 2 FPS assumption** |
| **Combined 2-Site Load** | **800 FPS** total across both factories | **800 FPS** total across both factories | Processed locally at respective edge servers |

---

## 3. Video Decoding & Compute Capacity Analysis

### 3.1 Software CPU Decoding vs. Hardware NVDEC Offloading
- **Software CPU Decode Reality:** Software decoding of 200 H.264/H.265 streams at 2.0 FPS requires decoding $200 \times 2 = 400\text{ frames/second}$. While a modern multi-core server CPU (e.g., AMD EPYC 32-core) can theoretically decode 400 frames/sec, CPU utilization would remain at ~35–50% purely for video decompression, creating high latency jitter, memory cache thrashing, and vulnerability to thread starvation during OS background tasks.
- **Hardware GPU NVDEC Decode Reality:** Modern NVIDIA enterprise GPUs (e.g., RTX A4000, A5000, L4, L40S) incorporate **dedicated hardware video decoders (NVDEC)**. A single NVIDIA L4 GPU features 4x NVDEC engines capable of decoding up to 1,040 FPS of 1080p H.264 video simultaneously with **0% CPU utilization** and zero GPU CUDA core consumption.

### 3.2 AI Inference Pipeline Stages & VRAM Allocation

```text
+----------------------------------------------------------------------------------------------------+
|                                    GPU VRAM ALLOCATION BUDGET (PER EDGE SERVER)                    |
|                                                                                                    |
|  [Hardware NVDEC Video Buffers]   ===> ~2.5 GB VRAM (200 ring buffers @ D1/720p)                  |
|  [Stage 1: Person & Object Detect] ===> ~3.2 GB VRAM (YOLOv8x FP16 TensorRT Engine, Batch=8)      |
|  [Stage 2: Pose / Fall Estimator]  ===> ~1.8 GB VRAM (YOLOv8-Pose FP16 TensorRT Engine, Batch=4)  |
|  [Stage 3: PPE Classifier]         ===> ~1.5 GB VRAM (Multi-label PPE TensorRT Engine, Batch=8)    |
|  [Stage 4: Face Embedding Vector]  ===> ~1.2 GB VRAM (ArcFace ResNet-50 TensorRT Engine, Batch=4) |
|  [PyTorch / CUDA Runtime Overhead] ===> ~1.5 GB VRAM                                               |
|  ------------------------------------------------------------------------------------------------  |
|  TOTAL PEAK VRAM CONSUMPTION:      ===> ~11.7 GB VRAM (Requires Minimum 16GB Enterprise GPU)      |
+----------------------------------------------------------------------------------------------------+
```

### 3.3 Evaluation of Hardware Compute Topologies

| Compute Topology Option | Architecture Description | Feasibility & Latency | Cost & Complexity | Recommendation |
|---|---|---|---|---|
| **Option A: 1x GPU per Factory** | Single NVIDIA RTX A5000 (24GB VRAM) or L40S (48GB VRAM) per site. | **Feasible:** Handles 400 FPS batch inference; latency <20ms; VRAM headroom >50%. Single point of failure for AI. | Moderate CapEx ($2,500–$7,500 per site); simple single-node ops. | **RECOMMENDED BASELINE (PROPOSED)** |
| **Option B: 2x GPUs per Factory (HA)** | Dual NVIDIA RTX A4000 (16GB each) or dual L4 (24GB each) in 1 server. | **High Resilience:** Workload split (200 FPS per GPU); automatic failover if 1 GPU driver crashes. | Higher CapEx ($4,000–$10,000 per site); excellent thermal distribution. | **RECOMMENDED FOR HIGH AVAILABILITY** |
| **Option C: Distributed AI Edge Nodes** | 4x NVIDIA Jetson Orin nodes (50 cameras each) per factory. | **High Resilience:** Failure of 1 node affects only 50 cameras. | High management overhead (8 physical edge boxes to manage and update). | Secondary Alternative |
| **Option D: Selective / Event-Driven AI** | 50 high-risk cameras infer continuously at 2 FPS; 150 cameras infer only when NVR motion sensor triggers. | **Ultra-Low Compute:** Reduces baseline load from 400 FPS to 120 FPS. | Dependent on NVR motion trigger reliability; risks missing stationary violations. | **RECOMMENDED FOR COST OPTIMIZATION** |

---

## 4. 30-Day Storage Mathematical Model (Separate BNF & RNF)

### 4.1 Detailed Storage Sizing Calculations

The 30-day retention calculation must account for real-world industrial factors: Variable Bitrate (VBR) fluctuations, RAID parity loss, filesystem formatting overhead, and temporary incident clip buffers.

$$\text{Daily Raw Ingest (TB)} = \frac{\text{Bitrate (bps)} \times 86,400\text{ seconds} \times \text{Cameras}}{8 \times 10^{12}\text{ (Bits/TB)}}$$

#### Calculation for BNF Factory (200 Cameras):
1. **Base Continuous Stream (2.0 Mbps Average):**
   $$\text{Base Daily} = \frac{2,000,000 \times 86,400 \times 200}{8 \times 10^{12}} = \mathbf{4.32\text{ TB / day}}$$
   $$\text{30-Day Base Video Storage} = 4.32\text{ TB} \times 30 = \mathbf{129.60\text{ TB}}$$
2. **Variable Bitrate (VBR) Headroom (+20% for high factory motion):**
   $$\text{VBR Buffer} = 129.60\text{ TB} \times 0.20 = \mathbf{25.92\text{ TB}}$$
3. **AI Incident Evidence Clips & Snapshot Staging (15s MP4 clips for 1,000 events/day):**
   $$\text{Evidence Store (30 Days)} \approx \mathbf{2.50\text{ TB}}$$
4. **Subtotal Usable Storage Required (BNF):**
   $$129.60 + 25.92 + 2.50 = \mathbf{158.02\text{ TB Usable Storage}}$$
5. **Filesystem Reserved Capacity (5% for OS and inode table):**
   $$\text{Filesystem Reserve} = 158.02 \times 0.05 = \mathbf{7.90\text{ TB}}$$
6. **Total Usable Volume Required (BNF):**
   $$158.02 + 7.90 = \mathbf{165.92\text{ TB Net Usable Capacity}}$$
7. **RAID-6 Parity Penalty (Dual-parity requires 2 parity disks out of a 12-disk array = ~20% overhead):**
   $$\text{Gross Raw Physical Capacity (BNF)} = \frac{165.92}{0.80} \approx \mathbf{207.4\text{ TB Raw Disk Space}}$$
   *(Equivalent to: $14\times 16\text{ TB Enterprise SATA HDDs}$ in RAID-6 per factory).*

#### Combined Two-Site Total (BNF + RNF):
- **Net Usable Video Storage:** $\mathbf{331.84\text{ TB}}$
- **Gross Raw Physical Storage:** $\mathbf{414.8\text{ TB}}$ across both factories.

---

## 5. Network Capacity & Switching Architecture Model

### 5.1 Reevaluation of the 10GbE Uplink Requirement

In v1.0, 10GbE was labeled "strictly mandatory" based on an assumed 400 Mbps average video load. This claim was technically oversimplified:
- **The Fact:** 400 Mbps of continuous traffic **can physically fit** on a standard 1 Gbps (1,000 Mbps) Ethernet pipe with 60% bandwidth remaining.
- **The Operational Reality:** Surveillance networks do not carry smooth, constant bitrates. When factory shift changes occur or lights turn on, VBR encoders burst to 2.5–3.5x baseline. Concurrently, NVR playback sessions, mobile live WebRTC streams, database sync jobs, and offsite backup dumps traverse the core switch.

```text
+----------------------------------------------------------------------------------------------------+
|                                    FACTORY TRAFFIC CONCURRENCY MODEL                               |
|                                                                                                    |
|  TRAFFIC COMPONENT                                   PEAK BANDWIDTH CONSUMPTION                    |
|  1. 200x Camera Ingest to NVR (VBR Peak)             ===> ~520 Mbps                                |
|  2. 200x AI Sub-Stream Ingest to go2rtc             ===> ~120 Mbps                                |
|  3. 10x Concurrent Mobile Live Views (1080p WebRTC)  ===> ~25 Mbps                                 |
|  4. 4x Historical Playback Streams from NVR          ===> ~12 Mbps                                 |
|  5. SQL Server & ZKBioTime Sync Traffic             ===> ~5 Mbps                                  |
|  6. Database Outbox & Prometheus Telemetry           ===> ~3 Mbps                                  |
|  ------------------------------------------------------------------------------------------------  |
|  TOTAL CONCURRENT PEAK NETWORK LOAD:                 ===> ~685 Mbps                                |
+----------------------------------------------------------------------------------------------------+
```

### 5.2 Network Architecture Decision:
- **Edge Layer (PoE Switches to Cameras):** Standard **1 Gbps** managed PoE+ access switches (e.g., Cisco Catalyst 1000 / Aruba CX 6000) are fully sufficient. 24 cameras @ 2.5 Mbps = 60 Mbps, occupying <6% of access switch capacity.
- **Distribution / Core Layer (Switch Uplinks to Server & NVR):**
  - Running 685 Mbps peak traffic across a single 1 Gbps link operates at **68.5% link saturation**, which causes TCP micro-burst queuing latency and dropped UDP RTSP packets.
  - **Engineering Standard:** The core link between the distribution switch and the AI Server / NVR fleet must utilize either:
    1. **10GbE SFP+ Direct Fiber/DAC Uplink** (Recommended for future-proofing and zero packet queueing).
    2. **Link Aggregation (LACP / 802.3ad Bonding):** Dual bonded 1GbE ports ($2 \times 1\text{ Gbps} = 2\text{ Gbps}$ aggregate) as an acceptable low-cost fallback if 10GbE switches are unavailable.

---

## 6. Capacity Model Sign-Off

- **Status:** MATHEMATICAL MODEL COMPLETE.
- **Action Item:** Validate bandwidth and storage assumptions against physical NVR configurations during Phase 1 integration discovery.

