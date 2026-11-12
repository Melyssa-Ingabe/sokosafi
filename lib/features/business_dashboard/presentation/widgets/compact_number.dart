/// Short numbers for small stat tiles: 950 stays "950", 10800 becomes
/// "10.8k" and 2500000 becomes "2.5M".
String compactNumber(num value) {
  final absolute = value.abs();
  if (absolute >= 1000000) return '${_oneDecimal(value / 1000000)}M';
  if (absolute >= 1000) return '${_oneDecimal(value / 1000)}k';
  return value.round().toString();
}

String _oneDecimal(num value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
