# Shawaf AI (شوف AI) — Workstation Live-Test & Identity Enablement Guide

**Authority**: `OWNER_AUTHORIZATION_LOCAL_DEV.md` (Updated 2026-11-17)  
**Governance State**: Workstation Live-Testing Authorized for SPK-01 (ZKTeco), SPK-03 (NVR/Camera RTSP), SPK-04 (SQL Server), DEC-03..08, and Face Recognition / Employee Identification ("Who & Where").  
**Sole Remaining Restriction**: Server/GPU hardware procurement (`BLK-002` / `OQ-011`) remains DEFERRED; entire stack executes on Owner's workstation/PC.  
**Multi-Site Isolation**: Sites strictly isolated via PostgreSQL 16 Row Level Security (RLS) under codes `BNF` and `RNF`.

---

## 1. Quickstart: Launching the Workstation Edge Stack

The full edge surveillance stack runs via Docker Compose on the workstation:

```bash
cd Industrial_AI_Surveillance_Project
docker compose -f deploy/docker-compose.local.yml up -d
```

### Stack Components & Health Endpoints

| Container | Service | Port / Protocol | Health / Verification |
| :--- | :--- | :--- | :--- |
| `surv_postgres` | PostgreSQL 16 with RLS | `localhost:5432` | `psql -U app_runtime -d surveillance` |
| `surv_go2rtc` | WebRTC / RTSP Restreamer | `localhost:1984` | `http://localhost:1984/` |
| `surv_mediamtx` | RTSP Simulation Gateway | `localhost:8554` | `rtsp://localhost:8554/` |
| `surv_edged` | Core Daemon & Outbox Engine | `localhost:8080` (HTTP), `50051` (gRPC) | `http://localhost:8080/healthz` |
| `surv_camsim` | Synthetic Camera Simulator | Internal loop | `rtsp://mediamtx:8554/cam_bnf_gate_01` |
| `surv_ai_worker` | CV Safety Worker (YOLOX) | Edge Ingestion | Consumes RTSP, submits structured events |

---

## 2. Onboarding NVRs and Real IP Cameras

Administrators and Security Managers (`role: security_manager`, `role: senior_management`, `role: admin`) can onboard cameras and NVRs either through the Flutter UI (`Onboard Camera Screen`) or via authenticated REST endpoints.

### 2.1 Testing Appliance Reachability (Probe)

Before persisting an appliance, probe the RTSP socket to verify network routing, latency, and RTSP handshake without storing plaintext credentials:

```bash
curl -X POST http://localhost:8080/api/v1/sites/11111111-1111-1111-1111-111111111111/cameras/test-connection \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor": "HIKVISION",
    "host_ip": "192.168.1.50",
    "port": 554,
    "channel": 1,
    "username": "admin",
    "password": "factoryCameraPassword123"
  }'
```

**Expected Response**:
```json
{
  "reachable": true,
  "sanitized_url": "rtsp://***:***@192.168.1.50:554/Streaming/Channels/102",
  "latency_ms": 14.2,
  "rtsp_status": "RTSP/1.0 200 OK"
}
```

### 2.2 Vendor URL Construction Heuristics

The daemon automatically maps appliance presets into sub-stream RTSP paths:

- **Hikvision**: `rtsp://[user]:[pass]@[ip]:[port]/Streaming/Channels/[channel]02`
- **Dahua**: `rtsp://[user]:[pass]@[ip]:[port]/cam/realmonitor?channel=[channel]&subtype=1`
- **Tiandy**: `rtsp://[user]:[pass]@[ip]:[port]/video2`
- **Generic / Custom**: `rtsp://[user]:[pass]@[ip]:[port]/[custom_path]`

### 2.3 Registering a Camera Appliance

```bash
curl -X POST http://localhost:8080/api/v1/sites/11111111-1111-1111-1111-111111111111/cameras \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "BNF North Perimeter Gate",
    "vendor": "HIKVISION",
    "host_ip": "192.168.1.50",
    "port": 554,
    "channel": 1,
    "username": "admin",
    "password": "factoryCameraPassword123",
    "fps_target": 15,
    "zones": ["bnf_zone_restricted_01"]
  }'
```

*Note: All RTSP credentials are encrypted via AES-256-GCM using `EDGED_ENCRYPTION_KEY` in PostgreSQL and scrubbed in all API representations.*

---

## 3. Personnel Enrollment & "Who & Where" Presence

### 3.1 Single Employee Enrollment (with Photo)

Upload an employee RGB reference photo via multipart form:

```bash
curl -X POST http://localhost:8080/api/v1/sites/11111111-1111-1111-1111-111111111111/employees \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -F "employee_id=EMP-1042" \
  -F "full_name=Tarek Mahmoud" \
  -F "department=OPERATIONS" \
  -F "photo=@/path/to/employee_photo.jpg"
```

The system:
1. Calculates SHA-256 of the photo bytes.
2. Securely persists photo to `/var/lib/surveillance/evidence/{site_id}/employees/{employee_id}.jpg`.
3. Computes a 512-dimensional $L_2$-normalized float32 face embedding (`mobilefacenet-v1`).
4. Persists the vector into PostgreSQL `employee_embeddings` under multi-site tenant isolation.

### 3.2 Bulk CSV Import

```bash
curl -X POST http://localhost:8080/api/v1/sites/11111111-1111-1111-1111-111111111111/employees/import \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: text/csv" \
  --data-binary @employees_bnf.csv
```

CSV format:
```csv
employee_id,full_name,department
EMP-201,Ahmed Mansour,OPERATIONS
EMP-202,Hossam Samir,SAFETY
EMP-203,Mona Gamal,LOGISTICS
```

### 3.3 Querying Real-Time Presence ("Who & Where")

```bash
curl -X GET http://localhost:8080/api/v1/sites/11111111-1111-1111-1111-111111111111/presence \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

**Response**:
```json
{
  "site_id": "11111111-1111-1111-1111-111111111111",
  "total_present": 1,
  "presence": [
    {
      "site_id": "11111111-1111-1111-1111-111111111111",
      "employee_id": "EMP-201",
      "full_name": "Ahmed Mansour",
      "department": "OPERATIONS",
      "camera_id": "bnf_cam_01",
      "zone_id": "bnf_zone_restricted_01",
      "confidence": 0.94,
      "last_seen_at": "2026-11-17T10:15:30Z"
    }
  ]
}
```

---

## 4. Flutter Web & Cross-Platform Client

The Flutter application runs in desktop browsers or mobile devices:

```bash
cd mobile-app
flutter run -d chrome --web-port 3000
```

### Navigation & Screens
- **Alert Inbox**: Displays real-time SEV1/SEV2/SEV3 safety alerts with countdown timer and state workflow (NEW -> ACKNOWLEDGED -> RESOLVED / DISMISSED).
- **Cameras**: Live WebRTC feeds with polygon safety exclusion overlays.
- **Onboard Camera Screen**: Vendor presets, reachability testing, and interactive polygon zone drawing.
- **Personnel & Presence Screen**:
  - *Who & Where Tab*: Real-time location of identified employees across cameras.
  - *Enrolled Directory Tab*: Identity directory with Single Enrollment and Bulk CSV Import.
