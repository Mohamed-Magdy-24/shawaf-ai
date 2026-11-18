import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/atoms/telemetry_text.dart';
import '../../../../core/widgets/atoms/touch_target.dart';
import '../../../incidents/domain/incident.dart';
import '../../domain/camera.dart';
import 'bounding_box_painter.dart';

enum StreamQuality { subStream360p, mainStream1080p }

class WebRtcViewport extends StatefulWidget {
  final CameraModel camera;
  final List<BoundingBox> detections;
  final bool showBoundingBoxes;
  final bool showTelemetryHud;
  final VoidCallback? onSnapshot;
  final VoidCallback? onToggleFullscreen;

  const WebRtcViewport({
    super.key,
    required this.camera,
    this.detections = const [],
    this.showBoundingBoxes = true,
    this.showTelemetryHud = true,
    this.onSnapshot,
    this.onToggleFullscreen,
  });

  @override
  State<WebRtcViewport> createState() => _WebRtcViewportState();
}

class _WebRtcViewportState extends State<WebRtcViewport> {
  StreamQuality _quality = StreamQuality.mainStream1080p;
  Timer? _clockTimer;
  DateTime _currentUtc = DateTime.now().toUtc();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentUtc = DateTime.now().toUtc());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.camera;

    if (camera.status == CameraStreamStatus.offline) {
      return _buildOfflineSlate(camera);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: camera.status == CameraStreamStatus.degraded
              ? AppColors.statusWarning
              : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Simulated Low-Latency WebRTC Stream Canvas (Dark industrial raster)
              CustomPaint(
                painter: _SimulatedStreamRasterPainter(
                  camera: camera,
                  timeTick: _currentUtc.second,
                ),
              ),

              // AI Detection Overlay Layer
              if (widget.showBoundingBoxes && widget.detections.isNotEmpty)
                CustomPaint(
                  painter: BoundingBoxPainter(
                    bboxes: widget.detections,
                    showLabels: true,
                    showConfidence: true,
                  ),
                ),

              // Telemetry HUD Layer (Top)
              if (widget.showTelemetryHud)
                Positioned(
                  top: AppDimensions.spacing8,
                  left: AppDimensions.spacing8,
                  right: AppDimensions.spacing8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: camera.status == CameraStreamStatus.online
                                    ? AppColors.statusNormal
                                    : AppColors.statusWarning,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacing6),
                            TelemetryText(
                              '${camera.name.toUpperCase()}  [${camera.id}]',
                              isSmall: true,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: TelemetryText(
                          DateFormatter.toTelemetryString(_currentUtc),
                          isSmall: true,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Bottom Telemetry Stats Bar
              if (widget.showTelemetryHud)
                Positioned(
                  bottom: AppDimensions.spacing8,
                  left: AppDimensions.spacing8,
                  right: AppDimensions.spacing8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: TelemetryText(
                          'FPS: ${camera.fpsDecoded.toStringAsFixed(1)} | LAT: ${camera.latencyMs.toStringAsFixed(0)}ms | BITRATE: ${(camera.bitrateKbps / 1000).toStringAsFixed(1)}Mbps | DROP: ${camera.droppedFrames}',
                          isSmall: true,
                          color: camera.droppedFrames > 50
                              ? AppColors.statusWarning
                              : AppColors.statusNormal,
                        ),
                      ),
                      // Controls (Snapshot, Quality, Fullscreen)
                      Row(
                        children: [
                          if (widget.onSnapshot != null)
                            TouchTarget(
                              minSize: 32.0,
                              onTap: widget.onSnapshot,
                              tooltip: 'Capture Snapshot',
                              child: Container(
                                padding: const EdgeInsets.all(AppDimensions.spacing4),
                                decoration: BoxDecoration(
                                  color: AppColors.overlayDark,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16.0, color: Colors.white),
                              ),
                            ),
                          const SizedBox(width: AppDimensions.spacing4),
                          TouchTarget(
                            minSize: 32.0,
                            onTap: () {
                              setState(() {
                                _quality = _quality == StreamQuality.mainStream1080p
                                    ? StreamQuality.subStream360p
                                    : StreamQuality.mainStream1080p;
                              });
                            },
                            tooltip: 'Toggle Resolution',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing6,
                                vertical: AppDimensions.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.overlayDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                              child: Text(
                                _quality == StreamQuality.mainStream1080p ? '1080P' : '360P',
                                style: AppTypography.badge.copyWith(fontSize: 9.0),
                              ),
                            ),
                          ),
                          if (widget.onToggleFullscreen != null) ...[
                            const SizedBox(width: AppDimensions.spacing4),
                            TouchTarget(
                              minSize: 32.0,
                              onTap: widget.onToggleFullscreen,
                              tooltip: 'Fullscreen',
                              child: Container(
                                padding: const EdgeInsets.all(AppDimensions.spacing4),
                                decoration: BoxDecoration(
                                  color: AppColors.overlayDark,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                child: const Icon(Icons.fullscreen, size: 16.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

              if (_isConnecting)
                Container(
                  color: AppColors.overlayDark,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.statusInfo),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineSlate(CameraModel camera) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.statusCritical, width: 1.5),
      ),
      child: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam_off,
                  size: 40.0,
                  color: AppColors.statusCritical,
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'OFFLINE — RTSP UNREACHABLE',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.statusCritical,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                TelemetryText(
                  'DEVICE: ${camera.name} (${camera.id})',
                  isSmall: true,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppDimensions.spacing4),
                TelemetryText(
                  'NFR-OBS-002: Coverage Lost Alert Active',
                  isSmall: true,
                  color: AppColors.statusCritical,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimulatedStreamRasterPainter extends CustomPainter {
  final CameraModel camera;
  final int timeTick;

  _SimulatedStreamRasterPainter({required this.camera, required this.timeTick});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with dark industrial surveillance slate
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw subtle grid lines representing camera calibration grid
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw horizon crosshair
    final crossPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 20),
      Offset(size.width / 2, size.height / 2 + 20),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2 - 20, size.height / 2),
      Offset(size.width / 2 + 20, size.height / 2),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SimulatedStreamRasterPainter oldDelegate) {
    return oldDelegate.camera != camera || oldDelegate.timeTick != timeTick;
  }
}

