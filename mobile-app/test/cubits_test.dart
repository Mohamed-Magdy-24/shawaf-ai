import 'package:flutter_test/flutter_test.dart';
import 'package:shawaf_ai_mobile/cubits/alert_inbox_cubit.dart';
import 'package:shawaf_ai_mobile/cubits/auth_cubit.dart';
import 'package:shawaf_ai_mobile/cubits/camera_stream_cubit.dart';
import 'package:shawaf_ai_mobile/cubits/connectivity_cubit.dart';
import 'package:shawaf_ai_mobile/cubits/site_cubit.dart';
import 'package:shawaf_ai_mobile/models/models.dart';
import 'package:shawaf_ai_mobile/repositories/surveillance_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FakeSurveillanceRepository implements SurveillanceRepository {
  bool shouldFail = false;
  String? token;

  final List<Site> testSites = const [
    Site(id: '11111111-1111-1111-1111-111111111111', code: 'BNF', name: 'BNF', timezone: 'Africa/Cairo', isActive: true),
    Site(id: '22222222-2222-2222-2222-222222222222', code: 'RNF', name: 'RNF', timezone: 'Africa/Cairo', isActive: true),
  ];

  final List<Camera> testCameras = const [
    Camera(
      id: 'bnf_cam_01',
      siteId: '11111111-1111-1111-1111-111111111111',
      name: 'BNF Camera 01',
      fpsTarget: 15,
      isActive: true,
      healthStatus: 'STREAMING',
      currentFPS: 15.0,
      rtspUrl: 'rtsp://mediamtx:8554/bnf_cam_01',
    ),
  ];

  final List<SurveillanceEvent> testAlerts = [
    SurveillanceEvent(
      id: 'evt-001',
      siteId: '11111111-1111-1111-1111-111111111111',
      cameraId: 'bnf_cam_01',
      zoneId: 'bnf_zone_01',
      eventType: 'ZONE_INTRUSION',
      severity: 'SEV1',
      state: 'NEW',
      confidence: 0.98,
      trackId: 101,
      occurredAt: DateTime.parse('2026-11-16T10:00:00Z'),
      metadata: const {'zone_name': 'Hazard Zone'},
    ),
  ];

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (shouldFail) throw Exception('Invalid credentials');
    token = 'test-jwt-token';
    return {'token': token, 'role': 'security_manager', 'site_id': '11111111-1111-1111-1111-111111111111'};
  }

  @override
  void logout() {
    token = null;
  }

  @override
  String? get currentToken => token;

  @override
  Future<List<Site>> getSites() async {
    if (shouldFail) throw Exception('Network timeout');
    return testSites;
  }

  @override
  Future<List<Camera>> getCameras(String siteId) async {
    if (shouldFail) throw Exception('Camera service offline');
    return testCameras;
  }

  @override
  Future<Camera> registerCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  }) async {
    if (shouldFail) throw Exception('Registration failed');
    return Camera(
      id: 'cam_new_01',
      siteId: siteId,
      name: name,
      fpsTarget: fpsTarget,
      isActive: true,
      healthStatus: 'STREAMING',
      currentFPS: 15.0,
      rtspUrl: rtspUrl,
    );
  }

  @override
  Future<List<Zone>> getZones(String siteId) async => [];

  @override
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId) async {
    if (shouldFail) throw Exception('Inbox unavailable');
    return testAlerts;
  }

  @override
  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note) async {
    if (shouldFail) throw Exception('Action rejected');
    return true;
  }

  @override
  Future<Map<String, dynamic>> requestWebRTCSdp(String siteId, String cameraId, String offerSdp) async {
    if (shouldFail) throw Exception('SDP exchange error');
    return {'type': 'answer', 'sdp': 'v=0...'};
  }

  @override
  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent) => null;
}

void main() {
  group('Cubit State Machine Tests', () {
    late FakeSurveillanceRepository repository;

    setUp(() {
      repository = FakeSurveillanceRepository();
    });

    test('AuthCubit: Login success emits AuthAuthenticated', () async {
      final cubit = AuthCubit(repository: repository);
      final result = await cubit.login('admin', 'secret123');

      expect(result, isTrue);
      expect(cubit.state, isA<AuthAuthenticated>());
      final auth = cubit.state as AuthAuthenticated;
      expect(auth.username, 'admin');
      expect(auth.role, 'security_manager');

      cubit.logout();
      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    test('AuthCubit: Login failure emits AuthUnauthenticated with error', () async {
      repository.shouldFail = true;
      final cubit = AuthCubit(repository: repository);
      final result = await cubit.login('admin', 'badpass');

      expect(result, isFalse);
      expect(cubit.state, isA<AuthUnauthenticated>());
      final unauth = cubit.state as AuthUnauthenticated;
      expect(unauth.errorMessage, contains('Invalid credentials'));
    });

    test('SiteCubit: loadSites populates BNF and RNF sites', () async {
      final cubit = SiteCubit(repository: repository);
      await cubit.loadSites();

      expect(cubit.state, isA<SiteLoaded>());
      final loaded = cubit.state as SiteLoaded;
      expect(loaded.sites.length, 2);
      expect(loaded.selectedSite.code, 'BNF');
      expect(loaded.selectedSite.name, 'BNF');

      // Switch to RNF
      cubit.switchSiteByCode('RNF');
      final updated = cubit.state as SiteLoaded;
      expect(updated.selectedSite.code, 'RNF');
      expect(updated.selectedSite.name, 'RNF');
    });

    test('AlertInboxCubit: loadAlerts and executeAction transition state', () async {
      final cubit = AlertInboxCubit(repository: repository);
      await cubit.loadAlerts('11111111-1111-1111-1111-111111111111');

      expect(cubit.state, isA<AlertInboxLoaded>());
      final loaded = cubit.state as AlertInboxLoaded;
      expect(loaded.alerts.length, 1);
      expect(loaded.alerts.first.state, 'NEW');

      final acted = await cubit.executeAction(
        '11111111-1111-1111-1111-111111111111',
        'evt-001',
        'ACKNOWLEDGE',
        'Operator acknowledged',
      );
      expect(acted, isTrue);
      final afterAction = cubit.state as AlertInboxLoaded;
      expect(afterAction.alerts.first.state, 'ACKNOWLEDGED');
    });

    test('CameraStreamCubit: loadCameras and registerCamera update list', () async {
      final cubit = CameraStreamCubit(repository: repository);
      await cubit.loadCameras('11111111-1111-1111-1111-111111111111');

      expect(cubit.state, isA<CameraStreamLoaded>());
      final loaded = cubit.state as CameraStreamLoaded;
      expect(loaded.cameras.length, 1);

      final registered = await cubit.registerCamera(
        '11111111-1111-1111-1111-111111111111',
        name: 'Gate 2 Camera',
        rtspUrl: 'rtsp://mediamtx:8554/bnf_cam_02',
      );
      expect(registered, isTrue);
      final afterReg = cubit.state as CameraStreamLoaded;
      expect(afterReg.cameras.length, 2);
    });

    test('ConnectivityCubit: transitions between online, degraded, and offline', () {
      final cubit = ConnectivityCubit();
      expect(cubit.state, isA<ConnectivityOnline>());

      cubit.setDegraded('High latency');
      expect(cubit.state, isA<ConnectivityDegraded>());
      expect((cubit.state as ConnectivityDegraded).reason, 'High latency');

      cubit.setOffline('Watchdog failure');
      expect(cubit.state, isA<ConnectivityOffline>());
      expect((cubit.state as ConnectivityOffline).reason, 'Watchdog failure');

      cubit.setOnline();
      expect(cubit.state, isA<ConnectivityOnline>());
    });
  });
}
