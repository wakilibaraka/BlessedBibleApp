/// A Study hub greeting: benediction title + companion subtitle.
class StudyGreeting {
  final String title;
  final String subtitle;

  const StudyGreeting(this.title, this.subtitle);
}

/// The everyday rotation: invitations, not imperatives (EID tone).
/// Shared by all users on a given day — calm, never flickering.
const List<StudyGreeting> _dailyGreetings = [
  StudyGreeting(
      'Peace be with you.', 'Let His word bring you rest.'),
  StudyGreeting(
      'Walk in the light.', 'His word is a lamp for your path.'),
  StudyGreeting(
      'Grace and peace to you.', 'Rest in the Vine today.'),
  StudyGreeting(
      'Come to the waters.', 'Jesus is the light of the world.'),
  StudyGreeting(
      'The Lord bless you.', 'Keep His promises close to your heart.'),
  StudyGreeting(
      'Be still and know.', 'Dwell in His quiet presence.'),
  StudyGreeting(
      'Morning mercies anew.', 'His compassions never fail.'),
  StudyGreeting(
      'Rooted in love.', 'Grow in grace and truth.'),
  StudyGreeting(
      'Let your light shine.', 'A city on a hill cannot be hidden.'),
  StudyGreeting(
      'Draw near to God.', 'He is already reaching for you.'),
  StudyGreeting(
      'The Word became flesh.', 'He understands your journey.'),
  StudyGreeting('Taste and see.', 'The Lord is incredibly good.'),
];

/// Mornings (5:00–11:59): starting-the-day words.
const List<StudyGreeting> _morningGreetings = [
  StudyGreeting('Awake, O sleeper.', 'Christ will shine on you.'),
  StudyGreeting(
      'Joy comes in the morning.', 'Step into His new day.'),
  StudyGreeting('This is the day the Lord has made.',
      'Let us rejoice in it.'),
];

/// Evenings and nights (18:00–4:59): rest words.
const List<StudyGreeting> _eveningGreetings = [
  StudyGreeting(
      'The day is done.', 'He gives sleep to those He loves.'),
  StudyGreeting('Under His wings.', 'You will find refuge tonight.'),
  StudyGreeting('Come to Me, you who are weary.',
      'And I will give you rest.'),
];

/// Grace days: the streak is broken but the reader has history, or
/// today restarts it. Comfort, not guilt.
const List<StudyGreeting> _graceGreetings = [
  StudyGreeting(
      'Cast all your anxiety on Him.', 'Because He cares for you.'),
  StudyGreeting(
      'My peace I give you.', 'Let not your heart be troubled.'),
  StudyGreeting(
      'He heals the brokenhearted.', 'And binds up their wounds.'),
  StudyGreeting(
      'Nothing can separate us.', 'From the love of God.'),
];

/// On a roll (streak of 3+): encouragement for the road.
const List<StudyGreeting> _encouragementGreetings = [
  StudyGreeting('Be strong and courageous.',
      'The Lord your God goes with you.'),
  StudyGreeting(
      'Run with endurance.', 'Keep your eyes fixed on Jesus.'),
  StudyGreeting('Iron sharpens iron.', 'Grow together in the Word.'),
];

/// Picks the Study greeting for this moment.
///
/// Priority: grace (returning after a break) > encouragement (streak
/// of 3+) > time of day (morning / evening pools) > the shared daily
/// rotation. Within a pool the pick rotates by calendar day, so the
/// header is stable all day and fresh tomorrow — deterministic and
/// testable, with no per-launch randomness.
StudyGreeting greetingFor({
  required DateTime now,
  required int streakCount,
  required int distinctDaysThisYear,
}) {
  final dayIndex =
      DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
          86400000;

  StudyGreeting pick(List<StudyGreeting> pool) =>
      pool[dayIndex % pool.length];

  final returning = (streakCount == 0 && distinctDaysThisYear > 0) ||
      (streakCount == 1 && distinctDaysThisYear > 1);
  if (returning) return pick(_graceGreetings);

  if (streakCount >= 3) return pick(_encouragementGreetings);

  final hour = now.hour;
  if (hour >= 5 && hour < 12) return pick(_morningGreetings);
  if (hour >= 18 || hour < 5) return pick(_eveningGreetings);
  return pick(_dailyGreetings);
}

/// Header eyebrow: weekday + daypart, echoing whichever pool is
/// active ("Sunday morning", "Sunday night", ...).
String greetingEyebrow(DateTime now) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final day = weekdays[now.weekday - 1];
  final hour = now.hour;
  final part = hour >= 5 && hour < 12
      ? 'morning'
      : hour >= 12 && hour < 18
          ? 'afternoon'
          : hour >= 18
              ? 'evening'
              : 'night';
  return '$day $part';
}
