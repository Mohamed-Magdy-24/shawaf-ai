import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/camera_stream_cubit.dart';

class CamerasPage extends StatelessWidget {
  const CamerasPage({super.key});

  void _showStreamDialog(BuildContext context, Camera camera) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: BorderSide(color: AppColors.borderline),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: AppSpacing.roundedXs,
                border: Border.all(color: AppColors.borderline),
              ),
              child: const Icon(Icons.videocam, color: AppColors.cobalt, size: 18),
            ),
            AppSpacing.hGap12,
            Expanded(child: Text(camera.name, style: AppTypography.titleMedium)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.borderline),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_outlined, size: 48, color: AppColors.cobalt),
                      AppSpacing.vGap12,
                      Text(
                        'WebRTC Low-Latency Stream (0.2s glass-to-glass)',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        'Camera ID: ${camera.id}',
                        style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vGap16,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target Frame Rate', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                  Text('${camera.fpsTarget} FPS', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.ink)),
                ],
              ),
              AppSpacing.vGap8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RTSP Masked Path', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                  Text(
                    camera.rtspUrl != null && camera.rtspUrl!.isNotEmpty
                        ? 'rtsp://***:***@lan-stream'
                        : 'Internal go2rtc Proxy',
                    style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CLOSE', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        if (siteState is SiteInitial) {
          context.read<SiteCubit>().loadSites();
          return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        if (siteState is SiteError) {
          final isAuthError = siteState.message.toLowerCase().contains('unauthorized') ||
              siteState.message.toLowerCase().contains('401') ||
              siteState.message.toLowerCase().contains('session expired');
          return ErrorStateView(
            errorMessage: siteState.message,
            actionLabel: isAuthError ? 'SIGN IN' : 'RETRY',
            onRetry: () {
              if (isAuthError) {
                context.go('/login');
              } else {
                context.read<SiteCubit>().loadSites();
              }
            },
          );
        }

        if (siteState is! SiteLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        final currentSite = siteState.selectedSite;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            padding: AppSpacing.p20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, currentSite),
                AppSpacing.vGap20,
                BlocBuilder<CameraStreamCubit, CameraStreamState>(
                  builder: (context, cameraState) {
                    if (cameraState is CameraStreamInitial) {
                      context.read<CameraStreamCubit>().loadCameras(currentSite.id);
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                      );
                    }

                    if (cameraState is CameraStreamLoading) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                      );
                    }

                    if (cameraState is CameraStreamError) {
                      return ErrorStateView(
                        errorMessage: cameraState.message,
                        onRetry: () => context.read<CameraStreamCubit>().loadCameras(currentSite.id),
                      );
                    }

                    final cameras = cameraState is CameraStreamLoaded ? cameraState.cameras : <Camera>[];

                    if (cameras.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.videocam_off_outlined,
                        title: 'No Cameras Monitored',
                        description: 'No active RTSP camera feeds provisioned for ${currentSite.code}.',
                        actionLabel: 'ADD CAMERA',
                        onAction: () => context.push('/cameras/add'),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: cameras.length,
                          itemBuilder: (context, index) {
                            final cam = cameras[index];
                            final isHealthy = cam.healthStatus.toUpperCase() == 'HEALTHY' || cam.isActive;
                            return AppCard(
                              padding: AppSpacing.p16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cam.name,
                                              style: AppTypography.titleSmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              cam.id,
                                              style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isHealthy
                                              ? AppColors.emerald.withValues(alpha: 0.15)
                                              : AppColors.crimson.withValues(alpha: 0.15),
                                          borderRadius: AppSpacing.roundedXs,
                                          border: Border.all(
                                            color: isHealthy ? AppColors.emerald : AppColors.crimson,
                                          ),
                                        ),
                                        child: Text(
                                          isHealthy ? 'STREAMING' : 'LOST',
                                          style: AppTypography.tabularMonoSmall.copyWith(
                                            color: isHealthy ? AppColors.emerald : AppColors.crimson,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.canvas,
                                      borderRadius: AppSpacing.roundedXs,
                                      border: Border.all(color: AppColors.borderline),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.videocam_outlined,
                                            color: isHealthy ? AppColors.cobalt : AppColors.dim,
                                            size: 24,
                                          ),
                                          AppSpacing.hGap8,
                                          Text(
                                            '${cam.fpsTarget} FPS · RTSP/WebRTC',
                                            style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.dim),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          label: 'VIEW STREAM',
                                          variant: ButtonVariant.outlined,
                                          onPressed: () => _showStreamDialog(context, cam),
                                        ),
                                      ),
                                    ],
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

  Widget _buildHeader(BuildContext context, Site site) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Cameras & NVRs', style: AppTypography.titleLarge),
                AppSpacing.hGap8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: AppSpacing.roundedXs,
                    border: Border.all(color: AppColors.borderline),
                  ),
                  child: Text(
                    site.code,
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
              'Encrypted RTSP credentials, zero-trust go2rtc proxy, and NFR-OBS-002 stream watchdog.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        AppButton(
          label: '+ ADD CAMERA / NVR IP',
          variant: ButtonVariant.primary,
          onPressed: () => context.push('/cameras/add'),
        ),
      ],
    );
  }
}
