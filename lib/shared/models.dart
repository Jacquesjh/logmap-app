import 'package:cloud_firestore/cloud_firestore.dart';


class Driver {
  final String name;
  final DocumentReference ref;

  Driver(this.name, this.ref);

  factory Driver.fromSnapshot(QueryDocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    final ref = snapshot.reference;

    final name = data != null ? data['name'] as String? ?? '' : '';

    return Driver(name, ref);
  }
}
