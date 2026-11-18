import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/atoms/industrial_badge.dart';
import '../../../../core/widgets/atoms/telemetry_text.dart';
import '../../../../core/widgets/molecules/state_badge.dart';
import '../../../incidents/domain/incident.dart';
import '../../../incidents/presentation/bloc/incident_bloc.dart';
import '../../../incidents/presentation/bloc/incident_state.dart';
import '../../../video/domain/camera.dart';
import '../../../video/presentation/bloc/camera_bloc.dart';
import '../../../video/presentation/bloc/camera_state.dart';
import '../../../video/presentation/widgets/webrtc_viewport.dart';

class CommandOverviewScreen extends StatelessWidget {
  final String activeSiteId;
  final ValueChanged<String> onSiteChanged;
  final ValueChanged<String>? onNavigateToCamera;
  final VoidCallback? onNavigateToIncidents;

  const CommandOverviewScreen({
    super.key,
    required this.activeSiteId,
    required this.onSiteChanged,
    this.onNavigateToCamera,
    this.onNavigateToIncidents,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDimensions.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OPERATIONAL COMMAND COCKPIT', style: AppTypography.heading1),
            Text('Autonomous Site Data Plane — $activeSiteId', style: AppTypography.caption),
          ],
        ),
        actions: [
          // Site Selector Segmented Toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Row(
              children: [
                _buildSiteTab('BNF (Beni Suef)', activeSiteId == 'site_bnf' || activeSiteId == 'BNF', () => onSiteChanged('site_bnf')),
                _buildSiteTab('RNF (Sadat City)', activeSiteId == 'site_rnf' || activeSiteId == 'RNF', () => onSiteChanged('site_rnf')),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacing16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            BlocBuilder<IncidentBloc, IncidentState>(
              builder: (context, incidentState) {
                return BlocBuilder<CameraBloc, CameraState>(
                  builder: (context, cameraState) {
                    final onlineCameras =
                        cameraState.cameras.where((c) => c.status == CameraStreamStatus.online).length;
                    final totalCameras = cameraState.cameras.length;

                    final criticalIncidents = incidentState.incidents
                        .where((i) =>
                            i.severity == IncidentSeverity.critical ||
                            i.severity == IncidentSeverity.criticalFire)
                        .length;
                    final unresolvedIncidents = incidentState.incidents
                        .where((i) => i.status == IncidentStatus.newStatus)
                        .length;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = isDesktop
                            ? (constraints.maxWidth - (AppDimensions.spacing16 * 3)) / 4
                            : (constraints.maxWidth - AppDimensions.spacing12) / 2;

                        return Wrap(
                          spacing: AppDimensions.spacing16,
                          runSpacing: AppDimensions.spacing16,
                          children: [
                            _buildKpiCard(
                              title: 'ACTIVE CAMERAS',
                              value: '$onlineCameras / $totalCameras',
                              subtext: totalCameras > 0
                                  ? '${((onlineCameras / totalCameras) * 100).toStringAsFixed(1)}% Fleet Online ($activeSiteId)'
                                  : 'No Cameras Configured',
                              statusColor: onlineCameras > 0
                                  ? AppColors.statusNormal
                                  : AppColors.statusWarning,
                              icon: Icons.videocam,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'AI INFERENCE',
                              value: onlineCameras > 0 ? 'ACTIVE' : 'STANDBY',
                              subtext: onlineCameras > 0
                                  ? 'ONNX YOLOv8x Runtime'
                                  : 'NO FEED (Waiting for frames)',
                              statusColor: onlineCameras > 0
                                  ? AppColors.statusInfo
                                  : AppColors.textSecondary,
                              icon: Icons.memory,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'UNRESOLVED ALERTS',
                              value: '$unresolvedIncidents ALERTS',
                              subtext: '$criticalIncidents Critical Severity',
                              statusColor: criticalIncidents > 0
                                  ? AppColors.statusCritical
                                  : (unresolvedIncidents > 0
                                      ? AppColors.statusWarning
                                      : AppColors.statusNormal),
                              icon: Icons.warning_amber_rounded,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'ATTENDANCE SYNC',
                              value: 'STANDBY',
                              subtext: 'ZKTeco terminal integration offline',
                              statusColor: AppColors.textSecondary,
                              icon: Icons.badge_outlined,
                              width: cardWidth,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Main Content: Priority Camera Wall & Recent Incidents Rail
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildPriorityCameras(context)),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(flex: 2, child: _buildRecentIncidentsRail(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildPriorityCameras(context),
                      const SizedBox(height: AppDimensions.spacing24),
                      _buildRecentIncidentsRail(context),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing6,
        ),
        color: isSelected ? AppColors.statusInfo : Colors.transparent,
        child: Text(
          label,
          style: AppTypography.badge.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required Color statusColor,
    required IconData icon,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.caption),
              Icon(icon, size: 20.0, color: statusColor),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(value, style: AppTypography.display.copyWith(fontSize: 22.0)),
          const SizedBox(height: AppDimensions.spacing4),
          TelemetryText(subtext, isSmall: true, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildPriorityCameras(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        final cameras = state.cameras.take(2).toList();
        return Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            color: AppColors.surfacePanel,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('HIGH-RISK PRIORITY STREAMS', style: AppTypography.heading2),
                  StateBadge(state: state.uiState),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              if (cameras.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No active priority cameras', style: AppTypography.bodySecondary),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.spacing12,
                    mainAxisSpacing: AppDimensions.spacing12,
                    childAspectRatio: 16.0 / 9.0,
                  ),
                  itemCount: cameras.length,
                  itemBuilder: (context, index) {
                    final cam = cameras[index];
                    return InkWell(
                      onTap: () => onNavigateToCamera?.call(cam.id),
                      child: WebRtcViewport(camera: cam, showBoundingBoxes: true),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentIncidentsRail(BuildContext context) {
    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        final recent = state.incidents.take(4).toList();

        return Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            color: AppColors.surfacePanel,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REAL-TIME INCIDENT STREAM', style: AppTypography.heading2),
                  if (onNavigateToIncidents != null)
                    TextButton(
                      onPressed: onNavigateToIncidents,
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('Zero active alerts', style: AppTypography.bodySecondary),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.borderSubtle, height: 16.0),
                  itemBuilder: (context, index) {
                    final inc = recent[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IndustrialBadge(
                          label: inc.severity.value,
                          variant: inc.severity == IncidentSeverity.criticalFire
                              ? BadgeVariant.critical
                              : BadgeVariant.warning,
                        ),
                        const SizedBox(width: AppDimensions.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inc.eventType, style: AppTypography.heading2),
                              const SizedBox(height: 2.0),
                              TelemetryText(
                                '${inc.cameraName}  •  ${inc.zoneId}',
                                isSmall: true,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        IndustrialBadge(
                          label: inc.status.value,
                          variant: inc.status == IncidentStatus.newStatus
                              ? BadgeVariant.critical
                              : BadgeVariant.subtle,
                        ),
                      ],
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
