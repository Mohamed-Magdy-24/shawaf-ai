import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final bgColor = isOffline ? AppTheme.sev1Red : AppTheme.sev2Amber;
    final fgColor = isOffline ? Colors.white : const Color(0xFF451A03);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bgColor,
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.warning_amber_rounded,
            color: fgColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOffline ? 'OFFLINE (ADR-016): $message' : 'DEGRADED CONNECTION: $message',
              style: TextStyle(
                color: fgColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: fgColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}
