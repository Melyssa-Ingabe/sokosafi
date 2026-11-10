import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_category_icon.dart';

/// "Recent templates": past products the owner can relist in one tap.
/// Hidden when the business has no listings yet.
class TemplateChips extends StatelessWidget {
  const TemplateChips({
    super.key,
    required this.templates,
    required this.onSelected,
  });

  final List<Listing> templates;
  final ValueChanged<Listing> onSelected;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent templates',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '1-tap refill',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSpacing.minTapTarget,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final template = templates[index];
              return ActionChip(
                onPressed: () => onSelected(template),
                avatar: HugeIcon(
                  icon: template.category.icon,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(template.title),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.borderSubtle),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
