import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';

void main() {
  final now = DateTime(2026, 11, 9, 18);

  test('formats times on a 12-hour clock', () {
    expect(DateFormatters.time(DateTime(2026, 11, 9, 20, 5)), '8:05 PM');
    expect(DateFormatters.time(DateTime(2026, 11, 9, 0, 30)), '12:30 AM');
    expect(DateFormatters.time(DateTime(2026, 11, 9, 12)), '12:00 PM');
  });

  test('names today, tomorrow and yesterday', () {
    expect(
      DateFormatters.dayAndTime(DateTime(2026, 11, 9, 20), now: now),
      'Today, 8:00 PM',
    );
    expect(
      DateFormatters.dayAndTime(DateTime(2026, 11, 10, 9), now: now),
      'Tomorrow, 9:00 AM',
    );
    expect(
      DateFormatters.dayAndTime(DateTime(2026, 11, 8, 6, 30), now: now),
      'Yesterday, 6:30 AM',
    );
  });

  test('shows weekday and date further out', () {
    expect(
      DateFormatters.dayAndTime(DateTime(2026, 11, 13, 9), now: now),
      'Fri 13 Nov, 9:00 AM',
    );
  });

  test('counts down to a time', () {
    expect(
      DateFormatters.timeUntil(now.add(const Duration(hours: 2)), now: now),
      'In 2h',
    );
    expect(
      DateFormatters.timeUntil(
        now.add(const Duration(hours: 1, minutes: 30)),
        now: now,
      ),
      'In 1h 30m',
    );
    expect(
      DateFormatters.timeUntil(now.add(const Duration(minutes: 45)), now: now),
      'In 45m',
    );
    expect(
      DateFormatters.timeUntil(
        now.subtract(const Duration(minutes: 1)),
        now: now,
      ),
      'Passed',
    );
  });
}
