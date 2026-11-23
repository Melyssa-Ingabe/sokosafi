import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

/// The order's progress as a card that starts collapsed to the latest
/// step and opens to show every step.
///
/// Stateful only to own the ExpansibleController.
class OrderStatusTimeline extends StatefulWidget {
  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.createdAt,
    this.collectedAt,
  });

  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? collectedAt;

  @override
  State<OrderStatusTimeline> createState() => _OrderStatusTimelineState();
}

class _OrderStatusTimelineState extends State<OrderStatusTimeline> {
  final _controller = ExpansibleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _buildSteps();
    final latest = steps.lastWhere((step) => step.isCompleted);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Expansible(
        controller: _controller,
        animationStyle: AnimationStyle(
          duration: AnimationConstants.pageTransition,
          curve: AnimationConstants.pageCurve,
        ),
        headerBuilder: (context, animation) => InkWell(
          onTap: () => _controller.isExpanded
              ? _controller.collapse()
              : _controller.expand(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order status', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        latest.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: animation.drive(Tween(begin: 0, end: 0.5)),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowDown01,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyBuilder: (context, animation) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++)
                _TimelineStep(
                  label: steps[i].label,
                  subtitle: steps[i].subtitle,
                  isCompleted: steps[i].isCompleted,
                  isLast: i == steps.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Step> _buildSteps() {
    final placed = _formatDate(widget.createdAt);
    final collectedAt = widget.collectedAt;
    return switch (widget.status) {
      OrderStatus.paid => [
        _Step('Order placed', placed, isCompleted: true),
        _Step(
          'Ready for pickup',
          'Show your code at the store',
          isCompleted: true,
        ),
        _Step('Awaiting collection', '', isCompleted: false),
      ],
      OrderStatus.collected => [
        _Step('Order placed', placed, isCompleted: true),
        _Step('Ready for pickup', '', isCompleted: true),
        _Step(
          'Collected',
          collectedAt != null ? _formatDate(collectedAt) : '',
          isCompleted: true,
        ),
      ],
      OrderStatus.cancelled => [
        _Step('Order placed', placed, isCompleted: true),
        _Step('Cancelled', 'Items returned to stock', isCompleted: true),
      ],
    };
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, $hour:$minute $period';
  }
}

class _Step {
  const _Step(this.label, this.subtitle, {required this.isCompleted});
  final String label;
  final String subtitle;
  final bool isCompleted;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.subtitle,
    required this.isCompleted,
    required this.isLast,
  });

  final String label;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = isCompleted
        ? AppColors.primary
        : Theme.of(context).colorScheme.outlineVariant;
    final lineColor = isCompleted
        ? AppColors.primary
        : Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
