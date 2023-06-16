import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  final String quantity;
  final String unit;

  Item({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Item.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Invalid data format");
    }

    return Item(
      name: data['name'] as String,
      quantity: data['quantity'] as String,
      unit: data['unit'] as String,
    );
  }
}

class GeoAddress {
  final double latitude;
  final double longitude;

  GeoAddress({
    required this.latitude,
    required this.longitude,
  });

  factory GeoAddress.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Invalid data format");
    }

    return GeoAddress(
      latitude: data['latitude'] as double,
      longitude: data['longitude'] as double,
    );
  }
}

class Delivery {
  final String address;
  final String addressNumber;
  final String city;
  final DocumentReference? clientRef;
  final Timestamp createdAt;
  final String deliveryDate;
  final Timestamp? deliveredAt;
  final DocumentReference? driverRef;
  final String expectedDeliveryInterval;
  final GeoAddress geoAddress;
  final String id;
  final bool isComplete;
  final List<Item> items;
  final int number;
  final DocumentReference? ref;
  final String state;
  final DocumentReference? truckRef;

  Delivery({
    required this.address,
    required this.addressNumber,
    required this.city,
    required this.clientRef,
    required this.createdAt,
    required this.deliveryDate,
    required this.deliveredAt,
    required this.driverRef,
    required this.expectedDeliveryInterval,
    required this.geoAddress,
    required this.id,
    required this.isComplete,
    required this.items,
    required this.number,
    required this.ref,
    required this.state,
    required this.truckRef,
  });

  factory Delivery.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Invalid data format");
    }

    final clientRef = data['clientRef'] as DocumentReference?;
    final deliveredAt = data['deliveredAt'] as Timestamp?;
    final driverRef = data['driverRef'] as DocumentReference?;
    final truckRef = data['truckRef'] as DocumentReference?;

    final itemsJson = data['items'] as List<dynamic>;
    final items =
        itemsJson.map((itemJson) => Item.fromSnapshot(itemJson)).toList();

    final geoAddress =
        GeoAddress.fromSnapshot(data['geoAddress'] as DocumentSnapshot);

    return Delivery(
      address: data['address'] as String,
      addressNumber: data['addressNumber'] as String,
      city: data['city'] as String,
      clientRef: clientRef,
      createdAt: data['createdAt'] as Timestamp,
      deliveryDate: data['deliveryDate'] as String,
      deliveredAt: deliveredAt,
      driverRef: driverRef,
      expectedDeliveryInterval: data['expectedDeliveryInterval'] as String,
      geoAddress: geoAddress,
      id: data['id'] as String,
      isComplete: data['isComplete'] as bool,
      items: items,
      number: data['number'] as int,
      ref: snapshot.reference,
      state: data['state'] as String,
      truckRef: truckRef,
    );
  }
}
