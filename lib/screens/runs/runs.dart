import 'package:flutter/material.dart';
import 'package:logmap/screens/runs/widgets/all_runs.dart';
import 'package:logmap/shared/widgets/bottom_nav.dart';

class RunsScreen extends StatelessWidget {
  const RunsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,// Number of tabs
        child: Scaffold(
          bottomNavigationBar: const BottomNavBar(),
          appBar: AppBar(
            title: const Text(
              'Corridas',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false, // Disable the back arrow
          ),
          body: const AllRuns(),
        ),
    );
  }
}
