import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/glass_ui_provider.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/bible_nav_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Consumer(builder: (context, ref, _) {
            final isGlassy = ref.watch(glassUiProvider);
            return SwitchListTile(
              title: const Text('Frosted Glass UI'),
              subtitle: const Text('Enable ultra-thin Apple-style liquid glass'),
              value: isGlassy,
              onChanged: (value) => ref.read(glassUiProvider.notifier).set(value),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final alwaysShowNav = ref.watch(navSettingsProvider.select((s) => s.alwaysShowNav));
            return SwitchListTile(
              title: const Text('Always show navigation bar'),
              subtitle: const Text('Keep bottom nav visible even when verses are selected'),
              value: alwaysShowNav,
              onChanged: (value) => ref.read(navSettingsProvider.notifier).setAlwaysShowNav(value),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final autoOpen = ref.watch(searchSettingsProvider.select((s) => s.autoOpenSingleSearchResult));
            return SwitchListTile(
              title: const Text('Auto-open single search result'),
              subtitle: const Text('Automatically navigate when a search returns exactly one result'),
              value: autoOpen,
              onChanged: (value) => ref.read(searchSettingsProvider.notifier).toggleAutoOpen(value),
            );
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Bible Navigation',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final layout = ref.watch(bibleNavSettingsProvider.select((s) => s.layout));
            return _AnimatedSegmentedTile<TestamentLayout>(
              title: 'Testament Layout',
              subtitle: 'How Old/New Testament books are arranged',
              selectedValue: layout,
              options: const [
                MapEntry(TestamentLayout.sideBySide, 'Side-by-side'),
                MapEntry(TestamentLayout.stickySections, 'Sticky sections'),
                MapEntry(TestamentLayout.filterTabs, 'Filter tabs'),
              ],
              onChanged: (val) => ref.read(bibleNavSettingsProvider.notifier).setLayout(val),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final depth = ref.watch(bibleNavSettingsProvider.select((s) => s.depth));
            return _AnimatedSegmentedTile<NavigationDepth>(
              title: 'Navigation Depth',
              subtitle: 'Steps to reach a verse',
              selectedValue: depth,
              options: const [
                MapEntry(NavigationDepth.twoPart, '2-part'),
                MapEntry(NavigationDepth.threePart, '3-part'),
                MapEntry(NavigationDepth.fourPart, '4-part'),
              ],
              onChanged: (val) => ref.read(bibleNavSettingsProvider.notifier).setDepth(val),
            );
          }),
          Consumer(builder: (context, ref, _) {
            final autoClose = ref.watch(bibleNavSettingsProvider.select((s) => s.autoCloseOnFinalSelection));
            return SwitchListTile(
              title: const Text('Auto-close sheet on final selection'),
              subtitle: const Text('Automatically dismiss the picker after the last step'),
              value: autoClose,
              onChanged: (value) => ref.read(bibleNavSettingsProvider.notifier).setAutoClose(value),
            );
          }),
        ],
      ),
    );
  }
}

class _AnimatedSegmentedTile<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T selectedValue;
  final List<MapEntry<T, String>> options;
  final ValueChanged<T> onChanged;

  const _AnimatedSegmentedTile({
    required this.title,
    required this.subtitle,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: options.map((entry) {
                final isSelected = entry.key == selectedValue;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(entry.key),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected 
                            ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
