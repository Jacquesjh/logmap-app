import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:logmap/providers/selected_run_provider.dart';

class DeliveryRoute extends ConsumerWidget {
  const DeliveryRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesRefStream = Stream.value(['Ref1', 'Ref2', 'Ref3']); // Replace with your actual stream
    //var curRun = ref.read(selectedRunProvider.notifier).state;

    
    return Scaffold(
      appBar: AppBar(
        title: Text('Rota de Entrega'),
      ),
      body: StreamBuilder<List<String>>(
        stream: deliveriesRefStream, // Replace with your actual stream
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching deliveries'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final deliveryReferences = snapshot.data ?? [];

          return ListView.builder(
            itemCount: deliveryReferences.length,
            itemBuilder: (context, index) {
              final deliveryRef = deliveryReferences[index];
              return Card(
                child: ListTile(
                  title: Text('Delivery Reference: $deliveryRef'),
                  // Add more information here if needed
                ),
              );
            },
          );
        },
      ),
    );
  }
}