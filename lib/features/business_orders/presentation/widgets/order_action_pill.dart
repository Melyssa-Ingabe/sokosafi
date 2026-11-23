import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/order_actions_cubit.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

/// A tick and a cross for an order waiting to be picked up, otherwise a
/// quiet pill saying how the order ended. Needs an [OrderActionsCubit]
/// above it.
class OrderActionPill extends StatelessWidget {
  const OrderActionPill({super.key, required this.item});

  final BusinessOrder item;

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<OrderActionsCubit>();
    final yes = await _ask(
      context,
      title: 'Mark as picked up?',
      body: 'Only do this once the customer has their food.',
      action: 'Picked up',
    );
    if (yes) await cubit.confirm(item);
  }

  Future<void> _cancel(BuildContext context) async {
    final cubit = context.read<OrderActionsCubit>();
    final yes = await _ask(
      context,
      title: 'Cancel this order?',
      body:
          'The portions go back on sale. Let the customer know why. This '
          'cannot be undone.',
      action: 'Cancel order',
      isDestructive: true,
    );
    if (yes) await cubit.cancel(item);
  }

  Future<bool> _ask(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    bool isDestructive = false,
  }) async {
    final answer = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(dialogContext).colorScheme.error,
                  )
                : null,
            child: Text(action),
          ),
        ],
      ),
    );
    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (item.order.status) {
      OrderStatus.paid =>
        BlocSelector<OrderActionsCubit, OrderActionsState, bool>(
          selector: (state) => state.busyOrderId == item.order.id,
          builder: (context, isBusy) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isBusy
                ? const SizedBox.square(
                    key: ValueKey('busy'),
                    dimension: AppSpacing.minTapTarget,
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    key: const ValueKey('actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoundAction(
                        tooltip: 'Cancel order',
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: scheme.error,
                        onTap: () => _cancel(context),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _RoundAction(
                        tooltip: 'Mark as picked up',
                        icon: HugeIcons.strokeRoundedTick02,
                        color: scheme.primary,
                        onTap: () => _confirm(context),
                      ),
                    ],
                  ),
          ),
        ),
      OrderStatus.collected => _StatusPill(
        label: 'Picked up',
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        color: scheme.primary,
        textColor: scheme.onSurface,
      ),
      OrderStatus.cancelled => _StatusPill(
        label: 'Cancelled',
        icon: HugeIcons.strokeRoundedCancelCircle,
        color: scheme.error,
        textColor: scheme.error,
      ),
    };
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: TapScale(
          child: Material(
            color: color.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: SizedBox.square(
                dimension: AppSpacing.minTapTarget,
                child: Center(
                  child: HugeIcon(icon: icon, size: 22, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  final String label;
  final List<List<dynamic>> icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
