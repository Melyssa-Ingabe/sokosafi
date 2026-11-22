part of 'order_detail_cubit.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  const factory OrderDetailState.loading() = OrderDetailLoading;
  const factory OrderDetailState.ready(OrderDetails details) = OrderDetailReady;
  const factory OrderDetailState.failure(String message) = OrderDetailFailure;

  @override
  List<Object?> get props => [];
}

final class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

final class OrderDetailReady extends OrderDetailState {
  const OrderDetailReady(this.details, {this.isCancelling = false});

  final OrderDetails details;
  final bool isCancelling;

  OrderDetailReady copyWith({bool? isCancelling}) => OrderDetailReady(
    details,
    isCancelling: isCancelling ?? this.isCancelling,
  );

  @override
  List<Object?> get props => [details, isCancelling];
}

final class OrderDetailFailure extends OrderDetailState {
  const OrderDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
