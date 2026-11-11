part of 'confirm_pickup_cubit.dart';

enum ConfirmPickupStatus { idle, checking, confirmed, failed }

class ConfirmPickupState extends Equatable {
  const ConfirmPickupState({
    this.status = ConfirmPickupStatus.idle,
    this.errorMessage,
  });

  final ConfirmPickupStatus status;

  /// Why the last code was refused, worded for the business owner.
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
