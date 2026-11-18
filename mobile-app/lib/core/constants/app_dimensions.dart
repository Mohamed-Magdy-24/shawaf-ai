import 'package:flutter/material.dart';

/// Layout, Spacing, and Breakpoint Constants
/// Conforms to 8pt Grid System & Minimum Touch Target Guidelines (min 48x48dp)
class AppDimensions {
  const AppDimensions._();

  // Spacing Scale
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Touch Targets (WCAG 2.1 AA & Rugged Industrial Device Standard)
  static const double minTouchTarget = 48.0;
  static const double gloveTouchTargetHeight = 64.0;

  // Border Radii
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusFull = 999.0;

  // Responsive Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;

  // Helper extension methods on BuildContext
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < breakpointMobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= breakpointMobile && width < breakpointTablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= breakpointTablet;
}
