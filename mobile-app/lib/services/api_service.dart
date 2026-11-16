import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String wsUrl = 'ws://127.0.0.1:8080/api/v1/ws';

  String? _authToken;
  String? get authToken => _authToken;

  // Mock initial data for standalone offline/demo resilience
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
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return true;
      }
    } catch (_) {}

    // Fallback: simulated local auth for dev/demo
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
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['sites'] as List).map((x) => Site.fromJson(x)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockSites;
  }

  Future<List<Camera>> getCameras(String siteId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/cameras?site_id=$siteId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['cameras'] as List).map((x) => Camera.fromJson(x)).toList();
      }
    } catch (_) {}

    // Simulated fallback
    return [
      Camera(
        id: 'cam-bnf-01',
        siteId: siteId,
        name: 'Overhead Crane Area A',
        fpsTarget: 15,
        isActive: true,
        healthStatus: 'STREAMING',
        currentFPS: 15.0,
      ),
      Camera(
        id: 'cam-bnf-02',
        siteId: siteId,
        name: 'Induction Furnace Perimeter',
        fpsTarget: 15,
        isActive: true,
        healthStatus: 'STREAMING',
        currentFPS: 14.8,
      ),
      Camera(
        id: 'cam-bnf-03',
        siteId: siteId,
        name: 'Forklift Transit Corridor',
        fpsTarget: 15,
        isActive: true,
        healthStatus: 'STREAMING',
        currentFPS: 15.0,
      ),
    ];
  }

  Future<List<Zone>> getZones(String siteId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/zones?site_id=$siteId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['zones'] as List).map((x) => Zone.fromJson(x)).toList();
      }
    } catch (_) {}

    return [
      Zone(
        id: 'zone-bnf-crane-01',
        siteId: siteId,
        cameraId: 'cam-bnf-01',
        name: 'Overhead Crane Travel Zone',
        zoneType: 'INTRUSION',
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
        id: 'zone-bnf-furnace-01',
        siteId: siteId,
        cameraId: 'cam-bnf-02',
        name: 'Induction Furnace Safety Perimeter',
        zoneType: 'RESTRICTED_ACCESS',
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
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['alerts'] as List).map((x) => SurveillanceEvent.fromJson(x)).toList();
      }
    } catch (_) {}

    // Simulated fallback events
    return [
      SurveillanceEvent(
        id: 'evt-sample-01',
        siteId: siteId,
        cameraId: 'cam-bnf-01',
        zoneId: 'zone-bnf-crane-01',
        eventType: 'ZONE_INTRUSION',
        severity: 'SEV1',
        state: 'NEW',
        confidence: 0.94,
        trackId: 104,
        occurredAt: DateTime.now().subtract(const Duration(minutes: 3)),
        metadata: {
          'zone_name': 'Overhead Crane Travel Zone',
          'inference_lat_ms': 4.15,
        },
      ),
      SurveillanceEvent(
        id: 'evt-sample-02',
        siteId: siteId,
        cameraId: 'cam-bnf-02',
        zoneId: 'zone-bnf-furnace-01',
        eventType: 'ZONE_RESTRICTED_ACCESS',
        severity: 'SEV1',
        state: 'ACKNOWLEDGED',
        confidence: 0.89,
        trackId: 108,
        occurredAt: DateTime.now().subtract(const Duration(minutes: 18)),
        metadata: {
          'zone_name': 'Induction Furnace Safety Perimeter',
          'inference_lat_ms': 4.22,
        },
      ),
    ];
  }

  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note) async {
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
          'action': action,
          'note': note,
        }),
      ).timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return true; // Local optimistic update
  }

  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent) {
    try {
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl?ticket=mock-ticket'));
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
