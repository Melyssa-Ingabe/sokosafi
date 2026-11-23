import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// The running total and the Reserve button, pinned to the bottom like the
/// checkout dock in Figma.
class ReserveBar extends StatelessWidget {
  const ReserveBar({
    super.key,
    required this.quantity,
    required this.total,
    required this.onReserve,
  });

  final int quantity;
  final int total;

  /// Null when the food can no longer be reserved.
  final VoidCallback? onReserve;

  static const double _buttonWidth = 204;
  static const double _buttonHeight = 48;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemLabel = quantity == 1 ? '1 item' : '$quantity items';
    final isAvailable = onReserve != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 13, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ($itemLabel)',
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(Formatters.rwf(total), style: textTheme.titleLarge),
                  ],
                ),
              ),
              TapScale(
                child: SizedBox(
                  width: _buttonWidth,
                  height: _buttonHeight,
                  child: FilledButton.icon(
                    onPressed: onReserve,
                    style: FilledButton.styleFrom(
                      // Figma's lighter green fails 4.5:1 with white text,
                      // so the button uses primary like PrimaryButton.
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      textStyle: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedShoppingBag01,
                      size: 18,
                      color: isAvailable
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    label: Text(isAvailable ? 'Reserve' : 'Not available'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
