import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum IncidentSeverity {
  info('INFO', AppColors.statusInfo),
  warning('WARNING', AppColors.statusWarning),
  critical('CRITICAL', AppColors.statusCritical),
  criticalFire('CRITICAL_FIRE', AppColors.statusCritical);

  final String value;
  final Color color;
  const IncidentSeverity(this.value, this.color);

  static IncidentSeverity fromString(String val) {
    switch (val.toUpperCase()) {
      case 'WARNING':
        return IncidentSeverity.warning;
      case 'CRITICAL':
        return IncidentSeverity.critical;
      case 'CRITICAL_FIRE':
        return IncidentSeverity.criticalFire;
      case 'INFO':
      default:
        return IncidentSeverity.info;
    }
  }
}

enum IncidentStatus {
  newStatus('NEW', AppColors.statusCritical),
  acknowledged('ACKNOWLEDGED', AppColors.statusWarning),
  resolved('RESOLVED', AppColors.statusNormal),
  dismissed('DISMISSED', AppColors.statusStale);

  final String value;
  final Color color;
  const IncidentStatus(this.value, this.color);

  static IncidentStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'ACKNOWLEDGED':
        return IncidentStatus.acknowledged;
      case 'RESOLVED':
        return IncidentStatus.resolved;
      case 'DISMISSED':
        return IncidentStatus.dismissed;
      case 'NEW':
      default:
        return IncidentStatus.newStatus;
    }
  }
}

class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final String label;
  final double confidence;
  final int? trackId;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.label,
    required this.confidence,
    this.trackId,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num?)?.toDouble() ?? 0.0,
      y1: (json['y1'] as num?)?.toDouble() ?? 0.0,
      x2: (json['x2'] as num?)?.toDouble() ?? 0.0,
      y2: (json['y2'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] as String? ?? 'DETECTION',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      trackId: json['track_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'label': label,
        'confidence': confidence,
        if (trackId != null) 'track_id': trackId,
      };
}

class SafetyIncident {
  final String id;
  final String siteId;
  final String cameraId;
  final String cameraName;
  final String zoneId;
  final String eventType;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final DateTime occurredAtUtc;
  final String modelId;
  final String modelVersion;
  final double confidence;
  final List<BoundingBox> bboxes;
  final String snapshotRelPath;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAtUtc;
  final String? resolvedBy;
  final DateTime? resolvedAtUtc;
  final String? dismissalReason;

  const SafetyIncident({
    required this.id,
    required this.siteId,
    required this.cameraId,
    required this.cameraName,
    required this.zoneId,
    required this.eventType,
    required this.severity,
    required this.status,
    required this.occurredAtUtc,
    required this.modelId,
    required this.modelVersion,
    required this.confidence,
    required this.bboxes,
    required this.snapshotRelPath,
    this.acknowledgedBy,
    this.acknowledgedAtUtc,
    this.resolvedBy,
    this.resolvedAtUtc,
    this.dismissalReason,
  });

  factory SafetyIncident.fromJson(Map<String, dynamic> json) {
    final bboxesList = (json['bboxes'] as List<dynamic>?)
            ?.map((e) => BoundingBox.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final id = (json['id'] ?? json['event_id']) as String;
    return SafetyIncident(
      id: id,
      siteId: json['site_id'] as String,
      cameraId: json['camera_id'] as String,
      cameraName: json['camera_name'] as String? ?? json['camera_id'] as String,
      zoneId: json['zone_id'] as String? ?? 'DEFAULT_ZONE',
      eventType: json['event_type'] as String,
      severity: IncidentSeverity.fromString(json['severity'] as String? ?? 'INFO'),
      status: IncidentStatus.fromString(json['status'] as String? ?? 'NEW'),
      occurredAtUtc: json['occurred_at_utc'] != null
          ? DateTime.parse(json['occurred_at_utc'] as String).toUtc()
          : DateTime.now().toUtc(),
      modelId: json['model_id'] as String? ?? 'yolox_s',
      modelVersion: json['model_version'] as String? ?? 'v1.0.0',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      bboxes: bboxesList,
      snapshotRelPath: json['snapshot_rel_path'] as String? ?? '',
      acknowledgedBy: json['acknowledged_by'] as String?,
      acknowledgedAtUtc: json['acknowledged_at_utc'] != null
          ? DateTime.parse(json['acknowledged_at_utc'] as String).toUtc()
          : null,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAtUtc: json['resolved_at_utc'] != null
          ? DateTime.parse(json['resolved_at_utc'] as String).toUtc()
          : null,
      dismissalReason: json['dismissal_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_id': siteId,
        'camera_id': cameraId,
        'camera_name': cameraName,
        'zone_id': zoneId,
        'event_type': eventType,
        'severity': severity.value,
        'status': status.value,
        'occurred_at_utc': occurredAtUtc.toIso8601String(),
        'model_id': modelId,
        'model_version': modelVersion,
        'confidence': confidence,
        'bboxes': bboxes.map((b) => b.toJson()).toList(),
        'snapshot_rel_path': snapshotRelPath,
        if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
        if (acknowledgedAtUtc != null) 'acknowledged_at_utc': acknowledgedAtUtc!.toIso8601String(),
        if (resolvedBy != null) 'resolved_by': resolvedBy,
        if (resolvedAtUtc != null) 'resolved_at_utc': resolvedAtUtc!.toIso8601String(),
        if (dismissalReason != null) 'dismissal_reason': dismissalReason,
      };

  SafetyIncident copyWith({
    String? id,
    String? siteId,
    String? cameraId,
    String? cameraName,
    String? zoneId,
    String? eventType,
    IncidentSeverity? severity,
    IncidentStatus? status,
    DateTime? occurredAtUtc,
    String? modelId,
    String? modelVersion,
    double? confidence,
    List<BoundingBox>? bboxes,
    String? snapshotRelPath,
    String? acknowledgedBy,
    DateTime? acknowledgedAtUtc,
    String? resolvedBy,
    DateTime? resolvedAtUtc,
    String? dismissalReason,
  }) {
    return SafetyIncident(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      zoneId: zoneId ?? this.zoneId,
      eventType: eventType ?? this.eventType,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      modelId: modelId ?? this.modelId,
      modelVersion: modelVersion ?? this.modelVersion,
      confidence: confidence ?? this.confidence,
      bboxes: bboxes ?? this.bboxes,
      snapshotRelPath: snapshotRelPath ?? this.snapshotRelPath,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAtUtc: acknowledgedAtUtc ?? this.acknowledgedAtUtc,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAtUtc: resolvedAtUtc ?? this.resolvedAtUtc,
      dismissalReason: dismissalReason ?? this.dismissalReason,
    );
  }
}
