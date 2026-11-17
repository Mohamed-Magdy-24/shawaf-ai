import '../../../../core/network/api_client.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements ICameraRepository {
  final IApiClient _apiClient;

  CameraRepositoryImpl({required IApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Camera>> getCameras(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/cameras');
    if (response is List) {
      return response.map((e) => Camera.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for cameras');
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
    final payload = {
      'name': name,
      'rtsp_url': rtspUrl,
      'fps_target': fpsTarget,
      if (nvrId != null && nvrId.isNotEmpty) 'nvr_id': nvrId,
      if (onvifHost != null && onvifHost.isNotEmpty) 'onvif_host': onvifHost,
      if (zones != null) 'zones': zones,
    };
    final response = await _apiClient.post('/api/v1/sites/$siteId/cameras', body: payload);
    if (response is Map<String, dynamic>) {
      return Camera.fromJson(response);
    }
    throw Exception('Failed to register camera');
  }

  @override
  Future<List<Zone>> getZones(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/zones');
    if (response is List) {
      return response.map((e) => Zone.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for zones');
  }

  @override
  Future<Map<String, dynamic>> requestWebRTCSdp(
    String siteId,
    String cameraId,
    String offerSdp,
  ) async {
    final response = await _apiClient.post('/api/v1/webrtc/sdp', body: {
      'site_id': siteId,
      'camera_id': cameraId,
      'sdp': offerSdp,
    });
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid SDP negotiation response');
  }

  @override
  Future<Map<String, dynamic>> testCameraConnection(
    String siteId,
    Map<String, dynamic> probePayload,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/sites/$siteId/cameras/test-connection',
      body: probePayload,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to test camera RTSP connection');
  }

  @override
  Future<List<NVR>> getNVRs(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/nvrs');
    if (response is List) {
      return response.map((e) => NVR.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for NVRs');
  }

  @override
  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload) async {
    final response = await _apiClient.post('/api/v1/sites/$siteId/nvrs', body: nvrPayload);
    if (response is Map<String, dynamic>) {
      return NVR.fromJson(response);
    }
    throw Exception('Failed to register NVR');
  }
}
