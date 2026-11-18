import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/ui_state.dart';
import '../../data/incident_repository.dart';
import '../../domain/incident.dart';
import 'incident_event.dart';
import 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;
  final String activeSiteId;
  late String _currentSiteId;
  StreamSubscription<SafetyIncident>? _liveStreamSub;

  String get currentSiteId => _currentSiteId;

  IncidentBloc({
    required this.repository,
    this.activeSiteId = 'site_bnf',
  }) : super(const IncidentState()) {
    _currentSiteId = activeSiteId;
    on<LoadIncidents>(_onLoadIncidents);
    on<LiveIncidentReceived>(_onLiveIncidentReceived);
    on<AcknowledgeIncidentEvent>(_onAcknowledgeIncident);
    on<ResolveIncidentEvent>(_onResolveIncident);
    on<DismissIncidentEvent>(_onDismissIncident);
    on<FilterChanged>(_onFilterChanged);

    _liveStreamSub = repository.liveIncidentStream.listen((incident) {
      add(LiveIncidentReceived(incident));
    });
  }

  Future<void> _onLoadIncidents(
    LoadIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    _currentSiteId = event.siteId;
    emit(state.copyWith(
      uiState: const UILoading('Retrieving factory incident feed...'),
      severityFilter: event.severityFilter,
      statusFilter: event.statusFilter,
    ));

    try {
      final incidents = await repository.getIncidents(
        siteId: event.siteId,
        severityFilter: event.severityFilter,
        statusFilter: event.statusFilter,
      );

      if (incidents.isEmpty) {
        emit(state.copyWith(
          uiState: const UIEmpty('Zero safety incidents match the selected site and filters.'),
          incidents: [],
        ));
      } else {
        emit(state.copyWith(
          uiState: const UILive(42.0),
          incidents: incidents,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        uiState: UIError(
          errorCode: 'FEED_FETCH_ERR',
          message: 'Failed to load safety incidents: ${e.toString()}',
        ),
      ));
    }
  }

  void _onLiveIncidentReceived(
    LiveIncidentReceived event,
    Emitter<IncidentState> emit,
  ) {
    final updatedList = List<SafetyIncident>.from(state.incidents);
    final index = updatedList.indexWhere((i) => i.id == event.incident.id);
    if (index >= 0) {
      updatedList[index] = event.incident;
    } else {
      updatedList.insert(0, event.incident);
    }

    emit(state.copyWith(
      incidents: updatedList,
      uiState: const UILive(18.0),
      actionFeedbackMessage: 'New incident ${event.incident.id} received (${event.incident.eventType})',
    ));
  }

  Future<void> _onAcknowledgeIncident(
    AcknowledgeIncidentEvent event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      final updated = await repository.acknowledgeIncident(
        siteId: _currentSiteId,
        incidentId: event.incidentId,
        operatorId: event.operatorId,
      );

      final list = state.incidents.map((i) => i.id == updated.id ? updated : i).toList();
      emit(state.copyWith(
        incidents: list,
        actionFeedbackMessage: 'Incident ${updated.id} acknowledged by ${event.operatorId}',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionFeedbackMessage: 'Acknowledgment error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResolveIncident(
    ResolveIncidentEvent event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      final updated = await repository.resolveIncident(
        siteId: _currentSiteId,
        incidentId: event.incidentId,
        operatorId: event.operatorId,
      );

      final list = state.incidents.map((i) => i.id == updated.id ? updated : i).toList();
      emit(state.copyWith(
        incidents: list,
        actionFeedbackMessage: 'Incident ${updated.id} resolved by ${event.operatorId}',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionFeedbackMessage: 'Resolution error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDismissIncident(
    DismissIncidentEvent event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      final updated = await repository.dismissIncident(
        siteId: _currentSiteId,
        incidentId: event.incidentId,
        operatorId: event.operatorId,
        reason: event.reason,
      );

      final list = state.incidents.map((i) => i.id == updated.id ? updated : i).toList();
      emit(state.copyWith(
        incidents: list,
        actionFeedbackMessage: 'Incident ${updated.id} dismissed (${event.reason})',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionFeedbackMessage: 'Dismissal error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<IncidentState> emit,
  ) async {
    add(LoadIncidents(
      siteId: _currentSiteId,
      severityFilter: event.severityFilter,
      statusFilter: event.statusFilter,
    ));
  }

  @override
  Future<void> close() {
    _liveStreamSub?.cancel();
    return super.close();
  }
}
