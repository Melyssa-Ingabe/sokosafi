import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles in Geist. Colors are not set here: they come from the theme,
/// so light and dark mode both work.
abstract final class AppTextStyles {
  static TextStyle _geist(double size, FontWeight weight, double lineHeight) {
    return GoogleFonts.geist(
      fontSize: size,
      fontWeight: weight,
      height: lineHeight / size,
    );
  }

  static final TextStyle headline = _geist(24, FontWeight.w600, 32);
  static final TextStyle title = _geist(20, FontWeight.w600, 28);
  static final TextStyle subtitle = _geist(16, FontWeight.w500, 24);
  static final TextStyle bodyLarge = _geist(16, FontWeight.w400, 24);
  static final TextStyle body = _geist(14, FontWeight.w400, 20);
  static final TextStyle label = _geist(14, FontWeight.w500, 20);
  static final TextStyle button = _geist(16, FontWeight.w600, 24);
  static final TextStyle caption = _geist(12, FontWeight.w400, 16);

  static TextTheme get textTheme => TextTheme(
    headlineMedium: headline,
    titleLarge: title,
    titleMedium: subtitle,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    labelLarge: button,
    labelMedium: label,
    bodySmall: caption,
  );
}
