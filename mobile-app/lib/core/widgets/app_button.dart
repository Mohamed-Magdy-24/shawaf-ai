import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, destructive, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primary;
        fg = AppColors.primaryTextOn;
        break;
      case ButtonVariant.secondary:
        bg = AppColors.surfaceLight;
        fg = AppColors.textPrimary;
        break;
      case ButtonVariant.destructive:
        bg = AppColors.sev1Red;
        fg = AppColors.textPrimary;
        break;
      case ButtonVariant.outlined:
        bg = AppColors.transparent;
        fg = AppColors.textPrimary;
        side = const BorderSide(color: AppColors.border);
        break;
    }

    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: AppSpacing.minTouchTarget,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.4),
          disabledForegroundColor: fg.withValues(alpha: 0.4),
          side: side,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        onPressed: disabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    AppSpacing.hGap8,
                  ],
                  Text(
                    label,
                    style: AppTypography.titleSmall.copyWith(
                      color: fg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
