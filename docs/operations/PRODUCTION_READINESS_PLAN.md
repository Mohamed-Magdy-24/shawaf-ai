# PRODUCTION READINESS PLAN
## Industrial AI Surveillance Platform — BNF / RNF
**Document Classification:** Authoritative Factory Commissioning, Operational Runbooks & Disaster Recovery Plan  
**Phase:** Phase 0 — Complete Project Assessment  
**Author:** Antigravity — Principal AI Engineer & Production Operations Lead  
**Governing Standard:** Section 21 & Section 28 of Ultimate Master Directive (`Prompt.md`)  
**Date:** 2026-11-18  

---

## 1. Production Scope & Factory Infrastructure Topology

The Industrial AI Surveillance Platform is an on-premises, mission-critical safety intelligence system deployed across two independent manufacturing plants in Egypt:
- **BNF Facility:** Heavy manufacturing plant (Beni Suef), ~200+ IP cameras, local NVR fleet, local ZKTeco attendance terminals, local SQL Server staging instance.
- **RNF Facility:** Processing plant (Sadat City), ~200+ IP cameras, local NVR fleet, local ZKTeco attendance terminals, local SQL Server staging instance.

### 1.1 Air-Gapped Factory Autonomy (D-001)
Each factory operates as a **self-contained, autonomous failure domain**. 
- In the event of central WAN or internet disruption, local camera ingestion, AI safety inference, local database recording, local outbox queuing, and on-premises security desk alerting continue without degradation.
- Synchronization of executive summaries and remote management access occurs opportunistically over an encrypted point-to-point WireGuard VPN tunnel when connectivity is restored.

---

## 2. Infrastructure Sizing & Hardware Bill of Materials (BOM)

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ PRODUCTION HARDWARE SIZING PER FACTORY (BNF & RNF INDEPENDENT RACK UNITS)                              │
├────────────────────┬───────────────────────────────────────────┬───────────────────────────────────────┤
│ Component          │ Minimum Production Specification          │ Technical Purpose & Headroom Sizing   │
├────────────────────┼───────────────────────────────────────────┼───────────────────────────────────────┤
│ Server Chassis     │ 2U Rackmount Industrial Server            │ Redundant power supplies (Dual 800W), │
│                    │                                           │ dust-filtered high-CFM chassis fans.  │
│ Processor (CPU)    │ Dual AMD EPYC 7302 (32 Cores, 64 Threads) │ Video sub-stream demuxing, Go daemon, │
│                    │ or Intel Xeon Silver 4314 (32 Threads)    │ PostgreSQL RLS, OS background tasks.  │
│ System Memory      │ 64 GB DDR4-3200 ECC Registered RAM        │ 24 GB OS/Postgres, 24 GB AI workers,  │
│                    │ (Expandable to 128 GB)                    │ 16 GB buffer cache headroom.          │
│ GPU Acceleration   │ Dual NVIDIA RTX 4000 Ada (20 GB VRAM each)│ Sustained multi-camera AI inference   │
│                    │ (or single NVIDIA L4 24 GB PCIe)          │ across 200 sub-streams @ 1-2 FPS.     │
│ Storage (OS & DB)  │ 2× 960 GB Enterprise SATA/NVMe SSD (RAID1)│ OS, PostgreSQL 16 WAL & database.     │
│ Storage (Evidence) │ 2× 3.84 TB Enterprise NVMe U.2 SSD (RAID1)│ Event snapshots, 30s incident clips,  │
│                    │                                           │ 90-day evidence retention watermark.  │
│ Network Interfaces │ 2× 10GbE SFP+ + 4× 1GbE RJ45 (Intel X520) │ LACP bonded link to factory core      │
│                    │                                           │ switch; isolated CCTV VLAN subnet.    │
│ Out-of-Band Mgmt   │ IPMI 2.0 / iDRAC9 / iLO 5 (Dedicated NIC) │ Remote power cycling, hardware health,│
│                    │                                           │ headless BIOS diagnostics.            │
└────────────────────┴───────────────────────────────────────────┴───────────────────────────────────────┘
```

> **Mandatory Procurement Note (`OQ-011`):** Existing factory servers have zero GPU compute. Server hardware procurement remains strictly blocked pending owner budget authorization. Local development and benchmarking (`WP-1` through `WP-6`) utilize the owner's workstation (Quadro P600) on 4–8 simulated cameras.

---

## 3. Operational Reliability, High Availability & Degraded Modes

### 3.1 Failure Domain Matrix & Self-Healing Behaviors

| Subsystem Component | Failure Scenario | Automated Self-Healing & Degraded Mode Behavior |
|---|---|---|
| **Camera RTSP Stream** | Physical camera power cut or network drop | `py-worker` detects socket drop within 2s; initiates exponential backoff reconnect (1s, 2s, 4s, 8s, max 30s). After 15s of silence, Go triggers `NFR-OBS-002` Coverage Lost alert to security console. |
| **Python AI Worker** | Process crash, segmentation fault, or OOM kill | Docker Engine restart policy (`restart: unless-stopped`) boots clean container within 5s. In-flight gRPC calls return error; Go retains event metadata and retries. |
| **Backend Go Daemon** | Kernel kill (`SIGKILL`) or power surge | Systemd / Docker restarts `edged`. Lease reaper automatically queries `outbox` table for rows where `status = 'PROCESSING' AND locked_until < NOW()`. Re-queues orphaned batches. Zero alert duplication. |
| **PostgreSQL Database** | Storage IO stall or crash | PostgreSQL WAL crash recovery automatically replays uncommitted transactions on reboot. Go connection pool retries with backoff. |
| **WAN / VPN Tunnel** | Telco internet failure / WireGuard drop | Local factory operation continues 100% autonomously. Local camera recording, AI detection, outbox queueing, and on-premises security desk alerting continue uninterrupted. Cross-site sync pauses until tunnel re-establishes. |
| **NVMe SSD Storage** | Disk utilization reaches 85% high-watermark | Automated cron storage reaper executes `/scripts/prune_old_snapshots.sh`, deleting oldest non-flagged JPEG snapshots until disk utilization drops below 75%. Flagged investigation evidence packages are pinned and never pruned. |

---

## 4. Disaster Recovery & Automated Backup Procedures

### 4.1 Backup Cadence & Retention Schedule
- **Database Metadata (PostgreSQL 16):**
  - Continuous Write-Ahead Log (WAL) archiving via `pg_receivewal` to secondary local SSD.
  - Daily full database backup (`pg_dump -Fc`) at **02:00 Africa/Cairo**.
  - Local retention: 30 daily snapshots on local NAS.
  - Off-site synchronization: Daily encrypted backup synced to opposite factory (BNF syncs to RNF; RNF syncs to BNF) over WireGuard tunnel during off-peak hours (03:30 Cairo).
- **Incident Snapshots & Evidence Clips:**
  - Preserved locally on RAID-1 NVMe SSD for 90 days.
  - Flagged legal/safety incident packages are retained indefinitely or until manually cleared by plant manager.

### 4.2 Disaster Recovery Verification Protocol (Recovery Time Objective < 15 Minutes)
Every 30 days, an automated DR restoration drill is executed against a staging container:
```bash
# 1. Terminate current test container and delete volume
docker stop postgres_restore_test && docker rm postgres_restore_test

# 2. Re-create empty database container
docker run -d --name postgres_restore_test -e POSTGRES_PASSWORD=test postgres:16-alpine

# 3. Restore yesterday's backup dump
pg_restore -h localhost -p 5433 -U postgres -d surveillance_restore /backups/daily/db_20261117.dump

# 4. Verify table row counts and RLS policy integrity
python scripts/verify_db_restore.py --port 5433
```
*Acceptance Standard: Script must report 100% table parity and return exit code 0 in < 15 minutes.*

---

## 5. Security Hardening & Zero-Trust Operational Runbook

### 5.1 Host & Container Hardening Guidelines
1. **Rootless Execution:** Application processes (`edged`, `py-worker`) run under dedicated non-root service accounts (`uid:gid 10001:10001`).
2. **Read-Only Root Filesystems:** Container root filesystems mounted read-only (`read_only: true`), with writable ephemeral storage restricted to `/tmp` (tmpfs) and `/var/lib/surveillance/snapshots` (mounted volume).
3. **No Published Ports Except Go API:**
   - PostgreSQL (5432): Internal Docker bridge network only.
   - `go2rtc` (1984): Internal Docker bridge network only.
   - Python gRPC (50051): Internal Docker bridge network only.
   - Go Daemon (8080/8443): Published to factory intranet with TLS.
4. **Credential Scrubbing:** All camera RTSP passwords masked in logs; no credentials stored in git or environment variables. Secrets mounted via Docker secrets or secure `/run/secrets/` volume files.

### 5.2 Egyptian Law 151/2020 Compliance Checklist
- [ ] No employee facial recognition models or biometric identification active in production baseline (`DEC-06`).
- [ ] Physical privacy masking applied to camera feeds covering prayer rooms, restrooms, and personal locker areas (`NFR-SEC-005`).
- [ ] Audit logs record every single instance of video stream access, recording playback, and evidence export with operator ID and timestamp (`NFR-PRV-001`).
- [ ] Formal legal compliance filing submitted to the Egyptian Data Protection Authority (EDPA) by plant legal counsel prior to commissioning.

---

## 6. Factory Acceptance Testing (FAT) Protocol & Sign-Off Gates

Before production commissioning at BNF and RNF, the platform must pass the 6-stage Factory Acceptance Protocol in the physical plant environment:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ FACTORY ACCEPTANCE TESTING (FAT) PROTOCOL                              │
│                                                                        │
│  Stage 1: Physical Infrastructure Audit (Switches, Cabling, UPS)       │
│     │                                                                  │
│     ▼                                                                  │
│  Stage 2: NVR & Camera Fleet Ingestion Verification (200+ streams)     │
│     │                                                                  │
│     ▼                                                                  │
│  Stage 3: AI Hazard Detection Accuracy on Floor Simulation             │
│     │   - Controlled worker walking into restricted zone polygon       │
│     │   - Controlled worker removing safety helmet / vest              │
│     │   - Controlled smoke simulation (safe test canister)             │
│     │                                                                  │
│     ▼                                                                  │
│  Stage 4: Low-Latency Emergency Dispatch Verification (<500ms)         │
│     │   - Security console audible alert triggered                     │
│     │   - Android handheld notification received                       │
│     │                                                                  │
│     ▼                                                                  │
│  Stage 5: 48-Hour WAN Disconnect Autonomous Resilience Drill           │
│     │   - Factory edge stack operates without central connection       │
│     │   - Zero dropped alerts or lost recordings                       │
│     │                                                                  │
│     ▼                                                                  │
│  Stage 6: 14-Day Continuous Pilot Operation (Zero Unhandled Crashes)   │
│     │                                                                  │
│     ▼                                                                  │
│  FINAL PRODUCTION COMMISSIONING CERTIFICATE SIGNED BY PLANT DIRECTOR   │
└────────────────────────────────────────────────────────────────────────┘
```
