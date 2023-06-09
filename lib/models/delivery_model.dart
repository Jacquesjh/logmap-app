import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Item {
  final String name;
  final String quantity;
  final String unit;

  Item({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Item.fromSnapshot(Map<String, dynamic> item) {
    return Item(
      name: item['name'] as String,
      quantity: item['quantity'] as String,
      unit: item['unit'] as String,
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

  factory GeoAddress.fromSnapshot(Map<String, dynamic> lastLocationMap) {
    return GeoAddress(
      latitude: lastLocationMap['latitude'] as double,
      longitude: lastLocationMap['longitude'] as double,
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
    required this.isComplete,
    required this.items,
    required this.number,
    required this.ref,
    required this.state,
    required this.truckRef,
  });

  factory Delivery.fromAsyncSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {
    final data = snapshot.data!.data() as Map<String, dynamic>?;
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

    final geoAddress = GeoAddress.fromSnapshot(data['geoAddress']);

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
      isComplete: data['isComplete'] as bool,
      items: items,
      number: data['number'] as int,
      ref: snapshot.data!.reference,
      state: data['state'] as String,
      truckRef: truckRef,
    );
  }
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

    final geoAddress = GeoAddress.fromSnapshot(data['geoAddress']);

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
      isComplete: data['isComplete'] as bool,
      items: items,
      number: data['number'] as int,
      ref: snapshot.reference,
      state: data['state'] as String,
      truckRef: truckRef,
    );
  }

  Future<void> updateIsComplete(bool isComplete) async {
    await ref?.update({'isComplete': isComplete});
  }
}
