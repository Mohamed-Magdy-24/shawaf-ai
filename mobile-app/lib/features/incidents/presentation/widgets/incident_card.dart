import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/atoms/industrial_badge.dart';
import '../../../../core/widgets/atoms/telemetry_text.dart';
import '../../domain/incident.dart';

/// Gloved-Thumb Operable Incident Card (>= 64dp Touch Target Height)
/// Conforms to Blueprint Screen M-03
class IncidentCard extends StatelessWidget {
  final SafetyIncident incident;
  final VoidCallback onTap;
  final VoidCallback? onLiveStreamTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    this.onLiveStreamTap,
  });

  BadgeVariant _mapSeverityBadge(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.criticalFire:
      case IncidentSeverity.critical:
        return BadgeVariant.critical;
      case IncidentSeverity.warning:
        return BadgeVariant.warning;
      case IncidentSeverity.info:
        return BadgeVariant.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = incident.severity == IncidentSeverity.criticalFire
        ? AppColors.statusCritical
        : (incident.status == IncidentStatus.newStatus
            ? AppColors.borderStrong
            : AppColors.borderSubtle);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: borderColor,
          width: incident.severity == IncidentSeverity.criticalFire ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Badges and Elapsed Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IndustrialBadge(
                        label: incident.eventType,
                        variant: _mapSeverityBadge(incident.severity),
                        icon: incident.severity == IncidentSeverity.criticalFire
                            ? Icons.local_fire_department
                            : Icons.warning_amber_rounded,
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      IndustrialBadge(
                        label: incident.status.value,
                        variant: incident.status == IncidentStatus.newStatus
                            ? BadgeVariant.critical
                            : (incident.status == IncidentStatus.acknowledged
                                ? BadgeVariant.warning
                                : BadgeVariant.subtle),
                      ),
                    ],
                  ),
                  TelemetryText(
                    DateFormatter.toRelativeTime(incident.occurredAtUtc),
                    isSmall: true,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // Middle: Camera & Zone Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.videocam_outlined,
                        size: 24.0,
                        color: incident.severity == IncidentSeverity.criticalFire
                            ? AppColors.statusCritical
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.cameraName,
                          style: AppTypography.heading2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        TelemetryText(
                          'ID: ${incident.id}  •  ZONE: ${incident.zoneId}',
                          isSmall: true,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (onLiveStreamTap != null) ...[
                    const SizedBox(width: AppDimensions.spacing8),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: AppColors.statusInfo, size: 32.0),
                      onPressed: onLiveStreamTap,
                      tooltip: 'View Live Stream',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),

              // Bottom Telemetry Bar: Model Version & Confidence
              Row(
                children: [
                  TelemetryText(
                    'MODEL: ${incident.modelId} (${incident.modelVersion})',
                    isSmall: true,
                  ),
                  const Spacer(),
                  TelemetryText(
                    'CONF: ${(incident.confidence * 100).toStringAsFixed(1)}%',
                    isSmall: true,
                    color: incident.confidence >= 0.9
                        ? AppColors.statusNormal
                        : AppColors.statusWarning,
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
