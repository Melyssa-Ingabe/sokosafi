part of 'feed_cubit.dart';

enum FeedStatus { loading, ready, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.loading,
    this.sections = const [],
    this.errorMessage,
    this.userLocation,
    this.locationMessage,
  });

  final FeedStatus status;
  final List<FeedSection> sections;

  /// Why the feed could not load.
  final String? errorMessage;

  /// Where the customer is, once the phone has shared it.
  final Place? userLocation;

  /// Shown instead of distances when the location is not available.
  final String? locationMessage;

  bool get isEmpty => status == FeedStatus.ready && sections.isEmpty;

  /// "350 m away", or null while the customer's location is unknown.
  String? distanceTo(Business business) {
    final from = userLocation;
    if (from == null) return null;
    return GeoDistance.label(
      GeoDistance.kilometres(
        fromLatitude: from.latitude,
        fromLongitude: from.longitude,
        toLatitude: business.latitude,
        toLongitude: business.longitude,
      ),
    );
  }

  FeedState copyWith({
    FeedStatus? status,
    List<FeedSection>? sections,
    String? errorMessage,
    Place? userLocation,
    String? locationMessage,
    bool clearLocationMessage = false,
  }) {
    return FeedState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
      userLocation: userLocation ?? this.userLocation,
      locationMessage: clearLocationMessage
          ? null
          : (locationMessage ?? this.locationMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    sections,
    errorMessage,
    userLocation,
    locationMessage,
  ];
}
