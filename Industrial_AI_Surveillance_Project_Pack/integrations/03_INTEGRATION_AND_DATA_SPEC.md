# Integration and Data Specification

**Document ID:** INT-001  
**Status:** Baseline + discovery requirements. Vendor/API details are intentionally not invented.  

## 1. Integration inventory

| System | Per-site topology | Known | Unknown / must verify |
|---|---|---|---|
| ZKBioTime | Independent BNF and RNF environments | Same product family; version/build unknown | Exact version/build, API availability, licensing, endpoint, auth, supported photo endpoints, pagination/rate limits |
| SQL Server | Separate database/server per factory | Separate SQL Server; Employee ID stable in attendance and SQL records | Host/version, DB/schema, views, permissions, data volume, network path, backup policy |
| Biometric terminals | 18+ per factory; mixed models | Images currently stored only on terminals/system | Exact models, firmware, supported export method, image resolution/format, whether photo sync reaches ZKBioTime |
| Cameras | 200+ per factory, expandable | Many cameras behind switches | Models, codec, resolution, FPS, IP plan, stream URLs, access method, day/night quality |
| NVRs | Multiple per site, mixed types | More than one NVR and multiple types | Vendors/models, firmware, SDK/API, playback API, channel mapping, recording retention, concurrent session limits |
| Network | Inter-factory connectivity exists | Described as stable | VLANs, routing, firewall, bandwidth, latency, jitter, site internet uplink, failover |
| Current server | Existing server has no GPU | No GPU | CPU, RAM, storage, OS, hypervisor, NIC, storage IOPS, available capacity |

## 2. Discovery protocol

The implementation agent must produce a device/integration inventory before writing production connectors. Do not ask the owner to guess technical values. Provide a read-only collection checklist and scripts/commands where safe; the responsible IT person runs them and returns results.

### 2.1 ZKBioTime discovery

Collect for each factory:

- Application version, build, license, installation path, OS, database type/version.
- API documentation and enabled API modules.
- Authentication method, service account options, rate limits, pagination, timestamp semantics.
- Employee/profile endpoints and photo/biophoto availability.
- Whether images stored on different biometric terminal models are synchronized to ZKBioTime.
- Sample response for a test employee with sensitive fields redacted.
- Supported export method and whether the image is a conventional photo or vendor-specific biometric template.

**BLOCKER:** face recognition cannot be approved until retrieval of conventional face images is proven for representative device models in both factories.

### 2.2 SQL Server discovery

Collect:

- SQL Server version and database names.
- Schema-only export: table/view names, column names/types, primary/foreign keys, indexes.
- Read-only service account privileges.
- Employee, department, attendance, and device mapping tables/views.
- Row counts and approximate growth, with no unnecessary personal data export.
- Query latency and network restrictions.

Use read-only credentials initially. Do not allow the agent to infer schema from table naming guesses.

### 2.3 Camera/NVR discovery

For every NVR family and a representative sample of cameras:

- Vendor/model, firmware, channel count, connected camera/channel mapping.
- Supported API/SDK and licensing constraints.
- Live stream protocol, playback protocol, authentication method, maximum concurrent sessions.
- Video codec, resolution, frame rate, bitrate, audio availability if relevant.
- Recording schedule, retention, export/clip method, timezone, timestamp accuracy.
- Network topology and whether AI workers can access streams without exposing NVRs to the public internet.

Do not assume RTSP/ONVIF support or that one adapter works for every model.

### 2.4 Hardware and network discovery

Collect CPU model/core count, RAM, storage type/capacity/IOPS, GPU model/VRAM/driver if any, NIC speed, virtualization, OS, thermal/power constraints, site-to-site and camera VLAN bandwidth. The current server has no GPU, but no further capacity conclusion can be made until inventory and benchmarks exist.

## 3. Adapter contracts

Implement each external system behind an application port. The initial port examples below are conceptual and must be adapted to the selected language and verified API.

### ZKBioTime adapter port

- `GetEmployees(site, cursor)`
- `GetEmployee(site, employeeId)`
- `GetAttendanceRecords(site, timeRange, cursor)`
- `GetEmployeePhoto(site, employeeId)`
- `GetCapabilities(site)`
- `HealthCheck(site)`

Photo retrieval returns a typed outcome, not a nullable byte array alone:

- `Available(image, source, capturedAt, format, dimensions)`
- `NotFound`
- `UnsupportedByDeviceOrVersion`
- `InvalidImage(reason)`
- `Unauthorized`
- `TransientFailure(retryAfter)`

### SQL Server adapter port

Use read-only access for initial synchronization. Map source records into internal DTOs, then validate and map into domain objects. Do not let SQL Server table names/types leak into the domain layer.

### NVR adapter port

- Discover devices/channels/capabilities.
- Create a live-view session.
- Create a playback session for a validated time range.
- Resolve event timestamp to recording/clip reference.
- Query device/stream health.
- Revoke/expire a session.

Every adapter publishes a capability matrix and handles unsupported features explicitly.

## 4. Canonical identity model

Use internal IDs independent of vendor IDs. Suggested keys:

- `SiteId` — immutable identifier for BNF or RNF.
- `EmployeeRecordId` — internal UUID.
- `SourceEmployeeId` — original Employee ID from the site's ZKBioTime/SQL data.
- Unique source constraint: `(SiteId, SourceEmployeeId)` unless discovery proves a stronger global uniqueness contract.
- `DeviceId`, `CameraId`, `NvrId`, `ZoneId` — internal IDs with external source references.

Never assume Employee IDs are unique across factories simply because they are stable within each factory.

## 5. Core data entities

| Entity | Purpose | Key relationships |
|---|---|---|
| Site | BNF/RNF site context | Has devices, users/entitlements, policies, events |
| Employee | Site-scoped employee profile | Source Employee ID, attendance references, face image state |
| BiometricImageAsset | Protected image metadata and secure locator | Employee, site, source, validation state, retention policy |
| Camera | Logical camera/channel | NVR, site, zone, capabilities |
| NvrDevice | Recording device | Site, channels, firmware, adapter type |
| BiometricTerminal | Attendance/face terminal | Site, model, firmware, ZKBioTime linkage |
| Zone | Spatial policy region | Site, cameras, PPE/restricted-area policies |
| Detection | Raw model output | Camera, model/version, bounding boxes, confidence |
| Track | Person/object track | One or more detections, camera/time sequence |
| IdentityAssociation | Candidate employee association | Track, Employee, confidence, evidence, status |
| Event | Normalized business event | Site, type, severity, evidence, rule version |
| Alert | Routed alert | Event, recipients, delivery attempts |
| ReportSnapshot | Scheduled in-app report | Site or authorized cross-site scope, period, generated time |
| AuditRecord | Security/administrative activity | Actor, action, resource, timestamp, result |

## 6. Event envelope

All inter-module event messages should be versioned and include:

```json
{
  "schema_version": "1.0",
  "event_id": "uuid",
  "site_id": "BNF-or-RNF-internal-id",
  "event_type": "ppe.violation.detected",
  "occurred_at_utc": "ISO-8601 UTC timestamp",
  "received_at_utc": "ISO-8601 UTC timestamp",
  "source": {
    "camera_id": "internal-id",
    "nvr_id": "internal-id-or-null",
    "model_id": "model-name",
    "model_version": "version"
  },
  "subject": {
    "type": "person-or-object",
    "employee_ref": null,
    "object_class": null,
    "association_status": "unknown"
  },
  "detection": {
    "confidence": 0.0,
    "rule_id": "rule-id",
    "rule_version": "version"
  },
  "location": {
    "zone_id": "internal-id-or-null",
    "label": "human-readable-location"
  },
  "evidence": {
    "snapshot_ref": "protected-reference-or-null",
    "recording_start_utc": "ISO-8601-or-null",
    "recording_end_utc": "ISO-8601-or-null",
    "clip_ref": "protected-reference-or-null"
  }
}
```

The numeric confidence example is illustrative only; no threshold is approved by this specification.

## 7. Storage and retention

- Video: 30 days baseline. Actual storage location and whether NVR storage already meets this requirement must be verified.
- Event metadata: retention period TBD.
- Face source images and face embeddings: retention, refresh, revocation, and deletion rules TBD and require legal/privacy approval.
- Audit records: retention TBD; must be tamper-resistant and access-controlled.
- Incident evidence hold: TBD; no indefinite hold may be silently implemented.

## 8. Time and synchronization

- Store normalized timestamps in UTC.
- Preserve source timestamp and detected clock offset for camera/NVR diagnostics.
- Verify NTP configuration for NVRs, servers, terminals, and site networks.
- Cross-camera movement reconstruction is unreliable if clocks drift beyond the validated tolerance. Do not hide this limitation.

## 9. Integration test environment

Provide fake/test adapters for unit and CI tests, but make production startup fail loudly if fake adapters are selected. Use sanitized representative fixtures and contract tests against real vendor environments in a controlled pilot. Never store production passwords or biometric images in source control or test fixtures.
