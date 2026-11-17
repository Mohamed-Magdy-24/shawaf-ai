import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../models/models.dart';

class CameraTile extends StatelessWidget {
  final Camera camera;
  final VoidCallback onStreamTap;

  const CameraTile({
    super.key,
    required this.camera,
    required this.onStreamTap,
  });

  SystemStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'STREAMING':
      case 'ONLINE':
      case 'HEALTHY':
        return SystemStatus.online;
      case 'DEGRADED':
        return SystemStatus.degraded;
      default:
        return SystemStatus.offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: AppCard(
        padding: AppSpacing.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_outlined, color: AppColors.primary, size: 20),
                      AppSpacing.hGap8,
                      Expanded(
                        child: Text(
                          camera.name,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(status: _mapStatus(camera.healthStatus), customLabel: camera.healthStatus),
              ],
            ),
            AppSpacing.vGap12,
            Row(
              children: [
                Text('FPS: ${camera.currentFPS.toStringAsFixed(1)} / ${camera.fpsTarget}',
                    style: AppTypography.monospace),
                const Spacer(),
                AppButton(
                  label: 'LIVE WEBRTC',
                  icon: Icons.play_arrow_rounded,
                  variant: ButtonVariant.outlined,
                  onPressed: onStreamTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
