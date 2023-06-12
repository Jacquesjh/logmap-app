import 'package:logmap/home/home.dart';
import 'package:logmap/login/login.dart';
import 'package:logmap/map/map.dart';
import 'package:logmap/profile/profile.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const EmailPasswordLogin(),
  '/map': (context) => const MapScreen(),
  '/profile': (context) => const ProfileScreen()
};
