/// The period the Analytics screen is showing.
enum AnalyticsRange {
  today('Today'),
  week('Week'),
  month('Month'),
  allTime('All time');

  const AnalyticsRange(this.label);

  final String label;
}
