import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum CameraStatus {
  online('ONLINE', AppColors.statusNormal),
  offline('OFFLINE', AppColors.statusCritical),
  degraded('DEGRADED', AppColors.statusWarning);

  final String value;
  final Color color;
  const CameraStatus(this.value, this.color);

  static CameraStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'OFFLINE':
        return CameraStatus.offline;
      case 'DEGRADED':
        return CameraStatus.degraded;
      case 'ONLINE':
      default:
        return CameraStatus.online;
    }
  }
}

typedef CameraStreamStatus = CameraStatus;

class Camera {
  final String id;
  final String siteId;
  final String name;
  final String zoneId;
  final CameraStatus status;
  final double fpsDecoded;
  final int droppedFrames;
  final DateTime lastHeartbeatUtc;
  final String resolution;
  final double bitrateKbps;
  final double latencyMs;

  const Camera({
    required this.id,
    required this.siteId,
    required this.name,
    required this.zoneId,
    required this.status,
    required this.fpsDecoded,
    required this.droppedFrames,
    required this.lastHeartbeatUtc,
    this.resolution = '1920x1080',
    this.bitrateKbps = 4096.0,
    this.latencyMs = 38.0,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as String,
      siteId: json['site_id'] as String,
      name: json['name'] as String,
      zoneId: json['zone_id'] as String? ?? 'DEFAULT_ZONE',
      status: CameraStatus.fromString(json['status'] as String? ?? 'ONLINE'),
      fpsDecoded: (json['fps_decoded'] as num?)?.toDouble() ?? 25.0,
      droppedFrames: (json['dropped_frames'] as num?)?.toInt() ?? 0,
      lastHeartbeatUtc: json['last_heartbeat'] != null
          ? DateTime.parse(json['last_heartbeat'] as String).toUtc()
          : DateTime.now().toUtc(),
      resolution: json['resolution'] as String? ?? '1920x1080',
      bitrateKbps: (json['bitrate_kbps'] as num?)?.toDouble() ?? 4096.0,
      latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 38.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_id': siteId,
        'name': name,
        'zone_id': zoneId,
        'status': status.value,
        'fps_decoded': fpsDecoded,
        'dropped_frames': droppedFrames,
        'last_heartbeat': lastHeartbeatUtc.toIso8601String(),
        'resolution': resolution,
        'bitrate_kbps': bitrateKbps,
        'latency_ms': latencyMs,
      };

  Camera copyWith({
    String? id,
    String? siteId,
    String? name,
    String? zoneId,
    CameraStatus? status,
    double? fpsDecoded,
    int? droppedFrames,
    DateTime? lastHeartbeatUtc,
    String? resolution,
    double? bitrateKbps,
    double? latencyMs,
  }) {
    return Camera(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      zoneId: zoneId ?? this.zoneId,
      status: status ?? this.status,
      fpsDecoded: fpsDecoded ?? this.fpsDecoded,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      lastHeartbeatUtc: lastHeartbeatUtc ?? this.lastHeartbeatUtc,
      resolution: resolution ?? this.resolution,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}

typedef CameraModel = Camera;
