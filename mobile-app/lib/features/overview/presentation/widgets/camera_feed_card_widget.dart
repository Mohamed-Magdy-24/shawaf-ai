import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../models/models.dart';

class CameraFeedCardWidget extends StatelessWidget {
  final Camera camera;
  final String? activeZone;
  final String? identifiedSubject;

  const CameraFeedCardWidget({
    super.key,
    required this.camera,
    this.activeZone,
    this.identifiedSubject,
  });

  @override
  Widget build(BuildContext context) {
    final isStreaming =
        camera.healthStatus.toUpperCase() == 'HEALTHY' || camera.isActive;
    final statusColor = isStreaming ? AppColors.emerald : AppColors.crimson;
    final fpsText =
        isStreaming ? '${camera.fpsTarget.toStringAsFixed(1)} FPS' : '0.0 FPS';

    return AppCard(
      padding: AppSpacing.p12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camera.name,
                        style: AppTypography.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(camera.id, style: AppTypography.tabularMonoSmall),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: AppSpacing.roundedXs,
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: statusColor, shape: BoxShape.circle),
                        ),
                        AppSpacing.hGap4,
                        Text(
                          camera.healthStatus.toUpperCase(),
                          style: AppTypography.tabularMonoSmall.copyWith(
                              color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  Text(fpsText, style: AppTypography.tabularMonoSmall),
                ],
              ),
            ],
          ),
          AppSpacing.vGap12,
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.borderline),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.videocam_outlined,
                    color: AppColors.dim.withValues(alpha: 0.4),
                    size: 48,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.2),
                      borderRadius: AppSpacing.roundedXs,
                      border: Border.all(
                          color: AppColors.crimson.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'SAFETY ZONE: ${activeZone ?? "ZONE A"}',
                      style: AppTypography.tabularMonoSmall.copyWith(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.panel.withValues(alpha: 0.8),
                      borderRadius: AppSpacing.roundedXs,
                      border: Border.all(color: AppColors.borderline),
                    ),
                    child: Text(
                      'LAN RESTREAM · GO2RTC',
                      style:
                          AppTypography.tabularMonoSmall.copyWith(fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zone: ${activeZone ?? "Perimeter"}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
              ),
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_outlined,
                      size: 14, color: AppColors.cobalt),
                  AppSpacing.hGap4,
                  Text(
                    identifiedSubject ?? 'MONITORING',
                    style: AppTypography.tabularMonoSmall.copyWith(
                      color: identifiedSubject != null
                          ? AppColors.ink
                          : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
