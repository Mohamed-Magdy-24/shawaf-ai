import 'package:flutter_test/flutter_test.dart';
import 'package:shawaf_ai_mobile/models/models.dart';
import 'package:shawaf_ai_mobile/services/api_service.dart';

void main() {
  group('ApiService & FR-ALT-008 Workflow Validation', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('FR-ALT-008: executeAlertAction throws ArgumentError when DISMISS has empty note', () async {
      expect(
        () => apiService.executeAlertAction(
          '11111111-1111-1111-1111-111111111111',
          'evt-test-01',
          'DISMISS',
          '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('FR-ALT-008: executeAlertAction throws ArgumentError when DISMISS note is < 10 characters', () async {
      expect(
        () => apiService.executeAlertAction(
          '11111111-1111-1111-1111-111111111111',
          'evt-test-01',
          'DISMISS',
          'too short',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Models: Site fromJson parses correctly with strict BNF naming', () {
      final json = {
        'id': '11111111-1111-1111-1111-111111111111',
        'code': 'BNF',
        'name': 'BNF',
        'timezone': 'Africa/Cairo',
        'is_active': true,
      };
      final site = Site.fromJson(json);
      expect(site.id, '11111111-1111-1111-1111-111111111111');
      expect(site.code, 'BNF');
      expect(site.name, 'BNF');
      expect(site.isActive, isTrue);
    });

    test('Models: Camera fromJson parses correctly', () {
      final json = {
        'id': 'bnf_cam_01',
        'site_id': '11111111-1111-1111-1111-111111111111',
        'name': 'BNF Camera 01',
        'fps_target': 15,
        'is_active': true,
        'health_status': 'STREAMING',
        'current_fps': 15.0,
        'rtsp_url': 'rtsp://mediamtx:8554/bnf_cam_01',
      };
      final cam = Camera.fromJson(json);
      expect(cam.id, 'bnf_cam_01');
      expect(cam.fpsTarget, 15);
      expect(cam.healthStatus, 'STREAMING');
      expect(cam.currentFPS, 15.0);
    });

    test('Models: SurveillanceEvent fromJson parses correctly and copyWith works', () {
      final json = {
        'id': 'evt-1001',
        'site_id': '11111111-1111-1111-1111-111111111111',
        'camera_id': 'bnf_cam_01',
        'zone_id': 'bnf_zone_restricted_01',
        'event_type': 'ZONE_INTRUSION',
        'severity': 'SEV1',
        'state': 'NEW',
        'confidence': 0.95,
        'track_id': 102,
        'occurred_at': '2026-11-16T12:00:00Z',
        'metadata': {'zone_name': 'Danger Perimeter'},
      };
      final evt = SurveillanceEvent.fromJson(json);
      expect(evt.id, 'evt-1001');
      expect(evt.severity, 'SEV1');
      expect(evt.confidence, 0.95);
      expect(evt.trackId, 102);

      final acknowledged = evt.copyWith(state: 'ACKNOWLEDGED');
      expect(acknowledged.state, 'ACKNOWLEDGED');
      expect(acknowledged.id, evt.id);
    });
  });
}
