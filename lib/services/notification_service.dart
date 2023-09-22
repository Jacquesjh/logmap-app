import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/providers/current_delivery_provider.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/shared/ref.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'notifications_channel',
          channelKey: 'notifications_channel',
          channelName: 'Notificações LogMap',
          channelDescription: 'Notificações do app LogMap',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
          enableVibration: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'notifications_channel',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  // Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  // Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  // Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');

    final payload = receivedAction.payload ?? {};

    if (receivedAction.buttonKeyPressed == "sim") {
      Ref ref = refHolder.ref;

      if (payload["finish"] == "run") {

        // Set the run status to complete, Set the truck driverRef to null
        // And set the driver currentTruckRef to null
        final driver = ref.read(selectedDriverProvider);
        final run = ref.read(selectedRunProvider.notifier).state;
        final truckRef = run?.truckRef;

        await run?.ref.update({'status': 'completed'});
        await driver?.ref.update({'currentTruckRef': null});
        await truckRef?.update({'driverRef': null});
        ref.read(runPlayMapButtonProvider.notifier).state.remove(run?.number);
      }

      if (payload["finish"] == "currentDelivery") {

        final currentDelivery =
            ref.read(currentDeliveryProvider.notifier).state;

        await currentDelivery?.ref?.update({'isComplete': true});

        ref.read(currentDeliveryIsCompletedProvider.notifier).state = true;
      }
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final int id = -1,
    final bool scheduled = false,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'notifications_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        wakeUpScreen: true,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
