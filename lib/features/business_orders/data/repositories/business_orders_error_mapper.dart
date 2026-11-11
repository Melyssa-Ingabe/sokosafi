import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';

BusinessOrdersFailure toBusinessOrdersFailure(Object error) {
  if (error is BusinessOrdersFailure) return error;
  if (error is TimeoutException) {
    return const BusinessOrdersFailure(
      'This is taking too long. Check your connection and try again',
    );
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const BusinessOrdersFailure(
          'You can only manage orders for your own business',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const BusinessOrdersFailure(
          'You seem to be offline. Check your connection and try again',
        );
      case 'failed-precondition':
        return const BusinessOrdersFailure(
          'Orders are not ready to show yet. Please try again in a few minutes',
        );
    }
  }
  return const BusinessOrdersFailure(BusinessOrdersFailure.genericMessage);
}
