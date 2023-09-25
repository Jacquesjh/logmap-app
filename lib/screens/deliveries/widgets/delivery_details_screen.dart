import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:logmap/models/client_model.dart';
import 'package:logmap/providers/current_delivery_provider.dart';
import 'package:logmap/shared/widgets/bottom_nav.dart';

class DeliveryDetailsScreen extends ConsumerWidget {
  final Delivery delivery;
  final Client client;
  final String? routeScreen;

  const DeliveryDetailsScreen({
    Key? key,
    required this.delivery,
    required this.client,
    required this.routeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> deliveryChild = [];
    if(routeScreen == '/deliveryRoute'){
      deliveryChild.add(const SizedBox(width: 10.0));
      
      deliveryChild.add(
        delivery.isComplete
            ? const Icon(
                Icons.check_box_outlined,
                color: Color(0xFF08F26E),
                size: 50,
              )
            : TextButton(
                onPressed: () async {
                  final confirmed = await showConfirmationDialog(context);
                  if (confirmed) {
                    await delivery.updateIsComplete(true);
                    final currentDelivery =
                        ref.read(currentDeliveryProvider.notifier).state;

                    if (delivery.number == currentDelivery?.number) {
                      ref
                          .read(currentDeliveryIsCompletedProvider.notifier)
                          .state = true;
                    }
                  }
                },
                child: const Icon(
                  Icons.check_box_outline_blank,
                  color: Color(0xFF08F26E),
                  size: 50,
                ),
              ),
      );

      deliveryChild.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Entrega #${delivery.number}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );


    }else{
      deliveryChild.add(const SizedBox(width: 10.0));
      
      deliveryChild.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Entrega #${delivery.number}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }


    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      appBar: AppBar(
        title: const Text('Voltar aos Pedidos'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                //borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(5.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: deliveryChild,
                  ),
                  //const SizedBox(height: 5), 
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ListTile(
                      title: Text(
                        client.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${delivery.address}, ${delivery.addressNumber}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${delivery.city}, ${delivery.state}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            delivery.expectedDeliveryInterval,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),  
                ],
              ),
            ),
          ),
          const Divider(
            height: 4,
            color: Color(0xFF08F26E),
            thickness: 2,
            indent: 0,
            endIndent: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Items',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: delivery.items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = delivery.items[index];
                        return ListTile(
                          title: Text(
                            '${item.quantity} ${item.unit} de ${item.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmação'),
              content: const Text('Quer completar esse pedido?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }
}
