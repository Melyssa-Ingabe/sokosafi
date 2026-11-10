/// Short, friendly date and time labels such as "Today, 8:00 PM" and
/// "In 2h". Kept separate from Formatters so no extra package is needed.
abstract final class DateFormatters {
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 20:05 becomes "8:05 PM".
  static String time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// "Today, 8:00 PM", "Yesterday, 6:30 AM", "Tomorrow, 9:00 AM", otherwise
  /// "Fri 13 Nov, 9:00 AM".
  static String dayAndTime(DateTime value, {required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final dayDifference = day.difference(today).inDays;
    final dayLabel = switch (dayDifference) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ =>
        '${_weekdays[value.weekday - 1]} ${value.day} '
            '${_months[value.month - 1]}',
    };
    return '$dayLabel, ${time(value)}';
  }

  /// "In 2h", "In 45m", "In 1h 30m", or "Passed" once the time has gone.
  static String timeUntil(DateTime value, {required DateTime now}) {
    final remaining = value.difference(now);
    if (remaining.inMinutes <= 0) return 'Passed';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours == 0) return 'In ${minutes}m';
    if (minutes == 0) return 'In ${hours}h';
    return 'In ${hours}h ${minutes}m';
  }
}
