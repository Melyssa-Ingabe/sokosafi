import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sokosafi/core/bloc/feedback_message.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';
import 'package:sokosafi/features/business_setup/domain/validation/business_validator.dart';

part 'business_setup_event.dart';
part 'business_setup_state.dart';

/// Drives the three setup steps: name and type, location, photo. Nothing is
/// saved until the last step, where the business document is created and
/// the owner's role becomes business.
class BusinessSetupBloc extends Bloc<BusinessSetupEvent, BusinessSetupState> {
  BusinessSetupBloc({
    required this._ownerId,
    required this._businessRepository,
    required this._locationRepository,
    required this._photoPicker,
    required this._imageStorage,
  }) : super(const BusinessSetupState()) {
    on<BusinessNameChanged>(
      (event, emit) => emit(state.copyWith(name: event.name)),
    );
    on<BusinessTypeSelected>(
      (event, emit) => emit(state.copyWith(type: event.type)),
    );
    on<BusinessAddressChanged>(
      (event, emit) => emit(state.copyWith(address: event.address)),
    );
    on<BusinessAddressSearched>(_onAddressSearched);
    on<CurrentLocationRequested>(_onCurrentLocationRequested);
    on<MapPinMoved>(_onMapPinMoved);
    on<BusinessPhotoRequested>(_onPhotoRequested);
    on<SetupContinued>(_onContinued);
    on<SetupPhotoSkipped>((event, emit) => _submit(emit, includePhoto: false));
    on<SetupStepBack>(_onStepBack);
  }

  final String _ownerId;
  final BusinessRepository _businessRepository;
  final LocationRepository _locationRepository;
  final PhotoPicker _photoPicker;
  final ImageStorage _imageStorage;

  Future<void> _onAddressSearched(
    BusinessAddressSearched event,
    Emitter<BusinessSetupState> emit,
  ) async {
    if (BusinessValidator.address(state.address) != null) return;
    emit(state.copyWith(isLocating: true));
    final place = await _locationRepository.search(state.address);
    if (place == null) {
      emit(
        state.copyWith(
          isLocating: false,
          feedback: FeedbackMessage.error(
            'We could not find that address. Move the map to place the pin',
          ),
        ),
      );
      return;
    }
    emit(_withPlace(place, keepTypedAddress: true));
  }

  Future<void> _onCurrentLocationRequested(
    CurrentLocationRequested event,
    Emitter<BusinessSetupState> emit,
  ) async {
    if (state.isLocating) return;
    emit(state.copyWith(isLocating: true));
    try {
      final place = await _locationRepository.currentPlace();
      emit(_withPlace(place, keepTypedAddress: false));
    } catch (error) {
      emit(
        state.copyWith(
          isLocating: false,
          feedback: FeedbackMessage.error(_messageFor(error)),
        ),
      );
    }
  }

  BusinessSetupState _withPlace(Place place, {required bool keepTypedAddress}) {
    final useStreet =
        place.street.isNotEmpty &&
        (!keepTypedAddress || state.address.trim().isEmpty);
    return state.copyWith(
      isLocating: false,
      latitude: place.latitude,
      longitude: place.longitude,
      neighborhood: place.neighborhood,
      address: useStreet ? place.street : null,
      mapFocusRevision: state.mapFocusRevision + 1,
    );
  }

  Future<void> _onMapPinMoved(
    MapPinMoved event,
    Emitter<BusinessSetupState> emit,
  ) async {
    emit(state.copyWith(latitude: event.latitude, longitude: event.longitude));
    final place = await _locationRepository.describe(
      latitude: event.latitude,
      longitude: event.longitude,
    );
    // The owner may have moved the map again while this lookup ran; only the
    // newest position may update the neighborhood.
    if (state.latitude != event.latitude ||
        state.longitude != event.longitude) {
      return;
    }
    emit(
      state.copyWith(
        neighborhood: place.neighborhood,
        address: state.address.trim().isEmpty && place.street.isNotEmpty
            ? place.street
            : null,
      ),
    );
  }

  Future<void> _onPhotoRequested(
    BusinessPhotoRequested event,
    Emitter<BusinessSetupState> emit,
  ) async {
    try {
      final path = await _photoPicker.pick(event.source);
      if (path != null) emit(state.copyWith(photoPath: path));
    } catch (_) {
      emit(
        state.copyWith(
          feedback: FeedbackMessage.error(
            event.source == PhotoSource.camera
                ? 'We could not open the camera. Check that SokoSafi may use it'
                : 'We could not open your photos. Please try again',
          ),
        ),
      );
    }
  }

  Future<void> _onContinued(
    SetupContinued event,
    Emitter<BusinessSetupState> emit,
  ) async {
    switch (state.step) {
      case BusinessSetupStep.details:
        final isValid =
            BusinessValidator.name(state.name) == null &&
            BusinessValidator.type(state.type) == null;
        _advanceOrShowErrors(emit, isValid, BusinessSetupStep.location);
      case BusinessSetupStep.location:
        final isValid =
            BusinessValidator.address(state.address) == null &&
            BusinessValidator.location(
                  latitude: state.latitude,
                  longitude: state.longitude,
                ) ==
                null;
        _advanceOrShowErrors(emit, isValid, BusinessSetupStep.photo);
      case BusinessSetupStep.photo:
        if (state.photoPath == null) {
          emit(
            state.copyWith(
              feedback: FeedbackMessage.error(
                'Add a photo, or tap "Skip for now"',
              ),
            ),
          );
          return;
        }
        await _submit(emit, includePhoto: true);
    }
  }

  void _advanceOrShowErrors(
    Emitter<BusinessSetupState> emit,
    bool isValid,
    BusinessSetupStep next,
  ) {
    if (isValid) {
      emit(state.copyWith(step: next, showErrors: false));
    } else {
      emit(
        state.copyWith(
          showErrors: true,
          feedback: FeedbackMessage.error('Please fix the highlighted fields'),
        ),
      );
    }
  }

  void _onStepBack(SetupStepBack event, Emitter<BusinessSetupState> emit) {
    if (state.isSubmitting || state.step == BusinessSetupStep.details) return;
    emit(
      state.copyWith(
        step: BusinessSetupStep.values[state.step.index - 1],
        showErrors: false,
      ),
    );
  }

  Future<void> _submit(
    Emitter<BusinessSetupState> emit, {
    required bool includePhoto,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: BusinessSetupStatus.submitting));

    var input = BusinessSetupInput(
      name: state.name,
      type: state.type!,
      address: BusinessValidator.fullAddress(
        address: state.address,
        neighborhood: state.neighborhood,
      ),
      latitude: state.latitude!,
      longitude: state.longitude!,
    );
    final photoPath = state.photoPath;
    final wantsPhoto = includePhoto && photoPath != null;

    try {
      if (wantsPhoto && _imageStorage.isAvailable) {
        final photoUrl = await _imageStorage.upload(
          localPath: photoPath,
          folder: 'businesses/$_ownerId',
        );
        input = input.withPhotoUrl(photoUrl);
      }
      final businessId = await _businessRepository.createBusiness(
        ownerId: _ownerId,
        input: input,
      );
      emit(
        state.copyWith(
          status: BusinessSetupStatus.success,
          businessId: businessId,
          feedback: FeedbackMessage.success(
            wantsPhoto && !_imageStorage.isAvailable
                ? 'Your business is ready. Photo upload is coming soon'
                : 'Your business is ready',
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BusinessSetupStatus.editing,
          feedback: FeedbackMessage.error(_messageFor(error)),
        ),
      );
    }
  }

  String _messageFor(Object error) =>
      error is BusinessFailure ? error.message : BusinessFailure.genericMessage;
}
