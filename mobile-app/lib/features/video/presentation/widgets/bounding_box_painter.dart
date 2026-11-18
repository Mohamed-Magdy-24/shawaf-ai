import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../incidents/domain/incident.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> bboxes;
  final bool showLabels;
  final bool showConfidence;

  const BoundingBoxPainter({
    required this.bboxes,
    this.showLabels = true,
    this.showConfidence = true,
  });

  Color _resolveBoxColor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('fire') || lower.contains('smoke') || lower.contains('restricted')) {
      return AppColors.statusCritical;
    } else if (lower.contains('no_helmet') ||
        lower.contains('no_vest') ||
        lower.contains('fall') ||
        lower.contains('worker_down')) {
      return AppColors.statusWarning;
    } else {
      return AppColors.accentCyan;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (bboxes.isEmpty) return;

    for (final box in bboxes) {
      final color = _resolveBoxColor(box.label);

      final left = (box.x1 * size.width).clamp(0.0, size.width);
      final top = (box.y1 * size.height).clamp(0.0, size.height);
      final right = (box.x2 * size.width).clamp(0.0, size.width);
      final bottom = (box.y2 * size.height).clamp(0.0, size.height);
      final rect = Rect.fromLTRB(left, top, right, bottom);

      // Draw bounding box outline
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, boxPaint);

      // Corner accent brackets for industrial HUD look
      final bracketPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      const bracketLen = 12.0;
      // Top-Left
      canvas.drawLine(Offset(left, top), Offset(left + bracketLen, top), bracketPaint);
      canvas.drawLine(Offset(left, top), Offset(left, top + bracketLen), bracketPaint);
      // Top-Right
      canvas.drawLine(Offset(right, top), Offset(right - bracketLen, top), bracketPaint);
      canvas.drawLine(Offset(right, top), Offset(right, top + bracketLen), bracketPaint);
      // Bottom-Left
      canvas.drawLine(Offset(left, bottom), Offset(left + bracketLen, bottom), bracketPaint);
      canvas.drawLine(Offset(left, bottom), Offset(left, bottom - bracketLen), bracketPaint);
      // Bottom-Right
      canvas.drawLine(Offset(right, bottom), Offset(right - bracketLen, bottom), bracketPaint);
      canvas.drawLine(Offset(right, bottom), Offset(right, bottom - bracketLen), bracketPaint);

      // Label & Confidence Tag
      if (showLabels) {
        final trackStr = box.trackId != null ? ' #${box.trackId}' : '';
        final confStr = showConfidence ? ' ${(box.confidence * 100).toStringAsFixed(0)}%' : '';
        final labelText = '${box.label.toUpperCase()}$trackStr$confStr';

        final textSpan = TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'JetBrains Mono',
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final labelBgRect = Rect.fromLTWH(
          left,
          (top - 18.0).clamp(0.0, size.height),
          textPainter.width + 8.0,
          16.0,
        );

        final labelBgPaint = Paint()..color = color.withValues(alpha: 0.85);
        canvas.drawRect(labelBgRect, labelBgPaint);

        textPainter.paint(canvas, Offset(labelBgRect.left + 4.0, labelBgRect.top + 1.0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.bboxes != bboxes ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.showConfidence != showConfidence;
  }
}
