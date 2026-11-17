import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/camera_stream_cubit.dart';
import '../widgets/camera_tile.dart';

class CamerasPage extends StatelessWidget {
  const CamerasPage({super.key});

  void _showStreamDialog(BuildContext context, Camera camera) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Live WebRTC: ${camera.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surfaceLight,
              child: const Center(
                child: Icon(Icons.videocam_rounded, size: 64, color: AppColors.primary),
              ),
            ),
            AppSpacing.vGap12,
            Text('Target FPS: ${camera.fpsTarget} • Current FPS: ${camera.currentFPS}'),
            Text('RTSP Path: ${camera.rtspUrl ?? "Internal RTSP Sidecar"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CLOSE'),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.cobalt,
            foregroundColor: AppColors.ink,
            onPressed: () => context.push('/cameras/add'),
            child: const Icon(Icons.add_a_photo_outlined),
          ),
          body: BlocBuilder<CameraStreamCubit, CameraStreamState>(
            builder: (context, cameraState) {
              if (cameraState is CameraStreamInitial) {
                context.read<CameraStreamCubit>().loadCameras(currentSite.id);
                return ListView.builder(
                  padding: AppSpacing.p16,
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                );
              }

              if (cameraState is CameraStreamLoading) {
                return ListView.builder(
                  padding: AppSpacing.p16,
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

              if (cameraState is CameraStreamEmpty) {
                return EmptyStateView(
                  icon: Icons.videocam_off_outlined,
                  title: 'No Cameras Monitored',
                  description: 'No active RTSP camera feeds provisioned for ${currentSite.code}.',
                  actionLabel: 'ADD CAMERA',
                  onAction: () => context.push('/cameras/add'),
                );
              }

              final cameras = (cameraState as CameraStreamLoaded).cameras;

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => context.read<CameraStreamCubit>().loadCameras(currentSite.id),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: cameras.length,
                  itemBuilder: (context, index) {
                    final cam = cameras[index];
                    return CameraTile(
                      camera: cam,
                      onStreamTap: () => _showStreamDialog(context, cam),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
