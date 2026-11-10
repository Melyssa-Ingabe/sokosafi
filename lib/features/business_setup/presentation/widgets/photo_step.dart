import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/photo_preview.dart';
import 'package:sokosafi/core/widgets/photo_source_sheet.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/setup_step_layout.dart';

/// Step 3: storefront photo, then "Complete setup" or "Skip for now".
class PhotoStep extends StatelessWidget {
  const PhotoStep({super.key});

  Future<void> _choosePhoto(BuildContext context) async {
    final bloc = context.read<BusinessSetupBloc>();
    final source = await PhotoSourceSheet.show(context);
    if (source != null) bloc.add(BusinessPhotoRequested(source));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessSetupBloc>();
    final state = context.watch<BusinessSetupBloc>().state;
    final theme = Theme.of(context);
    final hasPhoto = state.photoPath != null;

    return SetupStepLayout(
      title: 'Add a photo',
      subtitle:
          'A photo of your storefront or food helps customers recognize you.',
      actions: [
        PrimaryButton(
          label: 'Complete setup',
          isLoading: state.isSubmitting,
          onPressed: () => bloc.add(const SetupContinued()),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () => bloc.add(const SetupPhotoSkipped()),
          child: const Text('Skip for now'),
        ),
      ],
      children: [
        Center(
          child: PhotoPreview(
            photoPath: state.photoPath,
            onTap: () => _choosePhoto(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (hasPhoto)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Photo added · Tap to change',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedStore01,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'A real photo makes your store easy to spot',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
