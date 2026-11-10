import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/price_row.dart';
import 'package:sokosafi/features/orders/presentation/widgets/quantity_stepper.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.state,
    required this.onIncrease,
    required this.onDecrease,
  });

  final CheckoutState state;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final listing = state.item!.listing;
    final percentOff = Formatters.discountPercent(
      original: listing.originalPrice,
      discounted: listing.discountPrice,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Surplus bag summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.title, style: theme.textTheme.labelMedium),
                      Text(
                        '${Formatters.rwf(listing.discountPrice)} each · '
                        '${listing.quantityLeft} left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                QuantityStepper(
                  quantity: state.quantity,
                  onIncrease: state.canIncrease ? onIncrease : null,
                  onDecrease: state.canDecrease ? onDecrease : null,
                ),
              ],
            ),
            Divider(height: AppSpacing.xxl, color: scheme.outlineVariant),
            PriceRow(
              label: 'Original value',
              amount: Formatters.rwf(state.originalTotal),
            ),
            if (state.discount > 0)
              PriceRow(
                label: 'Surplus discount (-$percentOff%)',
                amount: '-${Formatters.rwf(state.discount)}',
                color: scheme.primary,
              ),
            const SizedBox(height: AppSpacing.xs),
            PriceRow(
              label: 'Total payment',
              amount: Formatters.rwf(state.total),
              isEmphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}
