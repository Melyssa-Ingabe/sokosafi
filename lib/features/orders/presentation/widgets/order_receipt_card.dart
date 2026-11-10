import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/presentation/widgets/pickup_time_text.dart';
import 'package:sokosafi/features/orders/presentation/widgets/price_row.dart';

class OrderReceiptCard extends StatelessWidget {
  const OrderReceiptCard({super.key, required this.details});

  final OrderDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final order = details.order;
    final address = details.business?.address ?? '';
    final pickupBy = details.listing?.pickupBy;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  color: scheme.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    details.businessName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(address, style: muted),
            ],
            if (pickupBy != null) ...[
              const SizedBox(height: AppSpacing.xs),
              PickupTimeText(pickupBy: pickupBy, style: muted),
            ],
            Divider(height: AppSpacing.xxl, color: scheme.outlineVariant),
            PriceRow(
              label: '${order.quantity} × ${details.title}',
              amount: Formatters.rwf(details.originalTotal),
            ),
            if (details.savedAmount > 0)
              PriceRow(
                label: 'Rescue discount',
                amount: '-${Formatters.rwf(details.savedAmount)}',
                color: scheme.primary,
              ),
            Divider(height: AppSpacing.xl, color: scheme.outlineVariant),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paid with', style: muted),
                      Text(
                        order.paymentMethod.label,
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total paid', style: muted),
                    Text(
                      Formatters.rwf(order.total),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
