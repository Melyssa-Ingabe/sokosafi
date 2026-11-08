import 'package:flutter/material.dart';

/// Design tokens from the Figma file. Always use these instead of raw hex values.
abstract final class AppColors {
  static const Color primary = Color(0xFF006A35);
  static const Color pressed = Color(0xFF005235);

  // White text on accent is only about 3.4:1, so use it for borders,
  // icons and large text, not for small labels on a filled background.
  static const Color accent = Color(0xFF3D9C5D);
  static const Color brandSubtle = Color(0xFFDBE5DE);

  static const Color lime = Color(0xFFB5EE78);
  static const Color onLime = Color(0xFF2D5000);

  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF0F0F0);

  static const Color textPrimary = Color(0xFF1C1B1B);
  static const Color textSecondary = Color(0xFF57615B);
  // Darkened from the Figma value (#6F7A6F), which failed the 4.5:1 contrast
  // check on the background.
  static const Color textTertiary = Color(0xFF5A665A);

  static const Color border = Color(0xFFBFC9C0);
  static const Color borderSubtle = Color(0xFFE5E7EB);

  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFB45309);
}
