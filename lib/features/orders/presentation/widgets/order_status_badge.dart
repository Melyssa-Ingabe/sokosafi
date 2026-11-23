import 'package:flutter/material.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      OrderStatus.paid => AppBadge(
        label: 'Ready for pickup',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: AppColors.primary,
      ),
      OrderStatus.collected => const AppBadge(label: 'Collected'),
      OrderStatus.cancelled => AppBadge(
        label: 'Cancelled',
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    };
  }
}
