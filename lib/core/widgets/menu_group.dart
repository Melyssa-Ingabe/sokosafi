import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// A card of [MenuTile]s separated by thin dividers, with an optional
/// small caps title above it.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title!.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: theme.colorScheme.outlineVariant,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
