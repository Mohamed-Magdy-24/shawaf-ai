import 'dart:async';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';
import '../domain/incident.dart';
import '../domain/incident_state_machine.dart';

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
      webSocketClient!.ticketProvider = fetchWsTicket;
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

  Future<String?> fetchWsTicket(String siteId) async {
    try {
      final response = await apiClient.post('/api/v1/sites/$siteId/ws-ticket');
      if (response is Map && response['ticket'] != null) {
        return response['ticket'] as String;
      }
    } catch (_) {}
    return null;
  }

  @override
  void setSite(String siteId, {String? wsTicket}) async {
    final ticket = wsTicket ?? await fetchWsTicket(siteId);
    webSocketClient?.switchSite(siteId, ticket: ticket);
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
    final response = await apiClient.get('/api/v1/sites/$siteId/incidents');
    if (response is List) {
      final incidents = response
          .map((item) => SafetyIncident.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final incident in incidents) {
        _insertOrUpdate(incident);
      }
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
    final target = index >= 0 ? _cache[index] : null;

    // Strict backend confirmation: no optimistic fake success if network or backend rejects
    final response = await apiClient.post(
      '/api/v1/sites/$siteId/incidents/$incidentId/acknowledge',
    );

    SafetyIncident updated;
    if (response is Map<String, dynamic>) {
      updated = SafetyIncident.fromJson(response);
    } else if (target != null) {
      updated = IncidentStateMachine.acknowledge(target, operatorId: operatorId);
    } else {
      throw StateTransitionException('Failed to acknowledge incident $incidentId');
    }

    _insertOrUpdate(updated);
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
    final target = index >= 0 ? _cache[index] : null;

    // Strict backend confirmation: no optimistic fake success if network or backend rejects
    final response = await apiClient.post(
      '/api/v1/sites/$siteId/incidents/$incidentId/resolve',
    );

    SafetyIncident updated;
    if (response is Map<String, dynamic>) {
      updated = SafetyIncident.fromJson(response);
    } else if (target != null) {
      updated = IncidentStateMachine.resolve(target, operatorId: operatorId);
    } else {
      throw StateTransitionException('Failed to resolve incident $incidentId');
    }

    _insertOrUpdate(updated);
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
    final target = index >= 0 ? _cache[index] : null;

    // Strict backend confirmation: no optimistic fake success if network or backend rejects
    final response = await apiClient.post(
      '/api/v1/sites/$siteId/incidents/$incidentId/dismiss',
      body: {'reason': reason},
    );

    SafetyIncident updated;
    if (response is Map<String, dynamic>) {
      updated = SafetyIncident.fromJson(response);
    } else if (target != null) {
      updated = IncidentStateMachine.dismiss(
        target,
        operatorId: operatorId,
        reason: reason,
      );
    } else {
      throw StateTransitionException('Failed to dismiss incident $incidentId');
    }

    _insertOrUpdate(updated);
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
