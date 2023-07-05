import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logmap/providers/current_delivery_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/providers/user_provider.dart';
import 'package:logmap/services/notification_service.dart';

class TrackingService {
  // The service will start tracking the location of the device when the
  // Runs Screen builds. It will only be useful in a certain condition however
  final WidgetRef ref;

  TrackingService(this.ref);

  late LocationSettings locationSettings;

  void getLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      );
    }
  }

  Future<void> startTracking() async {
    getLocationSettings();

    final locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      final newPermission = await Geolocator.requestPermission();
      if (newPermission != LocationPermission.whileInUse &&
          newPermission != LocationPermission.always) {
        throw Exception('Location permission not granted');
      }
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is not enabled');
    }

    Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best, distanceFilter: 5))
        .listen((Position currentPosition) {
      processLocation(currentPosition);
    });
  }

  void processLocation(Position currentPosition) {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;
    final currentDelivery = ref.read(currentDeliveryProvider.notifier).state;

    if (selectedRun != null &&
        selectedRun.truckRef != null &&
        selectedRun.status == "progress") {
      final geopoint =
          GeoPoint(currentPosition.latitude, currentPosition.longitude);

      selectedRun.truckRef!.update({
        'lastLocation': geopoint,
        'geoAddressArray': FieldValue.arrayUnion([geopoint])
      });

      if (currentDelivery != null) {
        // The truck is going to a make a delivery
        checkMadeDelivery(currentPosition);
      }

      if (ref.read(allDeliveriesCompleteProvider.notifier).state == true) {
        // The truck has no more deliveries to make and it's on it's way back
        checkBackToStore(currentPosition);
      }
    }
  }

  Future<void> checkBackToStore(Position currentPosition) async {
    final user = ref.read(userProvider.notifier).state;

    if (user != null) {
      final distanceToStore = Geolocator.distanceBetween(
          user.geoAddress.latitude,
          user.geoAddress.longitude,
          currentPosition.latitude,
          currentPosition.longitude);

      if (distanceToStore < 60) {
        await NotificationService.showNotification(
          title: "Você encerrou a corrida?",
          body: "Você encerrou a corrida?",
          id: 0,
          summary: "Você encerrou a corrida?",
          payload: {"finish": "run"},
          notificationLayout: NotificationLayout.Default,
          actionType: ActionType.Default,
          actionButtons: [
            NotificationActionButton(
              label: 'Sim',
              enabled: true,
              key: 'sim',
              color: Colors.green[400],
            ),
            NotificationActionButton(
              label: 'Não',
              enabled: true,
              key: 'não',
              color: Colors.red[400],
            )
          ],
        );
      }
    }
  }

  Future<void> checkMadeDelivery(Position currentPosition) async {
    final currentDelivery = ref.read(currentDeliveryProvider.notifier).state;

    if (currentDelivery != null) {
      final distanceToCurrentDelivery = Geolocator.distanceBetween(
          currentDelivery.geoAddress.latitude,
          currentDelivery.geoAddress.longitude,
          currentPosition.latitude,
          currentPosition.longitude);

      if (distanceToCurrentDelivery < 60) {
        await NotificationService.showNotification(
          title: 'Você completou a entrega #${currentDelivery.number}?',
          body: "Você completou a entrega #${currentDelivery.number}?",
          id: currentDelivery.number,
          summary: "Você completou a entrega #${currentDelivery.number}?",
          payload: {"finish": "currentDelivery"},
          notificationLayout: NotificationLayout.Default,
          actionType: ActionType.Default,
          actionButtons: [
            NotificationActionButton(
              label: 'Sim',
              enabled: true,
              key: 'sim',
              color: Colors.green[400],
            ),
            NotificationActionButton(
              label: 'Não',
              enabled: true,
              key: 'não',
              color: Colors.red[400],
            )
          ],
        );
      }
    }
  }
}
