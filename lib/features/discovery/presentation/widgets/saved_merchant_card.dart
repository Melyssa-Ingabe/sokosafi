import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/save_merchant_button.dart';

/// One saved shop, from the Saved Merchants frame in Figma.
class SavedMerchantCard extends StatelessWidget {
  const SavedMerchantCard({
    super.key,
    required this.business,
    required this.onExplore,
  });

  final Business business;
  final VoidCallback onExplore;

  static const double _radius = 18;
  static const double _photoHeight = 200;
  static const Color _hairline = Color(0x0A000000);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _photoHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Photo(url: business.photoUrl),
                  // Darkens the bottom so the white address stays readable.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0x73000000),
                          Color(0x00000000),
                          Color(0x26000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: SaveMerchantButton(business: business),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: 10,
                    child: Row(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedLocation01,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            business.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (business.type case final type?)
                    Text(
                      type.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1, thickness: 1, color: _hairline),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: AppSpacing.minTapTarget,
                    child: TextButton(
                      onPressed: onExplore,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                        textStyle: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Explore surplus'),
                          SizedBox(width: 6),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
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

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(color: AppColors.surfaceSubtle);
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
