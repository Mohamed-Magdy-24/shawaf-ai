import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/alert_inbox_cubit.dart';

class AlertDetailPage extends StatelessWidget {
  final SurveillanceEvent event;
  final TextEditingController noteController;

  AlertDetailPage({
    super.key,
    required this.event,
  }) : noteController = TextEditingController();

  void _execute(BuildContext context, String action) async {
    final note = noteController.text.trim();
    if (action == 'DISMISS' && note.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FR-ALT-008: Mandatory audit note required (min 10 characters).'),
          backgroundColor: AppColors.sev1Red,
        ),
      );
      return;
    }

    final siteCubit = context.read<SiteCubit>();
    final siteId = siteCubit.state is SiteLoaded
        ? (siteCubit.state as SiteLoaded).selectedSite.id
        : event.siteId;

    try {
      final success = await context.read<AlertInboxCubit>().executeAction(
            siteId,
            event.id,
            action,
            note,
          );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert transitioned to $action'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e'), backgroundColor: AppColors.sev1Red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss UTC').format(event.occurredAt.toUtc());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Incident ${event.id}', style: AppTypography.titleLarge),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SeverityBadge(severity: event.severity),
                      Text(timeStr, style: AppTypography.monospace),
                    ],
                  ),
                  AppSpacing.vGap16,
                  Text(event.eventType.replaceAll('_', ' '), style: AppTypography.headlineMedium),
                  AppSpacing.vGap8,
                  Text('Camera: ${event.cameraId} • Zone: ${event.zoneId}', style: AppTypography.bodyMedium),
                  if (event.employeeName != null) ...[
                    AppSpacing.vGap8,
                    Text('Identified Personnel: ${event.employeeName}',
                        style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
                  ],
                ],
              ),
            ),
            AppSpacing.vGap16,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Audit & Resolution Note (FR-ALT-008)', style: AppTypography.titleSmall),
                  AppSpacing.vGap8,
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter reason or action details (min 10 characters for dismissal)...',
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vGap24,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'ACKNOWLEDGE',
                    variant: ButtonVariant.secondary,
                    onPressed: () => _execute(context, 'ACKNOWLEDGED'),
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: AppButton(
                    label: 'DISMISS',
                    variant: ButtonVariant.destructive,
                    onPressed: () => _execute(context, 'DISMISSED'),
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: AppButton(
                    label: 'RESOLVE',
                    variant: ButtonVariant.primary,
                    onPressed: () => _execute(context, 'RESOLVED'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
