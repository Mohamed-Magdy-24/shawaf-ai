import '../../domain/incident.dart';

abstract class IncidentEvent {
  const IncidentEvent();
}

class LoadIncidents extends IncidentEvent {
  final String siteId;
  final IncidentSeverity? severityFilter;
  final IncidentStatus? statusFilter;

  const LoadIncidents({
    required this.siteId,
    this.severityFilter,
    this.statusFilter,
  });
}

class LiveIncidentReceived extends IncidentEvent {
  final SafetyIncident incident;
  const LiveIncidentReceived(this.incident);
}

class AcknowledgeIncidentEvent extends IncidentEvent {
  final String incidentId;
  final String operatorId;
  const AcknowledgeIncidentEvent({
    required this.incidentId,
    required this.operatorId,
  });
}

class ResolveIncidentEvent extends IncidentEvent {
  final String incidentId;
  final String operatorId;
  const ResolveIncidentEvent({
    required this.incidentId,
    required this.operatorId,
  });
}

class DismissIncidentEvent extends IncidentEvent {
  final String incidentId;
  final String operatorId;
  final String reason;
  const DismissIncidentEvent({
    required this.incidentId,
    required this.operatorId,
    required this.reason,
  });
}

class FilterChanged extends IncidentEvent {
  final IncidentSeverity? severityFilter;
  final IncidentStatus? statusFilter;
  const FilterChanged({this.severityFilter, this.statusFilter});
}
