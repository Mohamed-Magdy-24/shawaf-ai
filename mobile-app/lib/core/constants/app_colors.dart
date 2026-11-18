import 'package:flutter/material.dart';

/// Industrial Surveillance Color Token Palette
/// Strictly conforms to docs/design/PROPOSED_PRODUCT_UX_BLUEPRINT.md
class AppColors {
  const AppColors._();

  // Surface Tokens
  static const Color surfaceCanvas = Color(0xFF0B0F17);
  static const Color surfacePanel = Color(0xFF111827);
  static const Color surfaceRaised = Color(0xFF1F2937);

  // Border Tokens
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderStrong = Color(0xFF334155);

  // Typography Tokens
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF475569);

  // Semantic Status Tokens
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusNormal = Color(0xFF10B981);
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusStale = Color(0xFF64748B);

  // Accent and Specialized Tokens
  static const Color statusPurple = Color(0xFF8B5CF6); // Coverage lost / anomaly
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color overlayDark = Color(0xCC0B0F17);
}
