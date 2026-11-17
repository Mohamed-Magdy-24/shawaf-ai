import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../cameras/presentation/cubit/camera_stream_cubit.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';

class LiveControlRoomPage extends StatelessWidget {
  const LiveControlRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final site = siteState is SiteLoaded ? siteState.selectedSite : null;
        final siteCode = site?.code ?? 'BNF';

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
                            const Text('Live Control Room', style: AppTypography.titleLarge),
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
                          'Primary live video operations with low-latency WebRTC streaming and active zone overlays.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppButton(
                          label: 'CAMERA WALL (GRID)',
                          variant: ButtonVariant.outlined,
                          onPressed: () => context.go('/camera-wall'),
                        ),
                        AppSpacing.hGap8,
                        AppButton(
                          label: '+ ONBOARD CAMERA',
                          variant: ButtonVariant.primary,
                          onPressed: () => context.push('/cameras/add'),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.vGap20,
                BlocBuilder<CameraStreamCubit, CameraStreamState>(
                  builder: (context, camState) {
                    final cameras = camState is CameraStreamLoaded ? camState.cameras : [];
                    if (cameras.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.videocam_off_outlined,
                        title: 'No Cameras Monitored',
                        description: 'No active RTSP feeds attached to $siteCode.',
                        actionLabel: 'ADD CAMERA',
                        onAction: () => context.push('/cameras/add'),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: isWide ? 3 : 1,
                              child: AppCard(
                                padding: AppSpacing.p16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      height: 380,
                                      decoration: BoxDecoration(
                                        color: AppColors.canvas,
                                        borderRadius: AppSpacing.roundedSm,
                                        border: Border.all(color: AppColors.borderline),
                                      ),
                                      child: Stack(
                                        children: [
                                          const Center(
                                            child: Icon(Icons.videocam_outlined, size: 64, color: AppColors.cobalt),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.panel,
                                                borderRadius: AppSpacing.roundedXs,
                                                border: Border.all(color: AppColors.borderline),
                                              ),
                                              child: Text(
                                                'PRIMARY FEED · ${cameras.first.name}',
                                                style: AppTypography.tabularMonoSmall.copyWith(
                                                  color: AppColors.ink,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.crimson.withValues(alpha: 0.2),
                                                borderRadius: AppSpacing.roundedXs,
                                                border: Border.all(color: AppColors.crimson.withValues(alpha: 0.5)),
                                              ),
                                              child: Text(
                                                'RESTRICTED ZONE ACTIVE',
                                                style: AppTypography.tabularMonoSmall.copyWith(
                                                  color: AppColors.crimson,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.emerald.withValues(alpha: 0.2),
                                                borderRadius: AppSpacing.roundedXs,
                                                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                                              ),
                                              child: Text(
                                                'WEBRTC 15.0 FPS (0.2s)',
                                                style: AppTypography.tabularMonoSmall.copyWith(
                                                  color: AppColors.emerald,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppSpacing.vGap16,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Status: ACTIVE STREAM', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald)),
                                        Text('Audio: DISABLED (SAFETY CONSOLE)', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isWide) ...[
                              AppSpacing.hGap16,
                              SizedBox(
                                width: 280,
                                child: AppCard(
                                  padding: AppSpacing.p16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Available Cameras', style: AppTypography.titleSmall),
                                      AppSpacing.vGap12,
                                      ...cameras.map((c) => Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppColors.canvas,
                                                borderRadius: AppSpacing.roundedSm,
                                                border: Border.all(color: AppColors.borderline),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(c.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                                  Text(c.id, style: AppTypography.tabularMonoSmall.copyWith(fontSize: 10, color: AppColors.muted)),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
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
}
