import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for notification time
final notificationTimeProvider = StateProvider<TimeOfDay>((ref) {
  return const TimeOfDay(hour: 9, minute: 0);
});

// Provider for notification enabled state
final notificationEnabledProvider = StateProvider<bool>((ref) {
  return true;
});

// Callback for handling notification tap
typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static NotificationTapCallback? _onNotificationTap;
  static bool _launchedFromNotification = false;
  static String? _launchPayload;

  // Check if app was launched from notification
  static bool get launchedFromNotification => _launchedFromNotification;
  static String? get launchPayload => _launchPayload;

  // Clear launch flag after handling
  static void clearLaunchFlag() {
    _launchedFromNotification = false;
    _launchPayload = null;
  }

  // Set callback for notification tap
  static void setNotificationTapCallback(NotificationTapCallback callback) {
    _onNotificationTap = callback;
  }

  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap when app is running
        _onNotificationTap?.call(response.payload);
      },
    );

    // Check if app was launched from notification (cold start)
    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      _launchedFromNotification = true;
      _launchPayload = launchDetails.notificationResponse?.payload;
    }

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission for Android 13+
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }

      // Request exact alarm permission for Android 12+
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  // Schedule daily notification at specified time
  Future<void> scheduleDailyNotification({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    // Calculate next notification time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Savings Reminder',
      channelDescription: 'Daily reminder to save money',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'pig_overlay',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Postpone daily notification to tomorrow (called when user has fed today)
  Future<void> postponeNotificationToTomorrow({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    // Cancel today's notification
    await cancelAllNotifications();

    // Schedule for tomorrow at the same time
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(const Duration(days: 1));

    final tzScheduledDate = tz.TZDateTime.from(tomorrow, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Savings Reminder',
      channelDescription: 'Daily reminder to save money',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Continue daily after tomorrow
      payload: 'pig_overlay',
    );
  }

  // Show immediate notification (for testing)
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'For testing notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      title,
      body,
      notificationDetails,
      payload: 'pig_overlay',
    );
  }
}
