import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Opens a route as a modal bottom sheet over the current screen, so it
/// keeps its own URL and back behaviour. The child draws its own shape.
Page<void> buildBottomSheetPage({
  required GoRouterState state,
  required Widget child,
}) {
  return _BottomSheetPage(key: state.pageKey, child: child);
}

class _BottomSheetPage extends Page<void> {
  const _BottomSheetPage({super.key, required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<void>(
      settings: this,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => child,
    );
  }
}
