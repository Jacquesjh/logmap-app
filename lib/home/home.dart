import 'package:flutter/material.dart';
import 'package:logmap/login/login.dart';
import 'package:logmap/map/map.dart';
import 'package:logmap/profile/profile.dart';
import 'package:logmap/services/auth.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('error'),
          );
        } else if (snapshot.hasData) {
          return const MapScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}