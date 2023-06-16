import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final Map<String, List<DocumentReference>> deliveriesRef;
  final String name;
  final DocumentReference ref;

  Client({
    required this.deliveriesRef,
    required this.name,
    required this.ref,
  });

  factory Client.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Invalid data format");
    }

    final deliveriesRef = (data['deliveriesRef'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).cast<DocumentReference>(),
            ));

    return Client(
      deliveriesRef: deliveriesRef,
      name: data['name'] as String,
      ref: snapshot.reference,
    );
  }
}
