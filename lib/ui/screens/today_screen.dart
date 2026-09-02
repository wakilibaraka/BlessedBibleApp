import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../widgets/shared_top_header.dart';
import '../../state/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';
import '../../state/notes_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/nav_provider.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'your_space_screen.dart';
import 'notes_list_screen.dart';

import 'plans_hub_v2_screen.dart';

import 'commentary_hub_screen.dart';
import 'main_nav_screen.dart';
import '../../state/read_location_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/study_provider.dart';
import '../../state/commentary_provider.dart';
import 'votd_archive_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TODAY SCREEN — static scaffold (Stage 1: design / no data wiring)
//
// Stage 2 wiring plan:
//   • Greeting/Date     → intl package for DateFormat; time-of-day salutation
//   • Verse of the Day  → homeProvider (already wired in home_screen.dart)
//   • Today's Reading   → readingPlanProvider (currentDay + chapters)
//   • Latest Note       → notesProvider (first in list, sorted by date)
//   • Streak / Progress → readingPlanProvider (completedDays count / planData.length)
//   • Quick Actions     → navProvider.setIndex() + Navigator.push
// ─────────────────────────────────────────────────────────────────────────────

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakProvider.notifier).markAppOpenedToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final dayLabel =
        '${weekdays[now.weekday - 1]} · ${months[now.month - 1]} ${now.day}';

    final streak = ref.watch(streakProvider);
    final showNudge = !streak.readToday && streak.count > 0;

    final greetings = ['Good morning', 'Good afternoon', 'Good evening', 'Good night'];
    final hour = now.hour;
    final greeting = hour < 12
        ? greetings[0]
        : hour < 17
            ? greetings[1]
            : hour < 21
                ? greetings[2]
                : greetings[3];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(
              appThemeMode: ref.watch(themeProvider),
            ),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator.adaptive(
              color: theme.primaryColor,
              backgroundColor: theme.colorScheme.surface,
              onRefresh: () async {
                // CMS: fetch remote content here in future
                await Future.delayed(const Duration(milliseconds: 500));
                ref.invalidate(streakProvider);
                ref.invalidate(notesProvider);
              },
              child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // ── Shared top header ──────────────────────────────────
                        SharedTopHeader(
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: theme.colorScheme.onSurface,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 44, minHeight: 44),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          trailing: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(showNudge
                                      ? 'Read today to save your streak!'
                                      : 'Notifications coming soon!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0, left: 8.0),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Icon(Icons.notifications_none_rounded,
                                      size: 26, color: theme.colorScheme.onSurface),
                                  if (showNudge)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2, right: 2),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          centerContent: Text(
                            dayLabel,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ═══════════════════════════════════════════════════════
                        // 1. GREETING / DATE HEADER
                        // ═══════════════════════════════════════════════════════
                        _GreetingHeader(greeting: greeting, theme: theme),

                        const SizedBox(height: 20),

                        // ═══════════════════════════════════════════════════════
                        // 2. READING STREAK
                        // ═══════════════════════════════════════════════════════
                        _SectionLabel(label: 'READING STREAK', theme: theme),
                        const SizedBox(height: 8),
                        _StreakProgressCard(theme: theme),

                        const SizedBox(height: 20),

                        // ═══════════════════════════════════════════════════════
                        // 3. VOTD ARCHIVE
                        // ═══════════════════════════════════════════════════════
                        _VotdArchiveBanner(theme: theme),

                        const SizedBox(height: 20),

                        // ═══════════════════════════════════════════════════════
                        // 4. LATEST NOTE / HIGHLIGHT
                        // ═══════════════════════════════════════════════════════
                        _SectionLabel(label: 'LATEST NOTE', theme: theme),
                        const SizedBox(height: 8),
                        _LatestNoteCard(theme: theme),

                        const SizedBox(height: 20),

                        // ═══════════════════════════════════════════════════════
                        // 5. QUICK ACTIONS
                        // ═══════════════════════════════════════════════════════
                        _SectionLabel(label: 'QUICK ACTIONS', theme: theme),
                        const SizedBox(height: 8),
                        _QuickActionsRow(theme: theme),

                        // Bottom padding: clears the floating bottom nav
                        SizedBox(height: mq.padding.bottom + 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: AppColors.goldAccent,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// _GlassCard has been replaced by GlassContainer from lib/ui/widgets/glass_container.dart

// ─────────────────────────────────────────────────────────────────────────────
// 1. Greeting / Date header card
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final ThemeData theme;
  const _GreetingHeader({required this.greeting, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.wb_sunny_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your daily moment of peace.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 4. Latest Note card
// ─────────────────────────────────────────────────────────────────────────────
class _LatestNoteCard extends ConsumerWidget {
  final ThemeData theme;
  const _LatestNoteCard({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final hasNote = notes.isNotEmpty;
    final noteTitle = hasNote ? notes.first.title : 'No notes yet';
    final notePreview =
        hasNote ? notes.first.content : 'Write your first note to see it here.';
    final noteDate = hasNote ? notes.first.date : '';

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  color: AppColors.goldAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  noteTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                noteDate,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notePreview,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.55,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesListScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: const Text('View all notes'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.goldAccent,
                textStyle: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Streak / Progress card
// ─────────────────────────────────────────────────────────────────────────────
class _StreakProgressCard extends ConsumerWidget {
  final ThemeData theme;
  const _StreakProgressCard({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final streakDays = streak.count;
    
    final now = DateTime.now();
    final year = now.year;
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    final daysInYear = isLeapYear ? 366 : 365;
    
    final startOfYear = DateTime(year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays + 1;
    final progress = dayOfYear / daysInYear;
    final daysRemaining = daysInYear - dayOfYear;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left Side: Flame + Label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.local_fire_department_rounded,
                    color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                streakDays == 1 ? '1 day streak' : '$streakDays days streak',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(width: 20),
          Container(
            width: 1,
            height: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 20),

          // Right Side: Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayOfYear of $daysInYear',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$daysRemaining days of year remaining.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Quick Actions row
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsRow extends ConsumerWidget {
  final ThemeData theme;
  const _QuickActionsRow({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      (
        icon: Icons.menu_book_rounded,
        label: 'Read',
        color: theme.colorScheme.primary,
        onTap: () {
          Navigator.of(context).pop();
          ref.read(navProvider.notifier).setIndex(1);
        },
      ),
      (
        icon: Icons.casino_rounded,
        label: 'Surprise Me',
        color: theme.colorScheme.primary,
        onTap: () {
          final availableVerses =
              ref.read(commentaryProvider.notifier).versesWithCommentary;
          if (availableVerses.isNotEmpty) {
            final randomVerse =
                availableVerses[math.Random().nextInt(availableVerses.length)];
            final lastSpaceIdx = randomVerse.lastIndexOf(' ');
            final bookName = randomVerse.substring(0, lastSpaceIdx);
            final refParts = randomVerse.substring(lastSpaceIdx + 1).split(':');
            final chapter = int.parse(refParts[0]);
            final verseNum = int.parse(refParts[1]);

            final flatChapters = ref.read(flatChaptersProvider);
            try {
              final fc = flatChapters.firstWhere((c) =>
                  c.book.name == bookName && c.chapter.number == chapter);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const CastingLotsDialog(),
              ).then((_) {
                if (!context.mounted) return;

                HapticFeedback.selectionClick();
                ref.read(readLocationProvider.notifier).updateLocation(
                      bookAbbrev: fc.book.abbreviation,
                      bookName: bookName,
                      chapter: chapter,
                      verse: verseNum,
                    );
                ref
                    .read(activeStudyVerseProvider.notifier)
                    .setVerse('$bookName $chapter:$verseNum');

                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => CommentaryHubScreen(
                          book: bookName,
                          chapter: chapter,
                          verse: verseNum,
                          verseText: fc.chapter.verses[verseNum - 1].text,
                        )));
              });
            } catch (_) {}
          }
        },
      ),
      (
        icon: Icons.calendar_today_rounded,
        label: 'Reading Plan',
        color: theme.colorScheme.primary,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (_) => const PlansHubV2Screen()),
          );
        },
      ),
      (
        icon: Icons.self_improvement_rounded,
        label: 'Your Space',
        color: theme.colorScheme.primary,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (_) => const YourSpaceScreen(initialTab: 0)),
          );
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions
            .map(
              (a) => _QuickActionButton(
                icon: a.icon,
                label: a.label,
                color: a.color,
                theme: theme,
                onTap: a.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.13),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VotdArchiveBanner extends StatelessWidget {
  final ThemeData theme;
  const _VotdArchiveBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const VotdArchiveScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, color: theme.primaryColor, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verse of the Day Archive',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Catch up on verses from days you missed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right_rounded, color: theme.primaryColor),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: theme.primaryColor.withValues(alpha: 0.7), size: 16),
                      const SizedBox(width: 8),
                      Text('Explore your past daily verses',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

