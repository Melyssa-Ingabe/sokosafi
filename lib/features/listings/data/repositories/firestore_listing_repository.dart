import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/listings/data/models/listing_model.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';

class FirestoreListingRepository implements ListingRepository {
  FirestoreListingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  @override
  Stream<List<Listing>> watchBusinessListings(String businessId) {
    // Needs the composite index (businessId asc, createdAt desc) from
    // firestore.indexes.json.
    return _listings
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs.map(ListingModel.fromSnapshot).toList(growable: false),
        )
        .handleError((Object error) => throw _toFailure(error));
  }

  @override
  Future<String> createListing({
    required String businessId,
    required ListingInput input,
  }) async {
    try {
      final document = await _listings.add(
        ListingModel.createMap(businessId: businessId, input: input),
      );
      return document.id;
    } catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingInput input,
  }) async {
    try {
      await _listings.doc(listingId).update(ListingModel.editableFields(input));
    } catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> deleteListing({
    required String businessId,
    required String listingId,
  }) async {
    try {
      // Customers who already paid must still be able to collect their food,
      // so a listing with orders waiting for pickup cannot be removed. The
      // businessId filter keeps the query inside what the security rules let
      // a business read.
      final waitingOrders = await _orders
          .where('businessId', isEqualTo: businessId)
          .where('listingId', isEqualTo: listingId)
          .where('status', isEqualTo: 'paid')
          .limit(1)
          .get();
      if (waitingOrders.docs.isNotEmpty) {
        throw const ListingFailure(
          'Customers are still waiting to collect this listing. '
          'Confirm their pickups before deleting it',
        );
      }
      await _listings.doc(listingId).delete();
    } catch (error) {
      throw _toFailure(error);
    }
  }

  ListingFailure _toFailure(Object error) {
    if (error is ListingFailure) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const ListingFailure(
            'You do not have permission to change this listing',
          );
        case 'not-found':
          return const ListingFailure('This listing no longer exists');
        case 'unavailable':
        case 'deadline-exceeded':
          return const ListingFailure(
            'You seem to be offline. Check your connection and try again',
          );
        case 'failed-precondition':
          return const ListingFailure(
            'Listings are not ready yet. Please try again in a moment',
          );
      }
    }
    return const ListingFailure(ListingFailure.genericMessage);
  }
}
