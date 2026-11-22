import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// One placeholder row: an avatar circle, two text bars and a short
/// trailing bar. Shaped like a list row so skeletons look like real content.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          _Block(width: 56, height: 56, color: fill, circle: true),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.75,
                  child: _Block(height: 14, color: fill),
                ),
                const SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: _Block(height: 12, color: fill),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          _Block(width: 56, height: 12, color: fill),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.height,
    required this.color,
    this.width,
    this.circle = false,
  });

  final double? width;
  final double height;
  final Color color;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color,
          shape: circle ? const CircleBorder() : const StadiumBorder(),
        ),
      ),
    );
  }
}
