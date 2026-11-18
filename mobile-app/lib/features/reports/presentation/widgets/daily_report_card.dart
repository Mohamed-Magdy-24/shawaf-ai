import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/daily_report.dart';

/// Industrial High-Density Daily Safety Shift Report Card
/// Displays shift metrics, Cairo cutoff badge, and compliance percentage.
class DailyReportCard extends StatelessWidget {
  final DailyReport report;
  final VoidCallback? onExportPressed;

  const DailyReportCard({
    super.key,
    required this.report,
    this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool compliant = report.isCompliant;
    final Color scoreColor = compliant ? AppColors.statusNormal : AppColors.statusCritical;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: compliant ? AppColors.borderSubtle : AppColors.statusCritical.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assessment_outlined, color: AppColors.accentCyan, size: 20),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(
                    'DAILY SAFETY SHIFT REPORT',
                    style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Text(
                  '${report.timezone} (23:59:59)',
                  style: AppTypography.telemetrySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${report.safetyCompliancePercent.toStringAsFixed(1)}%',
                style: AppTypography.display.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  compliant ? 'COMPLIANT (Target >= 85%)' : 'NON-COMPLIANT (Below Target)',
                  style: AppTypography.caption.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('TOTAL', '${report.totalIncidents}', AppColors.textPrimary),
              _buildMetricColumn('CRITICAL', '${report.criticalIncidents}', AppColors.statusCritical),
              _buildMetricColumn('WARNINGS', '${report.warningIncidents}', AppColors.statusWarning),
              _buildMetricColumn('RESOLVED', '${report.resolvedIncidents}', AppColors.statusNormal),
              _buildMetricColumn('AVG ACK', '${report.avgAckSeconds.toStringAsFixed(0)}s', AppColors.accentCyan),
            ],
          ),
          if (onExportPressed != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.minTouchTarget,
              child: OutlinedButton.icon(
                onPressed: onExportPressed,
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('EXPORT AUDIT REPORT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderStrong),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading1.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
