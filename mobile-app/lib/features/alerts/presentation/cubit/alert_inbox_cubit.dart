import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/alert_repository.dart';
import 'alert_inbox_state.dart';

export 'alert_inbox_state.dart';

class AlertInboxCubit extends Cubit<AlertInboxState> {
  final IAlertRepository _repository;
  List<SurveillanceEvent> _cache = [];

  AlertInboxCubit({required IAlertRepository repository})
      : _repository = repository,
        super(const AlertInboxInitial());

  Future<void> loadAlerts(String siteId) async {
    emit(const AlertInboxLoading());
    try {
      final alerts = await _repository.getAlertsInbox(siteId);
      _cache = alerts;
      if (alerts.isEmpty) {
        emit(const AlertInboxEmpty());
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

  void onRealtimeEventReceived(SurveillanceEvent event) {
    _cache = [event, ..._cache.where((e) => e.id != event.id)];
    emit(AlertInboxLoaded(_cache));
  }

  Future<bool> executeAction(
    String siteId,
    String eventId,
    String action,
    String note,
  ) async {
    try {
      final success = await _repository.executeAlertAction(siteId, eventId, action, note);
      if (success) {
        var finalState = action.toUpperCase();
        if (finalState == 'ACKNOWLEDGE') finalState = 'ACKNOWLEDGED';
        if (finalState == 'RESOLVE') finalState = 'RESOLVED';
        if (finalState == 'DISMISS') finalState = 'DISMISSED';

        _cache = _cache.map((evt) {
          if (evt.id == eventId) {
            return evt.copyWith(state: finalState);
          }
          return evt;
        }).toList();
        emit(AlertInboxLoaded(_cache));
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
