import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DegradedBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isOffline;

  const DegradedBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isOffline ? AppColors.sev1Red : AppColors.sev2Amber;
    final fg = isOffline ? AppColors.textPrimary : const Color(0xFF451A03);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      color: bg,
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.warning_amber_rounded,
            size: 18,
            color: fg,
          ),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: fg,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(40, 32),
              ),
              child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
