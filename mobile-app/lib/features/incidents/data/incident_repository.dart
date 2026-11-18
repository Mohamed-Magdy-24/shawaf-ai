import 'dart:async';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';
import '../domain/incident.dart';
import '../domain/incident_state_machine.dart';
import 'mock_incident_data.dart';

abstract class IncidentRepository {
  Future<List<SafetyIncident>> getIncidents({
    required String siteId,
    IncidentSeverity? severityFilter,
    IncidentStatus? statusFilter,
  });

  Future<SafetyIncident> acknowledgeIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  });

  Future<SafetyIncident> resolveIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  });

  Future<SafetyIncident> dismissIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
    required String reason,
  });

  Stream<SafetyIncident> get liveIncidentStream;
  void setSite(String siteId, {String? wsTicket});
  void dispose();
}

class IncidentRepositoryImpl implements IncidentRepository {
  final ApiClient apiClient;
  final IndustrialWebSocketClient? webSocketClient;

  final List<SafetyIncident> _cache = [];
  final _incidentStreamController = StreamController<SafetyIncident>.broadcast();
  StreamSubscription? _wsSubscription;

  IncidentRepositoryImpl({
    required this.apiClient,
    this.webSocketClient,
  }) {
    // Zero mock data seeding in vertical slice - real events from backend only
    if (webSocketClient != null) {
      _wsSubscription = webSocketClient!.messages.listen((json) {
        final id = json['id'] ?? json['event_id'];
        if (json['event_type'] != null && id != null) {
          try {
            final incident = SafetyIncident.fromJson(json);
            _insertOrUpdate(incident);
            _incidentStreamController.add(incident);
          } catch (_) {}
        }
      });
    }
  }

  @override
  void setSite(String siteId, {String? wsTicket}) {
    webSocketClient?.switchSite(siteId, ticket: wsTicket);
  }

  void _insertOrUpdate(SafetyIncident incident) {
    final index = _cache.indexWhere((i) => i.id == incident.id);
    if (index >= 0) {
      _cache[index] = incident;
    } else {
      _cache.insert(0, incident);
    }
  }

  @override
  Future<List<SafetyIncident>> getIncidents({
    required String siteId,
    IncidentSeverity? severityFilter,
    IncidentStatus? statusFilter,
  }) async {
    try {
      final response = await apiClient.get('/api/v1/sites/$siteId/incidents');
      if (response is List) {
        final incidents = response
            .map((item) => SafetyIncident.fromJson(item as Map<String, dynamic>))
            .toList();
        for (final incident in incidents) {
          _insertOrUpdate(incident);
        }
      }
    } catch (_) {
      // Fallback to local memory cache for offline resilience / mock dev
    }

    return _cache.where((incident) {
      if (incident.siteId != siteId) return false;
      if (severityFilter != null && incident.severity != severityFilter) return false;
      if (statusFilter != null && incident.status != statusFilter) return false;
      return true;
    }).toList();
  }

  @override
  Future<SafetyIncident> acknowledgeIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  }) async {
    final index = _cache.indexWhere((i) => i.id == incidentId);
    if (index < 0) {
      throw StateTransitionException('Incident $incidentId not found');
    }

    final target = _cache[index];
    final updated = IncidentStateMachine.acknowledge(target, operatorId: operatorId);

    try {
      await apiClient.post(
        '/api/v1/sites/$siteId/incidents/$incidentId/acknowledge',
        body: {'operator_id': operatorId},
      );
    } catch (_) {
      // Offline fallback: keep local state transition
    }

    _cache[index] = updated;
    _incidentStreamController.add(updated);
    return updated;
  }

  @override
  Future<SafetyIncident> resolveIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  }) async {
    final index = _cache.indexWhere((i) => i.id == incidentId);
    if (index < 0) {
      throw StateTransitionException('Incident $incidentId not found');
    }

    final target = _cache[index];
    final updated = IncidentStateMachine.resolve(target, operatorId: operatorId);

    try {
      await apiClient.post(
        '/api/v1/sites/$siteId/incidents/$incidentId/resolve',
        body: {'operator_id': operatorId},
      );
    } catch (_) {
      // Offline fallback: keep local state transition
    }

    _cache[index] = updated;
    _incidentStreamController.add(updated);
    return updated;
  }

  @override
  Future<SafetyIncident> dismissIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
    required String reason,
  }) async {
    final index = _cache.indexWhere((i) => i.id == incidentId);
    if (index < 0) {
      throw StateTransitionException('Incident $incidentId not found');
    }

    final target = _cache[index];
    final updated = IncidentStateMachine.dismiss(
      target,
      operatorId: operatorId,
      reason: reason,
    );

    try {
      await apiClient.post(
        '/api/v1/sites/$siteId/incidents/$incidentId/dismiss',
        body: {'operator_id': operatorId, 'reason': reason},
      );
    } catch (_) {
      // Offline fallback: keep local state transition
    }

    _cache[index] = updated;
    _incidentStreamController.add(updated);
    return updated;
  }

  @override
  Stream<SafetyIncident> get liveIncidentStream => _incidentStreamController.stream;

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _incidentStreamController.close();
  }
}
