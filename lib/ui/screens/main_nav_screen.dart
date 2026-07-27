import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/theme_provider.dart';
import 'home_screen.dart';
import 'read_screen.dart';
import 'search_screen.dart';
import 'study_screen.dart';
import 'settings_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/textured_glass_container.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/read_settings_provider.dart';


import '../../state/study_provider.dart';
import 'verse_detail_screen.dart';

const double kBottomDockHeight = 64.0;
const double kBottomDockInset = 16.0;
const double kBottomDockGap = 12.0;

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navProvider);
    final isNavVisible = ref.watch(bottomNavVisibilityProvider);
    final isNavHidden = !isNavVisible;
    final navSettings = ref.watch(navSettingsProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final readLoc = ref.watch(readLocationProvider);

    final screens = [
      const HomeScreen(),
      const ReadScreen(),
      const SearchScreen(),
      const StudyScreen(),
      const SettingsScreen(),
    ];

    final appThemeMode = ref.watch(themeProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens.asMap().entries.map((entry) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBackground(
                      appThemeMode: appThemeMode,
                      tabIndex: entry.key,
                    ),
                  ),
                  entry.value,
                ],
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Builder(
          builder: (context) {
            final style = ref.watch(readSettingsProvider.select((s) => s.verseActionStyle));
            final isMinimalAction = currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.horizontal;
            final isRaindropAction = currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.raindrop;
            final effectiveNavHidden = isNavHidden && !isRaindropAction && !isMinimalAction;
            final double rawWidth = MediaQuery.of(context).size.width;
            final double availableWidth = rawWidth > 0 ? rawWidth : 360.0;
            final double maxDockWidth = 450.0;
            final double dockMaxWidth = math.max(
                250.0, math.min(maxDockWidth, availableWidth - 40 - 72 - 16));
            final double totalExpandedWidth = dockMaxWidth + 12.0 + 72.0;
            final double rightOffset =
                math.max(20.0, (availableWidth - totalExpandedWidth) / 2);
            final double height =
                (currentIndex == 1 && selectedVerses.isNotEmpty && style != VerseActionStyle.horizontal) ? 420.0 : 72.0;

            return SizedBox(
              height: height + (kBottomDockInset * 2),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: rightOffset,
                    bottom: kBottomDockInset,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: effectiveNavHidden ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: effectiveNavHidden,
                            child: TweenAnimationBuilder<BorderRadius?>(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              tween: BorderRadiusTween(
                                begin: BorderRadius.circular(kBottomDockHeight / 2),
                                end: effectiveNavHidden
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        bottomLeft: Radius.circular(32),
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      )
                                    : BorderRadius.circular(kBottomDockHeight / 2),
                              ),
                              builder: (context, radius, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {},
                                      ),
                                    ),
                                    TexturedGlassContainer(
                                      borderRadius:
                                          radius ?? BorderRadius.circular(kBottomDockHeight / 2),
                                      padding: EdgeInsets.zero,
                                      child: child!,
                                    ),
                                  ],
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                height: kBottomDockHeight,
                                width: effectiveNavHidden ? 0.0 : (isRaindropAction ? 180.0 : dockMaxWidth),
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerRight,
                                    minWidth: isRaindropAction ? 180.0 : dockMaxWidth,
                                    maxWidth: isRaindropAction ? 180.0 : dockMaxWidth,
                                    minHeight: kBottomDockHeight,
                                    maxHeight: kBottomDockHeight,
                                    child: SizedBox(
                                      width: isRaindropAction ? 180.0 : dockMaxWidth,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: isRaindropAction ? 0.0 : 8.0, 
                                            horizontal: isRaindropAction ? 0.0 : 24.0),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                          child: isMinimalAction
                                              ? _buildStyle3ActionRow(context, ref, Theme.of(context))
                                              : isRaindropAction
                                                  ? _buildRaindropColorRow(context, ref, Theme.of(context))
                                                  : Row(
                                                      key: const ValueKey('nav_tabs'),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                            _buildNavItem(
                                              context,
                                              ref,
                                              index: 0,
                                              icon: Icons.home_outlined,
                                              activeIcon: Icons.home,
                                              label: 'Home',
                                              currentIndex: currentIndex,
                                            ),
                                            _buildNavItem(
                                              context,
                                              ref,
                                              index: 1,
                                              icon: Icons.menu_book_outlined,
                                              activeIcon: Icons.menu_book,
                                              label: 'Read',
                                              currentIndex: currentIndex,
                                            ),
                                            _buildNavItem(
                                              context,
                                              ref,
                                              index: 3,
                                              icon: Icons.school_outlined,
                                              activeIcon: Icons.school,
                                              label: 'Study',
                                              currentIndex: currentIndex,
                                            ),
                                            _buildNavItem(
                                              context,
                                              ref,
                                              index: 2,
                                              icon: Icons.search,
                                              activeIcon: Icons.search,
                                              label: 'Search',
                                              currentIndex: currentIndex,
                                            ),
                                          ],
                                        ),
                                        ), // AnimatedSwitcher
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: effectiveNavHidden ? 0.0 : kBottomDockGap, // Collapse the gap too!
                        ),
                        // ── Dynamic Contextual FAB (Right) ──
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(
                            begin: kBottomDockHeight,
                            end: (currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.classic) ? 400.0 : kBottomDockHeight,
                          ),
                          builder: (context, height, child) {
                            final bool isClassicAction = currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.classic;
                            final bool isRaindropAction = currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.raindrop;
                            return Stack(
                              alignment: Alignment.bottomRight,
                              clipBehavior: Clip.none,
                              children: [
                                // Expand bounds to catch Top Pill hits
                                if (isClassicAction)
                                  SizedBox(width: 250, height: height + 70),

                                // ── Raindrop Vertical Pill ──
                                if (isRaindropAction)
                                  Positioned(
                                    bottom: kBottomDockHeight + kBottomDockGap, // Above the FAB
                                    right: 0,
                                    child: BouncyEntrance(
                                      isVisible: true,
                                      delay: const Duration(milliseconds: 40),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned.fill(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {},
                                            ),
                                          ),
                                          TexturedGlassContainer(
                                            borderRadius: BorderRadius.circular(kBottomDockHeight / 2),
                                            padding: EdgeInsets.zero,
                                            child: SizedBox(
                                              width: kBottomDockHeight,
                                              height: 280, // Accommodate 5 icons (56 * 5)
                                              child: _buildActionMenuIcons(context, ref, Theme.of(context), showCloseIcon: false),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // ── Classic Top Pill (Verse + Colors) ──
                                Positioned(
                                  bottom: height + kBottomDockGap,
                                  right: 0,
                                  child: IgnorePointer(
                                    ignoring: !isClassicAction,
                                    child: BouncyEntrance(
                                      isVisible: isClassicAction,
                                      delay: const Duration(milliseconds: 40),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned.fill(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {}, // Eat taps on the background
                                            ),
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {}, // Also eat taps inside the container bounds
                                            child: TexturedGlassContainer(
                                            borderRadius: BorderRadius.circular(36),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 12.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                            children: [
                                            Text(
                                              '${selectedVerses.length}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                            ),
                                            const SizedBox(width: 12),
                                            ...List.generate(
                                                highlightPalette.length, (i) {
                                              final color = highlightPalette[i];
                                              final highlights =
                                                  ref.watch(highlightsProvider);
                                              final allHaveThisColor =
                                                  selectedVerses.every((v) {
                                                final refStr = generateVerseKey(
                                                    readLoc.bookName,
                                                    readLoc.chapter,
                                                    v);
                                                return highlights
                                                        .containsKey(refStr) &&
                                                    highlights[refStr] == i;
                                              });

                                              return _buildColorDot(
                                                color,
                                                isSelected: allHaveThisColor,
                                                onTap: () {
                                                  ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(i);
                                                  VerseActionLogic.handleHighlight(context, Theme.of(context), ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList(), i);
                                                  ref.read(readSelectionProvider.notifier).clear();
                                                },
                                              );
                                            }),
                                          ],
                                        ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                                // ── Morphing FAB / Bottom Pill ──
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {},
                                  child: TexturedGlassContainer(
                                    borderRadius: BorderRadius.circular(kBottomDockHeight / 2),
                                    padding: EdgeInsets.zero,
                                    child: SizedBox(
                                      width: kBottomDockHeight,
                                      height: height,
                                      child: ClipRect(
                                        child: OverflowBox(
                                          minHeight: kBottomDockHeight,
                                          maxHeight: 400,
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedSwitcher(
                                            duration:
                                                const Duration(milliseconds: 300),
                                            child: isClassicAction
                                                ? _buildActionMenuIcons(context,
                                                    ref, Theme.of(context))
                                                : SizedBox(
                                                    key: const ValueKey('fab'),
                                                    height: kBottomDockHeight,
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: AnimatedSwitcher(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          transitionBuilder:
                                                              (Widget child,
                                                                  Animation<
                                                                          double>
                                                                      animation) {
                                                            return ScaleTransition(
                                                              scale: animation,
                                                              child:
                                                                  RotationTransition(
                                                                turns: Tween<
                                                                            double>(
                                                                        begin:
                                                                            0.5,
                                                                        end: 1.0)
                                                                    .animate(
                                                                        animation),
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child: (isRaindropAction) 
                                                              ? const Icon(Icons.close_rounded, size: 28, key: ValueKey('raindrop_close'))
                                                              : _buildFabIcon(
                                                                  currentIndex,
                                                                  navSettings,
                                                                  ref),
                                                        ),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: () {
                                                          if (isRaindropAction) {
                                                            ref.read(readSelectionProvider.notifier).clear();
                                                          } else {
                                                            _handleFabTap(
                                                                currentIndex,
                                                                ref,
                                                                context);
                                                          }
                                                        }
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFabIcon(
      int currentIndex, NavSettingsState navSettings, WidgetRef ref) {
    if (currentIndex == 0) {
      return Stack(
        key: const ValueKey('settings_entry'),
        alignment: Alignment.center,
        children: const [
          Icon(Icons.settings, size: 28),
          Icon(Icons.add, size: 18), // A prominent cross
        ],
      );
    } else if (currentIndex == 4) {
      return const Icon(Icons.close_rounded,
          size: 28, key: ValueKey('settings_close'));
    }

    IconData iconData;
    switch (currentIndex) {
      case 1: // Read
        iconData = ref.watch(immersiveModeProvider)
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded;
        break;
      case 2: // Search
        iconData = Icons.tune_rounded;
        break;
      case 3: // Study
        iconData = Icons.auto_awesome;
        break;
      default:
        iconData = Icons.add_rounded;
    }
    return Icon(
      iconData,
      key: ValueKey<int>(
          currentIndex * 10 + (ref.watch(immersiveModeProvider) ? 1 : 0)),
      size: 24,
    );
  }

  void _changeTab(int index, WidgetRef ref, BuildContext context) {
    // 1. Clear active verse selection
    ref.read(readSelectionProvider.notifier).clear();
    // 2. Dismiss any active keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    // 3. Clear any transient SnackBars/Banners
    ScaffoldMessenger.of(context).clearSnackBars();

    // Switch tab
    ref.read(navProvider.notifier).setIndex(index);
  }

  void _handleFabTap(int currentIndex, WidgetRef ref, BuildContext context) {
    switch (currentIndex) {
      case 0:
        // Home -> Opens global settings
        _changeTab(4, ref, context);
        break;
      case 1:
        // Read -> Toggle Manual Minimize
        final isHidden = ref.read(readSettingsProvider).isManualNavHidden;
        ref.read(readSettingsProvider.notifier).setManualNavHidden(!isHidden);
        ref.read(immersiveModeProvider.notifier).set(!isHidden);
        break;
      case 2:
        // Search tab: no FAB action (search bar is in the screen itself)
        break;
      case 3:
        // Study -> I'm Feeling Lucky
        _handleImFeelingLucky(context, ref);
        break;
      case 4:
        // Settings -> Return to Home
        _changeTab(0, ref, context);
        break;
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
  }) {
    final isActive = index == currentIndex;
    final theme = Theme.of(context);
    final color = isActive
        ? theme.primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    Widget iconWidget;
    if (label == 'Home') {
      iconWidget = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: Icon(
          isActive ? Icons.home : Icons.home_outlined,
          key: ValueKey(isActive),
          color: color,
          size: 24,
        ),
      );
    } else if (label == 'Read') {
      iconWidget = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: Icon(
          isActive ? Icons.auto_stories : Icons.menu_book,
          key: ValueKey(isActive),
          color: color,
          size: 24,
        ),
      );
    } else if (label == 'Study') {
      iconWidget = TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0.0, end: isActive ? 0.2 : 0.0),
        builder: (context, rotation, child) {
          return Transform.rotate(
            angle: rotation,
            child: Icon(Icons.school, color: color, size: 24),
          );
        },
      );
    } else if (label == 'Search') {
      iconWidget = TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 1.0, end: isActive ? 1.2 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Icon(Icons.search, color: color, size: 24),
          );
        },
      );
    } else {
      iconWidget = Icon(isActive ? activeIcon : icon, color: color, size: 24);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index != currentIndex) {
            _changeTab(index, ref, context);
          } else {
            // Tapping the same tab can act as a pop-to-root, but here we just clear transient state
            _changeTab(index, ref, context);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 24),
      color: color,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  Widget _buildColorDot(Color color,
      {bool isSelected = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Container(
            width: 20,
            height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border:
                isSelected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1)
                  ]
                : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenuIcons(
      BuildContext context, WidgetRef ref, ThemeData theme, {bool showCloseIcon = true}) {
    final readLoc = ref.watch(readLocationProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    return SizedBox(
      key: const ValueKey('action_menu_icons'),
      height: showCloseIcon ? 400.0 : 280.0, // Reduced height for Raindrop
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionIcon(
              selectedVerses.every((v) => bookmarks.contains(
                      generateVerseKey(readLoc.bookName, readLoc.chapter, v)))
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              'Bookmark',
              selectedVerses.every((v) => bookmarks.contains(
                      generateVerseKey(readLoc.bookName, readLoc.chapter, v)))
                  ? theme.primaryColor
                  : theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleBookmark(context, theme, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            _buildActionIcon(
              Icons.copy_rounded,
              'Copy',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleCopy(context, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            _buildActionIcon(
              Icons.note_add_outlined,
              'Note',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleNote(context, ref, theme, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            _buildActionIcon(
              Icons.lightbulb_outline_rounded,
              'Commentary',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleCommentary(context, ref, readLoc.bookName, readLoc.chapter, 1, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            _buildActionIcon(
              Icons.ios_share_rounded,
              'Share',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleShare(context, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            if (showCloseIcon)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                onPressed: () => ref.read(readSelectionProvider.notifier).clear(),
              ),
          ],
        ),
      ),
    );
  }

  void _handleImFeelingLucky(BuildContext context, WidgetRef ref) {
    final commentaryAsync = ref.read(combinedCommentaryProvider);
    if (commentaryAsync is AsyncData<CombinedCommentaryState>) {
      final state = commentaryAsync.value;

      List<String> availableVerses = [];
      for (var book in state.data.keys) {
        for (var chapter in state.data[book]!.keys) {
          for (var verse in state.data[book]![chapter]!.keys) {
            if (state.data[book]![chapter]![verse]!.isNotEmpty) {
              availableVerses.add('$book $chapter:$verse');
            }
          }
        }
      }

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
          final fc = flatChapters.firstWhere(
              (c) => c.book.name == bookName && c.chapter.number == chapter);
          // Just push the VerseDetailScreen without switching the active tab.
          ref.read(readLocationProvider.notifier).updateLocation(
                bookAbbrev: fc.book.abbreviation,
                bookName: bookName,
                chapter: chapter,
                verse: verseNum,
              );
          ref.read(activeStudyVerseProvider.notifier).setVerse('$bookName $chapter:$verseNum');

          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VerseDetailScreen(reference: '$bookName $chapter:$verseNum')));
        } catch (_) {}
      }
    }
  }

  static bool _hasShownStyle3Hint = false;

  Widget _buildStyle3ActionRow(BuildContext context, WidgetRef ref, ThemeData theme) {
    if (!_hasShownStyle3Hint) {
      _hasShownStyle3Hint = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Long-press a verse for more actions'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }

    final readLoc = ref.watch(readLocationProvider);
    final readSettings = ref.watch(readSettingsProvider);

    final selectedVerses = ref.watch(readSelectionProvider);
    final targetVerses = selectedVerses.toList();
    final bookmarks = ref.watch(bookmarksProvider);
    final highlights = ref.watch(highlightsProvider);
    final chapterNum = readLoc.chapter;
    final bookName = readLoc.bookName;
    
    final isHighlighted = targetVerses.isNotEmpty && targetVerses.every((v) {
      final refStr = generateVerseKey(bookName, chapterNum, v);
      return highlights.containsKey(refStr);
    });

    final isBookmarked = targetVerses.isNotEmpty && targetVerses.every((v) {
      final refStr = generateVerseKey(bookName, chapterNum, v);
      return bookmarks.contains(refStr);
    });
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Blocks tap-through to verses
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        key: const ValueKey('nav_tabs_style3'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionIcon(
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            'Bookmark',
            isBookmarked ? theme.primaryColor : theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleBookmark(context, theme, ref, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.copy_rounded,
            'Copy',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleCopy(context, ref, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.edit_document,
            'Note',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleNote(context, ref, theme, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            isHighlighted ? Icons.highlight_rounded : Icons.highlight_outlined,
            'Highlight',
            isHighlighted ? theme.primaryColor : theme.colorScheme.onSurface,
            () {
              final primaryColorIndex = readSettings.primaryHighlightColorIndex;
              final activeIndex = (primaryColorIndex >= 0 && primaryColorIndex < 5) ? primaryColorIndex : 2;
              VerseActionLogic.handleHighlight(context, theme, ref, bookName, chapterNum, targetVerses, activeIndex);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.ios_share_rounded,
            'Share',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleShare(context, ref, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(width: 1, height: 28, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          ),
          _buildColorDotRow(context, ref, displayOrder: [
            readSettings.primaryHighlightColorIndex, 
            readSettings.secondaryHighlightColorIndex, 
            ...List.generate(5, (i) => i).where((i) => i != readSettings.primaryHighlightColorIndex && i != readSettings.secondaryHighlightColorIndex)
          ]),
          _buildActionIcon(
            Icons.close_rounded,
            'Close',
            theme.colorScheme.onSurface.withValues(alpha: 0.5),
            () => ref.read(readSelectionProvider.notifier).clear(),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildColorDotRow(BuildContext context, WidgetRef ref, {List<int>? displayOrder}) {
    final theme = Theme.of(context);
    final readSettings = ref.watch(readSettingsProvider);
    final activeIndex = readSettings.activeHighlightColorIndex;
    final order = displayOrder ?? List.generate(highlightPalette.length, (i) => i);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(order.length, (i) {
        final paletteIndex = order[i];
        return _buildColorDot(
          highlightPalette[paletteIndex],
          isSelected: paletteIndex == activeIndex,
          onTap: () {
            ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(paletteIndex);
            
            final readLoc = ref.read(readLocationProvider);
            final targetVerses = ref.read(readSelectionProvider).toList();
            VerseActionLogic.handleHighlight(context, theme, ref, readLoc.bookName, readLoc.chapter, targetVerses, paletteIndex);
            ref.read(readSelectionProvider.notifier).clear();
          },
        );
      }),
    );
  }

  Widget _buildRaindropColorRow(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      height: kBottomDockHeight,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            key: const ValueKey('nav_tabs_raindrop'),
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildColorDotRow(context, ref),
            ],
          ),
        ),
      ),
    );
  }
}

