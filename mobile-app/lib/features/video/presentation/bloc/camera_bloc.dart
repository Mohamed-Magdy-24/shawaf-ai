import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/ui_state.dart';
import '../../data/camera_repository.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraRepository repository;
  final String activeSiteId;
  late String _currentSiteId;

  String get currentSiteId => _currentSiteId;

  CameraBloc({
    required this.repository,
    this.activeSiteId = 'site_bnf',
  }) : super(const CameraState()) {
    _currentSiteId = activeSiteId;
    on<LoadCameras>(_onLoadCameras);
    on<SelectCamera>(_onSelectCamera);
    on<SendPtzCommandEvent>(_onSendPtzCommand);
    on<ToggleBoundingBoxes>(_onToggleBoundingBoxes);
    on<ToggleTelemetryHud>(_onToggleTelemetryHud);
  }

  Future<void> _onLoadCameras(
    LoadCameras event,
    Emitter<CameraState> emit,
  ) async {
    _currentSiteId = event.siteId;
    emit(state.copyWith(
      uiState: const UILoading('Retrieving camera telemetry fleet...'),
    ));

    try {
      final cameras = await repository.getCameras(siteId: event.siteId);
      if (cameras.isEmpty) {
        emit(state.copyWith(
          uiState: const UIEmpty('No cameras configured for this factory site.'),
          cameras: [],
          selectedCameraId: null,
        ));
      } else {
        final isSelectionValid = cameras.any((c) => c.id == state.selectedCameraId);
        final newSelectedId = isSelectionValid ? state.selectedCameraId : cameras.first.id;
        emit(state.copyWith(
          uiState: const UILive(38.0),
          cameras: cameras,
          selectedCameraId: newSelectedId,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        uiState: UIError(
          errorCode: 'CAMERA_FLEET_ERR',
          message: 'Failed to retrieve camera stream metadata: ${e.toString()}',
        ),
      ));
    }
  }

  void _onSelectCamera(
    SelectCamera event,
    Emitter<CameraState> emit,
  ) {
    emit(state.copyWith(selectedCameraId: event.cameraId));
  }

  Future<void> _onSendPtzCommand(
    SendPtzCommandEvent event,
    Emitter<CameraState> emit,
  ) async {
    final camId = state.selectedCameraId;
    if (camId == null) return;

    try {
      await repository.sendPtzCommand(
        siteId: _currentSiteId,
        cameraId: camId,
        pan: event.pan,
        tilt: event.tilt,
        zoom: event.zoom,
      );
    } catch (e) {
      emit(state.copyWith(
        feedbackMessage: 'PTZ Command Error: ${e.toString()}',
      ));
    }
  }

  void _onToggleBoundingBoxes(
    ToggleBoundingBoxes event,
    Emitter<CameraState> emit,
  ) {
    emit(state.copyWith(showBoundingBoxes: event.show));
  }

  void _onToggleTelemetryHud(
    ToggleTelemetryHud event,
    Emitter<CameraState> emit,
  ) {
    emit(state.copyWith(showTelemetryHud: event.show));
  }
}
