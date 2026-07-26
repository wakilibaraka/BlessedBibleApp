import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../services/notification_service.dart';

class RemindersState {
  final bool sabbathEnabled;
  final double? sabbathLat;
  final double? sabbathLng;
  final String? sabbathLocationName;
  
  final bool dailyEnabled;
  final int dailyHour;
  final int dailyMinute;
  
  final bool customWeeklyEnabled;
  final int customWeeklyDay;
  final int customWeeklyHour;
  final int customWeeklyMinute;

  RemindersState({
    required this.sabbathEnabled,
    this.sabbathLat,
    this.sabbathLng,
    this.sabbathLocationName,
    required this.dailyEnabled,
    required this.dailyHour,
    required this.dailyMinute,
    required this.customWeeklyEnabled,
    required this.customWeeklyDay,
    required this.customWeeklyHour,
    required this.customWeeklyMinute,
  });

  RemindersState copyWith({
    bool? sabbathEnabled,
    double? sabbathLat,
    double? sabbathLng,
    String? sabbathLocationName,
    bool? dailyEnabled,
    int? dailyHour,
    int? dailyMinute,
    bool? customWeeklyEnabled,
    int? customWeeklyDay,
    int? customWeeklyHour,
    int? customWeeklyMinute,
  }) {
    return RemindersState(
      sabbathEnabled: sabbathEnabled ?? this.sabbathEnabled,
      sabbathLat: sabbathLat ?? this.sabbathLat,
      sabbathLng: sabbathLng ?? this.sabbathLng,
      sabbathLocationName: sabbathLocationName ?? this.sabbathLocationName,
      dailyEnabled: dailyEnabled ?? this.dailyEnabled,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      customWeeklyEnabled: customWeeklyEnabled ?? this.customWeeklyEnabled,
      customWeeklyDay: customWeeklyDay ?? this.customWeeklyDay,
      customWeeklyHour: customWeeklyHour ?? this.customWeeklyHour,
      customWeeklyMinute: customWeeklyMinute ?? this.customWeeklyMinute,
    );
  }
}

class RemindersNotifier extends Notifier<RemindersState> {
  @override
  RemindersState build() {
    final prefs = ref.watch(preferencesProvider);
    
    // Initialize Notification Service on build
    ref.read(notificationServiceProvider).initialize();

    return RemindersState(
      sabbathEnabled: prefs.getSabbathReminderEnabled(),
      sabbathLat: prefs.getSabbathLocationLat(),
      sabbathLng: prefs.getSabbathLocationLng(),
      sabbathLocationName: prefs.getSabbathLocationName(),
      dailyEnabled: prefs.getDailyReminderEnabled(),
      dailyHour: prefs.getDailyReminderHour(),
      dailyMinute: prefs.getDailyReminderMinute(),
      customWeeklyEnabled: prefs.getCustomWeeklyEnabled(),
      customWeeklyDay: prefs.getCustomWeeklyDay(),
      customWeeklyHour: prefs.getCustomWeeklyHour(),
      customWeeklyMinute: prefs.getCustomWeeklyMinute(),
    );
  }

  void toggleSabbath(bool value) {
    state = state.copyWith(sabbathEnabled: value);
    ref.read(preferencesProvider).setSabbathReminderEnabled(value);
    _syncSabbathSchedule();
  }

  void setSabbathLocation(String name, double lat, double lng) {
    state = state.copyWith(
      sabbathLocationName: name,
      sabbathLat: lat,
      sabbathLng: lng,
    );
    ref.read(preferencesProvider).setSabbathLocationName(name);
    ref.read(preferencesProvider).setSabbathLocationLat(lat);
    ref.read(preferencesProvider).setSabbathLocationLng(lng);
    _syncSabbathSchedule();
  }

  void _syncSabbathSchedule() {
    final ns = ref.read(notificationServiceProvider);
    if (state.sabbathEnabled && state.sabbathLat != null && state.sabbathLng != null) {
      ns.scheduleSabbathReminder(state.sabbathLat!, state.sabbathLng!);
    } else {
      ns.cancelSabbathReminders();
    }
  }

  void toggleDaily(bool value) {
    state = state.copyWith(dailyEnabled: value);
    ref.read(preferencesProvider).setDailyReminderEnabled(value);
    _syncDailySchedule();
  }

  void setDailyTime(int hour, int minute) {
    state = state.copyWith(dailyHour: hour, dailyMinute: minute);
    ref.read(preferencesProvider).setDailyReminderHour(hour);
    ref.read(preferencesProvider).setDailyReminderMinute(minute);
    _syncDailySchedule();
  }

  void _syncDailySchedule() {
    final ns = ref.read(notificationServiceProvider);
    if (state.dailyEnabled) {
      ns.scheduleDailyReminder(state.dailyHour, state.dailyMinute);
    } else {
      ns.cancelDailyReminder();
    }
  }

  void toggleCustomWeekly(bool value) {
    state = state.copyWith(customWeeklyEnabled: value);
    ref.read(preferencesProvider).setCustomWeeklyEnabled(value);
    _syncWeeklySchedule();
  }

  void setCustomWeeklyTime(int day, int hour, int minute) {
    state = state.copyWith(customWeeklyDay: day, customWeeklyHour: hour, customWeeklyMinute: minute);
    ref.read(preferencesProvider).setCustomWeeklyDay(day);
    ref.read(preferencesProvider).setCustomWeeklyHour(hour);
    ref.read(preferencesProvider).setCustomWeeklyMinute(minute);
    _syncWeeklySchedule();
  }

  void _syncWeeklySchedule() {
    final ns = ref.read(notificationServiceProvider);
    if (state.customWeeklyEnabled) {
      ns.scheduleWeeklyReminder(state.customWeeklyDay, state.customWeeklyHour, state.customWeeklyMinute);
    } else {
      ns.cancelWeeklyReminder();
    }
  }
}

final remindersProvider = NotifierProvider<RemindersNotifier, RemindersState>(RemindersNotifier.new);
