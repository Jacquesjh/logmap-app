import 'package:cloud_firestore/cloud_firestore.dart';

class Run {
  final String date;
  final int number;
  final List<DocumentReference> deliveriesRef;
  final DocumentReference? driverRef;
  final List<Note> notes;
  final DocumentReference ref;
  final List<dynamic> route;
  final String status;
  final DocumentReference? truckRef;

  Run({
    required this.date,
    required this.number,
    required this.deliveriesRef,
    required this.driverRef,
    required this.notes,
    required this.ref,
    required this.route,
    required this.status,
    required this.truckRef,
  });

  factory Run.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Invalid data format");
    }

    return Run(
      date: data['date'] as String,
      number: data['number'] as int,
      deliveriesRef:
          (data['deliveriesRef'] as List<dynamic>).cast<DocumentReference>(),
      driverRef: data['driverRef'] as DocumentReference?,
      notes: (data['notes'] as List<dynamic>).map((noteData) {
        return Note(
          content: [noteData.toString()] // Convert dynamic to String
        );
      }).toList(),
      ref: snapshot.reference,
      route: (data['route'] as List<dynamic>)
          .map((ref) => ref is DocumentReference ? ref : ref.toString())
          .toList(),
      status: data['status'] as String,
      truckRef: data['truckRef'] as DocumentReference?,
    );
  }

  Future<void> updateDriver(DocumentReference driverRef) async {
    await ref.update({'driverRef': driverRef});
  }

  Future<void> updateStatus(String newStatus) async {
    await ref.update({"status": status});
  }
}

class Note {
  final List<String> content;

  Note({required this.content});
}
