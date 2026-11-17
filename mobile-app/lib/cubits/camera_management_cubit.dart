import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';

abstract class CameraManagementState extends Equatable {
  const CameraManagementState();
  @override
  List<Object?> get props => [];
}

class CameraManagementInitial extends CameraManagementState {}

class CameraManagementLoading extends CameraManagementState {}

class CameraManagementLoaded extends CameraManagementState {
  final List<Camera> cameras;
  final List<NVR> nvrs;
  final Map<String, dynamic>? lastProbeResult;

  const CameraManagementLoaded({
    required this.cameras,
    required this.nvrs,
    this.lastProbeResult,
  });

  @override
  List<Object?> get props => [cameras, nvrs, lastProbeResult];
}

class CameraManagementError extends CameraManagementState {
  final String message;
  const CameraManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

class CameraManagementCubit extends Cubit<CameraManagementState> {
  final SurveillanceRepository _repository;

  CameraManagementCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(CameraManagementInitial());

  Future<void> load(String siteId) async {
    emit(CameraManagementLoading());
    try {
      final cameras = await _repository.getCameras(siteId);
      final nvrs = await _repository.getNVRs(siteId);
      emit(CameraManagementLoaded(cameras: cameras, nvrs: nvrs));
    } catch (e) {
      emit(CameraManagementError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> testConnection(String siteId, Map<String, dynamic> payload) async {
    try {
      final res = await _repository.testCameraConnection(siteId, payload);
      if (state is CameraManagementLoaded) {
        final current = state as CameraManagementLoaded;
        emit(CameraManagementLoaded(
          cameras: current.cameras,
          nvrs: current.nvrs,
          lastProbeResult: res,
        ));
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<Camera> addCamera(
    String siteId, {
    required String name,
    required String rtspUrl,
    int fpsTarget = 15,
    String? nvrId,
    String? onvifHost,
    List<Map<String, dynamic>>? zones,
  }) async {
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
      await load(siteId);
      return cam;
    } catch (e) {
      emit(CameraManagementError(e.toString()));
      rethrow;
    }
  }

  Future<NVR> addNVR(String siteId, Map<String, dynamic> nvrPayload) async {
    try {
      final nvr = await _repository.registerNVR(siteId, nvrPayload);
      await load(siteId);
      return nvr;
    } catch (e) {
      emit(CameraManagementError(e.toString()));
      rethrow;
    }
  }
}
