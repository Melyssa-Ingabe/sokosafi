import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';

/// Business photo, the question, and which pickup is being rated.
class ReviewBusinessHeader extends StatelessWidget {
  const ReviewBusinessHeader({super.key, required this.target});

  final ReviewTarget target;

  @override
  Widget build(BuildContext context) {
    final collectedAt = target.collectedAt;
    final initial = target.businessName.isEmpty
        ? '?'
        : target.businessName.characters.first.toUpperCase();
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.brandSubtle,
          foregroundImage: target.businessPhotoUrl.isEmpty
              ? null
              : NetworkImage(target.businessPhotoUrl),
          child: Text(
            initial,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'How was your pickup?',
          textAlign: TextAlign.center,
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          target.businessName,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        if (collectedAt != null)
          Text(
            'Picked up ${DateFormatters.dayAndTime(collectedAt, now: DateTime.now())}',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
