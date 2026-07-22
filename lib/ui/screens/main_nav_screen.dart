import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../widgets/glass_container.dart';
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
            children: [
              // ── Routing Pill (Left/Center) ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: isImmersive ? 0 : MediaQuery.of(context).size.width - 40 - 72 - 12,
                child: ClipRect(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isImmersive ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: isImmersive,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(32),
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              const SizedBox(width: 12),
              // ── Dynamic Contextual FAB (Right) ──
              GlassContainer(
                borderRadius: BorderRadius.circular(36), // Fully circular
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: 72, // Matches the height of the pill (56 + 16 padding)
                  height: 72,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabIcon(int currentIndex, bool isImmersive) {
    IconData iconData;
    switch (currentIndex) {
      case 0:
        iconData = Icons.tune_rounded;
        break;
      case 1:
        iconData = isImmersive ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded;
        break;
      case 2:
        iconData = Icons.filter_list_rounded;
        break;
      case 3:
        iconData = Icons.edit_note_rounded;
        break;
      default:
        iconData = Icons.more_horiz;
    }
    return Icon(iconData, key: ValueKey<String>('${currentIndex}_$isImmersive'), size: 28);
  }

  void _handleFabTap(int currentIndex, WidgetRef ref, BuildContext context) {
    switch (currentIndex) {
      case 0:
        // Home -> Opens global settings
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

    return GestureDetector(
      onTap: () => ref.read(navProvider.notifier).setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56, // >= 48dp touch target width
        height: 56, // >= 48dp touch target height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
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
    );
  }
}
