import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';

OrdersFailure toOrdersFailure(Object error) {
  if (error is OrdersFailure) return error;
  if (error is TimeoutException) {
    return const OrdersFailure(
      'This is taking too long. Check your connection and try again',
    );
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const OrdersFailure('You do not have access to this order');
      case 'unavailable':
      case 'deadline-exceeded':
        return const OrdersFailure(
          'You seem to be offline. Check your connection and try again',
        );
      case 'not-found':
        return const OrdersFailure('We could not find that order');
      case 'aborted':
        return const OrdersFailure(
          'Someone else just ordered this item. Please try again',
        );
    }
  }
  return const OrdersFailure(OrdersFailure.genericMessage);
}
