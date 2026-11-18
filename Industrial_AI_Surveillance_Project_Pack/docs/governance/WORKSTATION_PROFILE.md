# Workstation Profile & Hardware Baseline

Date: 2026-11-18 · Status: EMPIRICALLY MEASURED IN WP-2

## 1. Workstation Hardware Profile (Empirically Measured 2026-11-18)

| Parameter | Specification | Provenance / Measurement Command |
|---|---|---|
| Operating System | Windows 10 Pro 64-bit (Build 19045) | `MEASURED: Get-CimInstance Win32_OperatingSystem (2026-11-18)` |
| CPU Processor | Intel Xeon E-2236 @ 3.40 GHz (Coffee Lake) | `MEASURED: Get-CimInstance Win32_Processor (2026-11-18)` |
| Core Topology | 6 Physical Cores / 12 Logical Threads | `MEASURED: NumberOfCores=6, NumberOfLogicalProcessors=12` |
| Hardware Extensions | Intel VT-x (Active), AVX2, FMA3 | `MEASURED: CPU extensions verified` |
| Total System RAM | 15.69 GB (16,450,168 KB Physical RAM) | `MEASURED: Get-CimInstance Win32_OperatingSystem (2026-11-18)` |
| Available System RAM | 9.37 GB Free Physical RAM at measurement | `MEASURED: FreePhysicalMemory=9,824,000 KB (2026-11-18)` |
| Dedicated GPU Model | NVIDIA Quadro P600 (Pascal GP107GL, 384 CUDA cores) | `MEASURED: nvidia-smi (2026-11-18)` |
| GPU VRAM Capacity | 4,096 MiB Total GDDR5 (369 MiB used, 3,727 MiB free) | `MEASURED: nvidia-smi 552.55 (2026-11-18)` |
| GPU Compute Capability | SM 6.1 (Pascal Architecture) | `MEASURED: Quadro P600 Pascal SM 6.1` |
| NVIDIA Driver Version | 552.55 (CUDA Version: 12.4) | `MEASURED: nvidia-smi (2026-11-18)` |
| Drive C: (System SSD) | 27.80 GB Free (Total: 237.51 GB) | `MEASURED: Get-PSDrive (2026-11-18)` |
| Drive D: (Data Drive) | 657.60 GB Free (Total: 931.51 GB) | `MEASURED: Get-PSDrive (2026-11-18)` |
| Virtualization Engine | Docker Desktop / Engine 29.8.0, build 88096ef | `MEASURED: docker --version (2026-11-18)` |
| Installed Toolchains | Python 3.14.4, Flutter 3.44.7 (Dart 3.12.2), Git 2.45+ | `MEASURED: python --version; flutter --version (2026-11-18)` |
| Missing on Host PATH | Go Toolchain (`go` executable not in host PATH) | `MEASURED: go version -> CommandNotFoundException` |

## 2. Resource footprints

Filled by WP-2/WP-3 with MEASURED values; no estimates allowed here.
