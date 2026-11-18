import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';
import '../atoms/telemetry_text.dart';
import '../atoms/touch_target.dart';

typedef PTZActionCallback = void Function(double pan, double tilt, double zoom);

/// 8-Direction Industrial PTZ Control Pad with Auto-Release Timeout
/// Conforms to Blueprint Screen W-04
class PTZControlPad extends StatefulWidget {
  final PTZActionCallback onPtzCommand;
  final Duration autoReleaseTimeout;

  const PTZControlPad({
    super.key,
    required this.onPtzCommand,
    this.autoReleaseTimeout = const Duration(milliseconds: 300),
  });

  @override
  State<PTZControlPad> createState() => _PTZControlPadState();
}

class _PTZControlPadState extends State<PTZControlPad> {
  Timer? _releaseTimer;
  String _activeCommand = 'IDLE';

  void _dispatchCommand(double pan, double tilt, double zoom, String label) {
    _releaseTimer?.cancel();
    setState(() => _activeCommand = label);

    widget.onPtzCommand(pan, tilt, zoom);

    _releaseTimer = Timer(widget.autoReleaseTimeout, () {
      if (mounted) {
        setState(() => _activeCommand = 'IDLE');
        widget.onPtzCommand(0.0, 0.0, 0.0); // Stop movement
      }
    });
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  Widget _buildDirButton({
    required IconData icon,
    required double pan,
    required double tilt,
    required String label,
  }) {
    final isActive = _activeCommand == label;
    return TouchTarget(
      minSize: 44.0,
      onTap: () => _dispatchCommand(pan, tilt, 0.0, label),
      child: Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: isActive ? AppColors.statusInfo : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isActive ? Colors.white : AppColors.borderStrong,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 20.0,
          color: isActive ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PTZ CONTROLLER', style: AppTypography.heading2),
              TelemetryText('STATE: $_activeCommand', isSmall: true),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // 3x3 Direction Matrix
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirButton(icon: Icons.north_west, pan: -0.7, tilt: 0.7, label: 'UP_LEFT'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildDirButton(icon: Icons.north, pan: 0.0, tilt: 1.0, label: 'UP'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildDirButton(icon: Icons.north_east, pan: 0.7, tilt: 0.7, label: 'UP_RIGHT'),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirButton(icon: Icons.west, pan: -1.0, tilt: 0.0, label: 'LEFT'),
                  const SizedBox(width: AppDimensions.spacing8),
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Center(
                      child: Icon(Icons.videocam, size: 20.0, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildDirButton(icon: Icons.east, pan: 1.0, tilt: 0.0, label: 'RIGHT'),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirButton(icon: Icons.south_west, pan: -0.7, tilt: -0.7, label: 'DOWN_LEFT'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildDirButton(icon: Icons.south, pan: 0.0, tilt: -1.0, label: 'DOWN'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildDirButton(icon: Icons.south_east, pan: 0.7, tilt: -0.7, label: 'DOWN_RIGHT'),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Zoom Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TouchTarget(
                minSize: 44.0,
                onTap: () => _dispatchCommand(0.0, 0.0, -1.0, 'ZOOM_OUT'),
                child: OutlinedButton.icon(
                  onPressed: () => _dispatchCommand(0.0, 0.0, -1.0, 'ZOOM_OUT'),
                  icon: const Icon(Icons.zoom_out, size: 18.0),
                  label: const Text('ZOOM -'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              TouchTarget(
                minSize: 44.0,
                onTap: () => _dispatchCommand(0.0, 0.0, 1.0, 'ZOOM_IN'),
                child: ElevatedButton.icon(
                  onPressed: () => _dispatchCommand(0.0, 0.0, 1.0, 'ZOOM_IN'),
                  icon: const Icon(Icons.zoom_in, size: 18.0),
                  label: const Text('ZOOM +'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
