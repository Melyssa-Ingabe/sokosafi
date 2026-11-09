import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// "RWF" shown inside the price fields.
class RwfSuffix extends StatelessWidget {
  const RwfSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: 1,
        child: Text(
          'RWF',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
