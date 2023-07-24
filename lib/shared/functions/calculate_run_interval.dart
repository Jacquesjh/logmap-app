import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> calculateRunInterval(
    List<DocumentReference> deliveriesRef) async {
  if (deliveriesRef.isEmpty) {
    return '';
  }

  String? startTime;
  String? endTime;

  for (final deliveryRef in deliveriesRef) {
    final snapshot = await deliveryRef.get();
    final deliveryData = snapshot.data() as Map<String, dynamic>?;
    if (deliveryData != null) {
      final interval = deliveryData['expectedDeliveryInterval'] as String;
      final parts = interval.split('-');
      if (parts.length == 2) {
        final deliveryStartTime = parts[0];
        final deliveryEndTime = parts[1];

        if (startTime == null || deliveryStartTime.compareTo(startTime) < 0) {
          startTime = deliveryStartTime;
        }

        if (endTime == null || deliveryEndTime.compareTo(endTime) > 0) {
          endTime = deliveryEndTime;
        }
      }
    }
  }

  return startTime != null && endTime != null ? '$startTime-$endTime' : '';
}
