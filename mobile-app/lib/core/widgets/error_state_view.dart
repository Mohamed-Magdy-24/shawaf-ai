import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class ErrorStateView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final IconData icon;

  const ErrorStateView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.p16,
              decoration: BoxDecoration(
                color: AppColors.sev1RedGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sev1Red, width: 1.5),
              ),
              child: Icon(icon, size: 48, color: AppColors.sev1Red),
            ),
            AppSpacing.vGap16,
            Text(
              'Connection or System Error',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: AppColors.sev1Red),
            ),
            AppSpacing.vGap8,
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.vGap24,
            AppButton(
              label: 'RETRY CONNECTION',
              icon: Icons.refresh,
              onPressed: onRetry,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
