import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/sunset_calculator.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
    
    _initialized = true;
    debugPrint('NotificationService initialized successfully.');
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await requestPermissions();
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Time to Read',
      body: 'Take a moment to read and reflect today.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Reminders for daily reading',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint("NotificationService: scheduled daily reminder at $hour:$minute");
  }

  Future<void> scheduleWeeklyReminder(int weekday, int hour, int minute) async {
    await requestPermissions();
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Adjust to the desired weekday
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // If it's today but the time has passed, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Weekly Study Time',
      body: 'It\'s your scheduled time for study and reflection.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminder_channel',
          'Weekly Reminders',
          channelDescription: 'Custom weekly study reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    debugPrint("NotificationService: scheduled weekly reminder on weekday $weekday at $hour:$minute");
  }

  Future<void> scheduleSabbathReminder(double lat, double lng) async {
    await requestPermissions();
    
    final now = DateTime.now();
    // Start checking from this Friday (or today if it's Friday)
    DateTime friday = SunsetCalculator.getNextDayOfWeek(now, DateTime.friday);
    
    // Calculate sunset for that Friday
    DateTime? sunset = SunsetCalculator.getSunset(lat, lng, friday);
    
    // If no sunset (extreme latitudes), default to 6:00 PM
    sunset ??= DateTime(friday.year, friday.month, friday.day, 18, 0);
    
    if (sunset.isBefore(now)) {
      // If sunset already passed today, schedule for next Friday
      friday = friday.add(const Duration(days: 7));
      sunset = SunsetCalculator.getSunset(lat, lng, friday) ?? 
               DateTime(friday.year, friday.month, friday.day, 18, 0);
    }

    for (int i = 0; i < 4; i++) {
      DateTime targetFriday = friday.add(Duration(days: 7 * i));
      DateTime? targetSunset = SunsetCalculator.getSunset(lat, lng, targetFriday) ?? 
                               DateTime(targetFriday.year, targetFriday.month, targetFriday.day, 18, 0);
      
      final tz.TZDateTime tDate = tz.TZDateTime.from(targetSunset, tz.local);
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 10 + i,
        title: 'The Sabbath is Approaching',
        body: 'Welcome the day of rest.',
        scheduledDate: tDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sabbath_reminder_channel',
            'Sabbath Reminders',
            channelDescription: 'Weekly sunset reminders for Sabbath',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
    debugPrint("NotificationService: scheduled next 4 Sabbath reminders starting at ${sunset.toLocal()}");
  }

  Future<void> cancelDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(id: 0);
    debugPrint('NotificationService: cancelled daily reminder');
  }

  Future<void> cancelWeeklyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(id: 1);
    debugPrint('NotificationService: cancelled weekly reminder');
  }

  Future<void> cancelSabbathReminders() async {
    for (int i = 0; i < 4; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: 10 + i);
    }
    debugPrint('NotificationService: cancelled Sabbath reminders');
  }

  // Legacy support for previous Mock
  Future<void> cancelReminder() async {
    await cancelDailyReminder();
  }
}
