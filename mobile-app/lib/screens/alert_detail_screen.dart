import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/zone_painter.dart';

class AlertDetailScreen extends StatefulWidget {
  final SurveillanceEvent event;
  final Function(String action, String note) onAction;

  const AlertDetailScreen({
    Key? key,
    required this.event,
    required this.onAction,
  }) : super(key: key);

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  void _handleAction(String action) async {
    final note = _noteController.text.trim();
    if (action == 'DISMISS' && note.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FR-ALT-008: Mandatory audit note required for dismissal (minimum 10 characters).'),
          backgroundColor: AppTheme.sev1Red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onAction(action, note);
      setState(() {
        _isSubmitting = false;
        widget.event.state = action == 'ACKNOWLEDGE'
            ? 'ACKNOWLEDGED'
            : (action == 'DISMISS' ? 'DISMISSED' : 'ESCALATED');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action $action recorded for Event ${widget.event.id}'),
            backgroundColor: AppTheme.surfaceLight,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: $e'),
            backgroundColor: AppTheme.sev1Red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss UTC').format(e.occurredAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('ALERT #${e.trackId} DETAIL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Synthetic Snapshot Preview with Spatial Zone Overlay
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Simulated floor canvas
                    CustomPaint(
                      size: const Size(double.infinity, 220),
                      painter: ZonePainter(
                        zones: [
                          Zone(
                            id: e.zoneId,
                            siteId: e.siteId,
                            cameraId: e.cameraId,
                            name: e.metadata['zone_name'] ?? 'Zone 01',
                            zoneType: 'INTRUSION',
                            severity: e.severity,
                            polygon: [
                              [0.35, 0.30],
                              [0.85, 0.30],
                              [0.85, 0.85],
                              [0.35, 0.85],
                            ],
                            isActive: true,
                          ),
                        ],
                        activeEvents: [e],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CAM: ${e.cameraId} | ${e.state}',
                          style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LAW 151/2020 PRIVACY MASKED',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _infoRow('Event ID', e.id),
                  _infoRow('Site ID', e.siteId),
                  _infoRow('Event Type', e.eventType),
                  _infoRow('Severity', e.severity),
                  _infoRow('Track ID', '#${e.trackId}'),
                  _infoRow('Detection Confidence', '${(e.confidence * 100).toStringAsFixed(1)}%'),
                  _infoRow('Timestamp', timeStr),
                  if (e.metadata['inference_lat_ms'] != null)
                    _infoRow('Edge Inference Latency', '${e.metadata['inference_lat_ms']} ms'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Audit Note input
            const Text(
              'OPERATOR AUDIT NOTE',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter incident notes, authorization ID, or reason for dismissal...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryTeal),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // FR-ALT-008 Action Buttons
            const Text(
              'WORKFLOW TRANSITIONS (FR-ALT-008)',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : () => _handleAction('ACKNOWLEDGE'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('ACKNOWLEDGE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: const Color(0xFF042F2E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : () => _handleAction('DISMISS'),
                    icon: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
                    label: const Text('DISMISS', style: TextStyle(color: AppTheme.textSecondary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : () => _handleAction('ESCALATE'),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text('ESCALATE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sev1Red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
