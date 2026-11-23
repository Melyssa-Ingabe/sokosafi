import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/skeleton_row.dart';

/// Placeholder rows with a soft shimmer, shown while a list loads.
class SkeletonLoadingList extends StatefulWidget {
  const SkeletonLoadingList({super.key, this.rowCount = 5});

  final int rowCount;

  @override
  State<SkeletonLoadingList> createState() => _SkeletonLoadingListState();
}

class _SkeletonLoadingListState extends State<SkeletonLoadingList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.lerp(base, scheme.surfaceContainerLowest, 0.7)!;
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _shimmer,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              for (var index = 0; index < widget.rowCount; index++)
                const SkeletonRow(color: Colors.white),
            ],
          ),
          builder: (context, child) {
            // The band starts off the left edge and ends off the right edge.
            final shift = _shimmer.value * 3 - 1.5;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(shift - 1, 0),
                end: Alignment(shift + 1, 0),
                colors: [base, highlight, base],
              ).createShader(bounds),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
