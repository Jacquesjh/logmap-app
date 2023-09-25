import 'package:logmap/screens/deliveryRoute/delivery_route.dart';
import 'package:logmap/screens/home/home.dart';
import 'package:logmap/screens/deliveries/deliveries.dart';
import 'package:logmap/screens/driverSelect/driver_select.dart';
import 'package:logmap/screens/login/login.dart';
import 'package:logmap/screens/map/map.dart';
import 'package:logmap/screens/profile/profile.dart';
import 'package:logmap/screens/runs/runs.dart';
import 'package:flutter/material.dart';

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

String? currNavigatorScreen(BuildContext context){

  ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);

  if (currentRoute != null) {
    // You can access the current route's settings
    RouteSettings routeSettings = currentRoute.settings;

    // You can get the route name
    String? currentRouteName = routeSettings.name;

    return currentRouteName;
  }
  return null;
}
