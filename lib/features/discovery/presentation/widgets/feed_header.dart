import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/brand_header.dart';

/// The top of the feed from Figma: logo, where the customer is browsing
/// from, and their avatar, which opens Profile.
class FeedHeader extends StatelessWidget {
  const FeedHeader({
    super.key,
    required this.locationLabel,
    required this.userName,
    required this.photoUrl,
    required this.onProfileTap,
  });

  final String locationLabel;
  final String userName;
  final String photoUrl;
  final VoidCallback onProfileTap;

  static const double _avatarRadius = 16;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial = userName.trim().isEmpty
        ? '?'
        : userName.trim()[0].toUpperCase();

    return BrandHeader(
      locationLabel: locationLabel,
      trailing: Semantics(
        button: true,
        label: 'Open profile',
        child: InkResponse(
          onTap: onProfileTap,
          radius: AppSpacing.minTapTarget / 2,
          child: SizedBox.square(
            dimension: AppSpacing.minTapTarget,
            child: Center(
              child: CircleAvatar(
                radius: _avatarRadius,
                backgroundColor: AppColors.brandSubtle,
                foregroundImage: photoUrl.isEmpty
                    ? null
                    : NetworkImage(photoUrl),
                child: Text(
                  initial,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
