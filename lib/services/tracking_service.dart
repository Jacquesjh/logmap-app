import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:logmap/providers/selected_run_provider.dart';

class TrackingService {
  final WidgetRef ref;
  late Timer timer;

  TrackingService(this.ref) {
    start();
  }

  Future<void> start() async {
    final selectedRun = ref.watch(selectedRunProvider.notifier).state;

    if (selectedRun != null &&
        selectedRun.status == "progress" &&
        selectedRun.truckRef != null) {
      await checkPossibleTracking();

      final location = Location();

      location.enableBackgroundMode(enable: true);

      final locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        final GeoPoint location =
            GeoPoint(currentLocation.latitude!, currentLocation.longitude!);

        print('Last location: $location');

        // selectedRun.truckRef!.update({
        //   'lastLocation': location,
        //   'geoAddressArray': FieldValue.arrayUnion([location])
        // });
      });

      // Stop tracking when selectedRun changes
      locationSubscription.cancel();
    }
  }

  Future<void> checkPossibleTracking() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location service is not enabled');
      }
    }

    final permissionGranted = await location.hasPermission();
    if (permissionGranted != PermissionStatus.granted) {
      final newPermissionGranted = await location.requestPermission();
      if (newPermissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }
  }

  void startTrackingService() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      start();
    });
  }

  void stopTrackingService() {
    timer.cancel();
  }
}
