part of 'rate_experience_cubit.dart';

enum RateExperienceStatus {
  loading,
  ready,
  submitting,
  submitted,
  alreadyRated,
  failure,
}

class RateExperienceState extends Equatable {
  const RateExperienceState({
    this.status = RateExperienceStatus.loading,
    this.target,
    this.rating = 0,
    this.tags = const {},
    this.note = '',
    this.ratingMissing = false,
    this.errorMessage,
    this.submitError,
  });

  final RateExperienceStatus status;
  final ReviewTarget? target;

  /// 0 until the customer taps a star.
  final int rating;
  final Set<ReviewTag> tags;
  final String note;

  /// True after Submit is tapped with no stars chosen.
  final bool ratingMissing;

  /// Why the order could not be loaded.
  final String? errorMessage;

  /// Why the last submit failed, shown once in a SnackBar.
  final String? submitError;

  String get ratingLabel => switch (rating) {
    1 => 'Poor',
    2 => 'Not great',
    3 => 'Okay',
    4 => 'Good',
    5 => 'Perfect experience!',
    _ => 'Tap a star to rate',
  };

  RateExperienceState copyWith({
    RateExperienceStatus? status,
    int? rating,
    Set<ReviewTag>? tags,
    String? note,
    bool? ratingMissing,
    String? submitError,
  }) {
    return RateExperienceState(
      status: status ?? this.status,
      target: target,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      ratingMissing: ratingMissing ?? this.ratingMissing,
      errorMessage: errorMessage,
      // Cleared on every other change, so the same error can show again
      // after the next attempt.
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    target,
    rating,
    tags,
    note,
    ratingMissing,
    errorMessage,
    submitError,
  ];
}
