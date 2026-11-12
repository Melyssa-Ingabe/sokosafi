part of 'analytics_cubit.dart';

enum AnalyticsStatus { loading, ready, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.loading,
    this.range = AnalyticsRange.today,
    this.summary,
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final AnalyticsRange range;

  /// Set once orders and reviews have both loaded.
  final AnalyticsSummary? summary;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, range, summary, errorMessage];
}
