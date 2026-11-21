import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../state/home_provider.dart';
import '../../state/votd_tracker_provider.dart';
import '../../state/theme_provider.dart';
import 'commentary_hub_screen.dart';
import '../../state/commentary_provider.dart';
import '../../theme/reading_tokens.dart';
import '../../l10n/l10n.dart';
import '../../data/localized_book_names.dart';
import '../../data/let_read.dart';
import '../../utils/passage.dart';
import '../../theme/design_tokens.dart';

class VotdArchiveScreen extends ConsumerWidget {
  const VotdArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>()!;

    // Compute past 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calendar days, not 24-hour spans, so the rows survive a DST change.
    final dates = recentCalendarDays(today, 7);

    final appThemeMode = ref.watch(resolvedThemeProvider);
    final is3DTheme = appThemeMode.is3DTheme;

    Color getThemeBackgroundColor() {
      return appThemeMode.is3DTheme
          ? appThemeMode.backgroundColor
          : theme.scaffoldBackgroundColor;
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: getThemeBackgroundColor(),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                context.l10n.studyVerseOfTheDayHistory,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      getThemeBackgroundColor(),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final date = dates[index];
                  final isToday = index == 0;

                  final pool = ref.watch(votdPoolProvider);

                  // Same rule as Home, so history replays what was shown.
                  final votdEntry = pool[votdIndexFor(pool.length, date)];
                  final reference = votdEntry.reference;
                  final text = votdEntry.text;

                  String displayDate;
                  if (index == 0) {
                    displayDate = context.l10n.plansToday;
                  } else if (index == 1) {
                    displayDate = context.l10n.plansYesterday;
                  } else if (index == 2) {
                    displayDate = context.l10n.plansDaysAgo(2);
                  } else {
                    displayDate = DateFormat.yMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(date);
                  }

                  // "1 Kings 3:5" keeps "1 Kings" as its book; splitting on
                  // spaces would tag the card "1".
                  final bookTag =
                      (PassageRef.parse(reference)?.bookName ?? reference)
                          .toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Radii.xl),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: is3DTheme
                              ? theme.colorScheme.surface
                              : tokens.readingSurface,
                          borderRadius: BorderRadius.circular(Radii.xl),
                          border: Border.all(
                            width: 0.5,
                            color: is3DTheme
                                ? context.palette.divider
                                : tokens.readingBorder,
                          ),
                          boxShadow: appThemeMode.is3DTheme
                              ? [
                                  BoxShadow(
                                    color: context.palette.shadow,
                                    blurRadius: 24,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Radii.xl),
                            onTap: () {
                              ref
                                  .read(votdTrackerProvider.notifier)
                                  .markViewed(date);
                              final parsed = PassageRef.parse(reference);
                              if (parsed == null) return;
                              final verseNum = parsed.wholeChapter
                                  ? null
                                  : parsed.startVerse;

                              // Only navigate if commentary exists
                              final hasComm = ref.read(
                                  commentaryForChapterProvider(
                                      (parsed.bookName, parsed.chapter)));
                              if (!hasComm) return;

                              Navigator.of(context)
                                  .push(CupertinoPageRoute<void>(
                                builder: (_) => CommentaryHubScreen(
                                  book: parsed.bookName,
                                  chapter: parsed.chapter,
                                  verse: verseNum,
                                  verseText: null,
                                ),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Radii.xl),
                                border: isToday
                                    ? Border.all(
                                        color: theme.primaryColor
                                            .withValues(alpha: 0.3),
                                        width: 1)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        displayDate,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: isToday
                                              ? tokens.readingAccent
                                              : tokens.readingInkMuted,
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(Radii.sm),
                                        ),
                                        child: Text(
                                          bookTag,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: tokens.readingAccent,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.referenceInLocale(reference),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: tokens.readingInk,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: tokens.readingInkMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: dates.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
