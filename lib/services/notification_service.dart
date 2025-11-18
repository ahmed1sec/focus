import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      // Use local timezone - the system will handle timezone conversion
      // For scheduled notifications, we'll use the device's local timezone

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {},
      );

      if (initialized != true) {
        print('Notification plugin initialization failed');
        return;
      }

      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'daily_motivation_channel',
        'Daily Motivation',
        description: 'Daily motivational notifications',
        importance: Importance.high,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Schedule daily notification
      await scheduleDailyNotification();
    } catch (e) {
      // Handle plugin not found or initialization errors gracefully
      print('Error initializing notifications: $e');
      print('Note: Make sure to rebuild the app completely (not just hot reload) after adding the plugin');
    }
  }

  static Future<void> scheduleDailyNotification() async {
    // Cancel any existing daily notification
    await _notifications.cancel(1);

    // Schedule daily notification at 9:00 AM
    await _notifications.zonedSchedule(
      1,
      'Good morning 👋',
      'Good morning 👋, let\'s start your day with productivity and good habits. ⬆️💯',
      _nextInstanceOf9AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_motivation_channel',
          'Daily Motivation',
          channelDescription: 'Daily motivational notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOf9AM() {
    // Get current local time
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    // If 9 AM has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Convert to TZDateTime - using local timezone
    // The timezone package will use the system's local timezone
    try {
      return tz.TZDateTime.from(scheduledDate, tz.local);
    } catch (e) {
      // Fallback: create TZDateTime in UTC and let the system adjust
      return tz.TZDateTime.from(scheduledDate, tz.UTC);
    }
  }

  static Future<void> cancelDailyNotification() async {
    await _notifications.cancel(1);
  }

}

