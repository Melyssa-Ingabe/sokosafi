import 'package:flutter/widgets.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';

/// Fades and slides its child up once, delayed by its position in a list.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  // Long lists would wait too long for their last items, so the delay stops
  // growing after a handful of rows.
  static const int _maxStaggeredItems = 8;

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
    final steps = widget.index.clamp(0, _maxStaggeredItems);
    Future<void>.delayed(AnimationConstants.listStagger * steps, () {
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
      builder: (context, child) {
        return Opacity(
          opacity: _progress.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - _progress.value)),
            child: child,
          ),
        );
      },
    );
  }
}
