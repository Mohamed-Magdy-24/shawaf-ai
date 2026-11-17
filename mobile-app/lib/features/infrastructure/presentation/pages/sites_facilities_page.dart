import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';

class SitesFacilitiesPage extends StatelessWidget {
  const SitesFacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final sites = siteState is SiteLoaded ? siteState.sites : [];

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            padding: AppSpacing.p20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Sites & Facilities Management', style: AppTypography.titleLarge),
                AppSpacing.vGap4,
                const Text(
                  'Enterprise physical infrastructure hierarchy. Strict multi-tenant isolation enforced via PostgreSQL 16 RLS.',
                  style: AppTypography.bodySmall,
                ),
                AppSpacing.vGap20,
                ...sites.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
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
                                        color: AppColors.elevated,
                                        borderRadius: AppSpacing.roundedXs,
                                        border: Border.all(color: AppColors.borderline),
                                      ),
                                      child: const Icon(Icons.factory_outlined, color: AppColors.cobalt, size: 20),
                                    ),
                                    AppSpacing.hGap12,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Site Code: ${s.code}', style: AppTypography.titleMedium),
                                        Text(s.name, style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
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
                                  child: const Text('ACTIVE FACILITY', style: TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                                ),
                              ],
                            ),
                            AppSpacing.vGap16,
                            const Divider(color: AppColors.borderline),
                            AppSpacing.vGap12,
                            Text('UUID: ${s.id}', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim, fontSize: 11)),
                            AppSpacing.vGap4,
                            Text('Timezone: ${s.timezone}', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim, fontSize: 11)),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
