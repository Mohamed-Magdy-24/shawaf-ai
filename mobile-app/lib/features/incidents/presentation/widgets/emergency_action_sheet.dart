import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/atoms/industrial_badge.dart';
import '../../../../core/widgets/atoms/telemetry_text.dart';
import '../../domain/incident.dart';

/// FR-ALT-008 Emergency Incident Action Sheet Modal
/// Conforms to Blueprint Screen M-04
class EmergencyActionSheet extends StatefulWidget {
  final SafetyIncident incident;
  final String currentOperatorId;
  final VoidCallback onAcknowledge;
  final VoidCallback onResolve;
  final ValueChanged<String> onDismiss;
  final VoidCallback onWatchLiveStream;

  const EmergencyActionSheet({
    super.key,
    required this.incident,
    required this.currentOperatorId,
    required this.onAcknowledge,
    required this.onResolve,
    required this.onDismiss,
    required this.onWatchLiveStream,
  });

  static Future<void> show(
    BuildContext context, {
    required SafetyIncident incident,
    required String currentOperatorId,
    required VoidCallback onAcknowledge,
    required VoidCallback onResolve,
    required ValueChanged<String> onDismiss,
    required VoidCallback onWatchLiveStream,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfacePanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        side: BorderSide(color: AppColors.borderStrong, width: 1.0),
      ),
      builder: (context) => EmergencyActionSheet(
        incident: incident,
        currentOperatorId: currentOperatorId,
        onAcknowledge: onAcknowledge,
        onResolve: onResolve,
        onDismiss: onDismiss,
        onWatchLiveStream: onWatchLiveStream,
      ),
    );
  }

  @override
  State<EmergencyActionSheet> createState() => _EmergencyActionSheetState();
}

class _EmergencyActionSheetState extends State<EmergencyActionSheet> {
  final _dismissalController = TextEditingController();
  String _selectedReason = 'False Positive / Sensor Noise';
  bool _isDismissMode = false;
  String? _dismissError;

  final List<String> _commonDismissalReasons = [
    'False Positive / Sensor Noise',
    'Authorized Worker / Permitted Override',
    'Scheduled Drill / Safety Test',
    'Environmental Glare / Shadow Anomaly',
    'Other (Specify in audit log)',
  ];

  @override
  void dispose() {
    _dismissalController.dispose();
    super.dispose();
  }

  void _handleDismissSubmit() {
    final finalReason = _selectedReason == 'Other (Specify in audit log)'
        ? _dismissalController.text.trim()
        : _selectedReason;

    if (finalReason.isEmpty) {
      setState(() {
        _dismissError = 'FR-ALT-008: Mandatory dismissal reason required.';
      });
      return;
    }

    widget.onDismiss(finalReason);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final canAcknowledge = incident.status == IncidentStatus.newStatus;
    final canResolve = incident.status == IncidentStatus.newStatus ||
        incident.status == IncidentStatus.acknowledged;
    final canDismiss = canResolve;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.spacing20,
        right: AppDimensions.spacing20,
        top: AppDimensions.spacing16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacing24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY ACTION SHEET',
                        style: AppTypography.heading1.copyWith(
                          color: incident.severity == IncidentSeverity.criticalFire
                              ? AppColors.statusCritical
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      TelemetryText(
                        'INCIDENT ID: ${incident.id}  •  SITE: ${incident.siteId}',
                        isSmall: true,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
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
            const Divider(color: AppColors.borderSubtle, height: AppDimensions.spacing24),

            // Incident Metadata Inspector
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildMetaRow('EVENT TYPE', incident.eventType, isBold: true),
                  _buildMetaRow('CAMERA', '${incident.cameraName} (${incident.cameraId})'),
                  _buildMetaRow('ZONE', incident.zoneId),
                  _buildMetaRow('TIMESTAMP', DateFormatter.toTelemetryString(incident.occurredAtUtc)),
                  _buildMetaRow(
                    'AI CONFIDENCE',
                    '${(incident.confidence * 100).toStringAsFixed(1)}% [${incident.modelId}]',
                  ),
                  if (incident.acknowledgedBy != null)
                    _buildMetaRow(
                      'ACKNOWLEDGED BY',
                      '${incident.acknowledgedBy} (${DateFormatter.toRelativeTime(incident.acknowledgedAtUtc!)})',
                    ),
                  if (incident.resolvedBy != null)
                    _buildMetaRow('RESOLVED BY', incident.resolvedBy!),
                  if (incident.dismissalReason != null)
                    _buildMetaRow('DISMISSAL REASON', incident.dismissalReason!),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),

            // Live Stream Button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.minTouchTarget,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onWatchLiveStream();
                },
                icon: const Icon(Icons.videocam, color: AppColors.statusInfo),
                label: const Text('WATCH LIVE WEBRTC STREAM'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            // Action Buttons / Dismiss Form
            if (_isDismissMode) ...[
              Text(
                'DISMISS INCIDENT — MANDATORY REASON (FR-ALT-008)',
                style: AppTypography.caption.copyWith(color: AppColors.statusWarning),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                dropdownColor: AppColors.surfaceRaised,
                decoration: const InputDecoration(labelText: 'Select Justification'),
                items: _commonDismissalReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: AppTypography.body)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              if (_selectedReason == 'Other (Specify in audit log)') ...[
                const SizedBox(height: AppDimensions.spacing8),
                TextField(
                  controller: _dismissalController,
                  decoration: const InputDecoration(
                    labelText: 'Specify Reason',
                    hintText: 'Enter reason for audit trail...',
                  ),
                ),
              ],
              if (_dismissError != null) ...[
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  _dismissError!,
                  style: AppTypography.caption.copyWith(color: AppColors.statusCritical),
                ),
              ],
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isDismissMode = false),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCritical),
                      onPressed: _handleDismissSubmit,
                      child: const Text('CONFIRM DISMISS'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Normal Action Buttons
              if (canAcknowledge) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.gloveTouchTargetHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusWarning,
                      foregroundColor: AppColors.surfaceCanvas,
                    ),
                    onPressed: () {
                      widget.onAcknowledge();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 24.0),
                    label: const Text(
                      'ACKNOWLEDGE INCIDENT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
              ],

              if (canResolve) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.minTouchTarget,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusNormal,
                      foregroundColor: AppColors.surfaceCanvas,
                    ),
                    onPressed: () {
                      widget.onResolve();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.done_all, size: 20.0),
                    label: const Text('RESOLVE INCIDENT'),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
              ],

              if (canDismiss) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.minTouchTarget,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusCritical),
                      foregroundColor: AppColors.statusCritical,
                    ),
                    onPressed: () => setState(() => _isDismissMode = true),
                    icon: const Icon(Icons.close, size: 20.0),
                    label: const Text('DISMISS WITH REASON'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.0,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isBold
                  ? AppTypography.body.copyWith(fontWeight: FontWeight.w600)
                  : AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}
