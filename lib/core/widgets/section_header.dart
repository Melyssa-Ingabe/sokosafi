import 'package:flutter/material.dart';

/// Section title with an optional action such as "See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.isActionSubtle = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Grey instead of green, for secondary links like "View all".
  final bool isActionSubtle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: isActionSubtle
                  ? TextButton.styleFrom(
                      foregroundColor: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    )
                  : null,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
