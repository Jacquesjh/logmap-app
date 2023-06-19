import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logmap/models/delivery_model.dart';

// class GeoAddress {
//   final double latitude;
//   final double longitude;

//   GeoAddress({
//     required this.latitude,
//     required this.longitude,
//   });

//   factory GeoAddress.fromSnapshot(Map<String, dynamic> lastLocationMap) {
//     return GeoAddress(
//       latitude: lastLocationMap['latitude'] as double,
//       longitude: lastLocationMap['longitude'] as double,
//     );
//   }
// }

class UserModel {
  final String address;
  final String addressNumber;
  final String city;
  final String displayName;
  final GeoAddress geoAddress;
  final String state;
  final DocumentReference ref;

  UserModel({
    required this.address,
    required this.addressNumber,
    required this.city,
    required this.displayName,
    required this.geoAddress,
    required this.state,
    required this.ref,
  });

  factory UserModel.fromSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {
    final data = snapshot.data!.data() as Map<String, dynamic>?;
    final ref = snapshot.data!.reference;

    if (data == null) {
      throw Exception("Invalid data format");
    }

    final address = data['address'] as String;
    final addressNumber = data['addressNumber'] as String;
    final city = data['city'] as String;
    final displayName = data['displayName'] as String;
    final state = data['state'] as String;
    final geoAddress = GeoAddress(
        latitude: data['geoAddress'].latitude,
        longitude: data['geoAddress'].longitude);

    return UserModel(
        address: address,
        addressNumber: addressNumber,
        city: city,
        displayName: displayName,
        geoAddress: geoAddress,
        state: state,
        ref: ref);
  }
}
