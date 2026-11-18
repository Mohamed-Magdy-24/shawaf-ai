import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The 10 Mandatory Industrial UI States
/// Defined in Section 1 of docs/design/PROPOSED_PRODUCT_UX_BLUEPRINT.md
sealed class IndustrialUIState {
  const IndustrialUIState();

  String get label;
  Color get color;
  IconData get icon;
}

class UILoading extends IndustrialUIState {
  final String message;
  const UILoading([this.message = 'Retrieving telemetry...']);

  @override
  String get label => 'LOADING';
  @override
  Color get color => AppColors.textSecondary;
  @override
  IconData get icon => Icons.refresh;
}

class UILive extends IndustrialUIState {
  final double latencyMs;
  const UILive([this.latencyMs = 45.0]);

  @override
  String get label => 'LIVE';
  @override
  Color get color => AppColors.statusNormal;
  @override
  IconData get icon => Icons.fiber_manual_record;
}

class UIDelayed extends IndustrialUIState {
  final double latencySeconds;
  const UIDelayed([this.latencySeconds = 2.4]);

  @override
  String get label => 'DELAYED';
  @override
  Color get color => AppColors.statusWarning;
  @override
  IconData get icon => Icons.access_time;
}

class UIStale extends IndustrialUIState {
  final Duration elapsedSinceHeartbeat;
  const UIStale([this.elapsedSinceHeartbeat = const Duration(seconds: 15)]);

  @override
  String get label => 'STALE';
  @override
  Color get color => AppColors.statusStale;
  @override
  IconData get icon => Icons.history;
}

class UIOffline extends IndustrialUIState {
  final String reason;
  const UIOffline([this.reason = 'Device connection severed']);

  @override
  String get label => 'OFFLINE';
  @override
  Color get color => AppColors.statusCritical;
  @override
  IconData get icon => Icons.cloud_off;
}

class UIEmpty extends IndustrialUIState {
  final String explanation;
  const UIEmpty([this.explanation = 'Zero events match current filter']);

  @override
  String get label => 'EMPTY';
  @override
  Color get color => AppColors.textSecondary;
  @override
  IconData get icon => Icons.inbox;
}

class UIError extends IndustrialUIState {
  final String errorCode;
  final String message;
  const UIError({required this.errorCode, required this.message});

  @override
  String get label => 'ERROR';
  @override
  Color get color => AppColors.statusCritical;
  @override
  IconData get icon => Icons.warning_amber_rounded;
}

class UIUnauthorized extends IndustrialUIState {
  final String message;
  const UIUnauthorized([this.message = 'Operator role lacks permission for this camera or site']);

  @override
  String get label => 'UNAUTHORIZED';
  @override
  Color get color => AppColors.statusWarning;
  @override
  IconData get icon => Icons.lock_outline;
}

class UIPermissionDenied extends IndustrialUIState {
  final String detail;
  const UIPermissionDenied([this.detail = 'Action rejected by server RBAC (D-011)']);

  @override
  String get label => 'PERMISSION_DENIED';
  @override
  Color get color => AppColors.statusCritical;
  @override
  IconData get icon => Icons.block;
}

class UIPartiallyAvailable extends IndustrialUIState {
  final String reason;
  const UIPartiallyAvailable([this.reason = 'Degraded mode: sub-stream only, AI worker degraded']);

  @override
  String get label => 'PARTIALLY_AVAILABLE';
  @override
  Color get color => AppColors.statusPurple;
  @override
  IconData get icon => Icons.warning_rounded;
}
