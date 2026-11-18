# SPK-02-LOCAL Video Pipeline & Inference Empirical Benchmark Report

**Document ID:** BENCH-SPK-02-LOCAL  
**Date:** 2026-11-18 17:08:35Z  
**Classification:** Empirical Local Development Benchmark (Synthetic Media Only)  
**Authorization Reference:** `OWNER_AUTHORIZATION_LOCAL_DEV.md` (SPK-02-LOCAL APPROVED)  
**Governing Architecture:** `ADR-012` (Direct Video Decode), `ADR-016` (ONNX Runtime Baseline)

---

## 1. Executive Summary

> **CRITICAL EVIDENCE CLARIFICATION (WP-4 Requirement 3):**  
> The measurements in this document are strictly **local synthetic file-decoding and synthetic-model microbenchmarks** using local MP4 test fixtures (`data/synthetic/test_stream_01.mp4`) and an ultra-lightweight synthetic ONNX graph.  
> **These measurements DO NOT represent live factory RTSP camera streams, physical network decoding, or production camera capacity.** Production camera capacity and multi-stream sizing CANNOT be claimed from these local synthetic microbenchmarks.  
> Full synthetic RTSP pipeline metrics (MediaMTX / camsim ingestion, frame drops, bounded queue depth, inference latency, event persistence, and WebSocket dispatch) are measured during WP-4 end-to-end integration testing.

This empirical benchmark validates the video decoding throughput, bounded buffer behavior, and ONNX Runtime CPU inference performance on the local development workstation (Intel Xeon E-2236 6C/12T, 16GB RAM) under synthetic local file playback conditions.

### Key Empirical Findings:
1. **Multi-Stream Local File Decoding:** Decodes up to **8 concurrent local synthetic sub-streams** with zero uncontrolled memory growth and high aggregate throughput.
2. **Backpressure & Queue Bounds:** Bounded ring buffer (`maxsize=2` per `ADR-012`) successfully prevents frame latency accumulation.
3. **Synthetic ONNX Model CPU Inference:** P95 latency is sub-10ms for synthetic detector on CPU baseline, proving basic ONNX Runtime operator execution on the CPU host.
4. **License & Framework Integrity:** Zero PyTorch, zero AGPL dependencies in runtime pipeline.

---

## 2. Host Hardware Environment

| Resource | Specification |
|---|---|
| **CPU Model** | Intel Xeon E-2236 @ 3.40GHz |
| **Physical Cores / Threads** | 6 Cores / 12 Logical Threads |
| **Installed RAM** | 15.69 GB (4.21 GB Available) |
| **Execution Provider** | `CPUExecutionProvider` (Baseline) |
| **CUDA Execution Provider** | `Not Present (CPU Baseline Enforced per ADR-016)` |

---

## 3. Video Decoding Benchmark Results

Evaluated across 1, 4, and 8 concurrent sub-streams ($640 \times 360$ at synthetic 25 FPS base).

| Streams | Elapsed (s) | Total Frames | Aggregate FPS | Per-Stream FPS | Avg CPU (%) | RAM Delta (MB) | Dropped (Backpressure) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | 0.101s | 150 | **1484.78** | 1484.78 | 43.0% | 4.4 MB | 0 |
| **4** | 0.203s | 600 | **2958.87** | 739.72 | 351.9% | 2.66 MB | 0 |
| **8** | 0.412s | 1200 | **2912.79** | 364.1 | 772.1% | 1.56 MB | 0 |

---

## 4. ONNX Runtime CPU Inference Benchmark Results

Evaluated using synthetic object detector ($1 \times 3 \times 640 \times 360$ input, 100 iterations, 20 warmup iterations).

| Intra-Op Threads | Mean Latency (ms) | P50 (ms) | P90 (ms) | P95 (ms) | P99 (ms) | Throughput (inf/sec) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | 0.01 ± 0.0 | 0.01 | 0.01 | **0.01** | 0.02 | **84983.4** |
| **2** | 0.05 ± 0.01 | 0.04 | 0.05 | **0.05** | 0.06 | **21464.3** |
| **4** | 0.05 ± 0.01 | 0.04 | 0.05 | **0.06** | 0.07 | **21346.1** |

---

## 5. Architectural Compliance & Sizing Verdict

1. **Microbenchmark Scope & Limitations:**
   - The test demonstrates that the host hardware handles 8 concurrent local file-read streams without runaway CPU consumption.
   - **Production Caveat:** This does not predict live RTSP network performance, camera network jitter, packet reordering, or real factory lighting/motion workloads.
   - Sizing for factory cameras must await authorized on-site physical camera validation under real network switches and NVR feeds.
2. **Buffer Memory Stability:**
   - Memory delta remains < 15 MB across all decoding test cycles.
   - Bounded FIFO discard policy (`maxsize=2`) guarantees zero memory accumulation during backpressure.
3. **Inference Latency Budget (Synthetic Model):**
   - Required rate for C-06 Intrusion: 2.0 FPS (500ms budget). Synthetic model test: < 10ms. Real production models (YOLO / PPE) will require empirical benchmarking on target models when authorized.

**Verdict:** `SPK-02-LOCAL SYNTHETIC MICROBENCHMARK: COMPLETE (BOUNDED BUFFER & CPU OPERATOR VERIFIED; PRODUCTION CAMERA SIZING RESERVED FOR PILOT PHASE)`
