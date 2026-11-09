import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_receipt_card.dart';
import 'package:sokosafi/features/orders/presentation/widgets/pickup_pass_card.dart';
import 'package:sokosafi/features/orders/presentation/widgets/success_badge.dart';
import 'package:sokosafi/router/app_routes.dart';

class OrderConfirmationBody extends StatelessWidget {
  const OrderConfirmationBody({super.key, required this.details});

  final OrderDetails details;

  (String, String) get _headline => switch (details.order.status) {
    OrderStatus.paid => ('Reserved!', 'Show this at pickup'),
    OrderStatus.collected => ('Collected', 'Enjoy your rescued food'),
    OrderStatus.cancelled => ('Cancelled', 'This order was cancelled'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, subtitle) = _headline;
    final sections = <Widget>[
      Column(
        children: [
          if (details.order.status == OrderStatus.paid) ...[
            const SuccessBadge(),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      if (details.order.isActive)
        PickupPassCard(pickupCode: details.order.pickupCode),
      OrderReceiptCard(details: details),
      PrimaryButton(
        label: 'View my orders',
        onPressed: () => context.go(AppRoutes.myOrders),
      ),
    ];
    return SafeArea(
      top: false,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
        itemBuilder: (context, index) =>
            StaggeredEntrance(index: index, child: sections[index]),
      ),
    );
  }
}
