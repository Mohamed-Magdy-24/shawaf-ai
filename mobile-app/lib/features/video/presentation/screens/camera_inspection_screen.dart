import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/atoms/telemetry_text.dart';
import '../../../../core/widgets/organisms/ptz_control_pad.dart';
import '../../../incidents/domain/incident.dart';
import '../../domain/camera.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../widgets/webrtc_viewport.dart';

class CameraInspectionScreen extends StatefulWidget {
  final CameraModel camera;
  final String siteId;

  const CameraInspectionScreen({
    super.key,
    required this.camera,
    required this.siteId,
  });

  @override
  State<CameraInspectionScreen> createState() => _CameraInspectionScreenState();
}

class _CameraInspectionScreenState extends State<CameraInspectionScreen> {
  bool _showDetections = true;
  bool _showHud = true;

  final List<BoundingBox> _mockActiveDetections = const [
    BoundingBox(
      x1: 0.28,
      y1: 0.35,
      x2: 0.48,
      y2: 0.75,
      label: 'PERSON',
      confidence: 0.934,
      trackId: 108,
    ),
    BoundingBox(
      x1: 0.33,
      y1: 0.36,
      x2: 0.42,
      y2: 0.48,
      label: 'HELMET_OK',
      confidence: 0.912,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.camera.name, style: AppTypography.heading2),
            TelemetryText(
              '${widget.camera.id}  •  ${widget.camera.zoneId}',
              isSmall: true,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showDetections ? Icons.layers : Icons.layers_clear,
              color: _showDetections ? AppColors.statusInfo : AppColors.textSecondary,
            ),
            tooltip: 'Toggle AI Detections',
            onPressed: () => setState(() => _showDetections = !_showDetections),
          ),
          IconButton(
            icon: Icon(
              _showHud ? Icons.info_outline : Icons.info,
              color: _showHud ? AppColors.statusInfo : AppColors.textSecondary,
            ),
            tooltip: 'Toggle Telemetry HUD',
            onPressed: () => setState(() => _showHud = !_showHud),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Viewport
            WebRtcViewport(
              camera: widget.camera,
              detections: _mockActiveDetections,
              showBoundingBoxes: _showDetections,
              showTelemetryHud: _showHud,
              onSnapshot: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Snapshot captured: ${widget.camera.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      style: AppTypography.body,
                    ),
                    backgroundColor: AppColors.surfacePanel,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),

            // Telemetry & PTZ Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Camera Info Panel
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePanel,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STREAM TELEMETRY', style: AppTypography.heading2),
                        const SizedBox(height: AppDimensions.spacing12),
                        _buildRow('STATUS', widget.camera.status.value),
                        _buildRow('FPS', '${widget.camera.fpsDecoded.toStringAsFixed(1)} FPS'),
                        _buildRow('BITRATE', '${(widget.camera.bitrateKbps / 1000).toStringAsFixed(1)} Mbps'),
                        _buildRow('LATENCY', '${widget.camera.latencyMs.toStringAsFixed(0)} ms'),
                        _buildRow('DROPPED', '${widget.camera.droppedFrames} frames'),
                        _buildRow('RESOLUTION', widget.camera.resolution),
                        _buildRow('ZONE', widget.camera.zoneId),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing16),

                // PTZ Joystick Controller
                Expanded(
                  flex: 1,
                  child: PTZControlPad(
                    onPtzCommand: (pan, tilt, zoom) {
                      context.read<CameraBloc>().add(
                            SendPtzCommandEvent(pan: pan, tilt: tilt, zoom: zoom),
                          );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          TelemetryText(value, isSmall: true),
        ],
      ),
    );
  }
}
