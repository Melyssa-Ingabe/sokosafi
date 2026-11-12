import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/reviews/data/repositories/firestore_review_repository.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';
import 'package:sokosafi/features/reviews/presentation/bloc/rate_experience_cubit.dart';
import 'package:sokosafi/features/reviews/presentation/widgets/review_business_header.dart';
import 'package:sokosafi/features/reviews/presentation/widgets/review_tag_chips.dart';
import 'package:sokosafi/features/reviews/presentation/widgets/star_rating_picker.dart';

/// Shown to the customer after their order is collected.
class RateExperienceScreen extends StatelessWidget {
  const RateExperienceScreen({
    super.key,
    required this.orderId,
    required this.customerId,
  });

  final String orderId;
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RateExperienceCubit(
        repository: FirestoreReviewRepository(),
        orderId: orderId,
        customerId: customerId,
      )..load(),
      child: const _RateExperienceView(),
    );
  }
}

class _RateExperienceView extends StatelessWidget {
  const _RateExperienceView();

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocConsumer<RateExperienceCubit, RateExperienceState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.submitError != current.submitError,
        listener: (context, state) {
          final submitError = state.submitError;
          if (submitError != null) {
            AppSnackBar.showError(context, submitError);
          } else if (state.status == RateExperienceStatus.submitted) {
            AppSnackBar.showSuccess(context, 'Thanks for rating your pickup');
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final target = state.target;
          return switch (state.status) {
            RateExperienceStatus.loading => const LoadingView(),
            RateExperienceStatus.failure => EmptyView(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedStar,
                size: 48,
                color: iconColor,
              ),
              title: 'We could not open this review',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: context.read<RateExperienceCubit>().load,
            ),
            RateExperienceStatus.alreadyRated => EmptyView(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                size: 48,
                color: iconColor,
              ),
              title: 'You already rated this pickup',
              message: 'Thanks for helping other customers choose.',
            ),
            _ when target == null => const LoadingView(),
            _ => _RateForm(state: state, target: target),
          };
        },
      ),
    );
  }
}

class _RateForm extends StatelessWidget {
  const _RateForm({required this.state, required this.target});

  final RateExperienceState state;
  final ReviewTarget target;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RateExperienceCubit>();
    final isSubmitting = state.status == RateExperienceStatus.submitting;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              ReviewBusinessHeader(target: target),
              const SizedBox(height: AppSpacing.xl),
              StarRatingPicker(
                rating: state.rating,
                onRate: cubit.rate,
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: AppBadge(
                  label: state.ratingLabel,
                  backgroundColor: AppColors.surfaceSubtle,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
              if (state.ratingMissing) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap the stars to rate your pickup',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              ReviewTagChips(selected: state.tags, onToggle: cubit.toggleTag),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Anything you would like to share? (optional)',
                initialValue: state.note,
                onChanged: cubit.noteChanged,
                minLines: 3,
                maxLines: 5,
                maxLength: RateExperienceCubit.maxNoteLength,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Submit review',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : cubit.submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
                ),
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).maybePop(),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
