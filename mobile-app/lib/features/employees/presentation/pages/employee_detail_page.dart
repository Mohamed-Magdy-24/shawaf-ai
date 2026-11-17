import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../models/models.dart';

class EmployeeDetailPage extends StatelessWidget {
  final Employee? employee;

  const EmployeeDetailPage({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    final emp = employee;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: Text(emp != null ? 'Employee Profile: ${emp.fullName}' : 'Employee Profile', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employees'),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.p24,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppCard(
              padding: AppSpacing.p24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderline),
                        ),
                        child: const Icon(Icons.person, size: 36, color: AppColors.cobalt),
                      ),
                      AppSpacing.hGap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp?.fullName ?? 'Unknown Worker', style: AppTypography.titleLarge),
                            AppSpacing.vGap4,
                            Text('ID: ${emp?.employeeId ?? "—"} · Department: ${emp?.department ?? "—"}',
                                style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap24,
                  const Divider(color: AppColors.borderline),
                  AppSpacing.vGap16,
                  _buildDetailRow('Site ID', emp?.siteId ?? '—'),
                  _buildDetailRow('Enrollment Source', emp?.sourceType ?? 'MANUAL_UPLOAD'),
                  _buildDetailRow('Status', emp?.isActive == true ? 'ACTIVE (ENROLLED)' : 'INACTIVE'),
                  _buildDetailRow('Face Vector', '512-dim Normalized Cosine Embedding (AES Encrypted)'),
                  AppSpacing.vGap24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: 'RETURN TO DIRECTORY',
                        variant: ButtonVariant.outlined,
                        onPressed: () => context.go('/employees'),
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
