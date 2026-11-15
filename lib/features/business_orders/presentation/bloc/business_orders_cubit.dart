import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

part 'business_orders_state.dart';

/// Follows every order for one business and splits them into the tabs of
/// the Business Orders screen.
class BusinessOrdersCubit extends Cubit<BusinessOrdersState> {
  BusinessOrdersCubit({required this._repository, required this._businessId})
    : super(const BusinessOrdersState());

  final BusinessOrdersRepository _repository;
  final String _businessId;
  StreamSubscription<List<BusinessOrder>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: BusinessOrdersStatus.loading));
    _subscription = _repository
        .watchOrders(_businessId)
        .listen(
          (orders) => emit(
            state.copyWith(status: BusinessOrdersStatus.ready, orders: orders),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: BusinessOrdersStatus.failure,
              errorMessage: error is BusinessOrdersFailure
                  ? error.message
                  : BusinessOrdersFailure.genericMessage,
            ),
          ),
        );
  }

  void selectTab(BusinessOrdersTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
