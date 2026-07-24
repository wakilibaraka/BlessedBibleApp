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
import 'package:flutter/services.dart';
import 'notes_list_screen.dart';

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(navProvider);
    final isNavVisible = ref.watch(bottomNavVisibilityProvider);
    final isNavHidden = !isNavVisible;
    final navSettings = ref.watch(navSettingsProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final favorites = ref.watch(favoritesProvider);
    final readLoc = ref.watch(readLocationProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

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
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Builder(
          builder: (context) {
            final double rawWidth = MediaQuery.of(context).size.width;
            final double availableWidth = rawWidth > 0 ? rawWidth : 360.0;
            final double maxDockWidth = 450.0;
            final double dockMaxWidth = math.max(250.0, math.min(maxDockWidth, availableWidth - 40 - 72 - 16));
            final double totalExpandedWidth = dockMaxWidth + 12.0 + 72.0;
            final double rightOffset = math.max(20.0, (availableWidth - totalExpandedWidth) / 2);
            final double height = (currentIndex == 1 && selectedVerses.isNotEmpty) ? 300.0 : 72.0;

            return SizedBox(
              height: height + 32.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: rightOffset,
                    bottom: 16.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isNavHidden ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: isNavHidden,
                            child: TweenAnimationBuilder<BorderRadius?>(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              tween: BorderRadiusTween(
                                begin: BorderRadius.circular(32),
                                end: isNavHidden 
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        bottomLeft: Radius.circular(32),
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      )
                                    : BorderRadius.circular(32),
                              ),
                              builder: (context, radius, child) {
                                return TexturedGlassContainer(
                                  borderRadius: radius ?? BorderRadius.circular(32),
                                  padding: EdgeInsets.zero,
                                  child: child!,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                height: 64.0,
                                width: isNavHidden ? 0.0 : dockMaxWidth,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerRight,
                                    minWidth: dockMaxWidth,
                                    maxWidth: dockMaxWidth,
                                    minHeight: 64.0,
                                    maxHeight: 64.0,
                                    child: SizedBox(
                                      width: dockMaxWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                                        child: Row(
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
                          width: isNavHidden ? 0.0 : 12.0, // Collapse the gap too!
                        ),
                        // ── Dynamic Contextual FAB (Right) ──
                        Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // ── Default FAB ──
                            BouncyEntrance(
                              isVisible: !(currentIndex == 1 && selectedVerses.isNotEmpty),
                              duration: const Duration(milliseconds: 400),
                              animateIn: false,
                              child: TexturedGlassContainer(
                                borderRadius: BorderRadius.circular(28),
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: RotationTransition(
                                              turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildFabIcon(currentIndex, navSettings, ref),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        _handleFabTap(currentIndex, ref, context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // ── Two Pills Action Menu ──
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IgnorePointer(
                                ignoring: !(currentIndex == 1 && selectedVerses.isNotEmpty),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Top Pill (Verse + Colors)
                                    BouncyEntrance(
                                      isVisible: currentIndex == 1 && selectedVerses.isNotEmpty,
                                      delay: const Duration(milliseconds: 40), // Staggered
                                      child: TexturedGlassContainer(
                                        borderRadius: BorderRadius.circular(36),
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${selectedVerses.length}',
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            _buildColorDot(Colors.yellow.withValues(alpha: 0.8)),
                                            _buildColorDot(Colors.lightGreen.withValues(alpha: 0.8)),
                                            _buildColorDot(Colors.lightBlue.withValues(alpha: 0.8)),
                                            _buildColorDot(Colors.pinkAccent.withValues(alpha: 0.8)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Bottom Pill (Actions)
                                    BouncyEntrance(
                                      isVisible: currentIndex == 1 && selectedVerses.isNotEmpty,
                                      delay: Duration.zero, // Bottom appears first
                                      child: TexturedGlassContainer(
                                        borderRadius: BorderRadius.circular(36),
                                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                                        child: SizedBox(
                                          width: 72,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildActionIcon(
                                                selectedVerses.every((v) => bookmarks.contains('${readLoc.bookName} ${readLoc.chapter}:$v'))
                                                    ? Icons.bookmark_rounded
                                                    : Icons.bookmark_border_rounded,
                                                'Bookmark',
                                                selectedVerses.every((v) => bookmarks.contains('${readLoc.bookName} ${readLoc.chapter}:$v'))
                                                    ? theme.primaryColor
                                                    : Theme.of(context).colorScheme.onSurface,
                                                () {
                                                  final isAllBookmarked = selectedVerses.every((v) => bookmarks.contains('${readLoc.bookName} ${readLoc.chapter}:$v'));
                                                  for (var v in selectedVerses) {
                                                    final refStr = '${readLoc.bookName} ${readLoc.chapter}:$v';
                                                    if (isAllBookmarked) {
                                                      ref.read(bookmarksProvider.notifier).toggle(refStr); // remove
                                                    } else {
                                                      if (!bookmarks.contains(refStr)) ref.read(bookmarksProvider.notifier).toggle(refStr); // add
                                                    }
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(isAllBookmarked ? 'Bookmark(s) removed' : '${selectedVerses.length} verse(s) bookmarked!'),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                  ref.read(readSelectionProvider.notifier).clear();
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              _buildActionIcon(
                                                selectedVerses.every((v) => favorites.contains('${readLoc.bookName} ${readLoc.chapter}:$v'))
                                                    ? Icons.star_rounded
                                                    : Icons.star_outline_rounded,
                                                'Favorite',
                                                selectedVerses.every((v) => favorites.contains('${readLoc.bookName} ${readLoc.chapter}:$v'))
                                                    ? Colors.amber
                                                    : Theme.of(context).colorScheme.onSurface,
                                                () {
                                                  final isAllFavorited = selectedVerses.every((v) => favorites.contains('${readLoc.bookName} ${readLoc.chapter}:$v'));
                                                  for (var v in selectedVerses) {
                                                    final refStr = '${readLoc.bookName} ${readLoc.chapter}:$v';
                                                    if (isAllFavorited) {
                                                      ref.read(favoritesProvider.notifier).toggle(refStr);
                                                    } else {
                                                      if (!favorites.contains(refStr)) ref.read(favoritesProvider.notifier).toggle(refStr);
                                                    }
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(isAllFavorited ? 'Removed from Favorites' : '${selectedVerses.length} verse(s) favorited!'),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                  ref.read(readSelectionProvider.notifier).clear();
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              _buildActionIcon(
                                                Icons.copy_rounded,
                                                'Copy',
                                                Theme.of(context).colorScheme.onSurface,
                                                () {
                                                  if (flatChapters.isNotEmpty) {
                                                    try {
                                                      final chapter = flatChapters.firstWhere(
                                                        (c) => c.book.name == readLoc.bookName && c.chapter.number == readLoc.chapter,
                                                      ).chapter;
                                                      final sorted = selectedVerses.toList()..sort();
                                                      final texts = sorted.map((v) => v - 1 >= 0 && v - 1 < chapter.verses.length ? '$v. ${chapter.verses[v-1].text}' : '').join(' ');
                                                      final refStr = '${readLoc.bookName} ${readLoc.chapter}:${sorted.join(', ')}';
                                                      Clipboard.setData(ClipboardData(text: '$texts — $refStr'));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
                                                      );
                                                    } catch (_) {}
                                                  }
                                                  ref.read(readSelectionProvider.notifier).clear();
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              _buildActionIcon(
                                                Icons.note_add_outlined,
                                                'Note',
                                                Theme.of(context).colorScheme.onSurface,
                                                () {
                                                  final sorted = selectedVerses.toList()..sort();
                                                  final refStr = '${readLoc.bookName} ${readLoc.chapter}:${sorted.join(', ')}';
                                                  showAddNoteSheet(context, theme, initialReference: refStr);
                                                  ref.read(readSelectionProvider.notifier).clear();
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              IconButton(
                                                 icon: const Icon(Icons.auto_awesome),
                                                 color: Colors.redAccent,
                                                 tooltip: 'Deep Study',
                                                 padding: EdgeInsets.zero,
                                                 constraints: const BoxConstraints(),
                                                 visualDensity: VisualDensity.compact,
                                                 onPressed: () {
                                                   ref.read(navProvider.notifier).setIndex(3);
                                                   ref.read(readSelectionProvider.notifier).clear();
                                                 }
                                              ),
                                              const SizedBox(height: 16),
                                              IconButton(
                                                icon: const Icon(Icons.close_rounded, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                visualDensity: VisualDensity.compact,
                                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                                onPressed: () => ref.read(readSelectionProvider.notifier).clear(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildFabIcon(int currentIndex, NavSettingsState navSettings, WidgetRef ref) {
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
      return const Icon(Icons.close_rounded, size: 28, key: ValueKey('settings_close'));
    }

    IconData iconData;
    switch (currentIndex) {
      case 1: // Read
        iconData = ref.watch(immersiveModeProvider) ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded;
        break;
      case 2: // Search
        iconData = Icons.tune_rounded;
        break;
      case 3: // Study
        iconData = Icons.edit_note_rounded;
        break;
      default:
        iconData = Icons.add_rounded;
    }
    return Icon(
      iconData,
      key: ValueKey<int>(currentIndex * 10 + (ref.watch(immersiveModeProvider) ? 1 : 0)),
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
        ref.read(immersiveModeProvider.notifier).toggle();
        break;
      case 2:
        // Search -> Advanced Filters
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advanced filters coming soon!')),
        );
        break;
      case 3:
        // Study -> Notes Popover
        showNotesPopover(context, Theme.of(context));
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
    final color = isActive ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    Widget iconWidget;
    if (label == 'Home') {
      iconWidget = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
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
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
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
          width: 56, // >= 48dp touch target width
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
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
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

  Widget _buildColorDot(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
