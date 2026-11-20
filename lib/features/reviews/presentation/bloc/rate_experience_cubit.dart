import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_tag.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';
import 'package:sokosafi/features/reviews/domain/repositories/review_repository.dart';

part 'rate_experience_state.dart';

/// Holds the stars, tags and note the customer picks, and saves them as
/// one review for a collected order.
class RateExperienceCubit extends Cubit<RateExperienceState> {
  RateExperienceCubit({
    required this._repository,
    required this._orderId,
    required this._customerId,
  }) : super(const RateExperienceState());

  static const int maxNoteLength = 250;

  final ReviewRepository _repository;
  final String _orderId;
  final String _customerId;

  Future<void> load() async {
    emit(const RateExperienceState());
    try {
      final target = await _repository.loadTarget(
        orderId: _orderId,
        customerId: _customerId,
      );
      emit(
        RateExperienceState(
          status: target.alreadyReviewed
              ? RateExperienceStatus.alreadyRated
              : RateExperienceStatus.ready,
          target: target,
        ),
      );
    } on ReviewFailure catch (failure) {
      emit(
        RateExperienceState(
          status: RateExperienceStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  void rate(int stars) {
    emit(state.copyWith(rating: stars.clamp(1, 5), ratingMissing: false));
  }

  void toggleTag(ReviewTag tag) {
    final tags = {...state.tags};
    if (!tags.remove(tag)) tags.add(tag);
    emit(state.copyWith(tags: tags));
  }

  void noteChanged(String note) => emit(state.copyWith(note: note));

  Future<void> submit() async {
    final target = state.target;
    if (target == null || state.status != RateExperienceStatus.ready) return;
    if (state.rating == 0) {
      emit(state.copyWith(ratingMissing: true));
      return;
    }
    emit(state.copyWith(status: RateExperienceStatus.submitting));
    try {
      await _repository.submitReview(
        target: target,
        customerId: _customerId,
        rating: state.rating,
        comment: composeReviewComment(state.tags, state.note),
      );
      emit(state.copyWith(status: RateExperienceStatus.submitted));
    } on ReviewFailure catch (failure) {
      emit(
        state.copyWith(
          status: RateExperienceStatus.ready,
          submitError: failure.message,
        ),
      );
    }
  }
}
