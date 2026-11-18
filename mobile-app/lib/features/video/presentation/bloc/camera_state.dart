import '../../../../core/state/ui_state.dart';
import '../../domain/camera.dart';

class CameraState {
  final IndustrialUIState uiState;
  final List<CameraModel> cameras;
  final String? selectedCameraId;
  final bool showBoundingBoxes;
  final bool showTelemetryHud;
  final String? feedbackMessage;

  const CameraState({
    this.uiState = const UILoading('Retrieving camera fleet...'),
    this.cameras = const [],
    this.selectedCameraId,
    this.showBoundingBoxes = true,
    this.showTelemetryHud = true,
    this.feedbackMessage,
  });

  CameraModel? get selectedCamera {
    if (selectedCameraId == null) return null;
    try {
      return cameras.firstWhere((c) => c.id == selectedCameraId);
    } catch (_) {
      return null;
    }
  }

  CameraState copyWith({
    IndustrialUIState? uiState,
    List<CameraModel>? cameras,
    String? selectedCameraId,
    bool clearSelectedCamera = false,
    bool? showBoundingBoxes,
    bool? showTelemetryHud,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return CameraState(
      uiState: uiState ?? this.uiState,
      cameras: cameras ?? this.cameras,
      selectedCameraId: clearSelectedCamera
          ? null
          : (selectedCameraId ?? this.selectedCameraId),
      showBoundingBoxes: showBoundingBoxes ?? this.showBoundingBoxes,
      showTelemetryHud: showTelemetryHud ?? this.showTelemetryHud,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}
