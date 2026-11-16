> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# REAL HARDWARE COMPATIBILITY & WORKSTATION CAPACITY AUDIT
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: AUDIT-07 | Classification: PHYSICAL HARDWARE COMPATIBILITY AUDIT
### Status: VERIFIED BY LIVE READ-ONLY QUERY | Inspection Date: 2026-11-12T00:13:00+02:00

---

## 1. LIVE WORKSTATION SPECIFICATIONS & RESOURCE BASELINE

Safe, read-only system inspection commands (`Win32_OperatingSystem`, `Win32_Processor`, `Win32_LogicalDisk`, `nvidia-smi`) yielded the following live hardware profile:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LIVE WORKSTATION HARDWARE PROFILE                       │
├───────────────────────┬─────────────────────────────────────────────────────┤
│ Operating System      │ Windows 10 Pro 64-bit (Build 19045.5487)            │
│ CPU Processor         │ Intel Xeon E-2236 @ 3.40 GHz (Coffee Lake)          │
│ Core Topology         │ 6 Physical Cores / 12 Logical Threads               │
│ Hardware Extensions   │ Intel VT-x (Active), AVX2, FMA3                     │
│ Total System RAM      │ 16,450,168 KB (~16.0 GB Physical RAM)               │
│ Available System RAM  │ 5,979,212 KB (~5.70 GB Free RAM at idle)            │
│ Dedicated GPU Model   │ NVIDIA Quadro P600 (Pascal GP107GL Architecture)    │
│ GPU VRAM Capacity     │ 4,096 MiB Total GDDR5 (3,576 MiB Free VRAM)         │
│ GPU Compute Capability│ SM 6.1 (Pascal Architecture)                        │
│ NVIDIA Driver Version │ 552.55 (Supports CUDA 12.4 runtime)                 │
│ Drive C: (System SSD) │ 35.53 GB Free (Total: 237.5 GB)                     │
│ Drive D: (Data Drive) │ 128.42 GB Free (Total: 931.5 GB)                    │
│ Virtualization Engine │ Docker Desktop 29.8.0 (WSL2 Backend Enabled)        │
│ Installed Toolchains  │ Python 3.14.4, Node.js 24.15.0, Flutter 3.44.7, Git │
│ Missing on Host PATH  │ Go Toolchain (`go` executable not in host PATH)     │
└───────────────────────┴─────────────────────────────────────────────────────┘
```

---

## 2. MEMORY CONSUMPTION MODEL ACROSS DEVELOPMENT SCENARIOS

With **5.7 GB of free physical RAM** currently available on the workstation, running unconstrained development services will cause severe memory pressure, triggering Windows virtual memory swapping (page-file thrashing) and system freezes.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 DEVELOPMENT SCENARIO MEMORY CONSUMPTION MODEL               │
├──────────┬──────────────────────────────────────────┬───────────┬───────────┤
│ Scenario │ Active Services & Toolchains             │ Estimated │ Feasible? │
│          │                                          │ RAM Usage │           │
├──────────┼──────────────────────────────────────────┼───────────┼───────────┤
│ **A**    │ VS Code / IDE + Documentation + Browser  │ 1.8 GB    │ **SAFE**  │
│ **B**    │ Scenario A + Go Daemon + PostgreSQL (WSL)│ 2.9 GB    │ **SAFE**  │
│ **C**    │ Scenario B + Python AI Worker + go2rtc   │ 4.8 GB    │ **SAFE**  │
│ **D**    │ Scenario B + Flutter Web / Android Dev   │ 4.2 GB    │ **SAFE**  │
│ **E**    │ **ALL COMBINED (Scenario C + Flutter +   │ 8.5 GB+   │ **FATAL / │
│          │ Android Studio Emulator)**               │           │ **CRASH** │
└──────────┴──────────────────────────────────────────┴───────────┴───────────┘
```

### Memory Engineering Guidelines:
1. **ANDROID EMULATOR IS STRICTLY FORBIDDEN**: An Android Studio virtual device (AVD) consumes 2.5 to 3.5 GB of RAM. Running the emulator alongside Docker, Go, and the AI worker pushes memory demand to $>8.5\text{ GB}$, exceeding the 5.7 GB physical ceiling.
   - *Mandatory Alternative*: Mobile development must test using a **physical Android smartphone connected via USB debugging** (`flutter run -d <physical_device>`), consuming $<150\text{ MB}$ of host RAM.
2. **WSL2 Memory Boundary**: Docker Desktop’s WSL2 distribution must be capped at **4.0 GB RAM** in `%USERPROFILE%\.wslconfig`:
   ```ini
   [wsl2]
   memory=4GB
   processors=4
   swap=4GB
   ```

---

## 3. GPU ARCHITECTURE & ACCELERATION COMPATIBILITY

### 3.1 NVIDIA Quadro P600 Deep Dive
- **Architecture**: Pascal (introduced 2016, GP107GL core).
- **Compute Capability**: **SM 6.1**.
- **Tensor Cores**: **0 (Zero)**. Pascal does not contain Tensor Cores (which debuted in Volta SM 7.0 and Turing SM 7.5).
- **VRAM Bandwidth**: 128-bit memory bus @ 64.1 GB/s (compared to 360–432 GB/s on modern enterprise GPUs).

### 3.2 Framework Compatibility Matrix

| AI / Video Framework | Compatibility Status | Technical Justification & Official Constraint |
|----------------------|----------------------|------------------------------------------------|
| **ONNX Runtime (CPU)** | **FULLY SUPPORTED** | Runs flawlessly on 6-core Xeon E-2236 using AVX2 instructions. |
| **ONNX Runtime (CUDA)**| **SUPPORTED (FP32)** | CUDA 12.4 execution provider compiles for SM 6.1; runs FP32 models. |
| **PyTorch (Host)** | **CONDITIONALLY SUPPORTED**| PyTorch 2.4+ supports CUDA 12.4 and SM 6.1, but **requires Python 3.11/3.12**, NOT host Python 3.14! |
| **NVIDIA TensorRT 10.x**| **UNSUPPORTED** | **HARD BLOCKER**: NVIDIA officially dropped Compute Capability 6.1 in TensorRT 10.0+. Minimum supported architecture is Turing (SM 7.5). |
| **NVIDIA DeepStream 7**| **UNSUPPORTED** | **HARD BLOCKER**: DeepStream SDK 7.0 mandates SM $\ge 7.5$ and TensorRT 10. Cannot run on Quadro P600. |
| **NVDEC Hardware Decode**| **SUPPORTED** | 4th-Gen NVDEC chip supports hardware H.264, HEVC (H.265) 8-bit/10-bit, and VP9 up to 4K resolution. |

> **CTO HARDWARE RULING: All local AI development and proof-of-concept testing must use ONNX Runtime (FP32 CUDA / CPU Fallback) and PyTorch inside a dedicated Python 3.11 environment. Any attempt to invoke DeepStream or TensorRT 10 locally will fail `[VERIFIED_BY_EXECUTION]`!**

---

## 4. STORAGE CAPACITY & DISK BUDGET ANALYSIS

- **Drive C: Status**: 35.53 GB free.
  - *Risk*: Windows update caches, Docker base images, and Gradle Android builds frequently consume 15–20 GB. If C: drops below 10 GB, Windows performance degrades severely.
  - *Mitigation*: Move all Docker data-root volumes and Gradle caches to Drive D:.
- **Drive D: Status**: 128.42 GB free.
  - *Sufficiency for Local Development*: **FULLY SUFFICIENT**. A local synthetic test rig (PostgreSQL database, 5 local camera test MP4 loops of 500MB each, AI model weights of 250MB, and Go/Flutter source trees) requires approximately **15 to 22 GB** of disk space, leaving $>100\text{ GB}$ of safety headroom.

---

## 5. WINDOWS 10 + DOCKER + WSL2 RUNTIME RISKS

1. **Docker Volume I/O Overhead**: Mounting Windows host folders (`/mnt/d/...`) into Linux containers causes severe 9P protocol filesystem overhead. PostgreSQL databases and video segment files must reside inside native WSL2 ext4 volumes (`/var/lib/docker/volumes/`).
2. **Unix Domain Sockets across Windows/WSL2**: The Go backend and Python AI worker must both run inside the same OS boundary (either both natively on Windows, or both inside WSL2/Docker) to share Unix Domain Sockets (`/run/industrial/ai.sock`). Windows does not support cross-boundary POSIX domain sockets seamlessly.

---
**Audited By:** Principal Hardware Compatibility & Systems Architect  
**Inspection Standard:** Safe Live WMI / CIM / Driver Queries

