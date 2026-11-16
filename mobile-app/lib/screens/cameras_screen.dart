import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CamerasScreen extends StatelessWidget {
  final List<Camera> cameras;
  final List<Zone> zones;
  final Function() onRefresh;

  const CamerasScreen({
    Key? key,
    required this.cameras,
    required this.zones,
    required this.onRefresh,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'STREAMING':
        return AppTheme.successGreen;
      case 'COVERAGE_LOST':
        return AppTheme.sev1Red;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONITORED CAMERAS (${cameras.length})',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 20),
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final cam = cameras[index];
              final statusColor = _getStatusColor(cam.healthStatus);
              final camZones = zones.where((z) => z.cameraId == cam.id).toList();

              return Card(
                color: AppTheme.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.videocam_outlined, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cam.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              border: Border.all(color: statusColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cam.healthStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ID: ${cam.id} | Throughput: ${cam.currentFPS.toStringAsFixed(1)} FPS / ${cam.fpsTarget} FPS Target',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      if (camZones.isNotEmpty) ...[
                        const Text(
                          'CONFIGURED SAFETY ZONES:',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: camZones.map((z) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${z.name} [${z.zoneType}]',
                                style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connecting Zero-Trust WebRTC live stream for ${cam.name}...'),
                                backgroundColor: AppTheme.surfaceLight,
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_circle_outline, color: AppTheme.primaryTeal, size: 16),
                          label: const Text('ZERO-TRUST WEBRTC LIVE STREAM', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
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
