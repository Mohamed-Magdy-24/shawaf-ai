import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../models/models.dart';

class CameraDetailPage extends StatelessWidget {
  final Camera? camera;

  const CameraDetailPage({super.key, this.camera});

  @override
  Widget build(BuildContext context) {
    final cam = camera;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: Text(cam != null ? 'Camera Details: ${cam.name}' : 'Camera Details', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cameras'),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.p24,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: AppCard(
              padding: AppSpacing.p24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cam?.name ?? 'Camera Appliance', style: AppTypography.titleLarge),
                          AppSpacing.vGap4,
                          Text('ID: ${cam?.id ?? "—"}', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cam?.isActive == true ? AppColors.emerald : AppColors.crimson).withValues(alpha: 0.15),
                          borderRadius: AppSpacing.roundedXs,
                          border: Border.all(color: cam?.isActive == true ? AppColors.emerald : AppColors.crimson),
                        ),
                        child: Text(
                          cam?.healthStatus.toUpperCase() ?? 'STREAMING',
                          style: AppTypography.tabularMonoSmall.copyWith(
                            color: cam?.isActive == true ? AppColors.emerald : AppColors.crimson,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap24,
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(color: AppColors.borderline),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_outlined, size: 48, color: AppColors.cobalt),
                          AppSpacing.vGap8,
                          Text('Low-Latency RTSP-to-WebRTC Stream Proxy', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.vGap24,
                  _buildDetailRow('Site ID', cam?.siteId ?? '—'),
                  _buildDetailRow('Target FPS', '${cam?.fpsTarget ?? 15} FPS'),
                  _buildDetailRow('RTSP Path', cam?.rtspUrl != null && cam!.rtspUrl!.isNotEmpty ? 'rtsp://***:***@lan-stream' : 'go2rtc stream proxy'),
                  _buildDetailRow('Stream Health', cam?.healthStatus ?? 'HEALTHY'),
                  _buildDetailRow('Encryption', 'AES-256-GCM RTSP Credential Storage'),
                  AppSpacing.vGap24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: 'RETURN TO CAMERAS',
                        variant: ButtonVariant.outlined,
                        onPressed: () => context.go('/cameras'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          Text(value, style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
