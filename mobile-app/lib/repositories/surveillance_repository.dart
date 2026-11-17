import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';
import '../core/network/api_client.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/sites/domain/repositories/site_repository.dart';
import '../features/alerts/domain/repositories/alert_repository.dart';
import '../features/cameras/domain/repositories/camera_repository.dart';
import '../features/employees/domain/repositories/employee_repository.dart';

abstract class SurveillanceRepository
    implements
        IAuthRepository,
        ISiteRepository,
        IAlertRepository,
        ICameraRepository,
        IEmployeeRepository {
  @override
  Future<Map<String, dynamic>> login(String username, String password);
  @override
  void logout();
  @override
  String? get currentToken;
  @override
  Future<List<Site>> getSites();
  @override
  Future<List<Camera>> getCameras(String siteId);
  @override
  Future<Camera> registerCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  });
  @override
  Future<List<Zone>> getZones(String siteId);
  @override
  Future<List<SurveillanceEvent>> getAlertsInbox(String siteId);
  @override
  Future<bool> executeAlertAction(String siteId, String eventId, String action, String note);
  @override
  Future<Map<String, dynamic>> requestWebRTCSdp(String siteId, String cameraId, String offerSdp);
  @override
  WebSocketChannel? connectWebSocket(String siteId, Function(SurveillanceEvent) onEvent);
  @override
  Future<Map<String, dynamic>> testCameraConnection(String siteId, Map<String, dynamic> probePayload);
  @override
  Future<List<NVR>> getNVRs(String siteId);
  @override
  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload);
  @override
  Future<List<Employee>> getEmployees(String siteId);
  @override
  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload);
  @override
  Future<int> importEmployees(String siteId, String csvOrJson);
  @override
  Future<List<EmployeePresence>> getEmployeePresence(String siteId);
  void disconnectWebSocket();
  void dispose();
}

class HttpSurveillanceRepository implements SurveillanceRepository {
  final ApiService _apiService;

  HttpSurveillanceRepository({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _apiService.login(username, password);
    final token = res['token'] as String?;
    if (token != null && sl.isRegistered<IApiClient>()) {
      sl<IApiClient>().setAuthToken(token);
    }
    return res;
  }

  @override
  void logout() {
    _apiService.setAuthToken(null);
    if (sl.isRegistered<IApiClient>()) {
      sl<IApiClient>().setAuthToken(null);
    }
  }

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

  @override
  void disconnectWebSocket() => _apiService.disconnectWebSocket();

  @override
  void dispose() => _apiService.disconnectWebSocket();
}
