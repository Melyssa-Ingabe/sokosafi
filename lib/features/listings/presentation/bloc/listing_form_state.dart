part of 'listing_form_cubit.dart';

enum ListingFormStatus { editing, submitting, success }

/// Text the form should copy into its fields: the listing being edited, or
/// a template the owner tapped.
class ListingPrefill extends Equatable {
  const ListingPrefill({
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.instructions,
  });

  factory ListingPrefill.fromListing(Listing listing) {
    return ListingPrefill(
      title: listing.title,
      description: listing.description,
      originalPrice: listing.originalPrice.toString(),
      discountPrice: listing.discountPrice.toString(),
      instructions: listing.instructions,
    );
  }

  final String title;
  final String description;
  final String originalPrice;
  final String discountPrice;
  final String instructions;

  @override
  List<Object?> get props => [
    title,
    description,
    originalPrice,
    discountPrice,
    instructions,
  ];
}

class ListingFormState extends Equatable {
  const ListingFormState({
    required this.category,
    required this.quantity,
    required this.madeAt,
    required this.pickupBy,
    this.isEditing = false,
    this.status = ListingFormStatus.editing,
    this.originalPrice,
    this.discountPrice,
    this.photoPath,
    this.imageUrl = '',
    this.prefill,
    this.prefillRevision = 0,
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

  /// Prices as typed so far, used for the live "Customers save" line.
  final int? originalPrice;
  final int? discountPrice;

  /// A photo picked on this phone and not uploaded yet.
  final String? photoPath;

  /// The photo the listing already has online, when editing.
  final String imageUrl;

  final ListingPrefill? prefill;

  /// Goes up each time [prefill] should be copied into the text fields.
  final int prefillRevision;

  // Errors for the fields that are not text boxes, so the form cannot show
  // them through a TextFormField validator.
  final String? quantityError;
  final String? madeAtError;
  final String? pickupByError;

  final FeedbackMessage? feedback;

  bool get isSubmitting => status == ListingFormStatus.submitting;

  /// The saving shown under the prices, or null until both prices make a
  /// real discount.
  int? get savingsPercent {
    final original = originalPrice;
    final discount = discountPrice;
    if (original == null || discount == null) return null;
    if (original <= 0 || discount <= 0 || discount >= original) return null;
    return Formatters.discountPercent(original: original, discounted: discount);
  }

  ListingFormState copyWith({
    ListingCategory? category,
    int? quantity,
    DateTime? madeAt,
    DateTime? pickupBy,
    ListingFormStatus? status,
    int? Function()? originalPrice,
    int? Function()? discountPrice,
    String? photoPath,
    ListingPrefill? prefill,
    int? prefillRevision,
    String? Function()? quantityError,
    String? Function()? madeAtError,
    String? Function()? pickupByError,
    FeedbackMessage? feedback,
  }) {
    return ListingFormState(
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      madeAt: madeAt ?? this.madeAt,
      pickupBy: pickupBy ?? this.pickupBy,
      isEditing: isEditing,
      status: status ?? this.status,
      // Nullable values are passed as functions so a caller can clear them
      // by returning null.
      originalPrice: originalPrice != null
          ? originalPrice()
          : this.originalPrice,
      discountPrice: discountPrice != null
          ? discountPrice()
          : this.discountPrice,
      photoPath: photoPath ?? this.photoPath,
      imageUrl: imageUrl,
      prefill: prefill ?? this.prefill,
      prefillRevision: prefillRevision ?? this.prefillRevision,
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
    originalPrice,
    discountPrice,
    photoPath,
    imageUrl,
    prefill,
    prefillRevision,
    quantityError,
    madeAtError,
    pickupByError,
    feedback,
  ];
}
