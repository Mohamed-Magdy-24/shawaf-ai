> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 08 — Target Architecture & System Design Proposal (Remediated)

**Document ID:** DISC-08-TARGET-ARCHITECTURE  
**Version:** 1.1.0-remediated  
**Date:** 2026-11-11  
**Status:** PROPOSED ARCHITECTURAL BLUEPRINT  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Directive Reference:** Sections 8 & 9 of CTO Directive  

---

## 1. Architectural Style: Federated Two-Site Modular Monolith

The BNF and RNF Industrial AI Surveillance Platform is architected as a **Federated Two-Site Deployment** adhering to **Clean Architecture (Ports and Adapters)** principles.

To avoid the operational fragility, network latency, and distributed transaction complexity of microservices, the system couples a **Modular Monolith for Business Operations** with **Isolated High-Performance Edge Video & AI Workers**.

```text
====================================================================================================
                                    MANAGEMENT PLANE (BFF & ROUTER)
  [Android Manager App]  <== TLS 1.3 / JWT ==>  [Management API Gateway & Context Router]
                                                ├── Site Context & Claim Verification
                                                ├── Signed Scoped Video Token Minting (HMAC Integrity)
                                                └── Cross-Site Aggregated Analytics Proxy
====================================================================================================
                 │                                                           │
        Site-Scoped Authenticated                                   Site-Scoped Authenticated
            Virtual Channel                                             Virtual Channel
                 ▼                                                           ▼
+─────────────────────────────────────────────+   +─────────────────────────────────────────────+
│             BNF SITE DATA PLANE             │   │             RNF SITE DATA PLANE             │
│                                             │   │                                             │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
│  │   BNF Business Core (Modular Mono)    │  │   │  │   RNF Business Core (Modular Mono)    │  │
│  │   ├── Presentation: Site REST/WS APIs │  │   │  │   ├── Presentation: Site REST/WS APIs │  │
│  │   ├── Application: Use Cases & Ports  │  │   │  │   ├── Application: Use Cases & Ports  │  │
│  │   ├── Domain: Entities & Policies     │  │   │  │   ├── Domain: Entities & Policies     │  │
│  │   └── Infrastructure: DB/Queue Adptrs │  │   │  │   └── Infrastructure: DB/Queue Adptrs │  │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
│                      │                      │   │                      │                      │
│       Site-Scoped Message Stream (Valkey)   │   │       Site-Scoped Message Stream (Valkey)   │
│                      ▼                      │   │                      ▼                      │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
│  │   BNF Edge Video & AI Worker Cluster  │  │   │  │   RNF Edge Video & AI Worker Cluster  │  │
│  │   ├── go2rtc Stream Multiplexer       │  │   │  │   ├── go2rtc Stream Multiplexer       │  │
│  │   ├── Frame Sampler & ROI Masking     │  │   │  │   ├── Frame Sampler & ROI Masking     │  │
│  │   ├── TensorRT Multi-Model Inference  │  │   │  │   ├── TensorRT Multi-Model Inference  │  │
│  │   └── ByteTrack & Spatial Ray-Caster  │  │   │  │   └── ByteTrack & Spatial Ray-Caster  │  │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
│                      │                      │   │                      │                      │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
│  │   Connected Site Infrastructure       │  │   │  │   Connected Site Infrastructure       │  │
│  │   ├── BNF SQL Server (Read-Only)      │  │   │  │   ├── RNF SQL Server (Read-Only)      │  │
│  │   ├── BNF ZKBioTime (Instance 1)      │  │   │  │   ├── RNF ZKBioTime (Instance 2)      │  │
│  │   ├── BNF NVRs (~200+ Cameras)        │  │   │  │   ├── RNF NVRs (~200+ Cameras)        │  │
│  │   └── BNF PostgreSQL / Storage Store  │  │   │  │   └── RNF PostgreSQL / Storage Store  │  │
│  +───────────────────────────────────────+  │   │  +───────────────────────────────────────+  │
+─────────────────────────────────────────────+   +─────────────────────────────────────────────+
```

---

## 2. Distributed Alert Reliability & Delivery Architecture

In strict adherence to Section 9 of the CTO Directive:
> **Neither Redis nor Transactional Outbox provides an absolute theoretical guarantee of "zero lost alerts". The platform enforces a mathematically rigorous At-Least-Once Delivery model with consumer idempotency and dead-letter recovery.**

```mermaid
flowchart TD
    classDef domain fill:#0B111E,stroke:#10B981,stroke-width:2px,color:#F8F9FA;
    classDef db fill:#161F30,stroke:#0EA5E9,stroke-width:2px,color:#F8F9FA;
    classDef queue fill:#1E293B,stroke:#F59E0B,stroke-width:2px,color:#F8F9FA;
    classDef dead fill:#2D1515,stroke:#EF4444,stroke-width:2px,color:#EF4444;

    AI_OBS["AI Model Observation<br/>(e.g., Flame Detected)"] --> RULE_ENG["Policy Rule Evaluation"]:::domain
    
    RULE_ENG --> TX_START{"ACID Database Transaction"}:::db
    
    subgraph POSTGRESQL_TRANSACTION["Atomic Database Boundary"]
        TX_START --> WRITE_EVT["1. Insert Normalized Event<br/>(event_id, camera, confidence)"]:::db
        TX_START --> WRITE_OUTBOX["2. Insert Outbox Record<br/>(outbox_id, event_id, status='PENDING')"]:::db
    end
    
    WRITE_OUTBOX --> OUTBOX_PUB["Outbox Publisher Worker<br/>(Polls or CDC Tailer)"]:::db
    
    OUTBOX_PUB --> PUB_VALKEY["Publish to Valkey / Redis Stream<br/>(At-Least-Once Semantics)"]:::queue
    
    PUB_VALKEY --> DISPATCH_WORKER["Notification Dispatch Worker<br/>(Consumer Group with XACK)"]:::queue
    
    DISPATCH_WORKER --> IDEMP_CHECK{"Idempotency Key Check<br/>Has event_id been processed?"}:::domain
    
    IDEMP_CHECK -->|ALREADY PROCESSED| ACK_DROP["Acknowledge & Discard Duplicate"]:::domain
    IDEMP_CHECK -->|NEW EVENT| SEND_FCM["Dispatch FCM / WebSocket Push<br/>to Authorized Recipients"]:::domain
    
    SEND_FCM --> PUSH_SUCCESS{"Delivery Succeeded?"}
    PUSH_SUCCESS -->|YES| MARK_DONE["Mark Outbox Record 'PROCESSED'<br/>Issue XACK to Stream"]:::db
    PUSH_SUCCESS -->|NO (Retries Exceeded)| ROUTE_DLQ["Route to Dead-Letter Queue (DLQ)<br/>Raise Critical System Alert"]:::dead
```

### Detailed Reliability Guarantees:
1. **Atomic Outbox Persistence:** Events and notification intents are committed together within PostgreSQL. If the process crashes during evaluation, neither is saved. If the transaction commits, both are permanently preserved on disk.
2. **At-Least-Once Dispatch:** The Outbox Publisher processes pending rows and dispatches them to Valkey Streams. If the publisher crashes before recording a successful dispatch, it will re-dispatch upon reboot.
3. **Mandatory Consumer Idempotency:** Because at-least-once delivery inherently creates duplicate messages during network retries, the mobile client and backend consumers enforce an **Idempotency Cache** (keyed by `event_id`). Repeated deliveries of the same alert are acknowledged and discarded without triggering duplicate notifications.
4. **Dead-Letter Handling (DLQ):** Messages that fail delivery after 5 exponential backoff retries are diverted to a dedicated Dead-Letter Stream (`events:dead_letter`), triggering an immediate operational alert to system administrators.

---

## 3. Cryptographic Video Access & Token Security Architecture

In strict adherence to Section 8 of the CTO Directive:
> **HMAC is an authentication and message integrity mechanism, NOT an encryption algorithm. Video confidentiality is achieved through transport-layer encryption (TLS 1.3 / SRTP), while HMAC ensures cryptographic tamper-proofing of access claims.**

```text
+----------------------------------------------------------------------------------------------------+
|                                    ZERO-TRUST VIDEO SESSION ARCHITECTURE                           |
|                                                                                                    |
|  1. CLIENT REQUEST (over TLS 1.3):                                                                 |
|     Mobile Client ===> GET /api/v1/sites/BNF/cameras/CAM-012/stream-session                         |
|     Headers: Authorization: Bearer <User_JWT>                                                      |
|                                                                                                    |
|  2. AUTHORIZATION & CLAIM VERIFICATION:                                                            |
|     Management API evaluates:                                                                      |
|     - Is User authorized for BNF? (Tenant Scope)                                                  |
|     - Does User have explicit `video:stream:live` capability? (Security / Senior Role)             |
|     - Is Camera CAM-012 active and healthy?                                                        |
|                                                                                                    |
|  3. SHORT-LIVED SIGNED TOKEN MINTING:                                                              |
|     API generates Payload:                                                                         |
|     { "sub": "usr_941", "site": "BNF", "cam": "CAM-012", "exp": 1731360060, "nonce": "d8f1e..." } |
|     Signature = HMAC-SHA256(Payload, Secret_Key_Rotation_K1)                                      |
|     Token = Base64URL(Payload) + "." + Base64URL(Signature)                                        |
|     Token Lifetime: Strictly 60 Seconds.                                                          |
|                                                                                                    |
|  4. WEBRTC STREAM HANDSHAKE (over DTLS / SRTP):                                                    |
|     Client connects to go2rtc: wss://go2rtc.bnf.local/api/ws?src=CAM-012&token=<Token>             |
|     go2rtc validates HMAC signature and expiration time locally.                                   |
|     If valid: Negotiates DTLS-SRTP session and streams video. Zero NVR credentials exposed.        |
+----------------------------------------------------------------------------------------------------+
```

### Security Controls Enforced:
- **Confidentiality:** All control plane traffic is encrypted via **TLS 1.3**. All WebRTC video payloads are encrypted via **SRTP (AES-128/256-GCM)**.
- **Integrity & Authenticity:** HMAC-SHA256 guarantees tokens cannot be forged or modified (e.g., tampering with `cam_id` or `exp`).
- **Short Lifetime & Revocation:** Tokens expire within **60 seconds**. Revocation lists in Valkey immediately terminate abused streams.
- **Key Rotation:** HMAC signing keys rotate every 24 hours with a 10-minute grace window for active sessions.
- **Session Auditing:** Every minted video session records an immutable audit entry: `(timestamp, user_id, site_id, camera_id, client_ip, token_id)`.

---

## 4. Target Architecture Sign-Off

- **Status:** REMEDIATED ARCHITECTURAL SPECIFICATION.
- **Action Item:** Awaiting Gate 0 approval to proceed with Phase 1 technical spikes.
