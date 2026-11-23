import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_icons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';

/// The heart that saves or removes a business. Every heart reads the same
/// app-wide cubit, so saving on one screen fills the heart on all of them.
class SaveMerchantButton extends StatelessWidget {
  const SaveMerchantButton({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final (isSaved, isPending) = context.select(
      (SavedMerchantsCubit cubit) => (
        cubit.state.isSaved(business.id),
        cubit.state.pendingIds.contains(business.id),
      ),
    );
    return Tooltip(
      message: isSaved
          ? 'Remove ${business.name} from saved'
          : 'Save ${business.name}',
      child: Semantics(
        button: true,
        toggled: isSaved,
        child: TapScale(
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isPending
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      context.read<SavedMerchantsCubit>().toggle(business);
                    },
              child: SizedBox.square(
                dimension: AppSpacing.minTapTarget,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AnimationConstants.imageFade,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: HugeIcon(
                      icon: isSaved
                          ? AppIcons.favouriteFilled
                          : HugeIcons.strokeRoundedFavourite,
                      key: ValueKey(isSaved),
                      size: 22,
                      color: Colors.white,
                    ),
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
