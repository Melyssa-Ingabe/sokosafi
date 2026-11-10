import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';

/// Slide and fade transition used by every route.
Page<void> buildAppPage({required GoRouterState state, required Widget child}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AnimationConstants.pageTransition,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = animation.drive(
        CurveTween(curve: AnimationConstants.pageCurve),
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: curved.drive(
            Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero),
          ),
          child: child,
        ),
      );
    },
  );
}
