import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../../models/models.dart';

class AlertCardWidget extends StatelessWidget {
  final SurveillanceEvent alert;
  final VoidCallback onTap;

  const AlertCardWidget({
    super.key,
    required this.alert,
    required this.onTap,
  });

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'NEW':
        return AppColors.sev1Red;
      case 'ACKNOWLEDGED':
        return AppColors.sev2Amber;
      case 'RESOLVED':
        return AppColors.successGreen;
      case 'DISMISSED':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss • dd MMM').format(alert.occurredAt.toLocal());
    final stateColor = _getStateColor(alert.state);
    final isNew = alert.state == 'NEW';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: AppCard(
        onTap: onTap,
        borderColor: isNew ? AppColors.sev1Red.withValues(alpha: 0.6) : AppColors.border,
        borderWidth: isNew ? 1.5 : 1.0,
        padding: AppSpacing.p12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SeverityBadge(
                      severity: alert.severity,
                      isFireAlarm: alert.eventType.contains('FIRE'),
                    ),
                    AppSpacing.hGap8,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.roundedXs,
                      ),
                      child: Text(
                        alert.state,
                        style: AppTypography.labelSmall.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(timeStr, style: AppTypography.bodySmall),
              ],
            ),
            AppSpacing.vGap8,
            Text(
              alert.eventType.replaceAll('_', ' '),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGap4,
            Row(
              children: [
                const Icon(Icons.videocam_outlined, size: 14, color: AppColors.textSecondary),
                AppSpacing.hGap4,
                Text(alert.cameraId, style: AppTypography.bodySmall),
                AppSpacing.hGap16,
                if (alert.zoneId.isNotEmpty) ...[
                  const Icon(Icons.crop_square_outlined, size: 14, color: AppColors.textSecondary),
                  AppSpacing.hGap4,
                  Text(alert.zoneId, style: AppTypography.bodySmall),
                ],
              ],
            ),
            if (alert.employeeName != null && alert.employeeName!.isNotEmpty) ...[
              AppSpacing.vGap4,
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_outlined, size: 14, color: AppColors.primary),
                  AppSpacing.hGap4,
                  Text(
                    'Identified: ${alert.employeeName}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
