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
      OrderStatus.paid => const AppBadge(
        label: 'Ready for pickup',
        backgroundColor: AppColors.brandSubtle,
        foregroundColor: AppColors.primary,
      ),
      OrderStatus.collected => const AppBadge(label: 'Collected'),
      OrderStatus.cancelled => const AppBadge(
        label: 'Cancelled',
        backgroundColor: AppColors.surfaceSubtle,
        foregroundColor: AppColors.textSecondary,
      ),
    };
  }
}
