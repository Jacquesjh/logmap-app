import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final DocumentReference? currentTruckRef;
  final String name;
  final DocumentReference ref;

  Driver({
    required this.currentTruckRef,
    required this.name,
    required this.ref,
  });

  factory Driver.fromSnapshot(QueryDocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    final ref = snapshot.reference;

    if (data == null) {
      throw Exception("Invalid data format");
    }

    final name = data['name'] as String;
    final currentTruckRef = data['currentTruckRef'] as DocumentReference?;

    return Driver(currentTruckRef: currentTruckRef, name: name, ref: ref);
  }
}
