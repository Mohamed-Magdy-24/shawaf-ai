import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/camera_repository.dart';

abstract class CameraStreamState extends Equatable {
  const CameraStreamState();
  @override
  List<Object?> get props => [];
}

class CameraStreamInitial extends CameraStreamState {
  const CameraStreamInitial();
}

class CameraStreamLoading extends CameraStreamState {
  const CameraStreamLoading();
}

class CameraStreamLoaded extends CameraStreamState {
  final List<Camera> cameras;
  const CameraStreamLoaded(this.cameras);

  @override
  List<Object?> get props => [cameras];
}

class CameraStreamEmpty extends CameraStreamState {
  const CameraStreamEmpty();
}

class CameraStreamError extends CameraStreamState {
  final String message;
  const CameraStreamError(this.message);

  @override
  List<Object?> get props => [message];
}

class CameraStreamRegistering extends CameraStreamState {
  const CameraStreamRegistering();
}

class CameraStreamRegistrationSuccess extends CameraStreamState {
  final Camera camera;
  const CameraStreamRegistrationSuccess(this.camera);

  @override
  List<Object?> get props => [camera];
}

class CameraStreamCubit extends Cubit<CameraStreamState> {
  final ICameraRepository _repository;
  List<Camera> _cameras = [];

  CameraStreamCubit({required ICameraRepository repository})
      : _repository = repository,
        super(const CameraStreamInitial());

  Future<void> loadCameras(String siteId) async {
    emit(const CameraStreamLoading());
    try {
      final cameras = await _repository.getCameras(siteId);
      _cameras = cameras;
      if (cameras.isEmpty) {
        emit(const CameraStreamEmpty());
      } else {
        emit(CameraStreamLoaded(cameras));
      }
    } catch (e) {
      emit(CameraStreamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> registerCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  }) async {
    emit(const CameraStreamRegistering());
    try {
      final cam = await _repository.registerCamera(
        siteId,
        name: name,
        rtspUrl: rtspUrl,
        fpsTarget: fpsTarget,
        nvrId: nvrId,
        onvifHost: onvifHost,
        zones: zones,
      );
      _cameras = [..._cameras, cam];
      emit(CameraStreamRegistrationSuccess(cam));
      emit(CameraStreamLoaded(_cameras));
      return true;
    } catch (e) {
      emit(CameraStreamError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  Future<Map<String, dynamic>> negotiateWebRTCSdp(
    String siteId,
    String cameraId,
    String offerSdp,
  ) async {
    return _repository.requestWebRTCSdp(siteId, cameraId, offerSdp);
  }
}
