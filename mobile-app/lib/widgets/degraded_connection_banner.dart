import 'package:flutter/material.dart';
import '../core/widgets/degraded_banner.dart';

class DegradedConnectionBanner extends StatelessWidget {
  final String message;
  final bool isOffline;
  final VoidCallback? onRetry;

  const DegradedConnectionBanner({
    super.key,
    required this.message,
    this.isOffline = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DegradedBanner(
      message: isOffline ? 'OFFLINE (ADR-016): $message' : 'DEGRADED CONNECTION: $message',
      isOffline: isOffline,
      onRetry: onRetry,
    );
  }
}
