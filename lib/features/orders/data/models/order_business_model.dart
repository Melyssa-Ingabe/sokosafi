import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/orders/domain/entities/order_business.dart';

abstract final class OrderBusinessModel {
  static OrderBusiness fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OrderBusiness(
      id: doc.id,
      name: data.readString('name'),
      address: data.readString('address'),
    );
  }
}
