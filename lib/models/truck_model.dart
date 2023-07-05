import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logmap/models/delivery_model.dart';

class Truck {
  final List<DocumentReference> activeDeliveriesRef;
  final List<DocumentReference> completedDeliveriesRef;
  final DocumentReference? driverRef;
  final List<GeoAddress?> geoAddressArray;
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

  factory Truck.fromAsyncSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {
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
    final geoAddressArray = geoAddressArrayJson.isEmpty
        ? <GeoAddress>[] // Create an empty list
        : geoAddressArrayJson
            .map((geoAddressJson) => GeoAddress(
                  latitude: geoAddressJson.latitude,
                  longitude: geoAddressJson.longitude,
                ))
            .toList();

    final historyRef = data['historyRef'] as DocumentReference;
    final lastLocation = GeoAddress(
        latitude: data['lastLocation'].latitude,
        longitude: data['lastLocation'].longitude);

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
  factory Truck.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
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
        .map((geoAddressJson) => GeoAddress(
            latitude: geoAddressJson.latitude,
            longitude: geoAddressJson.longitude))
        .toList();

    final historyRef = data['historyRef'] as DocumentReference;
    final lastLocation = GeoAddress(
        latitude: data['lastLocation'].latitude,
        longitude: data['lastLocation'].longitude);

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
      ref: snapshot.reference,
      size: data['size'] as String,
      currentDateDriversRef: (data['currentDateDriversRef'] as List<dynamic>)
          .cast<DocumentReference>(),
    );
  }

  Future<void> updateLocation(GeoPoint lastLocation) async {
    await ref?.update({
      'lastLocation': lastLocation,
      'geoAddressArray': FieldValue.arrayUnion([lastLocation])
    });
  }
}
