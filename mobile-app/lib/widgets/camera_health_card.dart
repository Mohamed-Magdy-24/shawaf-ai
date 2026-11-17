import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CameraHealthCard extends StatelessWidget {
  final Camera camera;
  final VoidCallback? onLiveStreamTap;

  const CameraHealthCard({
    super.key,
    required this.camera,
    this.onLiveStreamTap,
  });

  Color _getHealthColor(String status) {
    switch (status.toUpperCase()) {
      case 'STREAMING':
      case 'ONLINE':
      case 'HEALTHY':
        return AppTheme.successGreen;
      case 'DEGRADED':
        return AppTheme.sev2Amber;
      case 'DISCONNECTED':
      case 'OFFLINE':
      default:
        return AppTheme.sev1Red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor(camera.healthStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.surface,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    camera.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: healthColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        camera.healthStatus.toUpperCase(),
                        style: TextStyle(
                          color: healthColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.speed, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${camera.currentFPS.toStringAsFixed(1)} / ${camera.fpsTarget} FPS',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                if (camera.nvrId != null && camera.nvrId!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.storage, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'NVR: ${camera.nvrId}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (camera.rtspUrl != null && camera.rtspUrl!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.link, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      camera.rtspUrl!,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onLiveStreamTap != null)
                  ElevatedButton.icon(
                    onPressed: onLiveStreamTap,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('LIVE WEBRTC', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
