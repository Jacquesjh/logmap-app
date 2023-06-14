import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logmap/driverSelect/driver_select.dart';
import 'package:logmap/login/login.dart';
import 'package:logmap/services/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService()
          .authStateChanges, // Stream to monitor authentication state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While authentication state is being determined, show a loading indicator
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // If an error occurs, display an error message
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          // If user is authenticated, navigate to the MapScreen
          return const DriverSelectScreen();
        } else {
          // If user is not authenticated, display the login screen
          return const EmailPasswordLogin();
          // Alternatively, you can use named routes to navigate:
          // Navigator.pushNamed(context, '/login');
        }
      },
    );
  }
}
