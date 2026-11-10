import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// A label on the left and an amount on the right.
class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.color,
    this.isEmphasized = false,
  });

  final String label;
  final String amount;
  final Color? color;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = isEmphasized ? textTheme.titleMedium : textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: style?.copyWith(color: color)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(amount, style: style?.copyWith(color: color)),
        ],
      ),
    );
  }
}
