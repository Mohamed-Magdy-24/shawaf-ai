import '../../../core/network/api_client.dart';
import '../domain/camera.dart';

abstract class CameraRepository {
  Future<List<CameraModel>> getCameras({required String siteId});
  Future<void> sendPtzCommand({
    required String siteId,
    required String cameraId,
    required double pan,
    required double tilt,
    required double zoom,
  });
  Future<String> requestWebRtcTicket({
    required String siteId,
    required String cameraId,
  });
}

class CameraRepositoryImpl implements CameraRepository {
  final ApiClient apiClient;

  CameraRepositoryImpl({required this.apiClient});

  @override
  Future<List<CameraModel>> getCameras({required String siteId}) async {
    try {
      final response = await apiClient.get('/api/v1/sites/$siteId/cameras');
      if (response is List) {
        return response
            .map((item) => CameraModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Re-throw so StateBoundaryBuilder renders actual error/unavailable state
      rethrow;
    }
    return [];
  }

  @override
  Future<void> sendPtzCommand({
    required String siteId,
    required String cameraId,
    required double pan,
    required double tilt,
    required double zoom,
  }) async {
    try {
      await apiClient.post(
        '/api/v1/sites/$siteId/cameras/$cameraId/ptz',
        body: {'pan': pan, 'tilt': tilt, 'zoom': zoom},
      );
    } catch (_) {}
  }

  @override
  Future<String> requestWebRtcTicket({
    required String siteId,
    required String cameraId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/sites/$siteId/cameras/$cameraId/webrtc-ticket',
      );
      if (response is Map && response['ticket'] != null) {
        return response['ticket'] as String;
      }
    } catch (_) {}
    return 'mock_ticket_${DateTime.now().millisecondsSinceEpoch}';
  }
}
