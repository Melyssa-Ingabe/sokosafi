part of 'search_cubit.dart';

enum SearchStatus { loading, ready, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.loading,
    this.filter = const SearchFilter(),
    this.results = const [],
    this.availableCount = 0,
    this.defaultRadiusKm,
    this.location,
    this.locationMessage,
    this.errorMessage,
  });

  final SearchStatus status;
  final SearchFilter filter;
  final List<SearchResult> results;

  /// How much food is on sale before any search or filter, so an empty
  /// result can say whether the filters or the shops are the reason.
  final int availableCount;

  /// The search distance from settings, which is not counted as a filter.
  final int? defaultRadiusKm;

  /// Where the customer is, once the phone has shared it.
  final CustomerLocation? location;

  /// Shown when the location is not available.
  final String? locationMessage;

  /// Why the listings could not load.
  final String? errorMessage;

  /// Whether the price or distance differ from the defaults, for the dot
  /// on the filter button.
  bool get hasCustomLimits =>
      filter.maxPriceRwf != null || filter.radiusKm != defaultRadiusKm;

  /// Whether "Clear filters" would change anything.
  bool get canClearFilters => hasCustomLimits || filter.category != null;

  SearchState copyWith({
    SearchStatus? status,
    SearchFilter? filter,
    List<SearchResult>? results,
    int? availableCount,
    CustomerLocation? location,
    String? locationMessage,
    bool clearLocationMessage = false,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      results: results ?? this.results,
      availableCount: availableCount ?? this.availableCount,
      defaultRadiusKm: defaultRadiusKm,
      location: location ?? this.location,
      locationMessage: clearLocationMessage
          ? null
          : (locationMessage ?? this.locationMessage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    results,
    availableCount,
    defaultRadiusKm,
    location,
    locationMessage,
    errorMessage,
  ];
}
