import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';

/// Scales its child down while pressed and springs back on release.
/// It only listens to pointer events, so the child's own tap handling is untouched.
class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child});

  final Widget child;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  // Unbounded so the spring can overshoot slightly for a natural bounce.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );

  void _springTo(double target) {
    _controller.animateWith(
      SpringSimulation(
        AnimationConstants.defaultSpring,
        _controller.value,
        target,
        _controller.velocity,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _springTo(1),
      onPointerUp: (_) => _springTo(0),
      onPointerCancel: (_) => _springTo(0),
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final scale =
              1 - (1 - AnimationConstants.tapScale) * _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
      ),
    );
  }
}
