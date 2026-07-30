import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';

import 'package:flutter/services.dart';
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
import '../widgets/action_icon.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final selectedVerses = ref.read(readSelectionProvider);
        if (selectedVerses.isNotEmpty) {
          ref.read(readSelectionProvider.notifier).clear();
          return;
        }

        if (currentIndex != 0) {
          _changeTab(0, ref, context);
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit The Blessed Bible?'),
              content: const Text('Are you sure you want to exit the app?'),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Exit', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ],
            );
          },
        );
        
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                _buildGlassWrapper(
                                  key: const ValueKey('unified_bar_container'),
                                  dockMaxWidth: dockMaxWidth,
                                  child: _buildUnifiedDockContent(context, ref, Theme.of(context), currentIndex, isRaindropAction, isMinimalAction),
                                ),
                                if ((isMinimalAction || isRaindropAction) && selectedVerses.isNotEmpty)
                                  Positioned(
                                    top: -18,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        selectedVerses.length == 1 ? '1 verse selected' : '${selectedVerses.length} verses selected',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
                                  left: 16,
                                  right: 16,
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
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              final color = AppColors.getRenderedHighlightColor(highlightPaletteSwatches[i], Theme.of(context).brightness, Theme.of(context).scaffoldBackgroundColor);
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
                                                  final currentTheme = Theme.of(context);
                                                  Future(() {
                                                    if (!context.mounted) return;
                                                    ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(i);
                                                    VerseActionLogic.handleHighlight(context, currentTheme, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList(), i);
                                                  });
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
                                                          child: (currentIndex == 1 && selectedVerses.isNotEmpty) 
                                                              ? const Icon(Icons.close_rounded, size: 28, key: ValueKey('raindrop_close'))
                                                              : _buildFabIcon(
                                                                  currentIndex,
                                                                  navSettings,
                                                                  ref),
                                                        ),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        onPressed: () {
                                                          if (currentIndex == 1 && selectedVerses.isNotEmpty) {
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
    ));
  }

  Widget _buildFabIcon(
      int currentIndex, NavSettingsState navSettings, WidgetRef ref) {
    if (currentIndex == 0) {
      return const Icon(
        Icons.settings,
        size: 28,
        key: ValueKey('settings_entry'),
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
        iconData = Icons.casino_rounded;
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
    HapticFeedback.selectionClick();
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

  Widget _buildMorphingSlot(
    BuildContext context,
    WidgetRef ref, {
    required bool isAction,
    required IconData navIcon,
    required IconData navActiveIcon,
    required String navLabel,
    required int navIndex,
    required int currentIndex,
    required IconData actionIcon,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onActionTap,
    VoidCallback? onActionLongPress,
  }) {
    final theme = Theme.of(context);
    final isActiveNav = navIndex == currentIndex;
    
    final navColor = isActiveNav
        ? theme.primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    final currentIcon = isAction ? actionIcon : (isActiveNav ? navActiveIcon : navIcon);
    final currentColor = isAction ? actionColor : navColor;
    final currentLabel = isAction ? actionLabel : navLabel;
    final isNavActiveStyle = !isAction && isActiveNav;

    Widget buildIcon() {
      if (!isAction) {
        if (navLabel == 'Study') {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: isActiveNav ? 0.2 : 0.0),
            builder: (context, rotation, child) => Transform.rotate(angle: rotation, child: child),
            child: Icon(Icons.school, color: currentColor, size: 24),
          );
        } else if (navLabel == 'Search') {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 1.0, end: isActiveNav ? 1.2 : 1.0),
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Icon(Icons.search, color: currentColor, size: 24),
          );
        }
      }
      return Icon(currentIcon, color: currentColor, size: 24);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isAction) {
            onActionTap();
          } else {
            _changeTab(navIndex, ref, context);
          }
        },
        onLongPress: isAction ? onActionLongPress : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(
                    key: ValueKey('${isAction ? 'action' : 'nav'}_$currentIcon'),
                    child: buildIcon(),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    currentLabel,
                    key: ValueKey(currentLabel),
                    style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'Inter',
                          color: currentColor,
                          fontWeight: isNavActiveStyle ? FontWeight.bold : FontWeight.normal,
                        ),
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
    return ActionIcon(
      icon: icon,
      tooltip: tooltip,
      color: color,
      onTap: onTap,
      size: 24,
    );
  }

  Widget _buildColorDot(Color color,
      {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
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
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black.withValues(alpha: 0.2), 
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [ BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 2) ]
                : [ BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, spreadRadius: 1) ],
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

    return Padding(
      key: const ValueKey('action_menu_icons'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 8),
            _buildActionIcon(
              Icons.copy_rounded,
              'Copy',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleCopy(context, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            const SizedBox(height: 8),
            _buildActionIcon(
              Icons.note_add_outlined,
              'Note',
              theme.colorScheme.onSurface,
              () async {
                await VerseActionLogic.handleNote(context, ref, theme, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            const SizedBox(height: 8),
            _buildActionIcon(
              Icons.lightbulb_outline_rounded,
              'Commentary',
              theme.colorScheme.onSurface,
              () {
                VerseActionLogic.handleCommentary(context, ref, readLoc.bookName, readLoc.chapter, 1, selectedVerses.toList());
              },
            ),
            const SizedBox(height: 8),
            _buildActionIcon(
              Icons.ios_share_rounded,
              'Share',
              theme.colorScheme.onSurface,
              () async {
                await VerseActionLogic.handleShare(context, ref, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),
            if (showCloseIcon) ...[
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                onPressed: () => ref.read(readSelectionProvider.notifier).clear(),
              ),
            ],
          ],
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
              
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CastingLotsDialog(),
          ).then((_) {
            if (!context.mounted) return;
            
            HapticFeedback.selectionClick();
            // Just push the VerseDetailScreen without switching the active tab.
            ref.read(readLocationProvider.notifier).updateLocation(
                  bookAbbrev: fc.book.abbreviation,
                  bookName: bookName,
                  chapter: chapter,
                  verse: verseNum,
                );
            ref.read(activeStudyVerseProvider.notifier).setVerse('$bookName $chapter:$verseNum');

            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => VerseDetailScreen(reference: '$bookName $chapter:$verseNum')));
          });
        } catch (_) {}
      }
    }
  }

  Widget _buildUnifiedDockContent(BuildContext context, WidgetRef ref, ThemeData theme, int currentIndex, bool isRaindropAction, bool isMinimalAction) {
    if (isRaindropAction) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: _buildRaindropColorRow(context, ref, theme),
      );
    }

    final readLoc = ref.watch(readLocationProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final targetVerses = selectedVerses.toList();
    final bookmarks = ref.watch(bookmarksProvider);
    final chapterNum = readLoc.chapter;
    final bookName = readLoc.bookName;
    final isBookmarked = targetVerses.isNotEmpty && targetVerses.every((v) {
      final refStr = generateVerseKey(bookName, chapterNum, v);
      return bookmarks.contains(refStr);
    });

    final actionIconColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Row(
        key: const ValueKey('unified_tabs'),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMorphingSlot(
            context, ref,
            isAction: isMinimalAction,
            navIcon: Icons.home_outlined, navActiveIcon: Icons.home, navLabel: 'Home', navIndex: 0, currentIndex: currentIndex,
            actionIcon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, actionLabel: 'Bookmark',
            actionColor: isBookmarked ? theme.primaryColor : actionIconColor,
            onActionTap: () {
              VerseActionLogic.handleBookmark(context, theme, ref, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildMorphingSlot(
            context, ref,
            isAction: isMinimalAction,
            navIcon: Icons.menu_book_outlined, navActiveIcon: Icons.menu_book, navLabel: 'Read', navIndex: 1, currentIndex: currentIndex,
            actionIcon: Icons.edit_document, actionLabel: 'Notes',
            actionColor: actionIconColor,
            onActionTap: () async {
              await VerseActionLogic.handleNote(context, ref, theme, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildMorphingSlot(
            context, ref,
            isAction: isMinimalAction,
            navIcon: Icons.school_outlined, navActiveIcon: Icons.school, navLabel: 'Study', navIndex: 3, currentIndex: currentIndex,
            actionIcon: Icons.highlight_rounded, actionLabel: 'Highlight',
            actionColor: actionIconColor,
            onActionTap: () {
              VerseActionLogic.handleHighlightInteraction(
                context: context,
                ref: ref,
                theme: theme,
                bookName: bookName,
                chapterNum: chapterNum,
                targetVerses: targetVerses,
                isLongPress: false,
                onClearSelection: () => ref.read(readSelectionProvider.notifier).clear(),
              );
            },
            onActionLongPress: () {
              VerseActionLogic.handleHighlightInteraction(
                context: context,
                ref: ref,
                theme: theme,
                bookName: bookName,
                chapterNum: chapterNum,
                targetVerses: targetVerses,
                isLongPress: true,
                onClearSelection: () => ref.read(readSelectionProvider.notifier).clear(),
              );
            }
          ),
          _buildMorphingSlot(
            context, ref,
            isAction: isMinimalAction,
            navIcon: Icons.search, navActiveIcon: Icons.search, navLabel: 'Search', navIndex: 2, currentIndex: currentIndex,
            actionIcon: Icons.ios_share_rounded, actionLabel: 'Share',
            actionColor: actionIconColor,
            onActionTap: () async {
              await VerseActionLogic.handleShare(context, ref, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassWrapper({required Key key, required double dockMaxWidth, required Widget child}) {
    return TweenAnimationBuilder<BorderRadius?>(
      key: key,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: BorderRadiusTween(
        begin: BorderRadius.circular(kBottomDockHeight / 2),
        end: BorderRadius.circular(kBottomDockHeight / 2),
      ),
      builder: (context, radius, childWidget) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {})),
            TexturedGlassContainer(
              borderRadius: radius ?? BorderRadius.circular(kBottomDockHeight / 2),
              padding: EdgeInsets.zero,
              child: childWidget!,
            ),
          ],
        );
      },
      child: Container(
        height: kBottomDockHeight,
        width: dockMaxWidth,
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: dockMaxWidth,
          child: child,
        ),
      ),
    );
  }


  Widget _buildColorDotRow(BuildContext context, WidgetRef ref, {List<int>? displayOrder}) {
    final theme = Theme.of(context);
    final readLoc = ref.watch(readLocationProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final highlights = ref.watch(highlightsProvider);
    final order = displayOrder ?? List.generate(highlightPalette.length, (i) => i);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 64.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(order.length, (i) {
          final paletteIndex = order[i];
          final allHaveThisColor = selectedVerses.isNotEmpty && selectedVerses.every((v) {
            final refStr = generateVerseKey(readLoc.bookName, readLoc.chapter, v);
            return highlights.containsKey(refStr) && highlights[refStr] == paletteIndex;
          });

          return _buildColorDot(
            AppColors.getRenderedHighlightColor(highlightPaletteSwatches[paletteIndex], theme.brightness, theme.scaffoldBackgroundColor),
            isSelected: allHaveThisColor,
            onTap: () {
              Future(() {
                if (!context.mounted) return;
                ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(paletteIndex);
                
                final targetVerses = ref.read(readSelectionProvider).toList();
                VerseActionLogic.handleHighlight(context, theme, ref, readLoc.bookName, readLoc.chapter, targetVerses, paletteIndex);
                ref.read(readSelectionProvider.notifier).clear();
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildRaindropColorRow(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      height: kBottomDockHeight,
      child: Center(
        child: _buildColorDotRow(context, ref),
      ),
    );
  }
}

class CastingLotsDialog extends StatefulWidget {
  const CastingLotsDialog({super.key});

  @override
  State<CastingLotsDialog> createState() => _CastingLotsDialogState();
}

class _CastingLotsDialogState extends State<CastingLotsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rotation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.4, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldAccent.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scale.value,
                    child: Transform.rotate(
                      angle: _rotation.value,
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.casino_rounded,
                  size: 48,
                  color: AppColors.goldAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Casting lots...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldAccent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
