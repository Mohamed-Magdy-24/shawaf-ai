import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';

/// Formatted monospace telemetry text with tabular digits
/// for timestamps, bitrates, frame rates, IPs, coordinates, and latency
class TelemetryText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final bool isSmall;

  const TelemetryText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = isSmall ? AppTypography.telemetrySmall : AppTypography.telemetry;
    return Text(
      text,
      style: baseStyle.copyWith(
        color: color ?? style?.color ?? AppColors.textPrimary,
      ),
    );
  }
}
