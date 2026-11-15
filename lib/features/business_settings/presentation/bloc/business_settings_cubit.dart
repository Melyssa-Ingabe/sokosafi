import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';
import 'package:sokosafi/features/business_settings/domain/entities/payout_account.dart';
import 'package:sokosafi/features/business_settings/domain/failures/business_settings_failure.dart';
import 'package:sokosafi/features/business_settings/domain/repositories/business_settings_repository.dart';

part 'business_settings_state.dart';

/// Follows the business's settings live and saves each change the owner
/// makes. The screen updates from the stream, so no manual refresh.
class BusinessSettingsCubit extends Cubit<BusinessSettingsState> {
  BusinessSettingsCubit({
    required this._repository,
    required this._businessId,
    required this._ownerId,
  }) : super(const BusinessSettingsState());

  final BusinessSettingsRepository _repository;
  final String _businessId;
  final String _ownerId;
  StreamSubscription<BusinessSettings>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const BusinessSettingsState());
    _subscription = _repository
        .watchSettings(_businessId)
        .listen(
          (settings) => emit(
            state.copyWith(
              status: BusinessSettingsStatus.ready,
              settings: settings,
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: BusinessSettingsStatus.failure,
              errorMessage: error is BusinessSettingsFailure
                  ? error.message
                  : BusinessSettingsFailure.genericMessage,
            ),
          ),
        );
    _loadPayoutAccount();
  }

  Future<void> _loadPayoutAccount() async {
    try {
      final phone = await _repository.loadOwnerPhone(_ownerId);
      if (!isClosed) {
        emit(state.copyWith(payoutAccount: PayoutAccount.fromPhone(phone)));
      }
    } on BusinessSettingsFailure {
      // The payout row then asks the owner to add a number; the rest of
      // the screen still works.
      if (!isClosed) {
        emit(state.copyWith(payoutAccount: PayoutAccount.fromPhone('')));
      }
    }
  }

  Future<void> setAcceptingOrders(bool isAccepting) {
    return _save(
      () =>
          _repository.updateSettings(_businessId, acceptingOrders: isAccepting),
      successMessage: isAccepting
          ? 'Your listings are visible to customers again'
          : 'Orders paused. Customers will not see your listings',
    );
  }

  Future<void> setAutoClose(bool isOn) {
    return _save(
      () => _repository.updateSettings(_businessId, autoClose: isOn),
    );
  }

  Future<void> setPickupWindow({required String start, required String end}) {
    if (!BusinessSettings.isValidPickupWindow(start, end)) {
      emit(
        state.copyWith(
          feedback: const SettingsFeedback.error(
            'The pickup window must end after it starts',
          ),
        ),
      );
      return Future.value();
    }
    return _save(
      () => _repository.updateSettings(
        _businessId,
        pickupStart: start,
        pickupEnd: end,
      ),
      successMessage: 'Pickup window updated',
    );
  }

  Future<void> setLandmark(String landmark) {
    if (landmark.trim().length > BusinessSettings.maxLandmarkLength) {
      emit(
        state.copyWith(
          feedback: const SettingsFeedback.error(
            'Keep the landmark under 120 characters',
          ),
        ),
      );
      return Future.value();
    }
    return _save(
      () => _repository.updateSettings(_businessId, landmark: landmark),
      successMessage: 'Pickup landmark saved',
    );
  }

  Future<void> _save(
    Future<void> Function() write, {
    String? successMessage,
  }) async {
    try {
      await write();
      if (successMessage != null && !isClosed) {
        emit(
          state.copyWith(feedback: SettingsFeedback.success(successMessage)),
        );
      }
    } on BusinessSettingsFailure catch (failure) {
      if (!isClosed) {
        emit(state.copyWith(feedback: SettingsFeedback.error(failure.message)));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
