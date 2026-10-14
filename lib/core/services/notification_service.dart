import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart'
    as tz;
import 'package:timezone/timezone.dart'
    as tz;

class NotificationService {

  static String? _pendingPayload;

  static final FlutterLocalNotificationsPlugin
      notifications =
          FlutterLocalNotificationsPlugin();

          
  static String? takePendingPayload() {
    final payload =
        _pendingPayload;

    _pendingPayload =
        null;

    return payload;
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final localTimezone =
        await FlutterTimezone
            .getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(
        localTimezone.identifier,
      ),
    );


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
      onDidReceiveNotificationResponse:
          (response) {
        final payload =
            response.payload;

        if (payload == null ||
            payload.trim().isEmpty) {
          return;
        }

        _pendingPayload =
            payload.trim();

        _pendingPayloadHandler
            ?.call();
      },
    );

    final launchDetails =
        await notifications
            .getNotificationAppLaunchDetails();

    final launchedFromNotification =
        launchDetails
                ?.didNotificationLaunchApp ??
            false;

    final launchPayload =
        launchDetails
            ?.notificationResponse
            ?.payload;

    if (launchedFromNotification &&
        launchPayload != null &&
        launchPayload.trim().isNotEmpty) {
      _pendingPayload =
          launchPayload.trim();
    }

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
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
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    final localDate =
        scheduledAt.toLocal();

    final scheduledDate =
        tz.TZDateTime(
      tz.local,
      localDate.year,
      localDate.month,
      localDate.day,
      localDate.hour,
      localDate.minute,
      localDate.second,
    );

    final now =
        tz.TZDateTime.now(
      tz.local,
    );

    if (!scheduledDate.isAfter(now)) {
      return;
    }

    final appName =
        AppConstants.appName;

    final androidDetails =
        AndroidNotificationDetails(
      'finance_tracker_channel',
      appName,
      channelDescription:
          'Finance reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelNotification({
    required int id,
  }) async {
    await notifications.cancel(
      id,
    );
  }

  static Future<
      List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return notifications
        .pendingNotificationRequests();
  }

  static void Function()? _pendingPayloadHandler;

  static void setPendingPayloadHandler(
    void Function()? handler,
  ) {
    _pendingPayloadHandler =
        handler;
  }

}