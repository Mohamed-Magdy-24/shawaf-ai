import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String wsUrl = 'ws://127.0.0.1:8080/api/v1/ws';

  /// Compile-time/Environment flag: When false (default), local network errors throw genuine
  /// exceptions rather than silently masking integration failures with fake mock data.
  static const bool USE_MOCK_FALLBACK = bool.fromEnvironment('USE_MOCK_FALLBACK', defaultValue: false);

  String? _authToken;
  String? get authToken => _authToken;

  // Mock initial data for standalone offline/demo resilience (used ONLY if USE_MOCK_FALLBACK is true)
  final List<Site> _mockSites = [
    Site(
      id: '11111111-1111-1111-1111-111111111111',
      code: 'BNF',
      name: 'Beni Suef Cement & Clinker Plant',
      timezone: 'Africa/Cairo',
      isActive: true,
    ),
    Site(
      id: '22222222-2222-2222-2222-222222222222',
      code: 'RNF',
      name: 'Ramliya Steel & Rebar Complex',
      timezone: 'Africa/Cairo',
      isActive: true,
    ),
  ];

  Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return true;
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Login failed: HTTP ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }

    // Fallback: simulated local auth for dev/demo if explicitly enabled
    if (username.isNotEmpty) {
      _authToken = 'dev-token-local';
      return true;
    }
    return false;
  }

  Future<List<Site>> getSites() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/sites'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['sites'] as List).map((x) => Site.fromJson(x)).toList();
        if (list.isNotEmpty) return list;
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Failed to fetch sites: HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }
    return _mockSites;
  }

  Future<List<Camera>> getCameras(String siteId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/cameras?site_id=$siteId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['cameras'] as List).map((x) => Camera.fromJson(x)).toList();
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Failed to fetch cameras: HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }

    return [
      Camera(
        id: 'bnf_cam_01',
        siteId: siteId,
        name: 'BNF Warehouse Loading Dock',
        fpsTarget: 15,
        isActive: true,
        healthStatus: 'STREAMING',
        currentFPS: 15.0,
      ),
      Camera(
        id: 'bnf_cam_02',
        siteId: siteId,
        name: 'BNF Perimeter North Fence',
        fpsTarget: 15,
        isActive: true,
        healthStatus: 'STREAMING',
        currentFPS: 14.8,
      ),
    ];
  }

  Future<List<Zone>> getZones(String siteId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/zones?site_id=$siteId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['zones'] as List).map((x) => Zone.fromJson(x)).toList();
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Failed to fetch zones: HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }

    return [
      Zone(
        id: 'bnf_zone_restricted_01',
        siteId: siteId,
        cameraId: 'bnf_cam_01',
        name: 'Loading Dock Danger Perimeter',
        zoneType: 'RESTRICTED_AREA',
        severity: 'SEV1',
        polygon: [
          [0.40, 0.35],
          [0.85, 0.35],
          [0.85, 0.80],
          [0.40, 0.80],
        ],
        isActive: true,
      ),
      Zone(
        id: 'bnf_zone_crane_01',
        siteId: siteId,
        cameraId: 'bnf_cam_02',
        name: 'Overhead Crane Safety Boundary',
        zoneType: 'CRANE_TRAVEL',
        severity: 'SEV1',
        polygon: [
          [0.20, 0.20],
          [0.70, 0.20],
          [0.70, 0.75],
          [0.20, 0.75],
        ],
        isActive: true,
      ),
    ];
  }

  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/alerts/inbox?site_id=$siteId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['alerts'] as List).map((x) => SurveillanceEvent.fromJson(x)).toList();
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Failed to fetch alerts inbox: HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }

    return [
      SurveillanceEvent(
        id: 'evt-sample-01',
        siteId: siteId,
        cameraId: 'bnf_cam_01',
        zoneId: 'bnf_zone_restricted_01',
        eventType: 'ZONE_INTRUSION',
        severity: 'SEV1',
        state: 'NEW',
        confidence: 0.94,
        trackId: 104,
        occurredAt: DateTime.now().subtract(const Duration(minutes: 3)),
        metadata: {
          'zone_name': 'Loading Dock Danger Perimeter',
          'inference_lat_ms': 4.15,
        },
      ),
    ];
  }

  /// FR-ALT-008: Transition workflow state.
  /// Mandates note length >= 10 when dismissing an incident.
  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note) async {
    final cleanAction = action.toUpperCase().trim();
    final cleanNote = note.trim();

    if (cleanAction == 'DISMISS' && cleanNote.length < 10) {
      throw ArgumentError('FR-ALT-008: Mandatory audit note required for dismissal (minimum 10 characters)');
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/alerts/actions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'site_id': siteId,
          'event_id': eventId,
          'action': cleanAction,
          'note': cleanNote,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return true;
      }

      if (!USE_MOCK_FALLBACK) {
        throw Exception('Failed to record action ($cleanAction): HTTP ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      if (!USE_MOCK_FALLBACK) {
        rethrow;
      }
    }
    return true; // Local optimistic update only when fallback is explicitly allowed
  }

  /// D-011: WebRTC SDP proxy exchange through edged RBAC.
  /// Verifies that unauthorized roles receive 403 Forbidden.
  Future<Map<String, dynamic>> requestWebRTCSdp(String siteId, String cameraId, String offerSdp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/webrtc/sdp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode({
        'site_id': siteId,
        'camera_id': cameraId,
        'sdp': offerSdp,
      }),
    ).timeout(const Duration(seconds: 5));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 403) {
      throw Exception('D-011: Forbidden - Role unauthorized to access camera WebRTC live feed');
    } else {
      throw Exception('WebRTC SDP negotiation failed: HTTP ${res.statusCode} - ${res.body}');
    }
  }

  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent) {
    try {
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl?ticket=$_authToken'));
      channel.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data['data'] != null) {
            final event = SurveillanceEvent.fromJson(data['data']);
            if (event.siteId == siteId) {
              onEvent(event);
            }
          }
        } catch (_) {}
      });
      return channel;
    } catch (_) {
      return null;
    }
  }
}
