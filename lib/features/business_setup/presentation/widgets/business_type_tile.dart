import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/business_type_icon.dart';

/// One choice in the "What kind of business?" grid.
class BusinessTypeTile extends StatelessWidget {
  const BusinessTypeTile({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final BusinessType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isSelected
        ? AppColors.primary
        : theme.colorScheme.onSurface;
    return Semantics(
      selected: isSelected,
      button: true,
      child: TapScale(
        child: AnimatedContainer(
          duration: AnimationConstants.listItem,
          curve: AnimationConstants.pageCurve,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandSubtle : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(icon: type.icon, color: foreground, size: 28),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    type.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
