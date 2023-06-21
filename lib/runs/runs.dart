import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/runs/widgets/all_runs.dart';
import 'package:logmap/runs/widgets/my_runs.dart';
import 'package:logmap/services/tracking_service.dart';
import 'package:logmap/shared/botto_nav.dart';

class RunsScreen extends ConsumerWidget {
  const RunsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(selectedRunProvider.notifier).state = null;

    // final trackingService = TrackingService(ref);

    // Start the tracking service when the widget is built
    // trackingService.startTrackingService();

    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          bottomNavigationBar: const BottomNavBar(),
          appBar: AppBar(
            title: const Text(
              'Corridas',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false, // Disable the back arrow
            bottom: const TabBar(
              unselectedLabelColor: Colors.white,
              labelColor: Color(0xFF08F26E),
              indicatorColor: Color(0xFF08F26E),
              tabs: [
                Tab(text: 'Todas'),
                Tab(text: 'Minhas'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // Widget for the 'Todas' tab
              AllRuns(),

              // Widget for the 'Minhas' tab
              MyRuns(),
            ],
          ),
        ),
      ),
    );
  }
}
