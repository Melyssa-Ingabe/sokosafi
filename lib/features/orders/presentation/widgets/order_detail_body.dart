import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/store_contact_buttons.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_receipt_card.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_status_timeline.dart';
import 'package:sokosafi/features/orders/presentation/widgets/pickup_pass_card.dart';
import 'package:sokosafi/router/app_routes.dart';

class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({
    super.key,
    required this.details,
    this.isCancelling = false,
    this.onCancel,
  });

  final OrderDetails details;
  final bool isCancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = details.order;
    final business = details.business;

    final sections = <Widget>[
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(details.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details.businessName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
      if (details.listing != null &&
          details.listing!.pickupBy.isAfter(DateTime.now()) &&
          order.isActive)
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pick up by ${Formatters.timeLeft(details.listing!.pickupBy.difference(DateTime.now()))}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (order.isActive && business != null)
        StoreContactButtons(
          latitude: business.latitude,
          longitude: business.longitude,
          phone: business.phone,
        ),
      OrderStatusTimeline(
        status: order.status,
        createdAt: order.createdAt,
        collectedAt: order.collectedAt,
      ),
      if (order.isActive) PickupPassCard(pickupCode: order.pickupCode),
      OrderReceiptCard(details: details),
      if (order.isActive)
        OutlinedButton(
          onPressed: isCancelling ? null : () => _confirmCancel(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
          ),
          child: isCancelling
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : const Text('Cancel order'),
        ),
      // A collected order opens Rate Experience, which also refuses an order
      // that was already rated.
      if (order.status == OrderStatus.collected)
        PrimaryButton(
          label: 'Rate your pickup',
          onPressed: () => context.push(AppRoutes.rateOrderFor(order.id)),
        ),
    ];

    return SafeArea(
      top: false,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) =>
            StaggeredEntrance(index: index, child: sections[index]),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'The items will be returned to stock and your payment refunded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) onCancel?.call();
    });
  }
}
