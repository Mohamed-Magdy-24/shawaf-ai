import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../alerts/presentation/cubit/alert_inbox_cubit.dart';
import '../../../cameras/presentation/cubit/camera_stream_cubit.dart';
import '../../../employees/presentation/cubit/employee_cubit.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../widgets/camera_feed_card_widget.dart';
import '../widgets/kpi_card_widget.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        if (siteState is SiteInitial) {
          context.read<SiteCubit>().loadSites();
          return ListView.builder(
            padding: AppSpacing.p24,
            itemCount: 4,
            itemBuilder: (_, __) => const ShimmerSkeletonCard(),
          );
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
          return ListView.builder(
            padding: AppSpacing.p24,
            itemCount: 4,
            itemBuilder: (_, __) => const ShimmerSkeletonCard(),
          );
        }

        final currentSite = siteState.selectedSite;

        return SingleChildScrollView(
          padding: AppSpacing.p24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, currentSite),
              AppSpacing.vGap24,
              _buildKpiStrip(context, currentSite),
              AppSpacing.vGap24,
              _buildContentGrid(context, currentSite),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Site site) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Operations Overview', style: AppTypography.titleLarge),
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
                'On-premise edge telemetry, active safety zones, and real-time incident queue.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        Row(
          children: [
            AppButton(
              label: '+ ADD CAMERA / NVR IP',
              variant: ButtonVariant.primary,
              onPressed: () => context.push('/cameras/add'),
            ),
            AppSpacing.hGap8,
            AppButton(
              label: '+ ENROLL EMPLOYEE',
              variant: ButtonVariant.outlined,
              onPressed: () => context.go('/employees'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiStrip(BuildContext context, Site site) {
    return BlocBuilder<CameraStreamCubit, CameraStreamState>(
      builder: (context, camState) {
        return BlocBuilder<AlertInboxCubit, AlertInboxState>(
          builder: (context, alertState) {
            return BlocBuilder<EmployeeCubit, EmployeeState>(
              builder: (context, empState) {
                final totalCams = camState is CameraStreamLoaded ? camState.cameras.length : 0;
                final onlineCams = camState is CameraStreamLoaded
                    ? camState.cameras.where((c) => c.healthStatus.toUpperCase() == 'HEALTHY' || c.isActive).length
                    : 0;
                final lostCams = totalCams - onlineCams;

                final alerts = alertState is AlertInboxLoaded
                    ? alertState.alerts
                    : (alertState is AlertInboxDegradedOffline ? alertState.cachedAlerts : <SurveillanceEvent>[]);
                final sev1Count = alerts.where((a) => a.severity.toUpperCase() == 'SEV1' && a.state.toUpperCase() != 'RESOLVED').length;

                final staffCount = empState is EmployeeLoaded ? empState.presence.length : 0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isWide ? 2.2 : 1.6,
                      children: [
                        KpiCardWidget(
                          title: 'Cameras Online',
                          value: '$onlineCams / $totalCams',
                          subtitle: lostCams > 0 ? '$lostCams LOST' : 'HEALTHY',
                          subtitleColor: lostCams > 0 ? AppColors.amber : AppColors.emerald,
                        ),
                        KpiCardWidget(
                          title: 'Open SEV1 Alerts',
                          value: '$sev1Count',
                          valueColor: sev1Count > 0 ? AppColors.crimson : AppColors.ink,
                          subtitle: 'FR-ALT-008',
                          subtitleColor: AppColors.muted,
                        ),
                        KpiCardWidget(
                          title: 'Identified Staff',
                          value: '$staffCount',
                          subtitle: 'ON-SITE',
                          subtitleColor: AppColors.emerald,
                        ),
                        const KpiCardWidget(
                          title: 'Edge API Latency (p95)',
                          value: '3.6 ms',
                          valueColor: AppColors.emerald,
                          subtitle: 'TARGET <=10ms',
                          subtitleColor: AppColors.muted,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContentGrid(BuildContext context, Site site) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1024;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isWide ? 2 : 1,
              child: _buildCameraFeedGrid(context, site),
            ),
            if (isWide) ...[
              AppSpacing.hGap16,
              SizedBox(
                width: 380,
                child: _buildRecentAlertsCard(context, site),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCameraFeedGrid(BuildContext context, Site site) {
    return BlocBuilder<CameraStreamCubit, CameraStreamState>(
      builder: (context, state) {
        if (state is CameraStreamLoading || state is CameraStreamInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is CameraStreamError) {
          return ErrorStateView(
            errorMessage: state.message,
            onRetry: () => context.read<CameraStreamCubit>().loadCameras(site.id),
          );
        }

        final cameras = (state as CameraStreamLoaded).cameras;
        if (cameras.isEmpty) {
          return AppCard(
            padding: AppSpacing.p24,
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.videocam_off_outlined, size: 40, color: AppColors.dim),
                  AppSpacing.vGap12,
                  const Text('No Cameras Onboarded for this Site', style: AppTypography.titleSmall),
                  AppSpacing.vGap8,
                  AppButton(
                    label: '+ ONBOARD FIRST CAMERA',
                    variant: ButtonVariant.primary,
                    onPressed: () => context.push('/cameras/add'),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 640 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
              ),
              itemCount: cameras.length,
              itemBuilder: (context, index) {
                final cam = cameras[index];
                return CameraFeedCardWidget(
                  camera: cam,
                  activeZone: 'Zone ${index + 1}',
                  identifiedSubject: index == 0 ? 'EMP-1042 (Ahmed H.)' : (index == 1 ? 'EMP-1018 (Tarek M.)' : 'UNKNOWN'),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentAlertsCard(BuildContext context, Site site) {
    return BlocBuilder<AlertInboxCubit, AlertInboxState>(
      builder: (context, state) {
        List<SurveillanceEvent> alerts = [];
        if (state is AlertInboxLoaded) {
          alerts = state.alerts;
        } else if (state is AlertInboxDegradedOffline) {
          alerts = state.cachedAlerts;
        }

        final recentAlerts = alerts.take(5).toList();

        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.p16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Site Alerts', style: AppTypography.titleSmall),
                    InkWell(
                      onTap: () => context.go('/inbox'),
                      child: Text(
                        'View All',
                        style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.cobalt, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderline),
              if (recentAlerts.isEmpty)
                const Padding(
                  padding: AppSpacing.p32,
                  child: Center(
                    child: Text('No active incidents reported', style: AppTypography.bodySmall),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentAlerts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderline),
                  itemBuilder: (context, index) {
                    final a = recentAlerts[index];
                    return InkWell(
                      onTap: () => context.push('/alerts/${a.id}', extra: a),
                      child: Padding(
                        padding: AppSpacing.p12,
                        child: Row(
                          children: [
                            SeverityBadge(severity: a.severity),
                            AppSpacing.hGap12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.eventType, style: AppTypography.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('${a.cameraId} · ${a.state.toUpperCase()}', style: AppTypography.tabularMonoSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

