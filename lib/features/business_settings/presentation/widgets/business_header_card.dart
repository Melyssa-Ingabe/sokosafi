import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';

/// Photo, name, area and type of the owner's business.
class BusinessHeaderCard extends StatelessWidget {
  const BusinessHeaderCard({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (business.address.isNotEmpty) business.address,
      if (business.type != null) business.type!.label,
    ].join(' · ');
    final initial = business.name.isEmpty
        ? '?'
        : business.name.characters.first.toUpperCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
              child: SizedBox.square(
                dimension: 56,
                child: business.photoUrl.isEmpty
                    ? ColoredBox(
                        color: AppColors.brandSubtle,
                        child: Center(
                          child: Text(
                            initial,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Image.network(business.photoUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
