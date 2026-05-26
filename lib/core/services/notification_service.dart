import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {

  static final FlutterLocalNotificationsPlugin
      notifications =
          FlutterLocalNotificationsPlugin();

  static Future<void>
    initialize()
  async {

    const android =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
        InitializationSettings(
      android: android,
    );

    await notifications
        .initialize(settings);

    await notifications

        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()

        ?.requestNotificationsPermission();
  }

  static Future<void>
      showNotification({

    required int id,

    required String title,

    required String body,
  }) async {

    const androidDetails =
      AndroidNotificationDetails(

        'finance_tracker_channel',

        'Finance Tracker',

        channelDescription:
            'Finance reminders and alerts',

        importance:
            Importance.max,

        priority:
            Priority.high,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(

      id,

      title,

      body,

      details,
    );
  }
}