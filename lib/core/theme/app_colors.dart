import 'package:flutter/material.dart';

/// Design tokens from the Figma file. Always use these instead of raw hex values.
abstract final class AppColors {
  static const Color primary = Color(0xFF3D9C5D);
  static const Color pressed = Color(0xFF2F7D49);

  /// The app has one brand green. Kept so older call sites keep compiling.
  static const Color accent = primary;
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

  // Card outlines thinner than [borderSubtle], from the discovery frames.
  static const Color hairline = Color(0x141F2E24);
  static const Color hairlineFaint = Color(0x0A000000);

  // Shading over shop photos so white text on them stays readable.
  static const Color photoShade = Color(0x73000000);
  static const Color photoShadeLight = Color(0x26000000);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorSubtle = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFB45309);

  /// A saved shop's heart.
  static const Color favourite = Color(0xFFE5484D);
}
