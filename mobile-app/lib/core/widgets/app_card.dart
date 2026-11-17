import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable atomic container card with consistent border and elevation.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.p16,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
    this.borderWidth = 1.0,
    this.borderRadius = AppSpacing.roundedMd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
