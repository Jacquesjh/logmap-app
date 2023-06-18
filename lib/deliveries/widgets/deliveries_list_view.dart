import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logmap/deliveries/widgets/delivery_details_screen.dart';
import 'package:logmap/models/client_model.dart';
import 'package:logmap/models/delivery_model.dart';

class DeliveriesListView extends StatelessWidget {
  final List<DocumentReference> deliveriesRef;

  const DeliveriesListView({
    Key? key,
    required this.deliveriesRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: deliveriesRef.length,
      itemBuilder: (context, index) {
        final deliveryRef = deliveriesRef[index];

        return FutureBuilder<DocumentSnapshot>(
          future: deliveryRef.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Error');
            }

            final delivery = Delivery.fromSnapshot(snapshot);
            final isComplete = delivery.isComplete;

            return FutureBuilder<DocumentSnapshot>(
              future: delivery.clientRef!.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Error');
                }

                final client = Client.fromSnapshot(snapshot);

                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailsScreen(
                          delivery: delivery,
                          client: client,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: SizedBox(
                          // width: 30,
                          child: isComplete
                              ? const Icon(
                                  Icons.check_box_outlined,
                                  color: Color(0xFF08F26E),
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.check_box_outline_blank,
                                  color: Color.fromARGB(255, 8, 215, 242),
                                  size: 30,
                                ),
                        ),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #${delivery.number}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              ' de ${client.name}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          delivery.expectedDeliveryInterval,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
