import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_typography.dart';
import '../../state/ui_state.dart';

/// State Badge Widget that visualizes any of the 10 Mandatory Industrial UI States
class StateBadge extends StatelessWidget {
  final IndustrialUIState state;
  final bool showDetail;

  const StateBadge({
    super.key,
    required this.state,
    this.showDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: state.color.withValues(alpha: 0.6), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.icon, size: 12.0, color: state.color),
          const SizedBox(width: AppDimensions.spacing4),
          Text(
            state.label,
            style: AppTypography.badge.copyWith(color: state.color),
          ),
          if (showDetail) ...[
            const SizedBox(width: AppDimensions.spacing4),
            Text(
              _resolveDetail(),
              style: AppTypography.caption.copyWith(
                color: state.color.withValues(alpha: 0.8),
                fontSize: 10.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _resolveDetail() {
    return switch (state) {
      UILive(:final latencyMs) => '(${latencyMs.toStringAsFixed(0)}ms)',
      UIDelayed(:final latencySeconds) => '(${latencySeconds.toStringAsFixed(1)}s)',
      UIStale(:final elapsedSinceHeartbeat) => '(${elapsedSinceHeartbeat.inSeconds}s ago)',
      UIError(:final errorCode) => '[$errorCode]',
      _ => '',
    };
  }
}
