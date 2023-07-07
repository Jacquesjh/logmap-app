import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/shared/functions/calculate_run_interval.dart';
import 'package:logmap/shared/functions/get_current_date.dart';

class AllRuns extends ConsumerWidget {
  const AllRuns({Key? key}) : super(key: key);

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

        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = Run.fromSnapshot(runs[index]);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: run.driverRef == null
                          ? () async {
                              final selectedDriver = ref
                                  .read(selectedDriverProvider.notifier)
                                  .state;
                              if (selectedDriver != null) {
                                final confirmed =
                                    await showConfirmationDialog(context);
                                if (confirmed) {
                                  await run.updateDriver(selectedDriver.ref);
                                }
                              }
                            }
                          : null,
                      child: const Icon(Icons.add),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Corrida #${run.number}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      run.truckRef == null
                          ? const Text('Sem caminhão',
                              style: TextStyle(fontSize: 13))
                          : FutureBuilder<DocumentSnapshot>(
                              future: run.truckRef!.get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final truck =
                                      Truck.fromAsyncSnapshot(snapshot);
                                  return Text('Caminhão ${truck.name}',
                                      style: const TextStyle(fontSize: 13));
                                } else if (snapshot.hasError) {
                                  return const Text('Error');
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                      FutureBuilder<String>(
                        future: calculateRunInterval(run.deliveriesRef),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Error',
                                style: TextStyle(fontSize: 13));
                          } else if (snapshot.hasError) {
                            return const Text('Error',
                                style: TextStyle(fontSize: 13));
                          } else {
                            final runInterval = snapshot.data ?? '';
                            return Text(runInterval,
                                style: const TextStyle(fontSize: 13));
                          }
                        },
                      ),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      run.driverRef == null
                          ? const Text('Disponível',
                              style: TextStyle(color: Color(0xFF08F26E)))
                          : FutureBuilder<DocumentSnapshot>(
                              future: run.driverRef!.get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final driverData = snapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  final driverName =
                                      driverData?['name'] as String?;

                                  return Text('Motorista $driverName');
                                } else if (snapshot.hasError) {
                                  return const Text('Error');
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                      Text('Número de pedidos: ${run.deliveriesRef.length}',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmação'),
              content: const Text('Quer associar a corrida a você?'),
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
