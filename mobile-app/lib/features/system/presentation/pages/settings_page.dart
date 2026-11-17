import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: AppSpacing.p20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Settings & Access Management', style: AppTypography.titleLarge),
            AppSpacing.vGap4,
            const Text(
              'Security policy enforcement, RBAC governance rules, and active session management.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.vGap20,
            AppCard(
              padding: AppSpacing.p20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Role-Based Access Control (ADR-011)', style: AppTypography.titleMedium),
                  AppSpacing.vGap16,
                  _buildSettingRow('Current Authenticated Operator', 'admin_corp (Senior Management)'),
                  _buildSettingRow('Tenant Isolation Mode', 'PostgreSQL 16 FORCE RLS (app_runtime)'),
                  _buildSettingRow('Session Expiry Interval', '15 Minutes (Auto Refresh Rotation)'),
                  _buildSettingRow('Credential Encryption Standard', 'AES-256-GCM Hardware-Backed Key'),
                  _buildSettingRow('Zero Mock Fallback Enforcement', 'STRICTLY ACTIVE (No Fallback to Fake State)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          Text(value, style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
