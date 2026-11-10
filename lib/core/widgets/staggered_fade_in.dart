import 'package:flutter/widgets.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';

/// Fades and slides a list item in, delayed by its position so a list
/// appears one item after another. Plays once, when the item first builds.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Items further down than this appear together, so long lists do not
  /// keep the user waiting.
  static const int maxStaggeredItems = 8;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AnimationConstants.listItem,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AnimationConstants.listCurve,
  );

  @override
  void initState() {
    super.initState();
    final position = widget.index.clamp(0, StaggeredFadeIn.maxStaggeredItems);
    Future<void>.delayed(AnimationConstants.listStagger * position, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}
