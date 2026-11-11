import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';

part 'confirm_pickup_state.dart';

/// Checks a scanned or typed pickup code and marks the order collected.
class ConfirmPickupCubit extends Cubit<ConfirmPickupState> {
  ConfirmPickupCubit({required this._repository, required this._businessId})
    : super(const ConfirmPickupState());

  final BusinessOrdersRepository _repository;
  final String _businessId;

  Future<void> confirm(String pickupCode) async {
    // The scanner reports the same QR code many times a second. Ignoring
    // scans while a check runs, or after success, stops the order from
    // being checked twice and showing "already picked up".
    if (state.status == ConfirmPickupStatus.checking ||
        state.status == ConfirmPickupStatus.confirmed) {
      return;
    }
    emit(const ConfirmPickupState(status: ConfirmPickupStatus.checking));
    try {
      await _repository.confirmPickup(
        businessId: _businessId,
        pickupCode: pickupCode,
      );
      emit(const ConfirmPickupState(status: ConfirmPickupStatus.confirmed));
    } on BusinessOrdersFailure catch (failure) {
      emit(
        ConfirmPickupState(
          status: ConfirmPickupStatus.failed,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
