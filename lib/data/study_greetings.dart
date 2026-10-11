import '../l10n/l10n.dart';

/// A Study hub greeting: benediction title + companion subtitle.
class StudyGreeting {
  final String title;
  final String subtitle;

  const StudyGreeting(this.title, this.subtitle);
}

/// The everyday rotation: invitations, not imperatives (EID tone).
/// Shared by all users on a given day — calm, never flickering.
List<StudyGreeting> _dailyGreetings(AppLocalizations l) => [
      StudyGreeting(l.greetingDaily1Title, l.greetingDaily1Subtitle),
      StudyGreeting(l.greetingDaily2Title, l.greetingDaily2Subtitle),
      StudyGreeting(l.greetingDaily3Title, l.greetingDaily3Subtitle),
      StudyGreeting(l.greetingDaily4Title, l.greetingDaily4Subtitle),
      StudyGreeting(l.greetingDaily5Title, l.greetingDaily5Subtitle),
      StudyGreeting(l.greetingDaily6Title, l.greetingDaily6Subtitle),
      StudyGreeting(l.greetingDaily7Title, l.greetingDaily7Subtitle),
      StudyGreeting(l.greetingDaily8Title, l.greetingDaily8Subtitle),
      StudyGreeting(l.greetingDaily9Title, l.greetingDaily9Subtitle),
      StudyGreeting(l.greetingDaily10Title, l.greetingDaily10Subtitle),
      StudyGreeting(l.greetingDaily11Title, l.greetingDaily11Subtitle),
      StudyGreeting(l.greetingDaily12Title, l.greetingDaily12Subtitle),
    ];

/// Mornings (5:00–11:59): starting-the-day words.
List<StudyGreeting> _morningGreetings(AppLocalizations l) => [
      StudyGreeting(l.greetingMorning1Title, l.greetingMorning1Subtitle),
      StudyGreeting(l.greetingMorning2Title, l.greetingMorning2Subtitle),
      StudyGreeting(l.greetingMorning3Title, l.greetingMorning3Subtitle),
    ];

/// Evenings and nights (18:00–4:59): rest words.
List<StudyGreeting> _eveningGreetings(AppLocalizations l) => [
      StudyGreeting(l.greetingEvening1Title, l.greetingEvening1Subtitle),
      StudyGreeting(l.greetingEvening2Title, l.greetingEvening2Subtitle),
      StudyGreeting(l.greetingEvening3Title, l.greetingEvening3Subtitle),
    ];

/// Grace days: the streak is broken but the reader has history, or
/// today restarts it. Comfort, not guilt.
List<StudyGreeting> _graceGreetings(AppLocalizations l) => [
      StudyGreeting(l.greetingGrace1Title, l.greetingGrace1Subtitle),
      StudyGreeting(l.greetingGrace2Title, l.greetingGrace2Subtitle),
      StudyGreeting(l.greetingGrace3Title, l.greetingGrace3Subtitle),
      StudyGreeting(l.greetingGrace4Title, l.greetingGrace4Subtitle),
    ];

/// On a roll (streak of 3+): encouragement for the road.
List<StudyGreeting> _encouragementGreetings(AppLocalizations l) => [
      StudyGreeting(l.greetingCheer1Title, l.greetingCheer1Subtitle),
      StudyGreeting(l.greetingCheer2Title, l.greetingCheer2Subtitle),
      StudyGreeting(l.greetingCheer3Title, l.greetingCheer3Subtitle),
    ];

/// Picks the Study greeting for this moment.
///
/// Priority: grace (returning after a break) > encouragement (streak
/// of 3+) > time of day (morning / evening pools) > the shared daily
/// rotation. Within a pool the pick rotates by calendar day, so the
/// header is stable all day and fresh tomorrow — deterministic and
/// testable, with no per-launch randomness.
StudyGreeting greetingFor({
  required AppLocalizations l10n,
  required DateTime now,
  required int streakCount,
  required int distinctDaysThisYear,
}) {
  final dayIndex =
      DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 86400000;

  StudyGreeting pick(List<StudyGreeting> pool) => pool[dayIndex % pool.length];

  final returning = (streakCount == 0 && distinctDaysThisYear > 0) ||
      (streakCount == 1 && distinctDaysThisYear > 1);
  if (returning) return pick(_graceGreetings(l10n));

  if (streakCount >= 3) return pick(_encouragementGreetings(l10n));

  final hour = now.hour;
  if (hour >= 5 && hour < 12) return pick(_morningGreetings(l10n));
  if (hour >= 18 || hour < 5) return pick(_eveningGreetings(l10n));
  return pick(_dailyGreetings(l10n));
}

/// Header eyebrow: weekday + daypart, echoing whichever pool is
/// active ("Sunday morning", "Sunday night", ...).
String greetingEyebrow(DateTime now, AppLocalizations l10n) {
  final day = switch (now.weekday) {
    DateTime.monday => l10n.settingsMonday,
    DateTime.tuesday => l10n.settingsTuesday,
    DateTime.wednesday => l10n.settingsWednesday,
    DateTime.thursday => l10n.settingsThursday,
    DateTime.friday => l10n.settingsFriday,
    DateTime.saturday => l10n.settingsSaturday,
    _ => l10n.settingsSunday,
  };
  final hour = now.hour;
  if (hour >= 5 && hour < 12) return l10n.greetingEyebrowMorning(day);
  if (hour >= 12 && hour < 18) return l10n.greetingEyebrowAfternoon(day);
  if (hour >= 18) return l10n.greetingEyebrowEvening(day);
  return l10n.greetingEyebrowNight(day);
}
