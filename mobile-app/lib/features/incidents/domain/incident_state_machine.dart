import 'incident.dart';

class StateTransitionException implements Exception {
  final String message;
  const StateTransitionException(this.message);

  @override
  String toString() => 'StateTransitionException: $message';
}

/// FR-ALT-008 Minimal Workflow State Machine
/// Transitions: NEW -> ACKNOWLEDGED -> RESOLVED | DISMISSED(reason mandatory)
class IncidentStateMachine {
  const IncidentStateMachine._();

  /// Transitions incident to ACKNOWLEDGED state
  static SafetyIncident acknowledge(
    SafetyIncident incident, {
    required String operatorId,
    DateTime? nowUtc,
  }) {
    if (incident.status != IncidentStatus.newStatus) {
      throw StateTransitionException(
        'Cannot acknowledge incident in state ${incident.status.value}. Only NEW incidents can be acknowledged.',
      );
    }

    final timestamp = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    return incident.copyWith(
      status: IncidentStatus.acknowledged,
      acknowledgedBy: operatorId,
      acknowledgedAtUtc: timestamp,
    );
  }

  /// Transitions incident to RESOLVED state
  static SafetyIncident resolve(
    SafetyIncident incident, {
    required String operatorId,
    DateTime? nowUtc,
  }) {
    if (incident.status != IncidentStatus.acknowledged &&
        incident.status != IncidentStatus.newStatus) {
      throw StateTransitionException(
        'Cannot resolve incident in state ${incident.status.value}. Only NEW or ACKNOWLEDGED incidents can be resolved.',
      );
    }

    final timestamp = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    return incident.copyWith(
      status: IncidentStatus.resolved,
      resolvedBy: operatorId,
      resolvedAtUtc: timestamp,
    );
  }

  /// Transitions incident to DISMISSED state with mandatory reason
  static SafetyIncident dismiss(
    SafetyIncident incident, {
    required String operatorId,
    required String reason,
    DateTime? nowUtc,
  }) {
    if (reason.trim().isEmpty) {
      throw const StateTransitionException(
        'Dismissal reason is mandatory under FR-ALT-008. Empty reason rejected.',
      );
    }

    if (incident.status != IncidentStatus.newStatus &&
        incident.status != IncidentStatus.acknowledged) {
      throw StateTransitionException(
        'Cannot dismiss incident in state ${incident.status.value}. Only NEW or ACKNOWLEDGED incidents can be dismissed.',
      );
    }

    final timestamp = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    return incident.copyWith(
      status: IncidentStatus.dismissed,
      resolvedBy: operatorId,
      resolvedAtUtc: timestamp,
      dismissalReason: reason.trim(),
    );
  }
}
