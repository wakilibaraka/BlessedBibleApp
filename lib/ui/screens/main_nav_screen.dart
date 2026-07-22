import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../widgets/textured_glass_container.dart';
import 'home_screen.dart';
import 'read_screen.dart';
import 'search_screen.dart';
import 'study_screen.dart';
import 'settings_screen.dart';

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navProvider);
    final isImmersive = ref.watch(immersiveModeProvider);
    final selectedVerses = ref.watch(readSelectionProvider);

    final screens = [
      const HomeScreen(),
      const ReadScreen(),
      const SearchScreen(),
      const StudyScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end, // Push everything to the right
            children: [
              // ── Routing Pill (Left/Center) ──
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isImmersive ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: isImmersive,
                  child: TexturedGlassContainer(
                    borderRadius: BorderRadius.circular(32),
                    padding: EdgeInsets.zero,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      width: math.max(0.0, isImmersive ? 0.0 : MediaQuery.of(context).size.width - 40 - 72 - 16),
                      child: ClipRect(
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
            const SizedBox(width: 12.0),
              // ── Dynamic Contextual FAB (Right) ──
              TexturedGlassContainer(
                borderRadius: BorderRadius.circular(36), // Fully circular
                padding: EdgeInsets.zero,
                child: AnimatedContainer(
                  duration: currentIndex == 1 ? const Duration(milliseconds: 650) : Duration.zero,
                  curve: Curves.elasticOut,
                  width: 72,
                  height: (currentIndex == 1 && selectedVerses.isNotEmpty) ? 300.0 : 72.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Circular Icon State
                      AnimatedOpacity(
                        duration: currentIndex == 1 ? const Duration(milliseconds: 200) : Duration.zero,
                        opacity: (currentIndex == 1 && selectedVerses.isNotEmpty) ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: (currentIndex == 1 && selectedVerses.isNotEmpty),
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: _buildFabIcon(currentIndex, isImmersive),
                              ),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                _handleFabTap(currentIndex, ref, context);
                              },
                            ),
                          ),
                        ),
                      ),
                      // Vertical Pill Action State
                      AnimatedOpacity(
                        duration: currentIndex == 1 ? const Duration(milliseconds: 300) : Duration.zero,
                        opacity: (currentIndex == 1 && selectedVerses.isNotEmpty) ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !(currentIndex == 1 && selectedVerses.isNotEmpty),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${selectedVerses.length}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  _buildActionIcon(
                                    Icons.bookmark_border_rounded,
                                    'Bookmark',
                                    Theme.of(context).colorScheme.onSurface,
                                    () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${selectedVerses.length} verse(s) bookmarked!'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      ref.read(readSelectionProvider.notifier).clear();
                                    },
                                  ),
                                  _buildActionIcon(
                                    Icons.note_add_outlined,
                                    'Note',
                                    Theme.of(context).colorScheme.onSurface,
                                    () => ref.read(readSelectionProvider.notifier).clear(),
                                  ),
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
                      ),
                    ),
                  ],
                  ),
                ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabIcon(int currentIndex, bool isImmersive) {
    IconData iconData;
    switch (currentIndex) {
      case 0: // Home
        iconData = Icons.dashboard_rounded;
        break;
      case 1: // Read
        iconData = isImmersive ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded;
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
      key: ValueKey<int>(currentIndex * 10 + (isImmersive ? 1 : 0)),
      size: 28,
    );
  }

  void _handleFabTap(int currentIndex, WidgetRef ref, BuildContext context) {
    switch (currentIndex) {
      case 0:
        // Home -> Opens global settings
        ref.read(readSelectionProvider.notifier).clear();
        ref.read(navProvider.notifier).setIndex(4);
        break;
      case 1:
        // Read -> Toggle Immersive Mode
        ref.read(immersiveModeProvider.notifier).toggle();
        break;
      case 2:
        // Search -> Advanced Filters
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advanced filters coming soon!')),
        );
        break;
      case 3:
        // Study -> Quick Note
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quick note coming soon!')),
        );
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
    final color = isActive ? theme.primaryColor : Colors.grey;

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
          ref.read(readSelectionProvider.notifier).clear();
          ref.read(navProvider.notifier).setIndex(index);
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
                style: TextStyle(
                  color: color,
                  fontSize: 10,
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
}
