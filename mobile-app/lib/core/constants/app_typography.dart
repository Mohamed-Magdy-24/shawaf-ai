import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Industrial Typography Specification
/// Conforms to Section 2.2 of PROPOSED_PRODUCT_UX_BLUEPRINT.md
class AppTypography {
  const AppTypography._();

  static const String fontFamilySans = 'Inter';
  static const String fontFamilyMono = 'JetBrains Mono';

  static const TextStyle display = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 32.0 / 28.0,
    letterSpacing: -0.02,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 26.0 / 20.0,
    letterSpacing: -0.01,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 22.0 / 16.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 16.0 / 12.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    height: 14.0 / 11.0,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Monospace Telemetry Styles
  static const TextStyle telemetry = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: ['Courier New', 'monospace'],
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 18.0 / 13.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle telemetrySmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: ['Courier New', 'monospace'],
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 14.0 / 11.0,
    color: AppColors.textSecondary,
  );
}
