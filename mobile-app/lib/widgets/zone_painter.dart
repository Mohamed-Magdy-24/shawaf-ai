import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ZonePainter extends CustomPainter {
  final List<Zone> zones;
  final List<SurveillanceEvent> activeEvents;

  ZonePainter({
    required this.zones,
    required this.activeEvents,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppTheme.primaryTeal
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    // Draw safety zones
    for (final zone in zones) {
      if (zone.polygon.length < 3) continue;

      final path = Path();
      for (int i = 0; i < zone.polygon.length; i++) {
        final x = zone.polygon[i][0] * size.width;
        final y = zone.polygon[i][1] * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: ' ${zone.name} (${zone.zoneType}) ',
          style: const TextStyle(
            color: Color(0xFF042F2E),
            backgroundColor: AppTheme.primaryTeal,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final firstX = zone.polygon[0][0] * size.width;
      final firstY = zone.polygon[0][1] * size.height;
      tp.paint(canvas, Offset(firstX + 4, firstY + 4));
    }

    // Draw active event detections / bounding boxes
    final alertBoxPaint = Paint()
      ..color = AppTheme.sev1Red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final ev in activeEvents) {
      if (ev.metadata['foot_point'] != null) {
        final fp = ev.metadata['foot_point'];
        if (fp is List && fp.length >= 2) {
          final fx = (fp[0] as num).toDouble() * size.width;
          final fy = (fp[1] as num).toDouble() * size.height;

          // Foot circle
          final footPaint = Paint()
            ..color = AppTheme.sev1Red
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(fx, fy), 5, footPaint);

          // Simulated bounding box around target
          final bw = size.width * 0.12;
          final bh = size.height * 0.28;
          final rect = Rect.fromCenter(
            center: Offset(fx, fy - bh / 2),
            width: bw,
            height: bh,
          );
          canvas.drawRect(rect, alertBoxPaint);

          // Label
          final labelPainter = TextPainter(
            text: TextSpan(
              text: ' TRACK #${ev.trackId} [ALERT] ',
              style: const TextStyle(
                color: Colors.white,
                backgroundColor: AppTheme.sev1Red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          labelPainter.layout();
          labelPainter.paint(canvas, Offset(rect.left, rect.top - 14));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ZonePainter oldDelegate) => true;
}
