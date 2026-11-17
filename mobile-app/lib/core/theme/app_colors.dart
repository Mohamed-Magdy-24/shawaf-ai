import 'package:flutter/material.dart';

/// Centralized WCAG AA compliant matte-graphite industrial palette for Shawaf AI.
/// Replicates exact design system from shawaf_ai_ui_prototype.html.
class AppColors {
  const AppColors._();

  // Control Room Matte Graphite Surfaces
  static const Color canvas = Color(0xFF0D0F13);
  static const Color panel = Color(0xFF14171D);
  static const Color elevated = Color(0xFF1B1F27);
  static const Color borderline = Color(0xFF262B36);

  // Surface Aliases for backward compatibility
  static const Color background = canvas;
  static const Color surface = panel;
  static const Color surfaceLight = elevated;
  static const Color surfaceCard = elevated;
  static const Color border = borderline;
  static const Color borderLight = borderline;

  // Typography Tokens
  static const Color ink = Color(0xFFF1F3F5);
  static const Color muted = Color(0xFF8B93A1);
  static const Color dim = Color(0xFF5A6270);

  // Typography Aliases
  static const Color textPrimary = ink;
  static const Color textSecondary = muted;
  static const Color textMuted = dim;
  static const Color textDisabled = Color(0xFF3E4552);

  // Operational Action Tokens
  static const Color cobalt = Color(0xFF3B82F6);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFD97706);
  static const Color crimson = Color(0xFFDC2626);

  // Brand & Severity Aliases
  static const Color primary = cobalt;
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryHover = Color(0xFF2563EB);
  static const Color primaryTextOn = Color(0xFFFFFFFF);

  static const Color sev1Red = crimson;
  static const Color sev1RedDark = Color(0xFF991B1B);
  static const Color sev1RedGlow = Color(0x33DC2626);

  static const Color sev2Amber = amber;
  static const Color sev2AmberDark = Color(0xFF92400E);
  static const Color sev2AmberGlow = Color(0x33D97706);
  static const Color amberDark = Color(0xFF451A03);

  static const Color sev3Blue = cobalt;
  static const Color sev3BlueDark = Color(0xFF1E40AF);
  static const Color sev3BlueGlow = Color(0x333B82F6);

  static const Color successGreen = emerald;
  static const Color successDark = Color(0xFF065F46);

  // Overlays
  static const Color overlayDark = Color(0xCC0D0F13);
  static const Color transparent = Colors.transparent;
}
