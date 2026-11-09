import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';

/// A check mark in a green circle that springs in when first shown.
class SuccessBadge extends StatefulWidget {
  const SuccessBadge({super.key});

  @override
  State<SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<SuccessBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _controller.animateWith(
      SpringSimulation(AnimationConstants.defaultSpring, 0, 1, 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: _controller.value.clamp(0, 1.2), child: child),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedTick02,
            color: scheme.onPrimary,
            size: 28,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}
