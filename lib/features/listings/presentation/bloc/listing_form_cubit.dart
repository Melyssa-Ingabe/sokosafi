import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sokosafi/core/bloc/feedback_message.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/storage/image_upload_failure.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';
import 'package:sokosafi/features/listings/domain/validation/listing_validator.dart';

part 'listing_form_state.dart';

/// State of the add and edit listing form. Text fields keep their own text
/// in controllers; everything else (category, quantity, times, photo) lives
/// here, and submit re-validates every field before anything is saved.
class ListingFormCubit extends Cubit<ListingFormState> {
  ListingFormCubit({
    required this._listingRepository,
    required this._photoPicker,
    required this._imageStorage,
    required this._businessId,
    Listing? initialListing,
    DateTime Function()? clock,
  }) : _initialListing = initialListing,
       _clock = clock ?? DateTime.now,
       super(_initialState(initialListing, (clock ?? DateTime.now)()));

  /// Matches the Figma hint "Default: 2 hours from now".
  static const Duration defaultPickupWindow = Duration(hours: 2);

  final ListingRepository _listingRepository;
  final PhotoPicker _photoPicker;
  final ImageStorage _imageStorage;
  final String _businessId;
  final Listing? _initialListing;
  final DateTime Function() _clock;

  static ListingFormState _initialState(Listing? listing, DateTime now) {
    if (listing != null) {
      return ListingFormState(
        category: listing.category,
        quantity: listing.quantity,
        madeAt: listing.madeAt,
        pickupBy: listing.pickupBy,
        isEditing: true,
        originalPrice: listing.originalPrice,
        discountPrice: listing.discountPrice,
        imageUrl: listing.imageUrl,
        prefill: ListingPrefill.fromListing(listing),
      );
    }
    return ListingFormState(
      category: ListingCategory.bakery,
      quantity: 1,
      madeAt: now,
      pickupBy: now.add(defaultPickupWindow),
    );
  }

  void categorySelected(ListingCategory category) {
    emit(state.copyWith(category: category));
  }

  void quantityIncremented() => _setQuantity(state.quantity + 1);

  void quantityDecremented() => _setQuantity(state.quantity - 1);

  void _setQuantity(int quantity) {
    final clamped = quantity.clamp(1, ListingValidator.maxQuantity);
    emit(state.copyWith(quantity: clamped, quantityError: () => null));
  }

  void pricesChanged({
    required String originalPrice,
    required String discountPrice,
  }) {
    emit(
      state.copyWith(
        originalPrice: () => ListingValidator.parsePrice(originalPrice),
        discountPrice: () => ListingValidator.parsePrice(discountPrice),
      ),
    );
  }

  void madeAtChanged(DateTime madeAt) {
    emit(state.copyWith(madeAt: madeAt, madeAtError: () => null));
  }

  void pickupByChanged(DateTime pickupBy) {
    emit(
      state.copyWith(
        pickupBy: pickupBy,
        pickupByError: () => null,
        madeAtError: () => null,
      ),
    );
  }

  /// Copies a past listing's details into the form ("Recent templates").
  /// Quantity and times stay as they are, since they change every day.
  void templateApplied(Listing template) {
    emit(
      state.copyWith(
        category: template.category,
        originalPrice: () => template.originalPrice,
        discountPrice: () => template.discountPrice,
        prefill: ListingPrefill.fromListing(template),
        prefillRevision: state.prefillRevision + 1,
      ),
    );
  }

  Future<void> photoRequested(PhotoSource source) async {
    try {
      final path = await _photoPicker.pick(source);
      if (path != null) emit(state.copyWith(photoPath: path));
    } catch (_) {
      emit(
        state.copyWith(
          feedback: FeedbackMessage.error(
            source == PhotoSource.camera
                ? 'We could not open the camera. Check that SokoSafi may use it'
                : 'We could not open your photos. Please try again',
          ),
        ),
      );
    }
  }

  /// Validates every field and saves the listing. The text values come from
  /// the form's controllers; prices are typed as text and parsed here.
  Future<void> submit({
    required String title,
    required String description,
    required String originalPrice,
    required String discountPrice,
    required String instructions,
  }) async {
    if (state.isSubmitting) return;

    final now = _clock();
    final quantityError = ListingValidator.quantity(state.quantity);
    final pickupByError = ListingValidator.pickupBy(state.pickupBy, now: now);
    final madeAtError = ListingValidator.madeAt(
      state.madeAt,
      pickupBy: state.pickupBy,
      now: now,
    );
    final textErrors = [
      ListingValidator.title(title),
      ListingValidator.description(description),
      ListingValidator.originalPrice(originalPrice),
      ListingValidator.discountPrice(discountPrice, original: originalPrice),
      ListingValidator.instructions(instructions),
    ];
    final hasErrors =
        quantityError != null ||
        pickupByError != null ||
        madeAtError != null ||
        textErrors.any((error) => error != null);

    if (hasErrors) {
      emit(
        state.copyWith(
          quantityError: () => quantityError,
          pickupByError: () => pickupByError,
          madeAtError: () => madeAtError,
          feedback: FeedbackMessage.error('Please fix the highlighted fields'),
        ),
      );
      return;
    }

    emit(state.copyWith(status: ListingFormStatus.submitting));
    final photoPath = state.photoPath;
    final photoWaiting = photoPath != null && !_imageStorage.isAvailable;
    try {
      var imageUrl = state.imageUrl;
      if (photoPath != null && _imageStorage.isAvailable) {
        imageUrl = await _imageStorage.upload(
          localPath: photoPath,
          folder: 'listings/$_businessId',
        );
      }
      final input = ListingInput(
        title: title,
        description: description,
        category: state.category,
        originalPrice: ListingValidator.parsePrice(originalPrice)!,
        discountPrice: ListingValidator.parsePrice(discountPrice)!,
        quantity: state.quantity,
        madeAt: state.madeAt,
        pickupBy: state.pickupBy,
        instructions: instructions,
        imageUrl: imageUrl,
      );

      final listing = _initialListing;
      if (listing == null) {
        await _listingRepository.createListing(
          businessId: _businessId,
          input: input,
        );
      } else {
        await _listingRepository.updateListing(
          listingId: listing.id,
          input: input,
        );
      }
      final saved = listing == null ? 'Listing published' : 'Listing updated';
      emit(
        state.copyWith(
          status: ListingFormStatus.success,
          feedback: FeedbackMessage.success(
            photoWaiting ? '$saved. Photo upload is coming soon' : saved,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ListingFormStatus.editing,
          feedback: FeedbackMessage.error(switch (error) {
            ListingFailure(:final message) => message,
            ImageUploadFailure(:final message) => message,
            _ => ListingFailure.genericMessage,
          }),
        ),
      );
    }
  }
}
