import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';

class SafetyZonesPage extends StatelessWidget {
  const SafetyZonesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final siteCode = siteState is SiteLoaded ? siteState.selectedSite.code : 'BNF';

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
                            const Text('Safety Zones Configuration', style: AppTypography.titleLarge),
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
                          'Spatial polygon boundaries, restricted area rules, and PPE compliance monitoring zones.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.vGap20,
                AppCard(
                  padding: AppSpacing.p20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.crimson.withValues(alpha: 0.15),
                                  borderRadius: AppSpacing.roundedXs,
                                  border: Border.all(color: AppColors.crimson.withValues(alpha: 0.3)),
                                ),
                                child: const Icon(Icons.warning_amber_rounded, color: AppColors.crimson, size: 20),
                              ),
                              AppSpacing.hGap12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Zone A — Heavy Equipment Crane Line', style: AppTypography.titleMedium),
                                  Text('Rule: RESTRICTED_AREA_ENTRY (SEV1 Critical)', style: AppTypography.bodySmall.copyWith(color: AppColors.crimson)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: AppSpacing.roundedXs,
                              border: Border.all(color: AppColors.emerald),
                            ),
                            child: const Text('ENFORCED', style: TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                          ),
                        ],
                      ),
                      AppSpacing.vGap16,
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(color: AppColors.borderline),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.polyline_outlined, color: AppColors.crimson, size: 40),
                              AppSpacing.vGap8,
                              Text('Polygon: [(110,150), (290,150), (260,85), (140,85)]',
                                  style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted)),
                              AppSpacing.vGap4,
                              const Text('Camera Target: BNF Warehouse Loading Dock (bnf_cam_01)',
                                  style: AppTypography.tabularMonoSmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
