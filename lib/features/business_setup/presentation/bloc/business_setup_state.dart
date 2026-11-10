part of 'business_setup_bloc.dart';

enum BusinessSetupStep {
  details,
  location,
  photo;

  /// 1-based position for the "1 of 3" header.
  int get number => index + 1;

  static int get count => values.length;
}

enum BusinessSetupStatus { editing, submitting, success }

class BusinessSetupState extends Equatable {
  const BusinessSetupState({
    this.step = BusinessSetupStep.details,
    this.status = BusinessSetupStatus.editing,
    this.name = '',
    this.type,
    this.address = '',
    this.neighborhood = '',
    this.latitude,
    this.longitude,
    this.mapFocusRevision = 0,
    this.isLocating = false,
    this.photoPath,
    this.showErrors = false,
    this.businessId,
    this.feedback,
  });

  final BusinessSetupStep step;
  final BusinessSetupStatus status;
  final String name;
  final BusinessType? type;
  final String address;
  final String neighborhood;
  final double? latitude;
  final double? longitude;

  /// Goes up whenever the pin is moved by the app (GPS or address search)
  /// rather than by the owner, so the map knows to fly to the new spot.
  final int mapFocusRevision;
  final bool isLocating;
  final String? photoPath;

  /// Errors only appear after the owner tries to continue, not while they
  /// are still typing for the first time.
  final bool showErrors;

  /// Set once the business is created.
  final String? businessId;
  final FeedbackMessage? feedback;

  bool get isSubmitting => status == BusinessSetupStatus.submitting;

  String? get nameError => showErrors ? BusinessValidator.name(name) : null;

  String? get typeError => showErrors ? BusinessValidator.type(type) : null;

  String? get addressError =>
      showErrors ? BusinessValidator.address(address) : null;

  String? get locationError => showErrors
      ? BusinessValidator.location(latitude: latitude, longitude: longitude)
      : null;

  BusinessSetupState copyWith({
    BusinessSetupStep? step,
    BusinessSetupStatus? status,
    String? name,
    BusinessType? type,
    String? address,
    String? neighborhood,
    double? latitude,
    double? longitude,
    int? mapFocusRevision,
    bool? isLocating,
    String? photoPath,
    bool? showErrors,
    String? businessId,
    FeedbackMessage? feedback,
  }) {
    return BusinessSetupState(
      step: step ?? this.step,
      status: status ?? this.status,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapFocusRevision: mapFocusRevision ?? this.mapFocusRevision,
      isLocating: isLocating ?? this.isLocating,
      photoPath: photoPath ?? this.photoPath,
      showErrors: showErrors ?? this.showErrors,
      businessId: businessId ?? this.businessId,
      // Feedback is shown once, so it is never carried into the next state.
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    name,
    type,
    address,
    neighborhood,
    latitude,
    longitude,
    mapFocusRevision,
    isLocating,
    photoPath,
    showErrors,
    businessId,
    feedback,
  ];
}
