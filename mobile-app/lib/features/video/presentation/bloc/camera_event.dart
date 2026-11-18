abstract class CameraEvent {
  const CameraEvent();
}

class LoadCameras extends CameraEvent {
  final String siteId;
  const LoadCameras(this.siteId);
}

class SelectCamera extends CameraEvent {
  final String cameraId;
  const SelectCamera(this.cameraId);
}

class SendPtzCommandEvent extends CameraEvent {
  final double pan;
  final double tilt;
  final double zoom;
  const SendPtzCommandEvent({
    required this.pan,
    required this.tilt,
    required this.zoom,
  });
}

class ToggleBoundingBoxes extends CameraEvent {
  final bool show;
  const ToggleBoundingBoxes(this.show);
}

class ToggleTelemetryHud extends CameraEvent {
  final bool show;
  const ToggleTelemetryHud(this.show);
}
