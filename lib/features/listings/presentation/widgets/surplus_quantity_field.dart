import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/quantity_stepper.dart';

/// "SURPLUS QUANTITY" row with the shared stepper and an optional error.
class SurplusQuantityField extends StatelessWidget {
  const SurplusQuantityField({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.errorText,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SURPLUS QUANTITY', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Number of portions or packs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            QuantityStepper(
              quantity: quantity,
              onDecrease: quantity > 1 ? onDecrement : null,
              onIncrease: onIncrement,
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
