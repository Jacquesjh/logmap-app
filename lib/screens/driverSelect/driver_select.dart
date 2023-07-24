import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/models/driver_model.dart';
import 'package:logmap/models/user_model.dart';
import 'package:logmap/providers/bottom_nav_bar_provider.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/providers/user_provider.dart';
import 'package:logmap/services/auth.dart';

class DriverSelectScreen extends ConsumerStatefulWidget {
  const DriverSelectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverSelectScreen> createState() => _DriverSelectScreenState();
}

class _DriverSelectScreenState extends ConsumerState<DriverSelectScreen> {
  Driver? selectedDriver;
  String? selectedDriverName;

  late Stream<QuerySnapshot> driversStream;

  Future<void> fetchUserModel(String? userUid) async {
    // Fetch the user data
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    final userModel = UserModel.fromSnapshot(userSnapshot);
    ref.read(userProvider.notifier).state = userModel;
  }

  @override
  void initState() {
    super.initState();

    final userUid = FirebaseAuth.instance.currentUser?.uid;

    // Fetch the user data
    fetchUserModel(userUid);

    // Fetch the drivers data
    driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('drivers')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Quem é você?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: driversStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error fetching drivers');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final drivers = snapshot.data?.docs ?? [];

                return DropdownButton<String>(
                  value: selectedDriverName,
                  onChanged: (String? driverName) {
                    final selectedDriverDoc = drivers.firstWhere(
                      (driverDoc) =>
                          Driver.fromSnapshot(driverDoc).name == driverName,
                    );

                    setState(() {
                      selectedDriverName = driverName;
                      selectedDriver = Driver.fromSnapshot(selectedDriverDoc);
                    });
                  },
                  items: drivers.map((driverDoc) {
                    final driver = Driver.fromSnapshot(driverDoc);

                    return DropdownMenuItem<String>(
                      value: driver.name,
                      child: Text(driver.name),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedDriver != null
                  ? () {
                      ref.read(selectedDriverProvider.notifier).state =
                          selectedDriver;

                      // Proceed to the next screen
                      Navigator.pushNamed(
                        context,
                        '/runs',
                      );
                    }
                  : null,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 1),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                ref.read(selectedIndexBottomNavBarProvider.notifier).state = 0;

                // ignore: use_build_context_synchronously
                Navigator.pushNamed(
                  context,
                  '/',
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.error),
              ),
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
