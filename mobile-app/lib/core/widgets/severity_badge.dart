import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool isFireAlarm;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.isFireAlarm = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;

    switch (severity.toUpperCase()) {
      case 'SEV1':
      case 'CRITICAL':
        bg = AppColors.sev1RedGlow;
        fg = AppColors.sev1Red;
        border = AppColors.sev1Red;
        icon = isFireAlarm ? Icons.local_fire_department : Icons.warning_rounded;
        break;
      case 'SEV2':
      case 'HIGH':
        bg = AppColors.sev2AmberGlow;
        fg = AppColors.sev2Amber;
        border = AppColors.sev2Amber;
        icon = Icons.error_outline_rounded;
        break;
      case 'SEV3':
      case 'MEDIUM':
      default:
        bg = AppColors.sev3BlueGlow;
        fg = AppColors.sev3Blue;
        border = AppColors.sev3Blue;
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          AppSpacing.hGap4,
          Text(
            severity.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
