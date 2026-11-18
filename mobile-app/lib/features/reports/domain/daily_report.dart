/// Daily shift safety report aggregate adhering to DEC-07
/// (23:59:59 Africa/Cairo cutoff standard)
class DailyReport {
  final String siteId;
  final String reportDate; // YYYY-MM-DD
  final String timezone; // Africa/Cairo
  final int totalIncidents;
  final int criticalIncidents;
  final int warningIncidents;
  final int resolvedIncidents;
  final int dismissedIncidents;
  final double avgAckSeconds;
  final double safetyCompliancePercent;

  const DailyReport({
    required this.siteId,
    required this.reportDate,
    this.timezone = 'Africa/Cairo',
    required this.totalIncidents,
    required this.criticalIncidents,
    required this.warningIncidents,
    required this.resolvedIncidents,
    required this.dismissedIncidents,
    required this.avgAckSeconds,
    required this.safetyCompliancePercent,
  });

  bool get isCompliant => safetyCompliancePercent >= 85.0;

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      siteId: json['site_id'] as String,
      reportDate: json['report_date'] as String,
      timezone: json['timezone'] as String? ?? 'Africa/Cairo',
      totalIncidents: json['total_incidents'] as int? ?? 0,
      criticalIncidents: json['critical_incidents'] as int? ?? 0,
      warningIncidents: json['warning_incidents'] as int? ?? 0,
      resolvedIncidents: json['resolved_incidents'] as int? ?? 0,
      dismissedIncidents: json['dismissed_incidents'] as int? ?? 0,
      avgAckSeconds: (json['avg_acknowledgment_sec'] as num?)?.toDouble() ?? 0.0,
      safetyCompliancePercent: (json['safety_compliance_percent'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'site_id': siteId,
    'report_date': reportDate,
    'timezone': timezone,
    'total_incidents': totalIncidents,
    'critical_incidents': criticalIncidents,
    'warning_incidents': warningIncidents,
    'resolved_incidents': resolvedIncidents,
    'dismissed_incidents': dismissedIncidents,
    'avg_acknowledgment_sec': avgAckSeconds,
    'safety_compliance_percent': safetyCompliancePercent,
  };
}
