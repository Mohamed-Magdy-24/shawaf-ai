import '../../../../models/models.dart';

abstract class ICameraRepository {
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
  Future<Map<String, dynamic>> requestWebRTCSdp(
    String siteId,
    String cameraId,
    String offerSdp,
  );
  Future<Map<String, dynamic>> testCameraConnection(
    String siteId,
    Map<String, dynamic> probePayload,
  );
  Future<List<NVR>> getNVRs(String siteId);
  Future<NVR> registerNVR(String siteId, Map<String, dynamic> nvrPayload);
}
