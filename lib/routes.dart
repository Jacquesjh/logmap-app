import 'package:logmap/screens/deliveryRoute/delivery_route.dart';
import 'package:logmap/screens/home/home.dart';
import 'package:logmap/screens/deliveries/deliveries.dart';
import 'package:logmap/screens/driverSelect/driver_select.dart';
import 'package:logmap/screens/login/login.dart';
import 'package:logmap/screens/map/map.dart';
import 'package:logmap/screens/profile/profile.dart';
import 'package:logmap/screens/runs/runs.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const EmailPasswordLogin(),
  '/map': (context) => const MapScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/driverSelect': (context) => const DriverSelectScreen(),
  '/deliveries': (context) => const DeliveriesScreen(),
  '/runs': (context) => const RunsScreen(),
  '/deliveryRoute': (context) => const DeliveryRouteScreen(),
};
