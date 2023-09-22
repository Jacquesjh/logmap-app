import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/screens/deliveries/widgets/delivery_details_screen.dart';
import 'package:logmap/models/client_model.dart';
import 'package:logmap/models/delivery_model.dart';

class DeliveryRouteScreen extends ConsumerWidget {
  const DeliveryRouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DocumentReference> deliveriesRef =
        ref.read(selectedRunProvider.notifier).state!.deliveriesRef;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rota de Entrega'),
      ),
      body: ListView.builder(
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

              final delivery = Delivery.fromAsyncSnapshot(snapshot);

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
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pedido #${delivery.number}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                client.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${delivery.address}, ${delivery.addressNumber}',
                                style: const TextStyle(
                                    fontSize: 13),
                              ),
                              Text(
                                delivery.expectedDeliveryInterval,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
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
      ),
    );
  }
}
