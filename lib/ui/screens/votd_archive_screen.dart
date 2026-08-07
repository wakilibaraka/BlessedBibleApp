import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/home_provider.dart';
import '../../state/votd_tracker_provider.dart';
import '../../state/theme_provider.dart';
import 'commentary_hub_screen.dart';
import '../../state/commentary_provider.dart';
import '../../theme/reading_tokens.dart';
import '../../theme/app_colors.dart';

class VotdArchiveScreen extends ConsumerWidget {
  const VotdArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>()!;

    // Compute past 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create list of dates (most recent first)
    final dates =
        List.generate(7, (index) => today.subtract(Duration(days: index)));

    // Epoch used for VotD calculation
    final epoch = DateTime(2026, 1, 1);

    final appThemeMode = ref.watch(themeProvider);
    final is3DTheme = appThemeMode == AppThemeMode.dawn ||
        appThemeMode == AppThemeMode.lilies ||
        appThemeMode == AppThemeMode.roses ||
        appThemeMode == AppThemeMode.olives ||
        appThemeMode == AppThemeMode.dusk ||
        appThemeMode == AppThemeMode.fresh;

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return theme.scaffoldBackgroundColor;
      }
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
                'Daily Verses',
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

                  // Compute VotD for this specific date
                  final dayIndex = date.difference(epoch).inDays % pool.length;
                  // Handle negative modulo correctly just in case
                  final validDayIndex = dayIndex < 0
                      ? dayIndex + pool.length
                      : dayIndex;
                  final votdEntry = pool[validDayIndex];
                  final reference = votdEntry.reference;
                  final text = votdEntry.text;

                  String displayDate;
                  if (index == 0) {
                    displayDate = 'Today';
                  } else if (index == 1) {
                    displayDate = 'Yesterday';
                  } else if (index == 2) {
                    displayDate = '2 days ago';
                  } else {
                    final months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ];
                    displayDate =
                        '${months[date.month - 1]} ${date.day}, ${date.year}';
                  }

                  final bookName = reference.split(' ').first;
                  final bookTag = bookName.toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 0.5,
                            color: is3DTheme
                                ? Colors.white.withValues(alpha: 0.15)
                                : tokens.readingBorder,
                          ),
                          boxShadow: (appThemeMode == AppThemeMode.dawn ||
                                  appThemeMode == AppThemeMode.lilies ||
                                  appThemeMode == AppThemeMode.roses ||
                                  appThemeMode == AppThemeMode.olives ||
                                  appThemeMode == AppThemeMode.dusk ||
                                  appThemeMode == AppThemeMode.fresh)
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
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
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              ref
                                  .read(votdTrackerProvider.notifier)
                                  .markViewed(date);
                              final refStr = reference;
                              final lastSpaceIdx = refStr.lastIndexOf(' ');
                              final bookName = lastSpaceIdx != -1
                                  ? refStr.substring(0, lastSpaceIdx)
                                  : refStr;
                              final refParts = lastSpaceIdx != -1
                                  ? refStr
                                      .substring(lastSpaceIdx + 1)
                                      .split(':')
                                  : [];
                              final chapterNum = refParts.isNotEmpty
                                  ? (int.tryParse(refParts[0]) ?? 1)
                                  : 1;
                              final verseNum = refParts.length > 1
                                  ? int.tryParse(refParts[1])
                                  : null;

                              // Only navigate if commentary exists
                              final hasComm = ref.read(
                                  commentaryForChapterProvider(
                                      (bookName, chapterNum)));
                              if (!hasComm) return;

                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) => CommentaryHubScreen(
                                  book: bookName,
                                  chapter: chapterNum,
                                  verse: verseNum,
                                  verseText:
                                      null,
                                ),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
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
                                              BorderRadius.circular(8),
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
                                    reference,
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
