// lib/state/rest_day_provider.dart
//
// Rest-day preference provider — Step 1 (data + provider only).
//
// Step 2 will use `restDayProvider` for:
//   • streak-grace: a rest day does not break the streak
//   • notification suppression: no daily-reading notification on the rest day
//   • rest-day card copy: show a special "rest & reflect" card instead of a reading card
//
// This file intentionally contains NO streak logic, NO notifications, and NO UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

// ---------------------------------------------------------------------------
// Week-day convention
// ---------------------------------------------------------------------------
// The app uses a Sunday-first week (Sabbath is Saturday, day 7 of the week).
// This differs from Dart's DateTime.weekday which is ISO-8601: Monday=1 … Sunday=7.
//
//  App convention   Dart DateTime.weekday
//  1 = Sunday       7
//  2 = Monday       1
//  3 = Tuesday      2
//  4 = Wednesday    3
//  5 = Thursday     4
//  6 = Friday       5
//  7 = Saturday     6
//
// Formula: appDay = (dartDay % 7) + 1
//   • dartDay=6 (Sat): (6 % 7) + 1 = 7  ✓ Saturday
//   • dartDay=7 (Sun): (7 % 7) + 1 = 1  ✓ Sunday
//   • dartDay=1 (Mon): (1 % 7) + 1 = 2  ✓ Monday
// ---------------------------------------------------------------------------

/// Converts Dart's [DateTime.weekday] (Mon=1 … Sun=7) to the app's Sunday-first
/// integer (1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday,
/// 7=Saturday).
///
/// Proof table:
///   Dart Sun (7)  → (7 % 7) + 1 = 0 + 1 = 1  ✓
///   Dart Mon (1)  → (1 % 7) + 1 = 1 + 1 = 2  ✓
///   Dart Tue (2)  → (2 % 7) + 1 = 2 + 1 = 3  ✓
///   Dart Wed (3)  → (3 % 7) + 1 = 3 + 1 = 4  ✓
///   Dart Thu (4)  → (4 % 7) + 1 = 4 + 1 = 5  ✓
///   Dart Fri (5)  → (5 % 7) + 1 = 5 + 1 = 6  ✓
///   Dart Sat (6)  → (6 % 7) + 1 = 6 + 1 = 7  ✓
int appWeekday(DateTime date) => (date.weekday % 7) + 1;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Holds the user's chosen rest day in the Sunday-first convention.
/// Valid range: 1 (Sunday) … 7 (Saturday). Default: 7 (Saturday / Sabbath).
class RestDayState {
  /// The chosen rest day in the app's Sunday-first numbering (1=Sun … 7=Sat).
  final int restDay;

  const RestDayState({required this.restDay});
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class RestDayNotifier extends Notifier<RestDayState> {
  @override
  RestDayState build() {
    // Read synchronously from SharedPreferences; PreferencesService is always
    // initialised before providers are first accessed (see main.dart).
    final prefs = ref.watch(preferencesProvider);
    return RestDayState(restDay: prefs.getReadingPlanRestDay());
  }

  /// Returns the current rest day (1=Sunday … 7=Saturday, Sunday-first).
  int get restDay => state.restDay;

  /// Persists the chosen rest day.
  ///
  /// [day] must be 1–7 (Sunday-first convention). Call only from callbacks
  /// (tap handlers, settings toggles) — never from build/initState.
  ///
  /// Step 2 will react to this change for streak-grace, notification
  /// suppression, and rest-day card copy.
  void setRestDay(int day) {
    assert(day >= 1 && day <= 7, 'restDay must be 1–7 (Sunday-first)');
    ref.read(preferencesProvider).setReadingPlanRestDay(day);
    state = RestDayState(restDay: day);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final restDayProvider = NotifierProvider<RestDayNotifier, RestDayState>(
  RestDayNotifier.new,
);
