import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// Shown while the app checks whether a user is logged in. The router moves
/// on as soon as the answer arrives.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: AnimationConstants.pageTransition,
          curve: AnimationConstants.pageCurve,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - value)),
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SokoSafi',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
