import 'dart:convert';

class Site {
  final String id;
  final String code;
  final String name;
  final String timezone;
  final bool isActive;

  Site({
    required this.id,
    required this.code,
    required this.name,
    required this.timezone,
    required this.isActive,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      timezone: json['timezone'] ?? 'UTC',
      isActive: json['is_active'] ?? true,
    );
  }
}

class Camera {
  final String id;
  final String siteId;
  final String name;
  final int fpsTarget;
  final bool isActive;
  final String healthStatus;
  final double currentFPS;
  final String? lastHeartbeat;

  Camera({
    required this.id,
    required this.siteId,
    required this.name,
    required this.fpsTarget,
    required this.isActive,
    required this.healthStatus,
    required this.currentFPS,
    this.lastHeartbeat,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] ?? '',
      siteId: json['site_id'] ?? '',
      name: json['name'] ?? '',
      fpsTarget: json['fps_target'] ?? 15,
      isActive: json['is_active'] ?? true,
      healthStatus: json['health_status'] ?? 'DISCONNECTED',
      currentFPS: (json['current_fps'] as num?)?.toDouble() ?? 0.0,
      lastHeartbeat: json['last_heartbeat'],
    );
  }
}

class Zone {
  final String id;
  final String siteId;
  final String cameraId;
  final String name;
  final String zoneType;
  final String severity;
  final List<List<double>> polygon;
  final bool isActive;

  Zone({
    required this.id,
    required this.siteId,
    required this.cameraId,
    required this.name,
    required this.zoneType,
    required this.severity,
    required this.polygon,
    required this.isActive,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    List<List<double>> poly = [];
    if (json['polygon'] != null) {
      var raw = json['polygon'];
      if (raw is String) {
        raw = jsonDecode(raw);
      }
      if (raw is List) {
        for (var pt in raw) {
          if (pt is List && pt.length >= 2) {
            poly.add([(pt[0] as num).toDouble(), (pt[1] as num).toDouble()]);
          }
        }
      }
    }
    return Zone(
      id: json['id'] ?? '',
      siteId: json['site_id'] ?? '',
      cameraId: json['camera_id'] ?? '',
      name: json['name'] ?? '',
      zoneType: json['zone_type'] ?? 'INTRUSION',
      severity: json['severity'] ?? 'SEV1',
      polygon: poly,
      isActive: json['is_active'] ?? true,
    );
  }
}

class SurveillanceEvent {
  final String id;
  final String siteId;
  final String cameraId;
  final String zoneId;
  final String eventType;
  final String severity;
  String state;
  final double confidence;
  final int trackId;
  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  SurveillanceEvent({
    required this.id,
    required this.siteId,
    required this.cameraId,
    required this.zoneId,
    required this.eventType,
    required this.severity,
    required this.state,
    required this.confidence,
    required this.trackId,
    required this.occurredAt,
    required this.metadata,
  });

  factory SurveillanceEvent.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> meta = {};
    if (json['metadata'] != null) {
      if (json['metadata'] is String) {
        try {
          meta = jsonDecode(json['metadata']);
        } catch (_) {}
      } else if (json['metadata'] is Map<String, dynamic>) {
        meta = json['metadata'];
      }
    }
    return SurveillanceEvent(
      id: json['id'] ?? '',
      siteId: json['site_id'] ?? '',
      cameraId: json['camera_id'] ?? '',
      zoneId: json['zone_id'] ?? '',
      eventType: json['event_type'] ?? 'UNKNOWN',
      severity: json['severity'] ?? 'SEV1',
      state: json['state'] ?? 'NEW',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      trackId: json['track_id'] ?? 0,
      occurredAt: json['occurred_at'] != null
          ? DateTime.tryParse(json['occurred_at']) ?? DateTime.now()
          : DateTime.now(),
      metadata: meta,
    );
  }
}
