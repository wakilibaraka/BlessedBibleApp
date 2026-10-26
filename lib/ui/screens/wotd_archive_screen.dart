import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../state/theme_provider.dart';
import '../../state/wotd_provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/reading_tokens.dart';
import '../widgets/dictionary_entry_sheet.dart';

/// Screen housing the last 7 days of Word of the Day entries.
class WotdArchiveScreen extends ConsumerWidget {
  const WotdArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>()!;
    final pastWordsAsync = ref.watch(pastWordsOfTheDayProvider);

    final appThemeMode = ref.watch(themeProvider);
    final is3DTheme = appThemeMode.is3DTheme;

    Color getThemeBackgroundColor() {
      return appThemeMode.is3DTheme
          ? appThemeMode.backgroundColor
          : theme.scaffoldBackgroundColor;
    }

    void openDefinition(String normalized) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DictionaryEntrySheet(normalizedWord: normalized),
      );
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
                context.l10n.studyWordOfTheDayHistory,
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
          pastWordsAsync.when(
            data: (entries) => SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final (date, wotd) = entries[index];
                    final isToday = index == 0;

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

                    final wordTitle = wotd?.word ?? '...';
                    final snippet = wotd?.snippet ?? '';

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
                              onTap: wotd != null
                                  ? () => openDefinition(wotd.normalized)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? theme.primaryColor
                                                    .withValues(alpha: 0.15)
                                                : theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.05),
                                            borderRadius:
                                                BorderRadius.circular(Radii.sm),
                                          ),
                                          child: Text(
                                            displayDate.toUpperCase(),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              color: isToday
                                                  ? theme.primaryColor
                                                  : theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.menu_book_rounded,
                                          size: 16,
                                          color: theme.primaryColor
                                              .withValues(alpha: 0.7),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      wordTitle,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: TypeScale.title,
                                        color: tokens.readingInk,
                                      ),
                                    ),
                                    if (snippet.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        snippet,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: tokens.readingInkMuted,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Text(
                                      context.l10n.studyCtaArrow(
                                          context.l10n.studyWordLookUp),
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.primaryColor,
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
                  childCount: entries.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text(context.l10n.studyUnavailableNow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
