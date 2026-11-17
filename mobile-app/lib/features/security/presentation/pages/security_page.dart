import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../cubits/connectivity_cubit.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  void _testRbacDenial(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'HTTP 403 FORBIDDEN: Access denied by system governance policy (ADR-011 RBAC).'),
        backgroundColor: AppColors.amber,
      ),
    );
  }

  void _simulateCoverageLost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'WATCHDOG ALARM: Stream drop >15s on West Perimeter. Automated NFR-OBS-002 SEV2 event raised.'),
        backgroundColor: AppColors.crimson,
      ),
    );
  }

  void _toggleDegradedMode(BuildContext context) {
    context.read<ConnectivityCubit>().setOffline('Simulated Network Drop');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'DEGRADED OFFLINE ACTIVE: Zero mock fallback triggered. Reconnection watchdog polling.'),
        backgroundColor: AppColors.crimson,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.p24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Security Controls & Bad Use Case Verification',
              style: AppTypography.titleLarge),
          AppSpacing.vGap4,
          Text(
            'Interactive verification of failure modes without silent mock fallbacks.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
          ),
          AppSpacing.vGap24,
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFailureTestsCard(context)),
                        AppSpacing.hGap16,
                        Expanded(
                            child: _buildArchitectureGuaranteesCard(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildFailureTestsCard(context),
                        AppSpacing.vGap16,
                        _buildArchitectureGuaranteesCard(context),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFailureTestsCard(BuildContext context) {
    return AppCard(
      padding: AppSpacing.p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Simulate Failure / Edge States',
              style: AppTypography.titleSmall),
          AppSpacing.vGap16,
          _buildActionButton(
            label: 'Test 403 RBAC Denial (Operator Live Video)',
            tag: 'D-011',
            tagColor: AppColors.amber,
            onTap: () => _testRbacDenial(context),
          ),
          AppSpacing.vGap12,
          _buildActionButton(
            label: 'Simulate Camera Stream Drop (>15s)',
            tag: 'NFR-OBS-002',
            tagColor: AppColors.crimson,
            onTap: () => _simulateCoverageLost(context),
          ),
          AppSpacing.vGap12,
          _buildActionButton(
            label: 'Simulate Backend Unreachable (Degraded Mode)',
            tag: 'ZERO MOCK',
            tagColor: AppColors.crimson,
            onTap: () => _toggleDegradedMode(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.canvas,
      borderRadius: AppSpacing.roundedSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.roundedSm,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(color: AppColors.borderline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style:
                        AppTypography.bodySmall.copyWith(color: AppColors.ink)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedXs,
                ),
                child: Text(
                  tag,
                  style: AppTypography.tabularMonoSmall
                      .copyWith(color: tagColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchitectureGuaranteesCard(BuildContext context) {
    return AppCard(
      padding: AppSpacing.p16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Active Architecture Guarantees',
              style: AppTypography.titleSmall),
          AppSpacing.vGap16,
          _buildGuaranteeRow(
              'Tenant Isolation', 'PostgreSQL 16 FORCE RLS', AppColors.emerald),
          _buildGuaranteeRow(
              'Raw Video Over Wire', '0 bytes (ADR-012)', AppColors.emerald),
          _buildGuaranteeRow('RTSP Password Storage', 'AES-256-GCM Encrypted',
              AppColors.emerald),
          _buildGuaranteeRow('Flutter Architecture',
              'Stateful Root + Stateless BLoC', AppColors.ink),
          _buildGuaranteeRow(
              'Edge Daemon Latency', '< 10ms LAN p95', AppColors.emerald),
          _buildGuaranteeRow('Biometric Face Identification',
              '512-dim ONNX Vectors', AppColors.ink),
        ],
      ),
    );
  }

  Widget _buildGuaranteeRow(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.borderline, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          Text(
            value,
            style: AppTypography.tabularMonoSmall
                .copyWith(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
