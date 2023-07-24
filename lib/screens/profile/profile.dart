import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/services/auth.dart';
import 'package:logmap/shared/widgets/bottom_nav.dart';

import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/providers/bottom_nav_bar_provider.dart';
import 'package:logmap/providers/current_delivery_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
 
    void resetProviders() {
      //bottom_nav_bar_provider.dart
      ref.read(selectedIndexBottomNavBarProvider.notifier).state = 0;
      
      //current_delivery_provider.dart
      ref.read(currentDeliveryProvider.notifier).state = null;
      ref.read(currentDeliveryIsCompletedProvider.notifier).state = false;
      ref.read(allDeliveriesCompleteProvider.notifier).state = false;

      //driver_select_provider.dart
      ref.read(selectedDriverProvider.notifier).state = null;

      //selected_run_provider.dart
      ref.read(selectedRunProvider.notifier).state = null;

      //user_provider.dart
      ref.read(userProvider.notifier).state = null;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: const BottomNavBar(),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the back arrow
          title: const Text('Perfil do Motorista'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 100,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              Text(
                'Motorista ${ref.watch(selectedDriverProvider.notifier).state!.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await AuthService().signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                  resetProviders();
                },
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
