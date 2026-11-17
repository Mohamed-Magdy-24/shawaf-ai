# 31 — Reporting Timezone, Shift Cutoffs & Calendar Rules

**Document ID:** DISC-31-TIMEZONE-RULES  
**Version:** 1.0.0  
**Date:** 2026-11-11  
**Status:** CANONICAL TEMPORAL SPECIFICATION  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` (Egyptian Law 24/2023) & `PROPOSED` (Shift Rules)  
**Directive Reference:** Finding P1-04 of CTO Review  

---

## 1. Executive Correction: The UTC vs. Factory Business Day Conflict

In accordance with Finding P1-04 of the CTO Review:
> **UTC is a technical storage standard, NOT the factory's operational business boundary.**
> Earlier documents stated that daily reports are scheduled at 00:00 UTC. In Egypt, 00:00 UTC corresponds to **02:00 AM (Winter) or 03:00 AM (Summer) local Cairo time**. 
> Generating a "daily report" at 00:00 UTC would split midnight factory shifts across two different calendar reports, corrupting daily KPIs, shift worker attendance tallies, and incident counts.

This document establishes the canonical dual-time architecture: **Technical UTC Ingest & Storage paired with Local Egyptian (`Africa/Cairo`) Analytical Rollups.**

---

## 2. Canonical Timezone Standard: `Africa/Cairo`

### 2.1 Egyptian Daylight Saving Time (DST) Legal Framework
Under **Egyptian Law No. 24 of 2023** (Reinstating Daylight Saving Time in Egypt):
- **Summer Time (DST):** Begins on the **last Friday of April at 00:00** (clocks advance 1 hour from UTC+2 to **UTC+3**).
- **Winter Time (Standard):** Resumes on the **last Thursday of October at 24:00 (Friday 00:00)** (clocks retreat 1 hour from UTC+3 to **UTC+2**).
- **Technical Implication:** Any software scheduling jobs using a hardcoded `+02:00` offset will experience an erroneous 1-hour reporting shift for 6 months of every year. All date/time conversions must utilize the official IANA Timezone Database identifier: **`Africa/Cairo`**.

---

## 3. Dual-Time Storage & Analytical Aggregation Model

```text
+----------------------------------------------------------------------------------------------------+
|                                    DUAL-TIME ARCHITECTURAL SPLIT                                   |
|                                                                                                    |
|  1. INGESTION & STORAGE LAYER (STRICT UTC):                                                        |
|     - All camera frames, RTSP video metadata, AI detections, and database rows are stamped in:     |
|       `occurred_at_utc` (ISO-8601 UTC with microsecond precision: `2026-11-11T19:45:00.124567Z`).   |
|     - Guarantees zero ambiguity during the 1-hour autumn DST overlap; sorting is strictly linear. |
|                                                                                                    |
|  2. ANALYTICAL & PRESENTATION LAYER (`Africa/Cairo`):                                              |
|     - Reporting aggregations convert UTC timestamps into `Africa/Cairo` calendar days:             |
|       `SELECT date_trunc('day', occurred_at_utc AT TIME ZONE 'Africa/Cairo') AS business_day ...`   |
|     - Guarantees that midnight shifts and daily safety KPIs match the factory wall clock.          |
+----------------------------------------------------------------------------------------------------+
```

---

## 4. Factory Operational Shift Definitions & Reporting Cutoffs

The platform supports a 3-shift operational rotation aligned with local Egyptian industrial schedules:

| Shift Identifier | Local Cairo Time Range | Summer UTC Equivalent (UTC+3) | Winter UTC Equivalent (UTC+2) | Operational Purpose |
|---|---|---|---|---|
| **Shift 1 (Morning Shift)** | 08:00 to 16:00 Cairo | 05:00 to 13:00 UTC | 06:00 to 14:00 UTC | Primary manufacturing & loading operations |
| **Shift 2 (Evening Shift)** | 16:00 to 00:00 Cairo | 13:00 to 21:00 UTC | 14:00 to 22:00 UTC | Secondary production & maintenance |
| **Shift 3 (Night Shift)** | 00:00 to 08:00 Cairo | 21:00 to 05:00 UTC (+1d) | 22:00 to 06:00 UTC (+1d) | Minimal staffing; high security vigilance |

### 4.1 Daily Reporting Cutoff & Snapshot Timing
- **Daily Business Day Boundary:** Closes at **23:59:59.999999 Cairo Time** (which is 20:59:59 UTC in Summer, 21:59:59 UTC in Winter).
- **Rollup Worker Execution:** Scheduled to run daily at **00:05:00 Cairo Time** (5 minutes after midnight local time) to allow late-arriving buffered events from edge workers to settle.
- **Weekly Reporting Boundary:** Closes on **Thursday at 23:59:59 Cairo Time** (matching the Egyptian working week weekend structure: Friday/Saturday). Weekly rollup generates on Friday at 01:00 Cairo Time.
- **Monthly Reporting Boundary:** Closes on the final calendar day of each Gregorian month at 23:59:59 Cairo Time.

---

## 5. Late-Arriving Data & Report Snapshot Locking (Immutable Reporting)

A critical engineering challenge in industrial surveillance is handling offline camera buffers or delayed attendance syncs:
1. **Immutable Snapshot Locking:** Once the daily rollup worker executes at 00:05 Cairo Time, it computes the compliance percentages, incident totals, and PPE violations, persisting the result as an **Immutable Report Snapshot** (`report_snapshots` table with cryptographic hash).
2. **Handling Delayed Punches / Late Events:**
   - If an edge worker or biometric terminal was disconnected and uploads events that occurred on a previous calendar day, the events are written to the database with their genuine historical `occurred_at_utc` timestamp.
   - **The locked report snapshot is NOT silently rewritten.**
   - Instead, the late-arriving records are flagged as `reconciled_after_cutoff = true`. If the late delta exceeds a 5% variance threshold, the system flags the historical report as `AMENDED` with an auditable discrepancy note explaining the offline camera source.
   - This prevents operational reporting figures from shifting mysteriously after managers have reviewed and signed off on daily shift logs.

---

## 6. Timezone Rules Sign-Off

- **Status:** CANONICAL SPECIFICATION.
- **Action Item:** Integrate `Africa/Cairo` date truncation into PostgreSQL 16 native partitioned rollup queries (TimescaleDB removed per ADR-013) in Phase 2.

