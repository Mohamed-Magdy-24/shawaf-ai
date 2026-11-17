import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/api_service.dart';

abstract class SurveillanceRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  void logout();
  String? get currentToken;
  Future<List<Site>> getSites();
  Future<List<Camera>> getCameras(String siteId);
  Future<Camera> registerCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  });
  Future<List<Zone>> getZones(String siteId);
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId);
  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note);
  Future<Map<String, dynamic>> requestWebRTCSdp(String siteId, String cameraId, String offerSdp);
  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent);
  Future<Map<String, dynamic>> testCameraConnection(String siteId, Map<String, dynamic> probePayload);
  Future<List<NVR>> getNVRs(String siteId);
  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload);
  Future<List<Employee>> getEmployees(String siteId);
  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload);
  Future<int> importEmployees(String siteId, String csvOrJson);
  Future<List<EmployeePresence>> getEmployeePresence(String siteId);
}

class HttpSurveillanceRepository implements SurveillanceRepository {
  final ApiService _apiService;

  HttpSurveillanceRepository({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<Map<String, dynamic>> login(String username, String password) => _apiService.login(username, password);

  @override
  void logout() => _apiService.setAuthToken(null);

  @override
  String? get currentToken => _apiService.authToken;

  @override
  Future<List<Site>> getSites() => _apiService.getSites();

  @override
  Future<List<Camera>> getCameras(String siteId) => _apiService.getCameras(siteId);

  @override
  Future<Camera> registerCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  }) {
    final payload = <String, dynamic>{
      'name': name,
      'rtsp_url': rtspUrl,
      'fps_target': fpsTarget,
      if (nvrId != null && nvrId.isNotEmpty) 'nvr_id': nvrId,
      if (onvifHost != null && onvifHost.isNotEmpty) 'onvif_host': onvifHost,
      if (zones != null) 'zones': zones,
    };
    return _apiService.registerCamera(siteId, payload);
  }

  @override
  Future<Map<String, dynamic>> testCameraConnection(String siteId, Map<String, dynamic> probePayload) =>
      _apiService.testCameraConnection(siteId, probePayload);

  @override
  Future<List<NVR>> getNVRs(String siteId) => _apiService.getNVRs(siteId);

  @override
  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload) =>
      _apiService.registerNVR(siteId, nvrPayload);

  @override
  Future<List<Employee>> getEmployees(String siteId) => _apiService.getEmployees(siteId);

  @override
  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload) =>
      _apiService.registerEmployee(siteId, empPayload);

  @override
  Future<int> importEmployees(String siteId, String csvOrJson) =>
      _apiService.importEmployees(siteId, csvOrJson);

  @override
  Future<List<EmployeePresence>> getEmployeePresence(String siteId) =>
      _apiService.getEmployeePresence(siteId);

  @override
  Future<List<Zone>> getZones(String siteId) => _apiService.getZones(siteId);

  @override
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId) => _apiService.getAlertsInbox(siteId);

  @override
  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note) =>
      _apiService.executeAlertAction(siteId, eventId, action, note);

  @override
  Future<Map<String, dynamic>> requestWebRTCSdp(String siteId, String cameraId, String offerSdp) =>
      _apiService.requestWebRTCSdp(siteId, cameraId, offerSdp);

  @override
  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent) =>
      _apiService.connectWebSocket(siteId, onEvent);
}
