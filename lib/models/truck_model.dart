import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class Truck {
  final List<DocumentReference> activeDeliveriesRef;
  final List<DocumentReference> completedDeliveriesRef;
  final DocumentReference? driverRef;
  final List<GeoAddress> geoAddressArray;
  final DocumentReference historyRef;
  final GeoAddress lastLocation;
  final String licensePlate;
  final String name;
  final int number;
  final DocumentReference? ref;
  final String size;
  final List<DocumentReference> currentDateDriversRef;

  Truck({
    required this.activeDeliveriesRef,
    required this.completedDeliveriesRef,
    required this.driverRef,
    required this.geoAddressArray,
    required this.historyRef,
    required this.lastLocation,
    required this.licensePlate,
    required this.name,
    required this.number,
    required this.ref,
    required this.size,
    required this.currentDateDriversRef,
  });

  factory Truck.fromSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {
    final data = snapshot.data!.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Invalid data format");
    }

    final activeDeliveriesRef = (data['activeDeliveriesRef'] as List<dynamic>)
        .cast<DocumentReference>();
    final completedDeliveriesRef =
        (data['completedDeliveriesRef'] as List<dynamic>)
            .cast<DocumentReference>();
    final driverRef = data['driverRef'] as DocumentReference?;

    final geoAddressArrayJson = data['geoAddressArray'] as List<dynamic>;
    final geoAddressArray = geoAddressArrayJson
        .map((geoAddressJson) => GeoAddress.fromSnapshot(geoAddressJson))
        .toList();

    final historyRef = data['historyRef'] as DocumentReference;
    final lastLocation = GeoAddress.fromSnapshot(data['lastLocation']);

    return Truck(
      activeDeliveriesRef: activeDeliveriesRef,
      completedDeliveriesRef: completedDeliveriesRef,
      driverRef: driverRef,
      geoAddressArray: geoAddressArray,
      historyRef: historyRef,
      lastLocation: lastLocation,
      licensePlate: data['licensePlate'] as String,
      name: data['name'] as String,
      number: data['number'] as int,
      ref: snapshot.data!.reference,
      size: data['size'] as String,
      currentDateDriversRef: (data['currentDateDriversRef'] as List<dynamic>)
          .cast<DocumentReference>(),
    );
  }
}
