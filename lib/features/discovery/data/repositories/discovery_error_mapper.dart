import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';

DiscoveryFailure toDiscoveryFailure(Object error) {
  if (error is DiscoveryFailure) return error;
  if (error is TimeoutException) {
    return const DiscoveryFailure(
      'This is taking too long. Check your connection and try again',
    );
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const DiscoveryFailure('Please sign in again to see food');
      case 'unavailable':
      case 'deadline-exceeded':
        return const DiscoveryFailure(
          'You seem to be offline. Check your connection and try again',
        );
      case 'failed-precondition':
        return const DiscoveryFailure(
          'The food list is still being set up. Please try again soon',
        );
    }
  }
  return const DiscoveryFailure(DiscoveryFailure.genericMessage);
}
