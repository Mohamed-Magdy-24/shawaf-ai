import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';
import '../../state/ui_state.dart';
import '../molecules/empty_state_view.dart';
import '../molecules/error_state_view.dart';
import '../molecules/skeleton_loader.dart';

/// Comprehensive State Boundary Builder that handles all 10 Industrial UI States
class StateBoundaryBuilder extends StatelessWidget {
  final IndustrialUIState state;
  final Widget Function(BuildContext) contentBuilder;
  final VoidCallback? onRetry;

  const StateBoundaryBuilder({
    super.key,
    required this.state,
    required this.contentBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      UILoading(:final message) => _buildLoading(context, message),
      UIEmpty(:final explanation) => EmptyStateView(
          explanation: explanation,
          onCtaPressed: onRetry,
          ctaLabel: onRetry != null ? 'Refresh' : null,
        ),
      UIError(:final errorCode, :final message) => ErrorStateView(
          errorCode: errorCode,
          message: message,
          onRetry: onRetry,
        ),
      UIOffline(:final reason) => _buildNotice(
          context,
          icon: Icons.cloud_off,
          title: 'DEVICE OFFLINE',
          subtitle: reason,
          color: AppColors.statusCritical,
          canRetry: true,
        ),
      UIUnauthorized(:final message) => _buildNotice(
          context,
          icon: Icons.lock_outline,
          title: 'ACCESS RESTRICTED',
          subtitle: message,
          color: AppColors.statusWarning,
        ),
      UIPermissionDenied(:final detail) => _buildNotice(
          context,
          icon: Icons.block,
          title: 'PERMISSION DENIED',
          subtitle: detail,
          color: AppColors.statusCritical,
        ),
      UILive() ||
      UIDelayed() ||
      UIStale() ||
      UIPartiallyAvailable() =>
        Stack(
          children: [
            contentBuilder(context),
            if (state is UIStale || state is UIDelayed || state is UIPartiallyAvailable)
              Positioned(
                top: AppDimensions.spacing8,
                right: AppDimensions.spacing8,
                child: _buildStateBanner(state),
              ),
          ],
        ),
    };
  }

  Widget _buildLoading(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonLoader(width: 240.0, height: 28.0),
            const SizedBox(height: AppDimensions.spacing12),
            const SkeletonLoader(width: 320.0, height: 16.0),
            const SizedBox(height: AppDimensions.spacing8),
            const SkeletonLoader(width: 180.0, height: 16.0),
            const SizedBox(height: AppDimensions.spacing16),
            Text(message, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool canRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, size: 40.0, color: color),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(title, style: AppTypography.heading2.copyWith(color: color)),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              subtitle,
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacing20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16.0),
                label: const Text('Reconnect'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateBanner(IndustrialUIState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: state.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.icon, size: 12.0, color: state.color),
          const SizedBox(width: AppDimensions.spacing4),
          Text(state.label, style: AppTypography.badge.copyWith(color: state.color)),
        ],
      ),
    );
  }
}
