import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/routes.dart';
import 'package:logmap/screens/deliveries/widgets/delivery_details_screen.dart';
import 'package:logmap/models/client_model.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:logmap/shared/functions/get_current_date.dart';
import 'package:logmap/shared/widgets/bottom_nav.dart';

List<int> completedRunNumbers = [];

class DeliveryRouteScreen extends ConsumerWidget {
  const DeliveryRouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('runs')
          .where('date', isEqualTo: getCurrentDate())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final runs = snapshot.data?.docs ?? [];

        completedRunNumbers.clear();

        final runIndex = ref.read(selectedRunProvider.notifier).state!.number - 1;
        final run = Run.fromSnapshot(runs[runIndex]);
        List<dynamic> deliveriesRef = run.route;
        
        final curScreen = currNavigatorScreen(context);
        
        return Scaffold(
          bottomNavigationBar: const BottomNavBar(),
          appBar: AppBar(
            title: const Text('Rota de Entrega'),
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
                                routeScreen: curScreen,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: SizedBox(
                                child: isComplete
                                    ? const Icon(
                                        Icons.check_box_outlined,
                                        color: Color(0xFF08F26E),
                                        size: 30,
                                      )
                                    : const Icon(
                                        Icons.check_box_outline_blank,
                                        color: Color(0xFF08F26E),
                                        size: 30,
                                      ),
                              ),                                                          
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pedido #${delivery.number}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF08F26E),                                      
                                    ),
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
                                      '${delivery.city}, ${delivery.state}',
                                      style: const TextStyle(fontSize: 13),
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
    );
  }
}
