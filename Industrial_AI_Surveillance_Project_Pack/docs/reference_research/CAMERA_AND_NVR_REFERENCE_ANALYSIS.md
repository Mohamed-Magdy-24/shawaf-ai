> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# CAMERA INGESTION, NVR & STREAMING REFERENCE ANALYSIS
## Industrial AI Surveillance Platform — BNF & RNF
### Document Reference: REF-RES-03 | Classification: CANONICAL SUBSYSTEM ANALYSIS
### Status: APPROVED FOR IMPLEMENTATION | Evidence Standard: VERIFIED

---

## 1. STREAM INGESTION & RTSP RESILIENCE FORENSIC ANALYSIS

In industrial environments such as BNF and RNF, IP cameras are subjected to physical line interference, industrial motor EMI, network switch reboots, and variable bitrate spikes. An industrial surveillance platform must maintain stream state without memory leaks, process crashes, or dropped recording segments.

### 1.1 Ingestion Comparative Analysis: go2rtc vs. MediaMTX vs. Frigate

| Ingestion Metric | go2rtc (`AlexxIT/go2rtc`) | MediaMTX (`bluenviron/mediamtx`) | Frigate (`blakeblackshear/frigate`) | ZoneMinder (`ZoneMinder`) |
|------------------|---------------------------|----------------------------------|-------------------------------------|---------------------------|
| **Core RTSP Engine** | Pure Go (`pkg/rtsp`) | Pure Go (`gortsplib`) | FFmpeg Subprocess Fork (`ffmpeg`) | C++ FFmpeg / Libav (`zmc`) |
| **Transport Protocols** | TCP, UDP, HTTP, HTTPS | TCP, UDP, Multicast | TCP, UDP (via FFmpeg CLI flags) | TCP, UDP |
| **Reconnect Strategy** | Exponential backoff (1s -> 30s) | Exponential backoff (1s -> 10s) | Process restart loop with delay | Daemon restart loop (`zmdc.pl`) |
| **Memory Isolation** | Goroutine per track | Goroutine per track | Separate OS process | Separate OS process |
| **Drop-Frame Recovery** | Resynchronizes on next IDR/SPS | Resynchronizes on next IDR | FFmpeg internal buffer flush | Ring-buffer overwrite / log flood |
| **Multi-Stream Ingestion**| Concurrent RTSP ingestion | Concurrent RTSP ingestion | Ingests Substream + Mainstream | Separate monitor daemon per stream |

### 1.2 The Two-Stream Principle (Mainstream vs. Substream)
As verified in Frigate and standard industrial surveillance engineering:
- **Mainstream (High-Resolution: 1080p / 4K @ 20–25 FPS)**:
  - High bitrate (2.5 Mbps – 8 Mbps, H.264 / H.265).
  - **Purpose**: Direct-to-disk recording (`-c copy`), snapshot generation upon verified incidents, and full-resolution forensic playback.
  - **Rule**: Never decode the Mainstream into raw RGB/YUV pixel arrays on CPU/GPU unless a forensic export or zoom is requested.
- **Substream (Low-Resolution: 640x360 or 704x576 @ 5–10 FPS)**:
  - Low bitrate (256 kbps – 512 kbps, H.264).
  - **Purpose**: Motion detection, background subtraction, and primary AI object detection (YOLOv8 person / vehicle detection).
  - **CPU/GPU Savings**: Processing a $640 \times 360$ frame requires $\approx 230,400$ pixels versus $2,073,600$ pixels for 1080p—an **88.9% reduction in decoded memory bandwidth and neural tensor dimensions** `[CALCULATED_FROM_EXPLICIT_ASSUMPTIONS]`.

```
[ IP Camera / Dahua / Hikvision / Uniview ]
   │
   ├── RTSP Mainstream (1080p @ 25fps) ──► [ go2rtc Gateway ] ──► [ Zero-Copy Disk Writer (10s fMP4) ]
   │                                              │
   │                                              └──► [ High-Res On-Demand WebRTC View ]
   │
   └── RTSP Substream  (360p  @ 5fps)  ──► [ go2rtc Gateway ]
                                                  │
                                                  ▼
                                      [ Motion Detection Ring Buffer ]
                                                  │
                                        (Motion Triggered?)
                                                  ▼
                                      [ Python AI gRPC Worker ]
```

---

## 2. LOW-LATENCY BROWSER STREAMING PROTOCOLS

Industrial operators monitoring hazardous machinery, forklift crossings, and production lines cannot tolerate the 3- to 10-second latency typical of traditional HLS streaming. The platform requires sub-second glass-to-glass latency across Web Admin and Flutter mobile clients.

### 2.1 WebRTC vs. MSE vs. HLS Architecture

```
                                  ┌── WebRTC (WHEP) ──────► Chrome / Edge / Firefox (< 200 ms)
                                  │   (Pion WebRTC / UDP)
[ go2rtc Streaming Gateway ] ─────┼── MSE (fMP4 / WS) ────► Enterprise Desktop Fallback (< 350 ms)
                                  │   (HTTP WebSocket)
                                  └── LL-HLS / HLS ───────► iOS Safari / WAN Mobile (< 2.0 s)
                                      (fMP4 Segments)
```

1. **WebRTC (Primary Live Stream: Target Latency < 200 ms)**:
   - **Mechanism**: Implemented via Pion WebRTC in go2rtc using WHEP (WebRTC HTTP Egress Protocol).
   - **Signaling**: Browser sends an HTTP POST with its SDP offer; go2rtc responds immediately with the SDP answer.
   - **Advantage**: Zero transcoding; delivers raw H.264/H.265 NAL units encapsulated into RTP packets over UDP.
   - **Corporate Network Challenge**: In enterprise networks where UDP ports are blocked by strict corporate firewalls, WebRTC peer connection fails during ICE negotiation if an external TURN server is unavailable.

2. **Media Source Extensions (MSE) (Industrial Failover: Target Latency < 350 ms)**:
   - **Mechanism**: Pioneered by `AlexxIT/go2rtc` for robust surveillance delivery.
   - **Signaling & Transport**: Browser establishes an HTTP GET or WebSocket connection to `/api/ws?src={camera_id}`.
   - **Zero Transcoding**: The Go server wraps H.264/H.265 NAL units into fragmented MP4 (fMP4) chunks in memory and pushes them over the WebSocket. The client JavaScript passes chunks directly into the browser's native `MediaSource` API.
   - **Advantage**: Bypasses all UDP/NAT firewall issues; operates reliably over standard HTTP port 80/443; zero ICE timeouts.

3. **Low-Latency HLS (LL-HLS) (Mobile Fallback: Latency 1.5–2.5 s)**:
   - **Target**: Mobile devices with unstable cellular connectivity or iOS Safari where WebRTC background playback is suspended by the OS.

---

## 3. ONVIF INTEGRATION & PTZ CONTROL SPECIFICATION

### 3.1 ONVIF Subsystem Architecture
The edge platform integrates ONVIF Profile S (Basic Video Streaming) and Profile T (Advanced Video Streaming & Analytics) using native Go implementations derived from `AlexxIT/go2rtc/pkg/onvif` and clean-room protocol parsers.

- **WS-Discovery (Automated Network Probe)**:
  - Broadcasts SOAP XML UDP multicast probe to `239.255.255.250:3702`.
  - Discovers all compliant industrial cameras across factory subnets (`192.168.10.0/24` BNF, `192.168.20.0/24` RNF).
  - Retrieves camera XAddrs, MAC addresses, firmware versions, and supported profiles.
- **Device Management & Media Service**:
  - Authenticates via WS-Security (UsernameDigest with Nonce and Created timestamp).
  - Calls `GetProfiles` to enumerate high-res Mainstream and low-res Substream RTSP URIs.
  - Queries `GetStreamUri` with `StreamSetup` (RTP-Unicast over RTSP).

### 3.2 PTZ (Pan-Tilt-Zoom) Protocol Implementation
ZoneMinder’s PTZ command abstractions (`ZoneMinder/Control/`) provide verified mathematical profiles for industrial PTZ cameras (Hikvision, Dahua, Pelco). The BNF/RNF edge daemon implements continuous and absolute positioning via ONVIF PTZ Service:

```xml
<!-- Example ContinuousMove Command Sent to Industrial PTZ Camera -->
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope">
  <s:Body xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl">
    <tptz:ContinuousMove>
      <tptz:ProfileToken>Profile_1</tptz:ProfileToken>
      <tptz:Velocity>
        <tt:PanTilt x="0.5" y="0.0" space="http://www.onvif.org/ver10/tptz/PanTiltSpaces/VelocityGenericSpace"/>
        <tt:Zoom x="0.0" space="http://www.onvif.org/ver10/tptz/ZoomSpaces/VelocityGenericSpace"/>
      </tptz:Velocity>
      <tptz:Timeout>PT2S</tptz:Timeout>
    </tptz:ContinuousMove>
  </s:Body>
</s:Envelope>
```

- **Safety Interlock**: All PTZ continuous movement commands enforce a server-side timeout (`PT2S` = 2 seconds) and an automatic stop watchdog to prevent runaway camera rotation if the operator's network connection drops.

---

## 4. VIDEO RECORDING & STORAGE LIFECYCLE ARCHITECTURE

### 4.1 Fragmented MP4 (fMP4) Zero-Transcoding Pass-Through
Following the proven Frigate recording architecture:
- Video recording is decoupled from the AI inference loop.
- The Go edge daemon or managed FFmpeg process receives the H.264/H.265 Mainstream and slices it into continuous **10-second fragmented MP4 (`.mp4`) segments** written directly to local NVMe storage using stream copy (`-c:v copy -c:a aac`).
- **Segment Metadata Indexing**: Each completed 10-second segment is committed to the local PostgreSQL database:
  ```sql
  INSERT INTO video_segments (
      id, camera_id, tenant_id, start_time, end_time, duration_ms, 
      file_path, file_size_bytes, has_motion, has_ai_event
  ) VALUES (
      gen_random_uuid(), 'cam-bnf-01', 'BNF', '2026-11-12 00:00:00+02', 
      '2026-11-12 00:00:10+02', 10000, '/data/recordings/BNF/cam-bnf-01/20261112/000000.mp4',
      3254100, true, false
  );
  ```

### 4.2 Tiered Industrial Storage Pipeline

```
[ Camera Mainstream ]
         │
         ▼
[ Tier 1: Local Edge NVMe SSD ] ─────────► Retains last 48 Hours (Continuous 24/7)
  (/data/recordings/hot/)                  Ultra-fast scrubbing & event clipping
         │
         ├── (Age > 48h AND No Incident Tag?) ──► [ Automated Purge ]
         │
         ▼ (Age > 48h AND Tagged with Event / Audit Hold)
[ Tier 2: Factory Network Attached Storage (NAS) ] ──► Retains 30 Days (Compliant with Law 151)
  (/mnt/factory-nas/warm/)                             Encrypted NFS / SMBv3
         │
         ▼ (Permanent Incident Archive / Regulatory Export)
[ Tier 3: Central S3 / MinIO Cold Storage ] ───────► Retains 1-5 Years (SHA-256 Verified)
```

1. **Tier 1 (Hot Buffer - Edge NVMe SSD)**:
   - Stores continuous 10-second segments for all cameras for 48 hours.
   - Provides instantaneous scrubbing speed for incident triage.
2. **Tier 2 (Warm Storage - Factory Local NAS)**:
   - Automated background worker archives segments flagged with AI detections, safety violations, or manual bookmarks to the factory NAS. Unflagged footage is overwritten using FIFO disk pressure thresholds (triggers cleanup at 85% disk capacity).
3. **Tier 3 (Cold Archive - Central Blob Storage)**:
   - Verified safety incidents, fire alarms, and audit exports are uploaded to central S3/MinIO over the encrypted WireGuard VPN tunnel with cryptographic SHA-256 integrity signatures.

---

## 5. EDGE VIDEO INGESTION SERVICE: GO IMPLEMENTATION BLUEPRINT

The Go edge daemon implements the video ingestion coordinator using the following clean modular architecture:

```go
// Package ingestion defines the core camera stream pipeline
package ingestion

import (
	"context"
	"fmt"
	"time"
)

// StreamConfig specifies camera connection parameters
type StreamConfig struct {
	CameraID       string
	TenantID       string
	MainstreamURI  string
	SubstreamURI   string
	RecordingPath  string
	SegmentSecs    int
	MotionGating   bool
}

// StreamManager coordinates ingestion, recording, and AI frame dispatch
type StreamManager struct {
	config  StreamConfig
	cancel  context.CancelFunc
	state   StreamState
}

// NewStreamManager initializes the resilient stream coordinator
func NewStreamManager(cfg StreamConfig) *StreamManager {
	return &StreamManager{
		config: cfg,
		state:  StateDisconnected,
	}
}

// Start begins the supervision loop with exponential backoff reconnects
func (sm *StreamManager) Start(ctx context.Context) error {
	ctx, sm.cancel = context.WithCancel(ctx)
	go sm.supervise(ctx)
	return nil
}

func (sm *StreamManager) supervise(ctx context.Context) {
	backoff := 1 * time.Second
	maxBackoff := 30 * time.Second

	for {
		select {
		case <-ctx.Done():
			return
		default:
			err := sm.connectAndIngest(ctx)
			if err != nil {
				sm.state = StateError
				time.Sleep(backoff)
				backoff *= 2
				if backoff > maxBackoff {
					backoff = maxBackoff
				}
			} else {
				backoff = 1 * time.Second
			}
		}
	}
}
```

---

## 6. VERIFICATION AND EVIDENCE CLASSIFICATION

- **Mainstream/Substream Bandwidth Reduction (88.9%)**: `CALCULATED_FROM_EXPLICIT_ASSUMPTIONS` ($640 \times 360 = 230,400$ vs. $1920 \times 1080 = 2,073,600$ pixels).
- **go2rtc MSE WebSocket Streaming**: `VERIFIED_IN_SOURCE` (Inspected `AlexxIT/go2rtc` `pkg/mp4` and `pkg/webrtc`).
- **ONVIF WS-Discovery Multicast Address**: `VERIFIED_OFFICIAL_SOURCE` (ONVIF Core Specification `239.255.255.250:3702`).
- **Zero-Transcoding fMP4 Recording**: `VERIFIED_IN_SOURCE` (Frigate `frigate/record/record.py`).

---
**Authored By:** Principal AI Engineer / CTO & Video Systems Architect  
**Approved For Implementation:** 2026-11-12

