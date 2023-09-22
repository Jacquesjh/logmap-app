import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/shared/functions/calculate_run_interval.dart';
import 'package:logmap/shared/functions/get_current_date.dart';

import '../../../providers/bottom_nav_bar_provider.dart';
import '../../../providers/current_delivery_provider.dart';
import '../../../providers/driver_select_provider.dart';
import '../../../providers/selected_run_provider.dart';

List<int> completedRunNumbers = [];

class MyRuns extends ConsumerWidget {
  const MyRuns({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('runs')
          .where('date', isEqualTo: getCurrentDate())
          .where('driverRef',
              isEqualTo: ref.read(selectedDriverProvider.notifier).state?.ref)
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

        for (final runDoc in runs) {
          final run = Run.fromSnapshot(runDoc);
          completedRunsProviderUpdate(run, ref);
        }

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
                      onPressed: run.status != "completed"
                          ? () async {
                              ref.read(selectedRunProvider.notifier).state =
                                  run;
                              ref.read(currentDeliveryProvider.notifier).state =
                                  null;
                              ref
                                  .read(selectedIndexBottomNavBarProvider
                                      .notifier)
                                  .state = 2;
                              Navigator.pushNamed(context, '/map');
                            }
                          : null,
                      child: myRunsIconState(context, run.status),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Corrida #${run.number}',
                        style: TextStyle(
                            color: run.status == "completed"
                                ? Colors.white38
                                : Colors.white),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      run.truckRef == null
                          ? Text(
                              'Sem veículo',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: run.status == "completed"
                                      ? Colors.white38
                                      : Colors.white),
                            )
                          : FutureBuilder<DocumentSnapshot>(
                              future: run.truckRef!.get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final truck =
                                      Truck.fromAsyncSnapshot(snapshot);
                                  return Text(
                                    truck.name,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: run.status == "completed"
                                            ? Colors.white38
                                            : Colors.white),
                                  );
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
                            return Text(
                              runInterval,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: run.status == "completed"
                                      ? Colors.white38
                                      : Colors.white),
                            );
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
                      run.status == "pending"
                          ? const Text('Não iniciado',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 242, 226, 8)))
                          : run.status == "progress"
                              ? const Text('Em andamento',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 8, 215, 242)))
                              : const Text('Completo',
                                  style: TextStyle(color: Colors.white38)),
                      Text('Número de \npedidos: ${run.deliveriesRef.length}',
                          style: TextStyle(
                              fontSize: 13,
                              color: run.status == "completed"
                                  ? Colors.white38
                                  : Colors.white70)),
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

  Icon myRunsIconState(BuildContext context, String runState) {
    Icon myRunIcon;
    switch (runState) {
      case "pending":
        myRunIcon = const Icon(Icons.play_arrow_outlined);
        break;
      case "progress":
        myRunIcon = const Icon(Icons.play_arrow);
        break;
      case "completed":
        myRunIcon = const Icon(Icons.done, color: Colors.white38);
        break;
      default:
        myRunIcon = const Icon(Icons.minimize);
    }
    return myRunIcon;
  }

  void completedRunsProviderUpdate(Run run, WidgetRef ref) async {
    if (run.status == "completed" &&
        !completedRunNumbers.contains(run.number)) {
      completedRunNumbers.add(run.number);
    }
    ref.read(completedRunsProvider.notifier).state = completedRunNumbers;
  }
}
