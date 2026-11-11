import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_status_badge.dart';

/// One order as the business sees it.
class BusinessOrderCard extends StatelessWidget {
  const BusinessOrderCard({
    super.key,
    required this.item,
    this.onConfirmPickup,
  });

  final BusinessOrder item;

  /// Only passed for orders still waiting to be picked up.
  final VoidCallback? onConfirmPickup;

  @override
  Widget build(BuildContext context) {
    final order = item.order;
    final title = item.listingTitle.isEmpty
        ? 'Removed listing'
        : item.listingTitle;
    final orderedAt = DateFormatters.dayAndTime(
      order.createdAt,
      now: DateTime.now(),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OrderIcon(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.quantity}× $title',
                        style: AppTextStyles.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${order.pickupCode} · $orderedAt',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(Formatters.rwf(order.total), style: AppTextStyles.label),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                OrderStatusBadge(status: order.status),
                const Spacer(),
                if (onConfirmPickup != null)
                  TextButton(
                    onPressed: onConfirmPickup,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        AppSpacing.minTapTarget,
                        AppSpacing.minTapTarget,
                      ),
                    ),
                    child: const Text('Confirm pickup'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const _OrderIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.brandSubtle,
          borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
        ),
        child: const Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedShoppingBag01,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
