import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'alert_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  final Site currentSite;
  final List<SurveillanceEvent> alerts;
  final Function() onRefresh;
  final Function(SurveillanceEvent, String, String) onAlertAction;

  const InboxScreen({
    Key? key,
    required this.currentSite,
    required this.alerts,
    required this.onRefresh,
    required this.onAlertAction,
  }) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _selectedSeverity = 'ALL';

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'SEV1':
        return AppTheme.sev1Red;
      case 'SEV2':
        return AppTheme.sev2Amber;
      case 'SEV3':
        return AppTheme.sev3Blue;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = widget.alerts.where((a) {
      if (_selectedSeverity == 'ALL') return true;
      return a.severity == _selectedSeverity;
    }).toList();

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.surface,
          child: Row(
            children: [
              const Text('FILTER: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              ...['ALL', 'SEV1', 'SEV2', 'SEV3'].map((sev) {
                final isSelected = _selectedSeverity == sev;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(sev, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF042F2E) : AppTheme.textPrimary)),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryTeal,
                    backgroundColor: AppTheme.surfaceLight,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSeverity = sev);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 20),
                onPressed: widget.onRefresh,
              ),
            ],
          ),
        ),

        // Alert list
        Expanded(
          child: filteredAlerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 54, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'ALL INDUSTRIAL SAFETY ZONES SECURE',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zero pending alerts for ${widget.currentSite.code}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];
                    final sevColor = _getSeverityColor(alert.severity);
                    final timeStr = DateFormat('HH:mm:ss').format(alert.occurredAt);

                    return Card(
                      color: AppTheme.surface,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: alert.state == 'NEW' ? sevColor.withValues(alpha: 0.7) : AppTheme.border,
                          width: alert.state == 'NEW' ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlertDetailScreen(
                                event: alert,
                                onAction: (action, note) {
                                  widget.onAlertAction(alert, action, note);
                                },
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: sevColor.withValues(alpha: 0.2),
                                      border: Border.all(color: sevColor),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      alert.severity,
                                      style: TextStyle(color: sevColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: alert.state == 'NEW'
                                          ? AppTheme.primaryTeal.withValues(alpha: 0.2)
                                          : AppTheme.border,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      alert.state,
                                      style: TextStyle(
                                        color: alert.state == 'NEW' ? AppTheme.primaryTeal : AppTheme.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                alert.eventType.replaceAll('_', ' '),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Zone: ${alert.metadata['zone_name'] ?? alert.zoneId} | Camera: ${alert.cameraId}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Track #${alert.trackId} | Conf: ${(alert.confidence * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'REVIEW AUDIT',
                                    style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.primaryTeal),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
