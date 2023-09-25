import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/screens/deliveries/widgets/deliveries_list_view.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/screens/runs/widgets/assigned_runs.dart';
import 'package:logmap/screens/runs/widgets/my_runs.dart';
import 'package:logmap/shared/widgets/bottom_nav.dart';

class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: const BottomNavBar(),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the back arrow
          title: const Text(
            'Entregas',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: selectedRun != null
            ? const AssignedRuns()
            : const Center(
                child: Text(
                  'Selecione uma corrida',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}
