import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/camera_management_cubit.dart';

class AddCameraPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController rtspController;
  final TextEditingController fpsController;

  AddCameraPage({super.key})
      : nameController = TextEditingController(),
        rtspController = TextEditingController(),
        fpsController = TextEditingController(text: '15');

  void _probeConnection(BuildContext context) async {
    final siteCubit = context.read<SiteCubit>();
    if (siteCubit.state is! SiteLoaded) return;
    final siteId = (siteCubit.state as SiteLoaded).selectedSite.id;

    final url = rtspController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an RTSP URL to test'), backgroundColor: AppColors.sev1Red),
      );
      return;
    }

    final res = await context.read<CameraManagementCubit>().testConnection(siteId, {'rtsp_url': url});
    final reachable = res['reachable'] == true;
    final latency = res['latency_ms'] ?? 0;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reachable ? 'Reachable! Handshake latency: ${latency}ms' : 'Unreachable: ${res["error"]}'),
          backgroundColor: reachable ? AppColors.successGreen : AppColors.sev1Red,
        ),
      );
    }
  }

  void _saveCamera(BuildContext context) async {
    final siteCubit = context.read<SiteCubit>();
    if (siteCubit.state is! SiteLoaded) return;
    final siteId = (siteCubit.state as SiteLoaded).selectedSite.id;

    final name = nameController.text.trim();
    final url = rtspController.text.trim();
    final fps = int.tryParse(fpsController.text.trim()) ?? 15;

    if (name.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera name and RTSP URL are required'), backgroundColor: AppColors.sev1Red),
      );
      return;
    }

    try {
      await context.read<CameraManagementCubit>().addCamera(
            siteId,
            name: name,
            rtspUrl: url,
            fpsTarget: fps,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera onboarded successfully'), backgroundColor: AppColors.successGreen),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add camera: $e'), backgroundColor: AppColors.sev1Red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Onboard RTSP Camera', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Camera Parameters', style: AppTypography.titleMedium),
                  AppSpacing.vGap16,
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Camera Name (e.g. Slag Pit Cam 01)'),
                  ),
                  AppSpacing.vGap16,
                  TextField(
                    controller: rtspController,
                    decoration: const InputDecoration(labelText: 'RTSP Stream URL'),
                  ),
                  AppSpacing.vGap16,
                  TextField(
                    controller: fpsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target Frame Rate (FPS)'),
                  ),
                  AppSpacing.vGap16,
                  AppButton(
                    label: 'TEST RTSP CONNECTION',
                    icon: Icons.network_check_rounded,
                    variant: ButtonVariant.outlined,
                    onPressed: () => _probeConnection(context),
                  ),
                ],
              ),
            ),
            AppSpacing.vGap24,
            AppButton(
              label: 'REGISTER CAMERA APPLIANCE',
              icon: Icons.check_circle_outline,
              variant: ButtonVariant.primary,
              onPressed: () => _saveCamera(context),
            ),
          ],
        ),
      ),
    );
  }
}
