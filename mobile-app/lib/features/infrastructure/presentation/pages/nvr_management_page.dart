import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';

class NvrManagementPage extends StatelessWidget {
  const NvrManagementPage({super.key});

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
                            const Text('NVR Management', style: AppTypography.titleLarge),
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
                          'Hardware Network Video Recorder appliances, channel multiplexing, and ONVIF discovery.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    AppButton(
                      label: '+ ADD NVR APPLIANCE',
                      variant: ButtonVariant.primary,
                      onPressed: () => context.push('/cameras/add'),
                    ),
                  ],
                ),
                AppSpacing.vGap20,
                AppCard(
                  padding: AppSpacing.p24,
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
                                child: const Icon(Icons.dns_outlined, color: AppColors.cobalt, size: 24),
                              ),
                              AppSpacing.hGap12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$siteCode Primary NVR Appliance', style: AppTypography.titleMedium),
                                  const Text('Dahua / Hikvision Embedded NVR (32-Channel)', style: AppTypography.bodySmall),
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
                            child: const Text('ONLINE', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                          ),
                        ],
                      ),
                      AppSpacing.vGap16,
                      const Divider(color: AppColors.borderline),
                      AppSpacing.vGap16,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('RTSP Multichannel Stream Proxy', style: AppTypography.bodySmall),
                          Text('ACTIVE (go2rtc sidecar)', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald)),
                        ],
                      ),
                      AppSpacing.vGap8,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Credential Storage', style: AppTypography.bodySmall),
                          Text('AES-256-GCM ENCRYPTED', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald)),
                        ],
                      ),
                      AppSpacing.vGap8,
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Connected Camera Channels', style: AppTypography.bodySmall),
                          Text('3 Channels Active', style: AppTypography.tabularMonoSmall),
                        ],
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
