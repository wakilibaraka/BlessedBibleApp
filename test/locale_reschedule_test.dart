// Changing the interface language re-schedules enabled reminders so their
// (pre-rendered) text follows the new language, without asking for
// permission again and without failing when notifications are unavailable.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/services/notification_service.dart';
import 'package:the_blessed_bible/state/locale_provider.dart';
import 'package:the_blessed_bible/state/reminders_provider.dart';

class _FakeNotifications extends NotificationService {
  final calls = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleDailyReminder(int hour, int minute,
      {bool askPermission = true}) async {
    calls.add('daily $hour:$minute ask=$askPermission');
  }

  @override
  Future<void> schedulePrayerReminder(int hour, int minute,
      {bool askPermission = true}) async {
    throw StateError('notifications not permitted');
  }

  @override
  Future<void> syncReadingPlanReminder(
      bool enabled, int hour, int minute, int? restDay,
      {Set<int>? restDays, String? planId, bool askPermission = true}) async {
    calls.add('plan $planId $hour:$minute ask=$askPermission');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setLanguage re-schedules enabled reminders without prompting',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = PreferencesService(prefs)
      ..setDailyReminderEnabled(true)
      ..setPrayerReminderEnabled(true)
      ..saveActivePlanIds(['nt90'])
      ..saveReadingPlanState('nt90', {
        'planId': 'nt90',
        'reminderEnabled': true,
        'reminderTimeHour': 7,
        'reminderTimeMinute': 30,
        'restDays': [1],
      });
    final fake = _FakeNotifications();
    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(service),
      notificationServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    await container.read(appLocaleProvider.notifier).setLanguage('fr');
    await pumpEventQueue();

    expect(container.read(appLocaleProvider)?.languageCode, 'fr');
    expect(fake.calls, contains(startsWith('daily ')));
    expect(fake.calls, contains('plan nt90 7:30 ask=false'));
    expect(fake.calls.every((c) => c.endsWith('ask=false')), isTrue);
    // The failing prayer reminder didn't stop the others.
    expect(container.read(remindersProvider).prayerEnabled, isTrue);
  });
}
