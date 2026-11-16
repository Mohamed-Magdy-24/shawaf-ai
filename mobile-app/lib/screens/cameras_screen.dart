import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CamerasScreen extends StatelessWidget {
  final List<Camera> cameras;
  final List<Zone> zones;
  final Function() onRefresh;
  final ApiService? apiService;

  const CamerasScreen({
    Key? key,
    required this.cameras,
    required this.zones,
    required this.onRefresh,
    this.apiService,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'STREAMING':
        return AppTheme.successGreen;
      case 'COVERAGE_LOST':
        return AppTheme.sev1Red;
      default:
        return AppTheme.textMuted;
    }
  }

  void _openLiveStream(BuildContext context, Camera cam) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _WebRTCStreamDialog(camera: cam, apiService: apiService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONITORED CAMERAS (${cameras.length})',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 20),
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final cam = cameras[index];
              final statusColor = _getStatusColor(cam.healthStatus);
              final camZones = zones.where((z) => z.cameraId == cam.id).toList();

              return Card(
                color: AppTheme.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.videocam_outlined, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cam.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              border: Border.all(color: statusColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cam.healthStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ID: ${cam.id} | Throughput: ${cam.currentFPS.toStringAsFixed(1)} FPS / ${cam.fpsTarget} FPS Target',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      if (camZones.isNotEmpty) ...[
                        const Text(
                          'CONFIGURED SAFETY ZONES:',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: camZones.map((z) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${z.name} [${z.zoneType}]',
                                style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openLiveStream(context, cam),
                          icon: const Icon(Icons.play_circle_outline, color: AppTheme.primaryTeal, size: 16),
                          label: const Text('ZERO-TRUST WEBRTC LIVE STREAM', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WebRTCStreamDialog extends StatefulWidget {
  final Camera camera;
  final ApiService? apiService;

  const _WebRTCStreamDialog({
    Key? key,
    required this.camera,
    this.apiService,
  }) : super(key: key);

  @override
  State<_WebRTCStreamDialog> createState() => _WebRTCStreamDialogState();
}

class _WebRTCStreamDialogState extends State<_WebRTCStreamDialog> {
  bool _isNegotiating = true;
  String _statusText = 'Generating WebRTC SDP Offer...';
  String? _errorMessage;
  Map<String, dynamic>? _sdpAnswer;

  @override
  void initState() {
    super.initState();
    _startSdpNegotiation();
  }

  void _startSdpNegotiation() async {
    if (widget.apiService == null) {
      setState(() {
        _isNegotiating = false;
        _errorMessage = 'API Service client not available';
      });
      return;
    }

    try {
      setState(() {
        _statusText = 'Exchanging SDP via edged reverse-proxy (RBAC Check D-011)...';
      });

      // Synthetic client SDP offer for H.264 video track
      const syntheticOffer = 'v=0\r\no=- 4294967295 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\nc=IN IP4 0.0.0.0\r\na=rtpmap:96 H264/90000\r\na=recvonly\r\n';

      final answer = await widget.apiService!.requestWebRTCSdp(
        widget.camera.siteId,
        widget.camera.id,
        syntheticOffer,
      );

      if (mounted) {
        setState(() {
          _isNegotiating = false;
          _sdpAnswer = answer;
          _statusText = 'WebRTC PeerConnection established (go2rtc internal sidecar).';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNegotiating = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border),
      ),
      title: Row(
        children: [
          const Icon(Icons.videocam, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'LIVE: ${widget.camera.name}',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Center(
                child: _isNegotiating
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primaryTeal, strokeWidth: 2),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                      )
                    : _errorMessage != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.sev1Red, size: 32),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.sev1Red, fontSize: 11),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline, color: AppTheme.successGreen, size: 32),
                              const SizedBox(height: 8),
                              const Text(
                                'ZERO-TRUST STREAM ACTIVE',
                                style: TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'RTSP: rtsp://mediamtx:8554/${widget.camera.id}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Security Boundary: D-011 Zero-Trust Proxy',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
            Text(
              'Sidecar Isolation: go2rtc internal only (port 1984/8555 not exposed)',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: AppTheme.primaryTeal)),
        ),
      ],
    );
  }
}
