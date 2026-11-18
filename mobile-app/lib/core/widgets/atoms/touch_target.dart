import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';

/// Wraps any child to ensure minimum 48x48dp touch target size
/// per WCAG 2.1 AA and flutter-ux-architecture requirements
class TouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final double minSize;

  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
    this.minSize = AppDimensions.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: Center(child: child),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: content,
      );
    }

    if (tooltip != null) {
      content = Tooltip(message: tooltip!, child: content);
    }

    return content;
  }
}
