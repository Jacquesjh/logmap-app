import 'package:flutter/material.dart';
import 'package:logmap/services/auth.dart';
import 'package:logmap/shared/botto_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:BottomNavBar(),
      backgroundColor: Colors.greenAccent.shade700,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ElevatedButton(
        onPressed: () async {
          await AuthService().signOut();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
        child: const Text('signout'),
      ),
    );
  }
}