import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/employee_cubit.dart';
import '../widgets/presence_radar_widget.dart';

class EmployeePresencePage extends StatelessWidget {
  const EmployeePresencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final siteCode = siteState is SiteLoaded ? siteState.selectedSite.code : 'BNF';
        final siteId = siteState is SiteLoaded ? siteState.selectedSite.id : '';

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            padding: AppSpacing.p20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Employee Presence & Radar', style: AppTypography.titleLarge),
                            AppSpacing.hGap8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.elevated,
                                borderRadius: AppSpacing.roundedXs,
                                border: Border.all(color: AppColors.borderline),
                              ),
                              child: Text(
                                siteCode,
                                style: AppTypography.tabularMonoSmall.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vGap4,
                        const Text(
                          'Verified on-site worker tracking: who was detected, on which camera, and in which safety zone.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: AppColors.muted),
                      onPressed: () {
                        if (siteId.isNotEmpty) {
                          context.read<EmployeeCubit>().load(siteId);
                        }
                      },
                    ),
                  ],
                ),
                AppSpacing.vGap20,
                BlocBuilder<EmployeeCubit, EmployeeState>(
                  builder: (context, empState) {
                    if (empState is EmployeeLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
                    }
                    if (empState is EmployeeError) {
                      return ErrorStateView(
                        errorMessage: empState.message,
                        onRetry: () => context.read<EmployeeCubit>().load(siteId),
                      );
                    }

                    final presence = empState is EmployeeLoaded ? empState.presence : <EmployeePresence>[];
                    if (presence.isEmpty) {
                      return AppCard(
                        padding: AppSpacing.p24,
                        child: Column(
                          children: [
                            const Icon(Icons.radar_outlined, size: 48, color: AppColors.dim),
                            AppSpacing.vGap12,
                            const Text('No Active Worker Presence Detected', style: AppTypography.titleMedium),
                            AppSpacing.vGap8,
                            Text(
                              'Identity recognition engine is actively scanning camera feeds. Workers will appear when detected in authorized safety zones.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PresenceRadarWidget(presenceList: presence),
                        AppSpacing.vGap16,
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    Expanded(flex: 2, child: Text('EMPLOYEE ID', style: _headerStyle)),
                                    Expanded(flex: 3, child: Text('NAME', style: _headerStyle)),
                                    Expanded(flex: 3, child: Text('CAMERA / ZONE', style: _headerStyle)),
                                    Expanded(flex: 2, child: Text('CONFIDENCE', style: _headerStyle)),
                                  ],
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: presence.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderline),
                                itemBuilder: (context, index) {
                                  final p = presence[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(p.employeeId, style: AppTypography.tabularMonoSmall.copyWith(fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(flex: 3, child: Text(p.fullName, style: AppTypography.bodySmall)),
                                        Expanded(
                                          flex: 3,
                                          child: Text('${p.cameraId} · ${p.zoneId ?? "General"}', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted)),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('${(p.confidence * 100).toStringAsFixed(1)}%', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
