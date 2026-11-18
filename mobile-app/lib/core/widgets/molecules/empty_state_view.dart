import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';
import '../atoms/touch_target.dart';

/// Neutral Empty State View per Blueprint Section 1 Tenet 3
class EmptyStateView extends StatelessWidget {
  final String title;
  final String explanation;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const EmptyStateView({
    super.key,
    this.title = 'No Incidents Found',
    this.explanation = 'Zero safety incidents match the selected site and filters.',
    this.icon = Icons.check_circle_outline,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(icon, size: 40.0, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              title,
              style: AppTypography.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380.0),
              child: Text(
                explanation,
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: AppDimensions.spacing20),
              TouchTarget(
                child: OutlinedButton.icon(
                  onPressed: onCtaPressed,
                  icon: const Icon(Icons.refresh, size: 18.0),
                  label: Text(ctaLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
