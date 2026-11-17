import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config/app_config.dart';
import '../models/models.dart';

class ApiService {
  final String baseUrl;
  final String wsUrl;
  final http.Client _client;

  String? _authToken;
  String? get authToken => _authToken;

  ApiService({
    String? baseUrl,
    String? wsUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        wsUrl = wsUrl ?? AppConfig.wsBaseUrl,
        _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _authToken = data['token'] as String?;
      return data;
    } else {
      throw Exception(
          'Authentication failed (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<List<Site>> getSites() async {
    final uri = Uri.parse('$baseUrl/api/v1/sites');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['sites'] as List? ?? [])
          .map((x) => Site.fromJson(x as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception(
          'Failed to fetch sites (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<List<Camera>> getCameras(String siteId) async {
    // Queries GET /api/v1/sites/{site_id}/cameras
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/cameras');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['cameras'] as List? ?? [])
          .map((x) => Camera.fromJson(x as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      // Fallback endpoint if legacy query param was used
      final legacyUri = Uri.parse('$baseUrl/api/v1/cameras?site_id=$siteId');
      final legacyRes = await _client
          .get(legacyUri, headers: _headers())
          .timeout(const Duration(seconds: 5));
      if (legacyRes.statusCode == 200) {
        final data = jsonDecode(legacyRes.body) as Map<String, dynamic>;
        return (data['cameras'] as List? ?? [])
            .map((x) => Camera.fromJson(x as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
          'Failed to fetch cameras for site $siteId (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<Camera> registerCamera(
      String siteId, Map<String, dynamic> cameraPayload) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/cameras');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode(cameraPayload),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Camera.fromJson(data['camera'] as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to register camera (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<List<Zone>> getZones(String siteId) async {
    final uri = Uri.parse('$baseUrl/api/v1/zones?site_id=$siteId');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['zones'] as List? ?? [])
          .map((x) => Zone.fromJson(x as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception(
          'Failed to fetch zones for site $siteId (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId) async {
    final uri = Uri.parse('$baseUrl/api/v1/alerts/inbox?site_id=$siteId');
    final response = await _client
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['alerts'] as List? ?? [])
          .map((x) => SurveillanceEvent.fromJson(x as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception(
          'Failed to fetch alerts inbox for site $siteId (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// FR-ALT-008: Transition workflow state.
  /// Mandates note length >= 10 when dismissing an incident.
  Future<bool> executeAlertAction(
      String siteId, String eventId, String action, String note) async {
    final cleanAction = action.toUpperCase().trim();
    final cleanNote = note.trim();

    if (cleanAction == 'DISMISS' && cleanNote.length < 10) {
      throw ArgumentError(
          'FR-ALT-008: Mandatory audit note required for dismissal (minimum 10 characters)');
    }

    final uri = Uri.parse('$baseUrl/api/v1/alerts/actions');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode({
            'site_id': siteId,
            'event_id': eventId,
            'action': cleanAction,
            'note': cleanNote,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to execute alert action $cleanAction (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// D-011: WebRTC SDP proxy exchange through edged RBAC.
  Future<Map<String, dynamic>> requestWebRTCSdp(
      String siteId, String cameraId, String offerSdp) async {
    final uri = Uri.parse('$baseUrl/api/v1/webrtc/sdp');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode({
            'site_id': siteId,
            'camera_id': cameraId,
            'sdp': offerSdp,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 403) {
      throw Exception(
          'D-011: Forbidden - Role unauthorized to access camera WebRTC live feed');
    } else {
      throw Exception(
          'WebRTC SDP negotiation failed (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// Probe camera RTSP connection and latency
  Future<Map<String, dynamic>> testCameraConnection(
      String siteId, Map<String, dynamic> probePayload) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/cameras/test-connection');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode(probePayload),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('RTSP Connection test failed (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// NVR Appliances
  Future<List<NVR>> getNVRs(String siteId) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/nvrs');
    final response = await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => NVR.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load NVRs (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/nvrs');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode(nvrPayload),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return NVR.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to register NVR (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// Personnel & Presence ("Who & Where")
  Future<List<Employee>> getEmployees(String siteId) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/employees');
    final response = await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load employees (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/employees');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode(empPayload),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to register employee (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<int> importEmployees(String siteId, String csvOrJson) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/employees/import');
    final response = await _client
        .post(
          uri,
          headers: _headers(),
          body: csvOrJson,
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return map['imported'] as int? ?? 0;
    } else {
      throw Exception('Failed to import employees (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  Future<List<EmployeePresence>> getEmployeePresence(String siteId) async {
    final uri = Uri.parse('$baseUrl/api/v1/sites/$siteId/presence');
    final response = await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => EmployeePresence.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load presence radar (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  WebSocketChannel? _activeChannel;

  WebSocketChannel? connectWebSocket(
      String siteId, Function(SurveillanceEvent) onEvent) {
    try {
      final ticketParam = _authToken != null ? '?ticket=$_authToken' : '';
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl$ticketParam'));
      _activeChannel = channel;
      channel.stream.listen((message) {
        try {
          final data = jsonDecode(message.toString());
          if (data['data'] != null) {
            final event = SurveillanceEvent.fromJson(
                data['data'] as Map<String, dynamic>);
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

  void disconnectWebSocket() {
    _activeChannel?.sink.close();
    _activeChannel = null;
  }
}
