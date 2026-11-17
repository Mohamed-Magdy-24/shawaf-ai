import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';

abstract class CameraStreamState extends Equatable {
  const CameraStreamState();
  @override
  List<Object?> get props => [];
}

class CameraStreamInitial extends CameraStreamState {}

class CameraStreamLoading extends CameraStreamState {}

class CameraStreamLoaded extends CameraStreamState {
  final List<Camera> cameras;
  const CameraStreamLoaded(this.cameras);

  @override
  List<Object?> get props => [cameras];
}

class CameraStreamEmpty extends CameraStreamState {}

class CameraStreamError extends CameraStreamState {
  final String message;
  const CameraStreamError(this.message);

  @override
  List<Object?> get props => [message];
}

class CameraStreamRegistering extends CameraStreamState {}

class CameraStreamRegistrationSuccess extends CameraStreamState {
  final Camera camera;
  const CameraStreamRegistrationSuccess(this.camera);

  @override
  List<Object?> get props => [camera];
}

class CameraStreamCubit extends Cubit<CameraStreamState> {
  final SurveillanceRepository _repository;
  List<Camera> _cameras = [];

  CameraStreamCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(CameraStreamInitial());

  Future<void> loadCameras(String siteId) async {
    emit(CameraStreamLoading());
    try {
      final cameras = await _repository.getCameras(siteId);
      _cameras = cameras;
      if (cameras.isEmpty) {
        emit(CameraStreamEmpty());
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
    emit(CameraStreamRegistering());
    try {
      final newCam = await _repository.registerCamera(
        siteId,
        name: name,
        rtspUrl: rtspUrl,
        fpsTarget: fpsTarget,
        nvrId: nvrId,
        onvifHost: onvifHost,
        zones: zones,
      );
      _cameras = [..._cameras, newCam];
      emit(CameraStreamRegistrationSuccess(newCam));
      emit(CameraStreamLoaded(_cameras));
      return true;
    } catch (e) {
      emit(CameraStreamError(e.toString().replaceAll('Exception: ', '')));
      // Restore loaded state if we had cameras
      if (_cameras.isNotEmpty) {
        emit(CameraStreamLoaded(_cameras));
      }
      return false;
    }
  }
}
