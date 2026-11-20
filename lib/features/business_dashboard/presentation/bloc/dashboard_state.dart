part of 'dashboard_cubit.dart';

enum DashboardStatus { loading, ready, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.summary,
    this.errorMessage,
  });

  final DashboardStatus status;

  /// Set once both listings and orders have loaded.
  final DashboardSummary? summary;

  /// Why the dashboard could not load.
  final String? errorMessage;

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
