import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      notifications =
          FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
        InitializationSettings(
      android: android,
    );

    await notifications.initialize(
      settings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final appName = AppConstants.appName;
    final androidDetails =
        AndroidNotificationDetails(
      'finance_tracker_channel',
      appName,
      channelDescription:
          'Finance reminders and alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details =
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