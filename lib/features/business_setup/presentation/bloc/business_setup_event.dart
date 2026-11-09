part of 'business_setup_bloc.dart';

sealed class BusinessSetupEvent extends Equatable {
  const BusinessSetupEvent();

  @override
  List<Object?> get props => [];
}

final class BusinessNameChanged extends BusinessSetupEvent {
  const BusinessNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class BusinessTypeSelected extends BusinessSetupEvent {
  const BusinessTypeSelected(this.type);

  final BusinessType type;

  @override
  List<Object?> get props => [type];
}

final class BusinessAddressChanged extends BusinessSetupEvent {
  const BusinessAddressChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

/// The owner pressed search on the keyboard; move the pin to that address.
final class BusinessAddressSearched extends BusinessSetupEvent {
  const BusinessAddressSearched();
}

final class CurrentLocationRequested extends BusinessSetupEvent {
  const CurrentLocationRequested();
}

/// The owner finished moving the map; the pin sits at its center.
final class MapPinMoved extends BusinessSetupEvent {
  const MapPinMoved({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

final class BusinessPhotoRequested extends BusinessSetupEvent {
  const BusinessPhotoRequested(this.source);

  final PhotoSource source;

  @override
  List<Object?> get props => [source];
}

/// Continue on steps 1 and 2, "Complete setup" on step 3.
final class SetupContinued extends BusinessSetupEvent {
  const SetupContinued();
}

/// "Skip for now" on the photo step.
final class SetupPhotoSkipped extends BusinessSetupEvent {
  const SetupPhotoSkipped();
}

final class SetupStepBack extends BusinessSetupEvent {
  const SetupStepBack();
}
