import 'package:logmap/deliveries/deliveries.dart';
import 'package:logmap/driverSelect/driver_select.dart';
import 'package:logmap/home/home.dart';
import 'package:logmap/login/login.dart';
import 'package:logmap/map/map.dart';
import 'package:logmap/profile/profile.dart';
import 'package:logmap/runs/runs.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const EmailPasswordLogin(),
  '/map': (context) => MapScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/driverSelect': (context) => const DriverSelectScreen(),
  '/deliveries': (context) => const DeliveriesScreen(),
  '/runs': (context) => const RunsScreen(),
};
