import 'package:flutter/animation.dart';

/// Shared animation values so every screen moves the same way.
abstract final class AnimationConstants {
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 25,
  );

  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Curve pageCurve = Curves.easeOutCubic;

  static const Duration listItem = Duration(milliseconds: 200);
  static const Duration listStagger = Duration(milliseconds: 40);
  static const Curve listCurve = Curves.easeOutQuart;

  static const Duration imageFade = Duration(milliseconds: 300);
  static const Curve imageFadeCurve = Curves.easeOut;

  /// Scale applied while a card or button is pressed.
  static const double tapScale = 0.96;
}
