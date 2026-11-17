import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Standardized typography scale for Shawaf AI.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Roboto';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppColors.primaryTextOn,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle monospace = TextStyle(
    fontSize: 12,
    fontFamily: 'JetBrains Mono',
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.primary,
  );

  static const TextStyle tabularMono = TextStyle(
    fontSize: 13,
    fontFamily: 'JetBrains Mono',
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.ink,
  );

  static const TextStyle tabularMonoSmall = TextStyle(
    fontSize: 11,
    fontFamily: 'JetBrains Mono',
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.muted,
  );
}
