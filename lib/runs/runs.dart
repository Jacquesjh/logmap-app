import 'package:flutter/material.dart';
import 'package:logmap/runs/widgets/all_runs.dart';
import 'package:logmap/runs/widgets/my_runs.dart';
import 'package:logmap/shared/bottom_nav.dart';

class RunsScreen extends StatelessWidget {
  const RunsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
