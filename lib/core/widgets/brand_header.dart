import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// The top bar from Figma: logo, "SokoSafi" and a location line, with an
/// optional widget on the right such as the customer's avatar.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.locationLabel, this.trailing});

  final String locationLabel;
  final Widget? trailing;

  static const String logoAsset = 'assets/images/sokosafi_logo.png';
  static const double _height = 64;
  static const double _logoSize = 32;
  static const double _logoRadius = 8;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final trailingWidget = trailing;
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
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      size: 12,
                      color: scheme.primary,
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
          ?trailingWidget,
        ],
      ),
    );
  }
}
