import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Industrial Dark Theme Engine
/// Enforces WCAG 2.1 AA Compliance with 4.5:1 Minimum Contrast
class AppTheme {
  const AppTheme._();

  static ThemeData get industrialDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      canvasColor: AppColors.surfaceCanvas,
      cardColor: AppColors.surfacePanel,
      dividerColor: AppColors.borderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.statusInfo,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.statusNormal,
        onSecondary: AppColors.surfaceCanvas,
        surface: AppColors.surfacePanel,
        onSurface: AppColors.textPrimary,
        error: AppColors.statusCritical,
        onError: AppColors.textPrimary,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.borderSubtle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfacePanel,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading1,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfacePanel,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusInfo,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          textStyle: AppTypography.heading2,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          side: const BorderSide(color: AppColors.borderStrong, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          textStyle: AppTypography.body,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.statusInfo,
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          textStyle: AppTypography.body,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing14,
        ),
        hintStyle: AppTypography.bodySecondary.copyWith(color: AppColors.textDisabled),
        labelStyle: AppTypography.caption,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.statusInfo, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.statusCritical),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfacePanel,
        selectedItemColor: AppColors.statusInfo,
        unselectedItemColor: AppColors.textDisabled,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}

