import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeverityBadge extends StatefulWidget {
  final String severity;
  final double fontSize;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.fontSize = 11,
  });

  @override
  State<SeverityBadge> createState() => _SeverityBadgeState();
}

class _SeverityBadgeState extends State<SeverityBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  bool get _isCritical =>
      widget.severity.toUpperCase().contains('SEV1') ||
      widget.severity.toUpperCase().contains('CRITICAL') ||
      widget.severity.toUpperCase().contains('FIRE');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isCritical) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SeverityBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isCritical && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!_isCritical && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBadgeColor() {
    final s = widget.severity.toUpperCase();
    if (s.contains('SEV1') || s.contains('FIRE') || s.contains('CRITICAL')) {
      return AppTheme.sev1Red;
    } else if (s.contains('SEV2') || s.contains('WARNING') || s.contains('MEDIUM')) {
      return AppTheme.sev2Amber;
    } else {
      return AppTheme.sev3Blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );

    if (_isCritical) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: badge,
      );
    }

    return badge;
  }
}
