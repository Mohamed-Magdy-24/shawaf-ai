import 'package:flutter_test/flutter_test.dart';
import 'package:surveillance_client/features/incidents/domain/incident.dart';
import 'package:surveillance_client/features/incidents/domain/incident_state_machine.dart';

void main() {
  group('FR-ALT-008 Incident State Machine Transitions', () {
    late SafetyIncident newIncident;

    setUp(() {
      newIncident = SafetyIncident(
        id: 'INC-TEST-001',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'Furnace Bay',
        zoneId: 'ZONE-A',
        eventType: 'CRITICAL_FIRE',
        severity: IncidentSeverity.criticalFire,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.utc(2026, 11, 18, 10, 0, 0),
        modelId: 'fire_v1',
        modelVersion: 'v1.0.0',
        confidence: 0.95,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );
    });

    test('NEW -> ACKNOWLEDGED transitions successfully with operator & timestamp', () {
      final now = DateTime.utc(2026, 11, 18, 10, 2, 0);
      final acknowledged = IncidentStateMachine.acknowledge(
        newIncident,
        operatorId: 'operator_ahmed',
        nowUtc: now,
      );

      expect(acknowledged.status, equals(IncidentStatus.acknowledged));
      expect(acknowledged.acknowledgedBy, equals('operator_ahmed'));
      expect(acknowledged.acknowledgedAtUtc, equals(now));
    });

    test('ACKNOWLEDGED -> RESOLVED transitions successfully', () {
      final acknowledged = IncidentStateMachine.acknowledge(
        newIncident,
        operatorId: 'operator_ahmed',
      );
      final resolved = IncidentStateMachine.resolve(
        acknowledged,
        operatorId: 'operator_ahmed',
      );

      expect(resolved.status, equals(IncidentStatus.resolved));
      expect(resolved.resolvedBy, equals('operator_ahmed'));
      expect(resolved.resolvedAtUtc, isNotNull);
    });

    test('NEW -> RESOLVED direct transition is permitted', () {
      final resolved = IncidentStateMachine.resolve(
        newIncident,
        operatorId: 'supervisor_tariq',
      );

      expect(resolved.status, equals(IncidentStatus.resolved));
      expect(resolved.resolvedBy, equals('supervisor_tariq'));
    });

    test('NEW -> DISMISSED succeeds with mandatory reason', () {
      final dismissed = IncidentStateMachine.dismiss(
        newIncident,
        operatorId: 'operator_ahmed',
        reason: 'False positive from furnace heat reflection',
      );

      expect(dismissed.status, equals(IncidentStatus.dismissed));
      expect(dismissed.dismissalReason, equals('False positive from furnace heat reflection'));
      expect(dismissed.resolvedBy, equals('operator_ahmed'));
    });

    test('DISMISS with empty or whitespace-only reason is strictly rejected', () {
      expect(
        () => IncidentStateMachine.dismiss(
          newIncident,
          operatorId: 'operator_ahmed',
          reason: '   ',
        ),
        throwsA(isA<StateTransitionException>()),
      );
    });

    test('Reject invalid transition: ACKNOWLEDGE on already RESOLVED incident', () {
      final resolved = IncidentStateMachine.resolve(
        newIncident,
        operatorId: 'operator_ahmed',
      );

      expect(
        () => IncidentStateMachine.acknowledge(
          resolved,
          operatorId: 'operator_ahmed',
        ),
        throwsA(isA<StateTransitionException>()),
      );
    });

    test('Reject invalid transition: DISMISS on already RESOLVED incident', () {
      final resolved = IncidentStateMachine.resolve(
        newIncident,
        operatorId: 'operator_ahmed',
      );

      expect(
        () => IncidentStateMachine.dismiss(
          resolved,
          operatorId: 'operator_ahmed',
          reason: 'Duplicate',
        ),
        throwsA(isA<StateTransitionException>()),
      );
    });
  });
}
