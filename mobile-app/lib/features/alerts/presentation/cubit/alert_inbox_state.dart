import 'package:equatable/equatable.dart';
import '../../../../models/models.dart';

abstract class AlertInboxState extends Equatable {
  const AlertInboxState();

  @override
  List<Object?> get props => [];
}

class AlertInboxInitial extends AlertInboxState {
  const AlertInboxInitial();
}

class AlertInboxLoading extends AlertInboxState {
  const AlertInboxLoading();
}

class AlertInboxLoaded extends AlertInboxState {
  final List<SurveillanceEvent> alerts;

  const AlertInboxLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class AlertInboxEmpty extends AlertInboxState {
  const AlertInboxEmpty();
}

class AlertInboxError extends AlertInboxState {
  final String message;

  const AlertInboxError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlertInboxDegradedOffline extends AlertInboxState {
  final List<SurveillanceEvent> cachedAlerts;
  final String error;

  const AlertInboxDegradedOffline({
    required this.cachedAlerts,
    required this.error,
  });

  @override
  List<Object?> get props => [cachedAlerts, error];
}
