import 'package:flutter_test/flutter_test.dart';
import 'package:shawaf_ai_mobile/services/api_service.dart';
import 'package:shawaf_ai_mobile/models/models.dart';

void main() {
  group('ApiService & FR-ALT-008 Workflow Validation', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('USE_MOCK_FALLBACK is false by default in production build', () {
      expect(ApiService.USE_MOCK_FALLBACK, isFalse);
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

    test('Models: Site fromJson parses correctly', () {
      final json = {
        'id': '11111111-1111-1111-1111-111111111111',
        'code': 'BNF',
        'name': 'Beni Suef Cement Plant',
        'timezone': 'Africa/Cairo',
        'is_active': true,
      };
      final site = Site.fromJson(json);
      expect(site.id, '11111111-1111-1111-1111-111111111111');
      expect(site.code, 'BNF');
      expect(site.isActive, isTrue);
    });

    test('Models: SurveillanceEvent fromJson parses correctly', () {
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
        'metadata': {'zone_name': 'Loading Dock'},
      };
      final evt = SurveillanceEvent.fromJson(json);
      expect(evt.id, 'evt-1001');
      expect(evt.severity, 'SEV1');
      expect(evt.confidence, 0.95);
      expect(evt.trackId, 102);
    });
  });
}
