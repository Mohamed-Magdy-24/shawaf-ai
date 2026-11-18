import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/molecules/state_badge.dart';
import '../../../../core/widgets/organisms/state_boundary_builder.dart';
import '../bloc/incident_bloc.dart';
import '../bloc/incident_event.dart';
import '../bloc/incident_state.dart';
import '../widgets/emergency_action_sheet.dart';
import '../widgets/incident_card.dart';
import '../widgets/incident_filter_bar.dart';

class IncidentFeedScreen extends StatelessWidget {
  final String siteId;
  final String currentOperatorId;
  final ValueChanged<String>? onNavigateToCameraStream;

  const IncidentFeedScreen({
    super.key,
    required this.siteId,
    this.currentOperatorId = 'supervisor_on_duty',
    this.onNavigateToCameraStream,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentBloc, IncidentState>(
      listener: (context, state) {
        if (state.actionFeedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionFeedbackMessage!, style: AppTypography.body),
              backgroundColor: AppColors.surfacePanel,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OPERATIONAL INBOX — $siteId', style: AppTypography.heading1),
                Text('Industrial AI Surveillance Telemetry', style: AppTypography.caption),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacing16),
                child: Center(child: StateBadge(state: state.uiState, showDetail: true)),
              ),
            ],
          ),
          body: Column(
            children: [
              IncidentFilterBar(
                selectedSeverity: state.severityFilter,
                selectedStatus: state.statusFilter,
                onSeverityChanged: (sev) {
                  context.bloc<IncidentBloc>().add(
                        FilterChanged(severityFilter: sev, statusFilter: state.statusFilter),
                      );
                },
                onStatusChanged: (status) {
                  context.bloc<IncidentBloc>().add(
                        FilterChanged(severityFilter: state.severityFilter, statusFilter: status),
                      );
                },
              ),
              Expanded(
                child: StateBoundaryBuilder(
                  state: state.uiState,
                  onRetry: () {
                    context.bloc<IncidentBloc>().add(LoadIncidents(siteId: siteId));
                  },
                  contentBuilder: (context) {
                    return RefreshIndicator(
                      color: AppColors.statusInfo,
                      backgroundColor: AppColors.surfacePanel,
                      onRefresh: () async {
                        context.bloc<IncidentBloc>().add(LoadIncidents(siteId: siteId));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.spacing16),
                        itemCount: state.incidents.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.spacing12),
                        itemBuilder: (context, index) {
                          final incident = state.incidents[index];
                          return IncidentCard(
                            incident: incident,
                            onTap: () {
                              EmergencyActionSheet.show(
                                context,
                                incident: incident,
                                currentOperatorId: currentOperatorId,
                                onAcknowledge: () {
                                  context.bloc<IncidentBloc>().add(
                                        AcknowledgeIncidentEvent(
                                          incidentId: incident.id,
                                          operatorId: currentOperatorId,
                                        ),
                                      );
                                },
                                onResolve: () {
                                  context.bloc<IncidentBloc>().add(
                                        ResolveIncidentEvent(
                                          incidentId: incident.id,
                                          operatorId: currentOperatorId,
                                        ),
                                      );
                                },
                                onDismiss: (reason) {
                                  context.bloc<IncidentBloc>().add(
                                        DismissIncidentEvent(
                                          incidentId: incident.id,
                                          operatorId: currentOperatorId,
                                          reason: reason,
                                        ),
                                      );
                                },
                                onWatchLiveStream: () {
                                  onNavigateToCameraStream?.call(incident.cameraId);
                                },
                              );
                            },
                            onLiveStreamTap: () {
                              onNavigateToCameraStream?.call(incident.cameraId);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension BuildContextBlocX on BuildContext {
  T bloc<T extends BlocBase<Object?>>() => BlocProvider.of<T>(this);
}
