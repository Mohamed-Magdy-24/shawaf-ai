import '../../../../core/state/ui_state.dart';
import '../../domain/incident.dart';

class IncidentState {
  final IndustrialUIState uiState;
  final List<SafetyIncident> incidents;
  final IncidentSeverity? severityFilter;
  final IncidentStatus? statusFilter;
  final String? selectedIncidentId;
  final String? actionFeedbackMessage;

  const IncidentState({
    this.uiState = const UILoading('Retrieving incidents...'),
    this.incidents = const [],
    this.severityFilter,
    this.statusFilter,
    this.selectedIncidentId,
    this.actionFeedbackMessage,
  });

  SafetyIncident? get selectedIncident {
    if (selectedIncidentId == null) return null;
    try {
      return incidents.firstWhere((i) => i.id == selectedIncidentId);
    } catch (_) {
      return null;
    }
  }

  IncidentState copyWith({
    IndustrialUIState? uiState,
    List<SafetyIncident>? incidents,
    IncidentSeverity? severityFilter,
    bool clearSeverityFilter = false,
    IncidentStatus? statusFilter,
    bool clearStatusFilter = false,
    String? selectedIncidentId,
    bool clearSelectedIncidentId = false,
    String? actionFeedbackMessage,
    bool clearActionFeedback = false,
  }) {
    return IncidentState(
      uiState: uiState ?? this.uiState,
      incidents: incidents ?? this.incidents,
      severityFilter: clearSeverityFilter ? null : (severityFilter ?? this.severityFilter),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      selectedIncidentId: clearSelectedIncidentId
          ? null
          : (selectedIncidentId ?? this.selectedIncidentId),
      actionFeedbackMessage: clearActionFeedback
          ? null
          : (actionFeedbackMessage ?? this.actionFeedbackMessage),
    );
  }
}
