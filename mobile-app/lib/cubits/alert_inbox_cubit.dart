import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';

abstract class AlertInboxState extends Equatable {
  const AlertInboxState();
  @override
  List<Object?> get props => [];
}

class AlertInboxInitial extends AlertInboxState {}

class AlertInboxLoading extends AlertInboxState {}

class AlertInboxLoaded extends AlertInboxState {
  final List<SurveillanceEvent> alerts;
  const AlertInboxLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class AlertInboxEmpty extends AlertInboxState {}

class AlertInboxError extends AlertInboxState {
  final String message;
  const AlertInboxError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlertInboxDegradedOffline extends AlertInboxState {
  final List<SurveillanceEvent> cachedAlerts;
  final String error;
  const AlertInboxDegradedOffline({required this.cachedAlerts, required this.error});

  @override
  List<Object?> get props => [cachedAlerts, error];
}

class AlertInboxCubit extends Cubit<AlertInboxState> {
  final SurveillanceRepository _repository;
  List<SurveillanceEvent> _cache = [];

  AlertInboxCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(AlertInboxInitial());

  Future<void> loadAlerts(String siteId) async {
    emit(AlertInboxLoading());
    try {
      final alerts = await _repository.getAlertsInbox(siteId);
      _cache = alerts;
      if (alerts.isEmpty) {
        emit(AlertInboxEmpty());
      } else {
        emit(AlertInboxLoaded(alerts));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (_cache.isNotEmpty) {
        emit(AlertInboxDegradedOffline(cachedAlerts: _cache, error: errorMsg));
      } else {
        emit(AlertInboxError(errorMsg));
      }
    }
  }

  Future<bool> executeAction(String siteId, String eventId, String action, String note) async {
    try {
      final success = await _repository.executeAlertAction(siteId, eventId, action, note);
      if (success) {
        // Update local list
        final updated = _cache.map((evt) {
          if (evt.id == eventId) {
            String newState = evt.state;
            if (action == 'ACKNOWLEDGE') newState = 'ACKNOWLEDGED';
            if (action == 'RESOLVE') newState = 'RESOLVED';
            if (action == 'DISMISS') newState = 'DISMISSED';
            return evt.copyWith(state: newState);
          }
          return evt;
        }).toList();
        _cache = updated;
        emit(AlertInboxLoaded(updated));
        return true;
      }
      return false;
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AlertInboxError('Action failed: $errorMsg'));
      return false;
    }
  }

  void onNewEvent(SurveillanceEvent event) {
    _cache = [event, ..._cache.where((e) => e.id != event.id)];
    emit(AlertInboxLoaded(_cache));
  }
}
