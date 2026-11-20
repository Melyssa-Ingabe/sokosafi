import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

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

  static const String logoAsset = 'assets/images/sokosafi_logo.png';
  static const double _height = 64;
  static const double _logoSize = 32;
  static const double _logoRadius = 8;
  static const double _avatarRadius = 16;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final initial = userName.trim().isEmpty
        ? '?'
        : userName.trim()[0].toUpperCase();

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_logoRadius),
            child: Image.asset(
              logoAsset,
              width: _logoSize,
              height: _logoSize,
              semanticLabel: 'SokoSafi',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SokoSafi',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      size: 12,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
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
        ],
      ),
    );
  }
}
