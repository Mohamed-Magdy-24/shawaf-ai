import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surveillance_client/core/state/ui_state.dart';
import 'package:surveillance_client/core/widgets/molecules/empty_state_view.dart';
import 'package:surveillance_client/core/widgets/organisms/ptz_control_pad.dart';
import 'package:surveillance_client/core/widgets/organisms/state_boundary_builder.dart';
import 'package:surveillance_client/features/incidents/domain/incident.dart';
import 'package:surveillance_client/features/incidents/presentation/widgets/emergency_action_sheet.dart';
import 'package:surveillance_client/features/incidents/presentation/widgets/incident_card.dart';

void main() {
  group('Widget Tests — Industrial Surveillance Client', () {
    testWidgets('EmptyStateView renders title, explanation, and CTA', (tester) async {
      bool ctaPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No Active Alerts',
              explanation: 'Zero safety incidents detected for BNF.',
              ctaLabel: 'Refresh Feed',
              onCtaPressed: () => ctaPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No Active Alerts'), findsOneWidget);
      expect(find.text('Zero safety incidents detected for BNF.'), findsOneWidget);
      expect(find.text('Refresh Feed'), findsOneWidget);

      await tester.tap(find.text('Refresh Feed'));
      expect(ctaPressed, isTrue);
    });

    testWidgets('IncidentCard renders severity, camera name, zone, and handles tap', (tester) async {
      bool cardTapped = false;
      final incident = SafetyIncident(
        id: 'INC-WIDGET-01',
        siteId: 'BNF',
        cameraId: 'CAM-FURNACE-01',
        cameraName: 'Furnace Bay High-Heat Zone',
        zoneId: 'ZONE-RESTRICTED',
        eventType: 'CRITICAL_FIRE',
        severity: IncidentSeverity.criticalFire,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'fire_v2',
        modelVersion: 'v2.1',
        confidence: 0.942,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncidentCard(
              incident: incident,
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('CRITICAL_FIRE'), findsOneWidget);
      expect(find.text('Furnace Bay High-Heat Zone'), findsOneWidget);
      expect(find.textContaining('ZONE-RESTRICTED'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);

      await tester.tap(find.byType(IncidentCard));
      expect(cardTapped, isTrue);
    });

    testWidgets('StateBoundaryBuilder renders 10 UI states correctly', (tester) async {
      // 1. Loading
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UILoading('Loading telemetry test...'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('Loading telemetry test...'), findsOneWidget);

      // 2. Empty
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIEmpty('Zero alerts'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('Zero alerts'), findsOneWidget);

      // 3. Error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIError(errorCode: 'ERR_SOCKET', message: 'Socket dropped'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('ERR_CODE: ERR_SOCKET'), findsOneWidget);
      expect(find.text('Socket dropped'), findsOneWidget);

      // 4. Offline
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIOffline('Camera RTSP unreachable'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('DEVICE OFFLINE'), findsOneWidget);
      expect(find.text('Camera RTSP unreachable'), findsOneWidget);

      // 5. Unauthorized
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIUnauthorized('Requires supervisor role'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('ACCESS RESTRICTED'), findsOneWidget);
      expect(find.text('Requires supervisor role'), findsOneWidget);

      // 6. Permission Denied
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIPermissionDenied('RBAC D-011 Violation'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('PERMISSION DENIED'), findsOneWidget);

      // 7. Live Content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UILive(35.0),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('LIVE_CONTENT'), findsOneWidget);

      // 8. Delayed Content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIDelayed(3.1),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('LIVE_CONTENT'), findsOneWidget);
      expect(find.text('DELAYED'), findsOneWidget);

      // 9. Stale Content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIStale(Duration(seconds: 14)),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('LIVE_CONTENT'), findsOneWidget);
      expect(find.text('STALE'), findsOneWidget);

      // 10. Partially Available Content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBoundaryBuilder(
              state: const UIPartiallyAvailable('Substream only'),
              contentBuilder: (_) => const Text('LIVE_CONTENT'),
            ),
          ),
        ),
      );
      expect(find.text('LIVE_CONTENT'), findsOneWidget);
      expect(find.text('PARTIALLY_AVAILABLE'), findsOneWidget);
    });

    testWidgets('EmergencyActionSheet renders tactile buttons and dispatches acknowledge', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool ackCalled = false;
      final incident = SafetyIncident(
        id: 'INC-ACTION-01',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'East Gate',
        zoneId: 'ZONE-A',
        eventType: 'INTRUSION_RESTRICTED',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'yolo_v1',
        modelVersion: 'v1.0',
        confidence: 0.89,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionSheet(
              key: const Key('sheet_ack'),
              incident: incident,
              currentOperatorId: 'operator_hassan',
              onAcknowledge: () => ackCalled = true,
              onResolve: () {},
              onDismiss: (reason) {},
              onWatchLiveStream: () {},
            ),
          ),
        ),
      );

      expect(find.text('EMERGENCY ACTION SHEET'), findsOneWidget);
      expect(find.text('ACKNOWLEDGE INCIDENT'), findsOneWidget);
      expect(find.text('RESOLVE INCIDENT'), findsOneWidget);
      expect(find.text('DISMISS WITH REASON'), findsOneWidget);
      expect(find.text('WATCH LIVE WEBRTC STREAM'), findsOneWidget);

      await tester.tap(find.text('ACKNOWLEDGE INCIDENT'), warnIfMissed: false);
      expect(ackCalled, isTrue);
    });

    testWidgets('EmergencyActionSheet dispatches resolve', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool resolveCalled = false;
      final incident = SafetyIncident(
        id: 'INC-ACTION-02',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'East Gate',
        zoneId: 'ZONE-A',
        eventType: 'INTRUSION_RESTRICTED',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'yolo_v1',
        modelVersion: 'v1.0',
        confidence: 0.89,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionSheet(
              key: const Key('sheet_resolve'),
              incident: incident,
              currentOperatorId: 'operator_hassan',
              onAcknowledge: () {},
              onResolve: () => resolveCalled = true,
              onDismiss: (reason) {},
              onWatchLiveStream: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('RESOLVE INCIDENT'), warnIfMissed: false);
      expect(resolveCalled, isTrue);
    });

    testWidgets('EmergencyActionSheet dispatches live stream', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool liveStreamCalled = false;
      final incident = SafetyIncident(
        id: 'INC-ACTION-03',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'East Gate',
        zoneId: 'ZONE-A',
        eventType: 'INTRUSION_RESTRICTED',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'yolo_v1',
        modelVersion: 'v1.0',
        confidence: 0.89,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionSheet(
              key: const Key('sheet_stream'),
              incident: incident,
              currentOperatorId: 'operator_hassan',
              onAcknowledge: () {},
              onResolve: () {},
              onDismiss: (reason) {},
              onWatchLiveStream: () => liveStreamCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('WATCH LIVE WEBRTC STREAM'), warnIfMissed: false);
      expect(liveStreamCalled, isTrue);
    });

    testWidgets('EmergencyActionSheet dispatches dismiss with reason', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? dismissReason;
      final incident = SafetyIncident(
        id: 'INC-ACTION-04',
        siteId: 'BNF',
        cameraId: 'CAM-01',
        cameraName: 'East Gate',
        zoneId: 'ZONE-A',
        eventType: 'INTRUSION_RESTRICTED',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.newStatus,
        occurredAtUtc: DateTime.now().toUtc(),
        modelId: 'yolo_v1',
        modelVersion: 'v1.0',
        confidence: 0.89,
        bboxes: const [],
        snapshotRelPath: 'snap.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionSheet(
              key: const Key('sheet_dismiss'),
              incident: incident,
              currentOperatorId: 'operator_hassan',
              onAcknowledge: () {},
              onResolve: () {},
              onDismiss: (reason) => dismissReason = reason,
              onWatchLiveStream: () {},
            ),
          ),
        ),
      );

      // Open Dismiss Mode
      await tester.tap(find.text('DISMISS WITH REASON'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('CONFIRM DISMISS'), findsOneWidget);
      await tester.tap(find.text('CONFIRM DISMISS'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dismissReason, isNotNull);
    });

    testWidgets('PTZControlPad dispatches directional commands and auto-releases', (tester) async {
      double lastPan = 0.0;
      double lastTilt = 0.0;
      double lastZoom = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PTZControlPad(
              autoReleaseTimeout: const Duration(milliseconds: 100),
              onPtzCommand: (p, t, z) {
                lastPan = p;
                lastTilt = t;
                lastZoom = z;
              },
            ),
          ),
        ),
      );

      expect(find.text('PTZ CONTROLLER'), findsOneWidget);
      expect(find.text('STATE: IDLE'), findsOneWidget);

      // Tap Up button
      await tester.tap(find.byIcon(Icons.north));
      await tester.pump();

      expect(lastTilt, equals(1.0));
      expect(find.text('STATE: UP'), findsOneWidget);

      // Wait for auto-release timeout
      await tester.pump(const Duration(milliseconds: 150));
      expect(lastTilt, equals(0.0));
      expect(find.text('STATE: IDLE'), findsOneWidget);

      // Tap West (Left) button
      await tester.tap(find.byIcon(Icons.west));
      await tester.pump();
      expect(lastPan, equals(-1.0));

      // Wait for auto-release
      await tester.pump(const Duration(milliseconds: 150));
      expect(lastPan, equals(0.0));

      // Tap Zoom In
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pump();
      expect(lastZoom, equals(1.0));
      expect(find.text('STATE: ZOOM_IN'), findsOneWidget);

      // Wait for auto-release
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('STATE: IDLE'), findsOneWidget);
    });
  });
}
