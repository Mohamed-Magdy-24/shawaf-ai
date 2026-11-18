import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:surveillance_client/core/state/ui_state.dart';
import 'package:surveillance_client/features/incidents/data/incident_repository.dart';
import 'package:surveillance_client/features/incidents/domain/incident.dart';
import 'package:surveillance_client/features/incidents/presentation/bloc/incident_bloc.dart';
import 'package:surveillance_client/features/incidents/presentation/bloc/incident_event.dart';

class FakeIncidentRepository implements IncidentRepository {
  final List<SafetyIncident> _items = [];
  final _streamController = StreamController<SafetyIncident>.broadcast();

  FakeIncidentRepository() {
    _items.add(
      SafetyIncident(
        id: 'INC-FAKE-01',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'Gate East',
        zoneId: 'ZONE-A',
        eventType: 'INTRUSION_RESTRICTED',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'yolo_v1',
        modelVersion: 'v1.0',
        confidence: 0.92,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      ),
    );
  }

  @override
  Future<List<SafetyIncident>> getIncidents({
    required String siteId,
    IncidentSeverity? severityFilter,
    IncidentStatus? statusFilter,
  }) async {
    return _items.where((i) {
      if (i.siteId != siteId) return false;
      if (severityFilter != null && i.severity != severityFilter) return false;
      if (statusFilter != null && i.status != statusFilter) return false;
      return true;
    }).toList();
  }

  @override
  Future<SafetyIncident> acknowledgeIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  }) async {
    final idx = _items.indexWhere((i) => i.id == incidentId);
    final updated = _items[idx].copyWith(
      status: IncidentStatus.acknowledged,
      acknowledgedBy: operatorId,
      acknowledgedAtUtc: DateTime.now().toUtc(),
    );
    _items[idx] = updated;
    return updated;
  }

  @override
  Future<SafetyIncident> resolveIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
  }) async {
    final idx = _items.indexWhere((i) => i.id == incidentId);
    final updated = _items[idx].copyWith(
      status: IncidentStatus.resolved,
      resolvedBy: operatorId,
      resolvedAtUtc: DateTime.now().toUtc(),
    );
    _items[idx] = updated;
    return updated;
  }

  @override
  Future<SafetyIncident> dismissIncident({
    required String siteId,
    required String incidentId,
    required String operatorId,
    required String reason,
  }) async {
    final idx = _items.indexWhere((i) => i.id == incidentId);
    final updated = _items[idx].copyWith(
      status: IncidentStatus.dismissed,
      resolvedBy: operatorId,
      resolvedAtUtc: DateTime.now().toUtc(),
      dismissalReason: reason,
    );
    _items[idx] = updated;
    return updated;
  }

  @override
  Stream<SafetyIncident> get liveIncidentStream => _streamController.stream;

  @override
  void setSite(String siteId, {String? wsTicket}) {}

  void emitLiveIncident(SafetyIncident incident) {
    _streamController.add(incident);
  }

  @override
  void dispose() {
    _streamController.close();
  }
}

void main() {
  group('IncidentBloc Tests', () {
    late FakeIncidentRepository repository;
    late IncidentBloc bloc;

    setUp(() {
      repository = FakeIncidentRepository();
      bloc = IncidentBloc(repository: repository, activeSiteId: 'BNF');
    });

    tearDown(() {
      bloc.close();
      repository.dispose();
    });

    test('Initial state has UILoading', () {
      expect(bloc.state.uiState, isA<UILoading>());
    });

    test('LoadIncidents loads incidents and emits UILive', () async {
      bloc.add(const LoadIncidents(siteId: 'BNF'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<dynamic>((state) => state.uiState is UILoading),
          predicate<dynamic>((state) =>
              state.uiState is UILive && state.incidents.length == 1),
        ]),
      );
    });

    test('AcknowledgeIncidentEvent updates incident to ACKNOWLEDGED', () async {
      bloc.add(const LoadIncidents(siteId: 'BNF'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const AcknowledgeIncidentEvent(
        incidentId: 'INC-FAKE-01',
        operatorId: 'operator_1',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<dynamic>((state) =>
              state.incidents.first.status == IncidentStatus.acknowledged &&
              state.incidents.first.acknowledgedBy == 'operator_1'),
        ),
      );
    });

    test('DismissIncidentEvent updates incident to DISMISSED with mandatory reason', () async {
      bloc.add(const LoadIncidents(siteId: 'BNF'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const DismissIncidentEvent(
        incidentId: 'INC-FAKE-01',
        operatorId: 'operator_1',
        reason: 'Authorized access test',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<dynamic>((state) =>
              state.incidents.first.status == IncidentStatus.dismissed &&
              state.incidents.first.dismissalReason == 'Authorized access test'),
        ),
      );
    });
    test('LoadIncidents with new siteId updates currentSiteId dynamically', () async {
      expect(bloc.currentSiteId, 'BNF');
      bloc.add(const LoadIncidents(siteId: 'site_rnf'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.currentSiteId, 'site_rnf');
    });
  });
}
