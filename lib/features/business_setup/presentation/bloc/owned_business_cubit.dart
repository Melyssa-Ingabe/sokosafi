import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';

enum OwnedBusinessStatus { loading, loaded, failure }

class OwnedBusinessState extends Equatable {
  const OwnedBusinessState({
    this.status = OwnedBusinessStatus.loading,
    this.business,
    this.errorMessage,
  });

  final OwnedBusinessStatus status;

  /// Null once loaded means the user has not set up a business yet.
  final Business? business;
  final String? errorMessage;

  bool get needsSetup =>
      status == OwnedBusinessStatus.loaded && business == null;

  @override
  List<Object?> get props => [status, business, errorMessage];
}

/// Follows the signed-in user's business. Drives the "Switch to business"
/// flow (setup when there is none, dashboard when there is one) and gives
/// the listings screens their businessId.
class OwnedBusinessCubit extends Cubit<OwnedBusinessState> {
  OwnedBusinessCubit({
    required this._businessRepository,
    required this._ownerId,
  }) : super(const OwnedBusinessState());

  final BusinessRepository _businessRepository;
  final String _ownerId;
  StreamSubscription<Business?>? _subscription;

  void start() {
    _subscription?.cancel();
    emit(const OwnedBusinessState());
    _subscription = _businessRepository
        .watchOwnedBusiness(_ownerId)
        .listen(
          (business) => emit(
            OwnedBusinessState(
              status: OwnedBusinessStatus.loaded,
              business: business,
            ),
          ),
          onError: (Object error) => emit(
            OwnedBusinessState(
              status: OwnedBusinessStatus.failure,
              errorMessage: error is BusinessFailure
                  ? error.message
                  : BusinessFailure.genericMessage,
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
