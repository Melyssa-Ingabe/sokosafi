part of 'confirm_pickup_cubit.dart';

enum ConfirmPickupStatus { idle, checking, confirmed, failed }

class ConfirmPickupState extends Equatable {
  const ConfirmPickupState({
    this.status = ConfirmPickupStatus.idle,
    this.errorMessage,
    this.refusedCode,
  });

  final ConfirmPickupStatus status;

  final String? errorMessage;

  /// The code that was just refused, so the scanner does not keep
  /// re-checking it while it stays in view.
  final String? refusedCode;

  @override
  List<Object?> get props => [status, errorMessage, refusedCode];
}
