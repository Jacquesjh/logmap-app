import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/services/auth.dart';
import 'package:logmap/shared/models.dart';

class DriverSelectScreen extends ConsumerStatefulWidget {
  const DriverSelectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverSelectScreen> createState() => _DriverSelectScreenState();
}

class _DriverSelectScreenState extends ConsumerState<DriverSelectScreen> {
  Driver? selectedDriver;
  String? selectedDriverName;

  late Stream<QuerySnapshot> driversStream;

  @override
  void initState() {
    super.initState();

    final userUid = FirebaseAuth.instance.currentUser?.uid;

    driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('drivers')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        '/map',
                      );
                    }
                  : null,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 1),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();

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
