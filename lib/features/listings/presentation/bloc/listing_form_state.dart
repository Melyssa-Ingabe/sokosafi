part of 'listing_form_cubit.dart';

enum ListingFormStatus { editing, submitting, success }

class ListingFormState extends Equatable {
  const ListingFormState({
    required this.category,
    required this.quantity,
    required this.madeAt,
    required this.pickupBy,
    this.isEditing = false,
    this.status = ListingFormStatus.editing,
    this.quantityError,
    this.madeAtError,
    this.pickupByError,
    this.feedback,
  });

  final ListingCategory category;
  final int quantity;
  final DateTime madeAt;
  final DateTime pickupBy;

  /// True when the form edits an existing listing instead of creating one.
  final bool isEditing;
  final ListingFormStatus status;

  // Errors for the fields that are not text boxes, so the form cannot show
  // them through a TextFormField validator.
  final String? quantityError;
  final String? madeAtError;
  final String? pickupByError;

  final ListingFeedback? feedback;

  bool get isSubmitting => status == ListingFormStatus.submitting;

  ListingFormState copyWith({
    ListingCategory? category,
    int? quantity,
    DateTime? madeAt,
    DateTime? pickupBy,
    ListingFormStatus? status,
    String? Function()? quantityError,
    String? Function()? madeAtError,
    String? Function()? pickupByError,
    ListingFeedback? feedback,
  }) {
    return ListingFormState(
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      madeAt: madeAt ?? this.madeAt,
      pickupBy: pickupBy ?? this.pickupBy,
      isEditing: isEditing,
      status: status ?? this.status,
      // Passed as functions so a caller can clear an error by returning null.
      quantityError: quantityError != null
          ? quantityError()
          : this.quantityError,
      madeAtError: madeAtError != null ? madeAtError() : this.madeAtError,
      pickupByError: pickupByError != null
          ? pickupByError()
          : this.pickupByError,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    category,
    quantity,
    madeAt,
    pickupBy,
    isEditing,
    status,
    quantityError,
    madeAtError,
    pickupByError,
    feedback,
  ];
}
