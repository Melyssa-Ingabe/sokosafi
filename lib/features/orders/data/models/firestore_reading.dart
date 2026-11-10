import 'package:cloud_firestore/cloud_firestore.dart';

/// Lenient readers for documents written by other features, so a missing
/// or mistyped field shows a fallback instead of crashing the screen.
extension FirestoreReading on Map<String, dynamic> {
  String readString(String key) {
    final value = this[key];
    return value is String ? value : '';
  }

  num readNum(String key) {
    final value = this[key];
    return value is num ? value : 0;
  }

  int readInt(String key) => readNum(key).toInt();

  DateTime? readDate(String key) {
    final value = this[key];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
