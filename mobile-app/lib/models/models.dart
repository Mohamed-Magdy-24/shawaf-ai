import 'dart:convert';
import 'package:equatable/equatable.dart';

class Site extends Equatable {
  final String id;
  final String code;
  final String name;
  final String timezone;
  final bool isActive;

  const Site({
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'timezone': timezone,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, code, name, timezone, isActive];
}

class Camera extends Equatable {
  final String id;
  final String siteId;
  final String name;
  final int fpsTarget;
  final bool isActive;
  final String healthStatus;
  final double currentFPS;
  final String? lastHeartbeat;
  final String? rtspUrl;
  final String? nvrId;
  final String? onvifHost;

  const Camera({
    required this.id,
    required this.siteId,
    required this.name,
    required this.fpsTarget,
    required this.isActive,
    required this.healthStatus,
    required this.currentFPS,
    this.lastHeartbeat,
    this.rtspUrl,
    this.nvrId,
    this.onvifHost,
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
      rtspUrl: json['rtsp_url'],
      nvrId: json['nvr_id'],
      onvifHost: json['onvif_host'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_id': siteId,
        'name': name,
        'fps_target': fpsTarget,
        'is_active': isActive,
        'health_status': healthStatus,
        'current_fps': currentFPS,
        'last_heartbeat': lastHeartbeat,
        'rtsp_url': rtspUrl,
        'nvr_id': nvrId,
        'onvif_host': onvifHost,
      };

  @override
  List<Object?> get props => [
        id,
        siteId,
        name,
        fpsTarget,
        isActive,
        healthStatus,
        currentFPS,
        lastHeartbeat,
        rtspUrl,
        nvrId,
        onvifHost
      ];
}

class Zone extends Equatable {
  final String id;
  final String siteId;
  final String cameraId;
  final String name;
  final String zoneType;
  final String severity;
  final List<List<double>> polygon;
  final bool isActive;

  const Zone({
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_id': siteId,
        'camera_id': cameraId,
        'name': name,
        'zone_type': zoneType,
        'severity': severity,
        'polygon': polygon,
        'is_active': isActive,
      };

  @override
  List<Object?> get props =>
      [id, siteId, cameraId, name, zoneType, severity, polygon, isActive];
}

class SurveillanceEvent extends Equatable {
  final String id;
  final String siteId;
  final String cameraId;
  final String zoneId;
  final String eventType;
  final String severity;
  final String state;
  final double confidence;
  final int trackId;
  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  String? get employeeName => metadata['employee_name'] as String?;
  String? get employeeId => metadata['employee_id'] as String?;

  const SurveillanceEvent({
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

  SurveillanceEvent copyWith({
    String? id,
    String? siteId,
    String? cameraId,
    String? zoneId,
    String? eventType,
    String? severity,
    String? state,
    double? confidence,
    int? trackId,
    DateTime? occurredAt,
    Map<String, dynamic>? metadata,
  }) {
    return SurveillanceEvent(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      cameraId: cameraId ?? this.cameraId,
      zoneId: zoneId ?? this.zoneId,
      eventType: eventType ?? this.eventType,
      severity: severity ?? this.severity,
      state: state ?? this.state,
      confidence: confidence ?? this.confidence,
      trackId: trackId ?? this.trackId,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_id': siteId,
        'camera_id': cameraId,
        'zone_id': zoneId,
        'event_type': eventType,
        'severity': severity,
        'state': state,
        'confidence': confidence,
        'track_id': trackId,
        'occurred_at': occurredAt.toIso8601String(),
        'metadata': metadata,
      };

  @override
  List<Object?> get props => [
        id,
        siteId,
        cameraId,
        zoneId,
        eventType,
        severity,
        state,
        confidence,
        trackId,
        occurredAt,
        metadata
      ];
}

class NVR extends Equatable {
  final String siteId;
  final String nvrId;
  final String name;
  final String vendor;
  final String hostIp;
  final int port;
  final String username;
  final String status;

  const NVR({
    required this.siteId,
    required this.nvrId,
    required this.name,
    required this.vendor,
    required this.hostIp,
    required this.port,
    required this.username,
    required this.status,
  });

  factory NVR.fromJson(Map<String, dynamic> json) {
    return NVR(
      siteId: json['site_id'] ?? '',
      nvrId: json['nvr_id'] ?? '',
      name: json['name'] ?? '',
      vendor: json['vendor'] ?? 'GENERIC',
      hostIp: json['host_ip'] ?? '',
      port: json['port'] ?? 554,
      username: json['username'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'nvr_id': nvrId,
        'name': name,
        'vendor': vendor,
        'host_ip': hostIp,
        'port': port,
        'username': username,
        'status': status,
      };

  @override
  List<Object?> get props =>
      [siteId, nvrId, name, vendor, hostIp, port, username, status];
}

class Employee extends Equatable {
  final String siteId;
  final String employeeId;
  final String fullName;
  final String department;
  final String? photoRelPath;
  final String sourceType;
  final bool isActive;

  String get id => employeeId;

  const Employee({
    required this.siteId,
    required this.employeeId,
    required this.fullName,
    required this.department,
    this.photoRelPath,
    required this.sourceType,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      siteId: json['site_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? 'OPERATIONS',
      photoRelPath: json['photo_rel_path'],
      sourceType: json['source_type'] ?? 'MANUAL_UPLOAD',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'employee_id': employeeId,
        'full_name': fullName,
        'department': department,
        'photo_rel_path': photoRelPath,
        'source_type': sourceType,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [
        siteId,
        employeeId,
        fullName,
        department,
        photoRelPath,
        sourceType,
        isActive
      ];
}

class EmployeePresence extends Equatable {
  final String siteId;
  final String employeeId;
  final String fullName;
  final String department;
  final String cameraId;
  final String? zoneId;
  final double confidence;
  final DateTime lastSeenAt;

  String? get zoneName => zoneId;

  const EmployeePresence({
    required this.siteId,
    required this.employeeId,
    required this.fullName,
    required this.department,
    required this.cameraId,
    this.zoneId,
    required this.confidence,
    required this.lastSeenAt,
  });

  factory EmployeePresence.fromJson(Map<String, dynamic> json) {
    return EmployeePresence(
      siteId: json['site_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? 'OPERATIONS',
      cameraId: json['camera_id'] ?? '',
      zoneId: json['zone_id'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'employee_id': employeeId,
        'full_name': fullName,
        'department': department,
        'camera_id': cameraId,
        'zone_id': zoneId,
        'confidence': confidence,
        'last_seen_at': lastSeenAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        siteId,
        employeeId,
        fullName,
        department,
        cameraId,
        zoneId,
        confidence,
        lastSeenAt
      ];
}
