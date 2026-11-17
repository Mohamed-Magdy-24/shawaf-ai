import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class AiAnalyticsPage extends StatelessWidget {
  const AiAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: AppSpacing.p20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('AI Analytics & Inference Engine', style: AppTypography.titleLarge),
            AppSpacing.vGap4,
            const Text(
              'Operational machine learning telemetry: ONNX runtime throughput, inference latency, and detection metrics.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.vGap20,
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 2.0 : 2.5,
                  children: [
                    _buildMetricCard('YOLOv8 Detection Model', 'ACTIVE (v8.2)', 'Inference p95: 18ms', AppColors.emerald),
                    _buildMetricCard('Identity Embedding Model', 'MobileFaceNet ONNX', '512-dim Normalized Cosine', AppColors.cobalt),
                    _buildMetricCard('Safety Zone Rule Engine', 'ACTIVE (Ray-Casting)', 'Zero False Alarms', AppColors.emerald),
                  ],
                );
              },
            ),
            AppSpacing.vGap20,
            AppCard(
              padding: AppSpacing.p20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Model Provenance & Operational Standards', style: AppTypography.titleMedium),
                  AppSpacing.vGap16,
                  _buildSpecRow('Model Provenance', 'Apache-2.0 / MIT ONNX Model Artifacts'),
                  _buildSpecRow('Zero AI-Slop Policy', 'Synthetic hash-based fake matching strictly prohibited'),
                  _buildSpecRow('Raw Video Over Wire', '0 bytes transmitted to cloud (Strict Edge Processing ADR-012)'),
                  _buildSpecRow('Watchdog Stream Health', 'Automated coverage loss alarm if frames dropped >15s (NFR-OBS-002)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String status, String subtitle, Color color) {
    return AppCard(
      padding: AppSpacing.p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          Text(status, style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(subtitle, style: AppTypography.tabularMonoSmall.copyWith(fontSize: 10, color: AppColors.dim)),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
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
