import 'package:flutter/material.dart';

/// Centralized WCAG AA compliant color palette for Shawaf AI.
/// Strict dark theme industrial palette.
class AppColors {
  const AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0B111E);
  static const Color surface = Color(0xFF161F30);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color surfaceCard = Color(0xFF121B2A);
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);

  // Brand Primary (Teal)
  static const Color primary = Color(0xFF2DD4BF);
  static const Color primaryDark = Color(0xFF0D9488);
  static const Color primaryHover = Color(0xFF14B8A6);
  static const Color primaryTextOn = Color(0xFF042F2E);

  // Industrial Safety Severities
  static const Color sev1Red = Color(0xFFEF4444);
  static const Color sev1RedDark = Color(0xFF991B1B);
  static const Color sev1RedGlow = Color(0x33EF4444);

  static const Color sev2Amber = Color(0xFFF59E0B);
  static const Color sev2AmberDark = Color(0xFF92400E);
  static const Color sev2AmberGlow = Color(0x33F59E0B);

  static const Color sev3Blue = Color(0xFF3B82F6);
  static const Color sev3BlueDark = Color(0xFF1E40AF);
  static const Color sev3BlueGlow = Color(0x333B82F6);

  static const Color successGreen = Color(0xFF10B981);
  static const Color successDark = Color(0xFF065F46);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Overlays
  static const Color overlayDark = Color(0xCC0B111E);
  static const Color transparent = Colors.transparent;
}
