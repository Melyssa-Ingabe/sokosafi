import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:sokosafi/features/orders/presentation/widgets/pickup_time_text.dart';
import 'package:sokosafi/features/orders/presentation/widgets/price_row.dart';

/// An order summary that expands to show its details and actions.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.details,
    required this.isExpanded,
    required this.isCancelling,
    required this.onToggle,
    required this.onShowPass,
    required this.onCancel,
  });

  final OrderDetails details;
  final bool isExpanded;
  final bool isCancelling;
  final VoidCallback onToggle;
  final VoidCallback onShowPass;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final order = details.order;
    return TapScale(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AnimatedSize(
              duration: AnimationConstants.pageTransition,
              curve: AnimationConstants.pageCurve,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrderStatusBadge(status: order.status),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              details.businessName,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${order.quantity} × ${details.title}',
                              maxLines: isExpanded ? null : 1,
                              overflow: isExpanded
                                  ? null
                                  : TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.rwf(order.total),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: AnimationConstants.pageTransition,
                            curve: AnimationConstants.pageCurve,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowDown01,
                              color: scheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isExpanded) _ExpandedDetails(card: this),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({required this.card});

  final OrderCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = card.details;
    final order = details.order;
    final pickupBy = details.listing?.pickupBy;
    final address = details.business?.address ?? '';
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: AppSpacing.xl, color: scheme.outlineVariant),
        PriceRow(
          label: 'Original value',
          amount: Formatters.rwf(details.originalTotal),
        ),
        if (details.savedAmount > 0)
          PriceRow(
            label: 'You saved',
            amount: Formatters.rwf(details.savedAmount),
            color: scheme.primary,
          ),
        const SizedBox(height: AppSpacing.sm),
        if (address.isNotEmpty)
          _InfoLine(
            icon: HugeIcons.strokeRoundedLocation01,
            child: Text(address, style: muted),
          ),
        if (pickupBy != null && order.isActive)
          _InfoLine(
            icon: HugeIcons.strokeRoundedClock01,
            child: PickupTimeText(pickupBy: pickupBy, style: muted),
          ),
        _InfoLine(
          icon: HugeIcons.strokeRoundedInvoice01,
          child: Text(
            '${order.paymentMethod.label} · ${order.pickupCode}',
            style: muted,
          ),
        ),
        if (order.isActive) ...[
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Show pickup pass', onPressed: card.onShowPass),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: card.isCancelling ? null : card.onCancel,
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(card.isCancelling ? 'Cancelling…' : 'Cancel order'),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.child});

  final List<List<dynamic>> icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}
