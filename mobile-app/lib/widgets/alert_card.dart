import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'severity_badge.dart';

class AlertCard extends StatelessWidget {
  final SurveillanceEvent alert;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'NEW':
        return AppTheme.sev1Red;
      case 'ACKNOWLEDGED':
        return AppTheme.sev2Amber;
      case 'RESOLVED':
        return AppTheme.successGreen;
      case 'DISMISSED':
        return AppTheme.textMuted;
      default:
        return AppTheme.primaryTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss • dd MMM').format(alert.occurredAt.toLocal());
    final stateColor = _getStateColor(alert.state);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: alert.state == 'NEW' ? AppTheme.sev1Red.withValues(alpha: 0.6) : AppTheme.border,
          width: alert.state == 'NEW' ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SeverityBadge(severity: alert.severity),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stateColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: stateColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          alert.state.toUpperCase(),
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                alert.eventType.replaceAll('_', ' '),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.videocam_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    alert.cameraId,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  if (alert.zoneId.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.shield_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alert.metadata['zone_name']?.toString() ?? alert.zoneId,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence: ${(alert.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (alert.trackId > 0)
                    Text(
                      'Track ID: #${alert.trackId}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
