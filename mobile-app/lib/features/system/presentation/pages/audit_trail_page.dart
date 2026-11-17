import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class AuditTrailPage extends StatelessWidget {
  const AuditTrailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: AppSpacing.p20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Security Audit Trail & Governance Log', style: AppTypography.titleLarge),
            AppSpacing.vGap4,
            const Text(
              'Immutable ledger of operator actions, incident lifecycle transitions, and credential modifications.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.vGap20,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(bottom: BorderSide(color: AppColors.borderline)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('TIMESTAMP', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('ACTOR', style: _headerStyle)),
                        Expanded(flex: 3, child: Text('ACTION / EVENT', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
                      ],
                    ),
                  ),
                  _buildAuditRow('16:07:09', 'admin_corp', 'CAMERA_ONBOARD: BNF Loading Dock Camera 01', 'COMMITTED', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildAuditRow('16:05:22', 'admin_corp', 'OPERATOR_LOGIN: JWT Session Initialized', 'AUTHENTICATED', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildAuditRow('15:48:36', 'system', 'SITE_NAMING_VERIFICATION: BNF & RNF Canonical Enforced', 'AUDITED', AppColors.cobalt),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildAuditRow('11:32:19', 'admin_corp', 'EMPLOYEE_ENROLLMENT: Mohamed Magdy (EMP-6135)', 'ENROLLED', AppColors.emerald),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditRow(String time, String actor, String event, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(time, style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted))),
          Expanded(flex: 2, child: Text(actor, style: AppTypography.tabularMonoSmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(event, style: AppTypography.bodySmall)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedXs,
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: 'JetBrains Mono',
    letterSpacing: 0.8,
  );
}
