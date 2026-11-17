import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum SystemStatus { online, degraded, offline }

class StatusPill extends StatelessWidget {
  final SystemStatus status;
  final String? customLabel;

  const StatusPill({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;
    String labelText;

    switch (status) {
      case SystemStatus.online:
        dotColor = AppColors.successGreen;
        bgColor = AppColors.successGreen.withValues(alpha: 0.15);
        labelText = customLabel ?? 'ONLINE';
        break;
      case SystemStatus.degraded:
        dotColor = AppColors.sev2Amber;
        bgColor = AppColors.sev2Amber.withValues(alpha: 0.15);
        labelText = customLabel ?? 'DEGRADED';
        break;
      case SystemStatus.offline:
        dotColor = AppColors.sev1Red;
        bgColor = AppColors.sev1Red.withValues(alpha: 0.15);
        labelText = customLabel ?? 'OFFLINE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.hGap8,
          Text(
            labelText,
            style: AppTypography.labelSmall.copyWith(
              color: dotColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
