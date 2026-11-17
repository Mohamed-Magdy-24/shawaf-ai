import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? valueColor;
  final Color? subtitleColor;

  const KpiCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.valueColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          AppSpacing.vGap8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.displayLarge.copyWith(
                  fontFamily: 'JetBrains Mono',
                  color: valueColor ?? AppColors.ink,
                  fontSize: 22,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (subtitleColor ?? AppColors.muted).withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedXs,
                ),
                child: Text(
                  subtitle,
                  style: AppTypography.tabularMonoSmall.copyWith(
                    color: subtitleColor ?? AppColors.muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
