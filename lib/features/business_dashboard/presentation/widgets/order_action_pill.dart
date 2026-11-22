import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

/// "Confirm pickup" for an order waiting to be collected, otherwise a quiet
/// pill saying how the order ended.
class OrderActionPill extends StatelessWidget {
  const OrderActionPill({
    super.key,
    required this.status,
    required this.onConfirm,
  });

  final OrderStatus status;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    return switch (status) {
      OrderStatus.paid => TapScale(
        child: Material(
          color: scheme.surfaceContainerHighest,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onConfirm,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    'Confirm pickup',
                    style: labelStyle?.copyWith(color: scheme.primary),
                  ),
                ),
              ),
            ),
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
