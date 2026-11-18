import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';

enum BadgeVariant {
  critical,
  warning,
  normal,
  info,
  stale,
  subtle,
}

class IndustrialBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool isPulsing;

  const IndustrialBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.info,
    this.icon,
    this.isPulsing = false,
  });

  Color _resolveColor() {
    switch (variant) {
      case BadgeVariant.critical:
        return AppColors.statusCritical;
      case BadgeVariant.warning:
        return AppColors.statusWarning;
      case BadgeVariant.normal:
        return AppColors.statusNormal;
      case BadgeVariant.info:
        return AppColors.statusInfo;
      case BadgeVariant.stale:
        return AppColors.statusStale;
      case BadgeVariant.subtle:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.0, color: color),
            const SizedBox(width: AppDimensions.spacing4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
