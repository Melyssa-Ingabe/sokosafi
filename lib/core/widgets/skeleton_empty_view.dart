import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/skeleton_row.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';

/// Empty state drawn as faded placeholder rows with a title and hint below,
/// so an empty list still shows what will appear there. Scrolls so it never
/// overflows in landscape. Place it inside a bounded parent such as Expanded.
class SkeletonEmptyView extends StatelessWidget {
  const SkeletonEmptyView({
    super.key,
    required this.title,
    this.message,
    this.rowCount = 3,
  });

  final String title;
  final String? message;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - AppSpacing.xl * 2).clamp(
                0,
                double.infinity,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rows fade out towards the text so the eye lands on it.
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: [0.3, 1],
                  ).createShader(bounds),
                  child: Column(
                    children: [
                      for (var index = 0; index < rowCount; index++)
                        StaggeredEntrance(
                          index: index,
                          child: const SkeletonRow(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                StaggeredEntrance(
                  index: rowCount,
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
