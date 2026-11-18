import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';
import '../atoms/telemetry_text.dart';
import '../atoms/touch_target.dart';

/// Explicit Error State View with Error Code and Retry Action
class ErrorStateView extends StatelessWidget {
  final String errorCode;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    required this.errorCode,
    required this.message,
    this.onRetry,
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
                color: AppColors.statusCritical.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.statusCritical.withValues(alpha: 0.4)),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 40.0,
                color: AppColors.statusCritical,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            TelemetryText(
              'ERR_CODE: $errorCode',
              style: AppTypography.caption.copyWith(color: AppColors.statusCritical),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Telemetry Connection Failure',
              style: AppTypography.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Text(
                message,
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacing20),
              TouchTarget(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceRaised,
                    side: const BorderSide(color: AppColors.borderStrong),
                  ),
                  icon: const Icon(Icons.refresh, size: 18.0),
                  label: const Text('Retry Connection'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
