import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
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
                  index: 2,
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  label: 'Search',
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
                  index: 4,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  currentIndex: currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
