import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../cameras/presentation/cubit/camera_stream_cubit.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';

class CameraWallPage extends StatelessWidget {
  const CameraWallPage({super.key});

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
                            const Text('Camera Wall Grid', style: AppTypography.titleLarge),
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
                          'Multi-camera concurrent operational matrix. Monitored in real-time with automatic stream watchdog.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.borderline),
                          ),
                          child: const Text('GRID: 2x2 MATRIX', style: AppTypography.tabularMonoSmall),
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
                        icon: Icons.grid_view_rounded,
                        title: 'No Cameras Available',
                        description: 'Attach cameras to populate the camera wall grid.',
                        actionLabel: 'REFRESH',
                        onAction: () {
                          if (siteState is SiteLoaded) {
                            context.read<CameraStreamCubit>().loadCameras(siteState.selectedSite.id);
                          }
                        },
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth > 800 ? 2 : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.45,
                          ),
                          itemCount: cameras.length.clamp(1, 4),
                          itemBuilder: (context, index) {
                            final cam = cameras[index];
                            return AppCard(
                              padding: AppSpacing.p12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(cam.name, style: AppTypography.titleSmall),
                                      Text(
                                        'CH ${index + 1} · 15 FPS',
                                        style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.vGap8,
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.canvas,
                                        borderRadius: AppSpacing.roundedSm,
                                        border: Border.all(color: AppColors.borderline),
                                      ),
                                      child: Stack(
                                        children: [
                                          const Center(
                                            child: Icon(Icons.videocam_outlined, size: 36, color: AppColors.dim),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: const BoxDecoration(
                                                color: AppColors.panel,
                                                borderRadius: AppSpacing.roundedXs,
                                              ),
                                              child: Text(cam.id, style: const TextStyle(fontSize: 9, fontFamily: 'JetBrains Mono')),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
