import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_setup/data/models/business_model.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/data/repositories/discovery_error_mapper.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/listings/data/models/listing_model.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';

class FirestoreDiscoveryRepository implements DiscoveryRepository {
  FirestoreDiscoveryRepository({
    FirebaseFirestore? firestore,
    DateTime Function()? clock,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _clock = clock ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _clock;

  static const Duration _timeout = Duration(seconds: 20);

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection('businesses');

  @override
  Stream<List<FeedItem>> watchFeed() {
    // A range and a sort on the same field are served by Firestore's
    // automatic single-field index, so the feed needs no composite index.
    // Status, stock and "accepting orders" are checked on the phone by
    // FeedSections, which also drops listings whose time runs out while
    // the screen is open.
    return _listings
        .where('pickupBy', isGreaterThan: Timestamp.fromDate(_clock()))
        .orderBy('pickupBy')
        .snapshots()
        .asyncMap((snapshot) async {
          final listings = snapshot.docs
              .map(ListingModel.fromSnapshot)
              .toList(growable: false);
          final businesses = await _readBusinesses(
            listings.map((listing) => listing.businessId).toSet(),
          );
          return [
            for (final listing in listings)
              if (businesses[listing.businessId] case final business?)
                FeedItem(listing: listing, business: business),
          ];
        })
        .handleError((Object error) => throw toDiscoveryFailure(error));
  }

  @override
  Stream<FeedItem> watchItem(String listingId) {
    return _listings
        .doc(listingId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (!snapshot.exists) {
            throw const DiscoveryFailure('This food is no longer listed');
          }
          final Listing listing = ListingModel.fromSnapshot(snapshot);
          final businesses = await _readBusinesses({listing.businessId});
          final business = businesses[listing.businessId];
          if (business == null) {
            throw const DiscoveryFailure('We could not find this shop');
          }
          return FeedItem(listing: listing, business: business);
        })
        .handleError((Object error) => throw toDiscoveryFailure(error));
  }

  @override
  Stream<List<FeedItem>> watchShopItems(Business business) {
    // An equality filter on one field needs no composite index.
    return _listings
        .where('businessId', isEqualTo: business.id)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              FeedItem(
                listing: ListingModel.fromSnapshot(doc),
                business: business,
              ),
          ],
        )
        .handleError((Object error) => throw toDiscoveryFailure(error));
  }

  /// Reads each business once per update. A listing whose business is
  /// missing is left out rather than shown without a name or address.
  Future<Map<String, Business>> _readBusinesses(Set<String> ids) async {
    final snapshots = await Future.wait(
      ids.where((id) => id.isNotEmpty).map((id) => _businesses.doc(id).get()),
    ).timeout(_timeout);
    return {
      for (final snapshot in snapshots)
        if (snapshot.exists) snapshot.id: BusinessModel.fromSnapshot(snapshot),
    };
  }
}
