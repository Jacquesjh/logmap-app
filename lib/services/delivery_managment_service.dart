import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/providers/current_delivery_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';

class DeliveryManagmentService {
  final WidgetRef ref;

  DeliveryManagmentService(this.ref);

  Future<void> findCurrentDelivery() async {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    if (selectedRun != null) {
      for (final deliveryRef in selectedRun.deliveriesRef) {
        final deliverySnapshot = await deliveryRef.get();
        final delivery = Delivery.fromSnapshot(deliverySnapshot);

        if (delivery.isComplete == false) {
          ref.read(currentDeliveryProvider.notifier).state = delivery;
          ref.read(currentDeliveryIsCompletedProvider.notifier).state = false;
          ref.read(allDeliveriesCompleteProvider.notifier).state = false;

          return;
        }
      }
    }

    ref.read(currentDeliveryProvider.notifier).state = null;
    ref.read(currentDeliveryIsCompletedProvider.notifier).state = false;
    ref.read(allDeliveriesCompleteProvider.notifier).state = true;
    return;
  }

  void manageDeliveries() {
    ref.listen<Run?>(selectedRunProvider, (previous, next) {
      findCurrentDelivery();
    });

    ref.listen<bool>(currentDeliveryIsCompletedProvider, (previous, next) {
      // This means that the current delivery, in the currentDeliveryProvide
      // was complete, so it's time to find the next currentDelivery
      if (previous == false && next == true) {
        findCurrentDelivery();
      }
    });
  }
}



//   void manageDeliveries() {
//     // If the selectedRunProvider change, check for the new current delivery
//     ref.listen<Run?>(
//       selectedRunProvider,
//       (previous, next) {
//         print("The selected Run changed!");
//         findCurrentDelivery();

//         // If the current delivery changes it's status to "isComplete=true", then find the new
//         // current delviery
//         ref.listen<Delivery?>(
//           currentDeliveryProvider,
//           (previous, next) {
//             // Create a stream to monitor the values of the properties of the current Delivery object
//             final stream = Stream.value(currentDeliveryProvider);

//             stream.listen((event) {
//               print('Something change about the delivery');
//               if (previous?.isComplete == false && next?.isComplete == true) {
//                 print(
//                     'Delivery #${ref.read(currentDeliveryProvider.notifier).state?.number} was completed!');
//                 findCurrentDelivery();
//               }
//             });
//           },
//         );
//       },
//     );
//   }
// }
