import 'package:flutter/material.dart';
import '../models/models.dart';
import '../features/alerts/presentation/pages/alert_detail_page.dart';

export '../features/alerts/presentation/pages/alert_detail_page.dart';

class AlertDetailScreen extends StatelessWidget {
  final SurveillanceEvent event;
  final Future<void> Function(String action, String note)? onAction;

  const AlertDetailScreen({
    super.key,
    required this.event,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDetailPage(event: event);
  }
}
