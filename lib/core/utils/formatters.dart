/// Display formatting shared across features.
abstract final class Formatters {
  /// 1000 becomes "1,000 RWF".
  static String rwf(num amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return '$buffer RWF';
  }

  static String timeLeft(Duration remaining) {
    if (remaining.isNegative || remaining == Duration.zero) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m left';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}m left';
    return 'Less than 1m left';
  }

  static int discountPercent({required num original, required num discounted}) {
    if (original <= 0) return 0;
    return (((original - discounted) / original) * 100).round();
  }
}
