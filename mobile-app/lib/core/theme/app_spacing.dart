import 'package:flutter/material.dart';

/// 8px Grid Constants and Radius values for Shawaf AI.
class AppSpacing {
  const AppSpacing._();

  // Spacing values
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Touch Target minimums (WCAG 2.1 AAA)
  static const double minTouchTarget = 48.0;

  // Radius values
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;

  // BorderRadius objects
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // EdgeInsets presets
  static const EdgeInsets p4 = EdgeInsets.all(xs);
  static const EdgeInsets p8 = EdgeInsets.all(sm);
  static const EdgeInsets p12 = EdgeInsets.all(md);
  static const EdgeInsets p16 = EdgeInsets.all(lg);
  static const EdgeInsets p24 = EdgeInsets.all(xl);
  static const EdgeInsets p32 = EdgeInsets.all(xxl);

  static const EdgeInsets px8 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets py4 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets py8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets py12 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets py16 = EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets badgePadding = EdgeInsets.symmetric(horizontal: radiusSm, vertical: xxs);

  // SizedBox spacing widgets
  static const Widget vGap4 = SizedBox(height: xs);
  static const Widget vGap8 = SizedBox(height: sm);
  static const Widget vGap12 = SizedBox(height: md);
  static const Widget vGap16 = SizedBox(height: lg);
  static const Widget vGap24 = SizedBox(height: xl);
  static const Widget vGap32 = SizedBox(height: xxl);

  static const Widget hGap4 = SizedBox(width: xs);
  static const Widget hGap8 = SizedBox(width: sm);
  static const Widget hGap12 = SizedBox(width: md);
  static const Widget hGap16 = SizedBox(width: lg);
  static const Widget hGap24 = SizedBox(width: xl);
  static const Widget hGap32 = SizedBox(width: xxl);
}
