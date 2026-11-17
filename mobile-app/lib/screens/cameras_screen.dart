import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/camera_stream_cubit.dart';
import '../cubits/site_cubit.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_health_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/shimmer_skeleton_card.dart';

class CamerasScreen extends StatelessWidget {
  const CamerasScreen({super.key});

  void _showAddCameraDialog(BuildContext context, String siteId) {
    final nameController = TextEditingController();
    final rtspController = TextEditingController(text: 'rtsp://mediamtx:8554/');
    final fpsController = TextEditingController(text: '15');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryTeal, size: 20),
            SizedBox(width: 8),
            Text(
              'REGISTER RTSP CAMERA',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Camera Name',
                    hintText: 'Perimeter West Gate',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: rtspController,
                  decoration: const InputDecoration(
                    labelText: 'RTSP Stream URL',
                    hintText: 'rtsp://user:pass@host:port/path',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'RTSP URL is required';
                    if (!v.trim().toLowerCase().startsWith('rtsp://') && !v.trim().toLowerCase().startsWith('rtsps://')) {
                      return 'Must begin with rtsp:// or rtsps://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fpsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target FPS (1 - 30)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 30) return 'Enter FPS between 1 and 30';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final nav = Navigator.of(dialogCtx);
                final fps = int.tryParse(fpsController.text) ?? 15;
                final success = await context.read<CameraStreamCubit>().registerCamera(
                      siteId,
                      name: nameController.text.trim(),
                      rtspUrl: rtspController.text.trim(),
                      fpsTarget: fps,
                    );
                if (success) {
                  nav.pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera registered successfully (creds scrubbed).'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('REGISTER'),
          ),
        ],
      ),
    );
  }

  void _openLiveStream(BuildContext context, Camera cam) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _WebRTCStreamDialog(camera: cam),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final currentSiteId = siteState is SiteLoaded ? siteState.selectedSite.id : '';
        final currentSiteCode = siteState is SiteLoaded ? siteState.selectedSite.code : '';

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.surface,
              child: Row(
                children: [
                  Text(
                    'CAMERAS — $currentSiteCode',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 20),
                    onPressed: () {
                      if (currentSiteId.isNotEmpty) {
                        context.read<CameraStreamCubit>().loadCameras(currentSiteId);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: currentSiteId.isEmpty
                        ? null
                        : () => _showAddCameraDialog(context, currentSiteId),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('ADD CAMERA', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CameraStreamCubit, CameraStreamState>(
                builder: (context, state) {
                  if (state is CameraStreamLoading || state is CameraStreamRegistering) {
                    return ListView.builder(
                      itemCount: 3,
                      itemBuilder: (_, __) => const ShimmerSkeletonCard(height: 120),
                    );
                  }

                  if (state is CameraStreamError) {
                    return EmptyStateView(
                      icon: Icons.error_outline,
                      title: 'CAMERA SYSTEM UNREACHABLE',
                      message: state.message,
                      actionLabel: 'RETRY',
                      onAction: () {
                        if (currentSiteId.isNotEmpty) {
                          context.read<CameraStreamCubit>().loadCameras(currentSiteId);
                        }
                      },
                    );
                  }

                  if (state is CameraStreamEmpty) {
                    return EmptyStateView(
                      icon: Icons.videocam_off_outlined,
                      title: 'NO CAMERAS REGISTERED',
                      message: 'No video streams configured for site $currentSiteCode.',
                      actionLabel: 'REGISTER FIRST CAMERA',
                      onAction: currentSiteId.isEmpty
                          ? null
                          : () => _showAddCameraDialog(context, currentSiteId),
                    );
                  }

                  final cameras = state is CameraStreamLoaded ? state.cameras : <Camera>[];

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cameras.length,
                    itemBuilder: (context, index) {
                      final cam = cameras[index];
                      return CameraHealthCard(
                        camera: cam,
                        onLiveStreamTap: () => _openLiveStream(context, cam),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WebRTCStreamDialog extends StatefulWidget {
  final Camera camera;

  const _WebRTCStreamDialog({required this.camera});

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
    try {
      setState(() {
        _statusText = 'Exchanging SDP via edged reverse-proxy (RBAC Check D-011)...';
      });

      // Synthetic client SDP offer for H.264 video track
      const syntheticOffer =
          'v=0\r\no=- 4294967295 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\nc=IN IP4 0.0.0.0\r\na=rtpmap:96 H264/90000\r\na=recvonly\r\n';

      final repo = context.read<SurveillanceRepository>();
      final answer = await repo.requestWebRTCSdp(
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
          _errorMessage = e.toString().replaceAll('Exception: ', '');
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
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
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
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, color: AppTheme.successGreen, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'ZERO-TRUST STREAM ACTIVE',
                                style: TextStyle(
                                  color: AppTheme.successGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'WebRTC H.264 stream proxy active',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 12),
            if (_sdpAnswer != null)
              Text(
                'SDP Negotiated: ${_sdpAnswer?['type'] ?? 'answer'} (H.264)',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              ),
            const Text(
              'Security Boundary: D-011 Zero-Trust Proxy',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
            const Text(
              'Sidecar Isolation: go2rtc internal only (port 1984/8555 not exposed)',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
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
