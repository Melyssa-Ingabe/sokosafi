part of 'saved_merchants_cubit.dart';

enum SavedMerchantsStatus { signedOut, loading, ready, failure }

/// A one-off message for a SnackBar. Not Equatable on purpose: the same
/// message twice in a row is still shown twice.
class SavedMerchantsFeedback {
  SavedMerchantsFeedback(this.message, {this.isError = false});

  final String message;
  final bool isError;
}

class SavedMerchantsState extends Equatable {
  const SavedMerchantsState({
    this.status = SavedMerchantsStatus.signedOut,
    this.merchants = const [],
    this.pendingIds = const {},
    this.errorMessage,
    this.feedback,
  });

  final SavedMerchantsStatus status;
  final List<SavedMerchant> merchants;

  /// Businesses with a save or remove still on its way to Firestore, so a
  /// double tap does not send two writes.
  final Set<String> pendingIds;

  /// Why the list could not load.
  final String? errorMessage;
  final SavedMerchantsFeedback? feedback;

  bool isSaved(String businessId) =>
      merchants.any((merchant) => merchant.business.id == businessId);

  SavedMerchantsState copyWith({
    SavedMerchantsStatus? status,
    List<SavedMerchant>? merchants,
    Set<String>? pendingIds,
    String? errorMessage,
    SavedMerchantsFeedback? feedback,
  }) {
    return SavedMerchantsState(
      status: status ?? this.status,
      merchants: merchants ?? this.merchants,
      pendingIds: pendingIds ?? this.pendingIds,
      errorMessage: errorMessage ?? this.errorMessage,
      // Feedback is shown once, so it is never carried into the next state.
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    merchants,
    pendingIds,
    errorMessage,
    feedback,
  ];
}
