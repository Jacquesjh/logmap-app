import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/providers/bottom_nav_bar_provider.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/shared/calculate_run_interval.dart';
import 'package:logmap/shared/get_current_date.dart';

class MyRuns extends ConsumerWidget {
  const MyRuns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('runs')
          .where('date', isEqualTo: "2023-06-08")
          // .where('date', isEqualTo: getCurrentDate())
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

        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = Run.fromSnapshot(runs[index]);

            return TextButton(
              onPressed: () {
                ref.read(selectedRunProvider.notifier).state = run;
                ref.read(selectedIndexBottomNavBarProvider.notifier).state = 2;
                Navigator.pushNamed(context, '/map');
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
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
                        run.status == "pending"
                            ? const Text('Não iniciado',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 242, 226, 8)))
                            : run.status == "progress"
                                ? const Text('Em andamento',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 8, 215, 242)))
                                : const Text('Completo',
                                    style: TextStyle(color: Color(0xFF08F26E))),
                        Text('Número de pedidos: ${run.deliveriesRef.length}',
                            style: const TextStyle(fontSize: 13)),
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
  }
}
