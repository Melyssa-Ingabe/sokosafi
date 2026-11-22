import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/order_action_pill.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';

/// The latest orders as rows in one card, each with its pickup action or
/// status on the right.
class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({
    super.key,
    required this.orders,
    required this.onConfirmPickup,
  });

  final List<BusinessOrder> orders;
  final VoidCallback onConfirmPickup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: ColoredBox(
        color: scheme.surfaceContainerLowest,
        child: Column(
          children: [
            for (final (index, item) in orders.indexed) ...[
              if (index > 0)
                Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
              StaggeredEntrance(
                index: index,
                child: _OrderRow(item: item, onConfirmPickup: onConfirmPickup),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.item, required this.onConfirmPickup});

  final BusinessOrder item;
  final VoidCallback onConfirmPickup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final order = item.order;
    final title = item.listingTitle.isEmpty
        ? 'Removed listing'
        : item.listingTitle;
    final portions = order.quantity == 1
        ? '1 portion'
        : '${order.quantity} portions';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: scheme.surfaceContainerHighest,
                shape: const CircleBorder(),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '$portions · ${Formatters.rwf(order.total)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OrderActionPill(status: order.status, onConfirm: onConfirmPickup),
        ],
      ),
    );
  }
}
