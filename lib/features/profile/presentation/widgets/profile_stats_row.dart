import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:sokosafi/features/profile/presentation/widgets/stat_tile.dart';

/// Orders, money saved and meals rescued, worked out from the orders.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  static String _compact(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(0)}k';
    final digits = value.round().toString();
    if (digits.length <= 3) return digits;
    return '${digits.substring(0, digits.length - 3)},'
        '${digits.substring(digits.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOrdersCubit, MyOrdersState>(
      builder: (context, state) {
        final isReady = state.status == MyOrdersStatus.ready;
        final stats = state.stats;
        String show(num value) => isReady ? _compact(value) : '–';
        return Row(
          children: [
            Expanded(
              child: StatTile(value: show(stats.orderCount), label: 'Orders'),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                value: show(stats.amountSaved),
                label: 'RWF saved',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                value: show(stats.mealsRescued),
                label: 'Meals rescued',
              ),
            ),
          ],
        );
      },
    );
  }
}
