import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../l10n/l10n.dart';
import '../state/locale_provider.dart';
import '../utils/sunset_calculator.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
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
  }

  /// Strings in the app's saved interface language. Notifications are
  /// scheduled ahead of time, so callers re-schedule when it changes
  /// (see [AppLocaleNotifier.setLanguage]).
  Future<AppLocalizations> _strings() async {
    String? code;
    try {
      code = (await SharedPreferences.getInstance())
          .getString(AppLocaleNotifier.key);
    } catch (_) {}
    return l10nFor(code);
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyReminder(int hour, int minute,
      {bool askPermission = true}) async {
    if (askPermission) await requestPermissions();
    final l10n = await _strings();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: l10n.notifDailyTitle,
      body: l10n.notifDailyBody,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          l10n.notifDailyChannel,
          channelDescription: l10n.notifDailyChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> schedulePrayerReminder(int hour, int minute,
      {bool askPermission = true}) async {
    if (askPermission) await requestPermissions();
    final l10n = await _strings();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 2,
      title: l10n.notifPrayerTitle,
      body: l10n.notifPrayerBody,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          "prayer_reminder_channel",
          l10n.notifPrayerChannel,
          channelDescription: l10n.notifPrayerChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklyReminder(int weekday, int hour, int minute,
      {bool askPermission = true}) async {
    if (askPermission) await requestPermissions();
    final l10n = await _strings();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

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
      title: l10n.notifWeeklyTitle,
      body: l10n.notifWeeklyBody,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminder_channel',
          l10n.notifWeeklyChannel,
          channelDescription: l10n.notifWeeklyChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleSabbathReminder(double lat, double lng,
      {bool askPermission = true}) async {
    if (askPermission) await requestPermissions();
    final l10n = await _strings();

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
      final DateTime targetFriday = friday.add(Duration(days: 7 * i));
      final DateTime targetSunset = SunsetCalculator.getSunset(
              lat, lng, targetFriday) ??
          DateTime(
              targetFriday.year, targetFriday.month, targetFriday.day, 18, 0);

      final tz.TZDateTime tDate = tz.TZDateTime.from(targetSunset, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 10 + i,
        title: l10n.notifSabbathTitle,
        body: l10n.notifSabbathBody,
        scheduledDate: tDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'sabbath_reminder_channel',
            l10n.notifSabbathChannel,
            channelDescription: l10n.notifSabbathChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(id: 0);
  }

  Future<void> cancelPrayerReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(id: 2);
  }

  Future<void> cancelWeeklyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(id: 1);
  }

  Future<void> cancelSabbathReminders() async {
    for (int i = 0; i < 4; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: 10 + i);
    }
  }

  // Legacy support for previous Mock
  Future<void> cancelReminder() async {
    await cancelDailyReminder();
  }

  /// Per-plan reading reminder.
  ///
  /// IDs are derived from [planId] so concurrent plans never overwrite each
  /// other (the old shared 100-107 range meant only the last-synced plan
  /// notified; those legacy IDs are cancelled once on every sync).
  /// [restDay] uses the app convention (1=Sunday..7=Saturday) and is
  /// converted to the plugin's Dart-weekday convention before scheduling —
  /// comparing them directly skipped the wrong day.
  Future<void> syncReadingPlanReminder(
      bool enabled, int hour, int minute, int? restDay,
      {Set<int>? restDays, String? planId, bool askPermission = true}) async {
    // One-time cleanup of the legacy shared range.
    for (int i = 100; i <= 107; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: i);
    }

    // Stable per-plan base: daily uses base, weekly uses base+dartWeekday.
    final base = 1000 + ((planId ?? 'default').hashCode.abs() % 20000);
    for (int i = 0; i <= 7; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: base + i);
    }

    if (!enabled) return;
    if (askPermission) await requestPermissions();
    final l10n = await _strings();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
          'reading_plan_channel', l10n.notifPlanChannel,
          channelDescription: l10n.notifPlanChannelDesc,
          importance: Importance.high,
          priority: Priority.high),
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // App weekday (Sun=1..Sat=7) -> Dart weekday (Mon=1..Sun=7).
    // The rest-day set wins when non-empty; otherwise the legacy single day.
    final restDartDays = <int>{};
    if (restDays != null && restDays.isNotEmpty) {
      for (final d in restDays) {
        if (d >= 1 && d <= 7) restDartDays.add(((d + 5) % 7) + 1);
      }
    } else if (restDay != null && restDay != -1) {
      restDartDays.add(((restDay + 5) % 7) + 1);
    }

    if (restDartDays.isEmpty) {
      // Schedule daily reminder
      tz.TZDateTime scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: base,
        title: l10n.notifDailyTitle,
        body: l10n.notifPlanBody,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      // Schedule weekly reminders for the non-rest days (Dart weekdays).
      for (int i = 1; i <= 7; i++) {
        if (restDartDays.contains(i)) continue;
        tz.TZDateTime scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
        while (scheduledDate.weekday != i) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: base + i,
          title: l10n.notifDailyTitle,
          body: l10n.notifPlanBody,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }
}
