import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/glass_ui_provider.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../services/backup_service.dart';

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
          Consumer(builder: (context, ref, _) {
            final classicSearch = ref.watch(searchSettingsProvider.select((s) => s.useClassicSearch));
            return SwitchListTile(
              title: const Text('Classic Search UI'),
              subtitle: const Text('Use the old full-screen search layout'),
              value: classicSearch,
              onChanged: (value) => ref.read(searchSettingsProvider.notifier).toggleClassicSearch(value),
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Reading',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final viewMode = ref.watch(readSettingsProvider.select((s) => s.readingViewMode));
            return _AnimatedSegmentedTile<ReadingViewMode>(
              title: 'Immersive Reading',
              subtitle: 'Hide navigation bars while scrolling',
              selectedValue: viewMode,
              options: const [
                MapEntry(ReadingViewMode.immersive, 'On'),
                MapEntry(ReadingViewMode.pinned, 'Off'),
              ],
              onChanged: (val) => ref.read(readSettingsProvider.notifier).setReadingViewMode(val),
            );
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Advanced',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final glowStyle = ref.watch(readSettingsProvider.select((s) => s.backgroundGlowStyle));
            final swipeDown = ref.watch(bibleNavSettingsProvider.select((s) => s.swipeDownToNav));
            
            return Column(
              children: [
                _AnimatedSegmentedTile<BackgroundGlowStyle>(
                  title: 'Background Glow',
                  subtitle: 'Position of the animated background glow in Read view',
                  selectedValue: glowStyle,
                  options: const [
                    MapEntry(BackgroundGlowStyle.top, 'Top glow (default)'),
                    MapEntry(BackgroundGlowStyle.full, 'Full background glow (original)'),
                  ],
                  onChanged: (val) => ref.read(readSettingsProvider.notifier).setBackgroundGlowStyle(val),
                ),
                SwitchListTile(
                  title: Text(
                    'Swipe Down to Open Navigation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Pull down at the top of a chapter to quickly open the Book/Chapter selector.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: swipeDown,
                  activeTrackColor: Theme.of(context).primaryColor,
                  onChanged: (val) => ref.read(bibleNavSettingsProvider.notifier).setSwipeDown(val),
                ),
              ],
            );
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Data & Backup',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_rounded),
                  title: const Text('Back up my data'),
                  subtitle: const Text('Export notes, highlights, and settings'),
                  onTap: () => BackupService.exportData(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Restore from backup'),
                  subtitle: const Text('Import your data from a backup JSON'),
                  onTap: () {
                    final controller = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Restore from Backup'),
                        content: TextField(
                          controller: controller,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Paste your backup JSON here...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final text = controller.text.trim();
                              Navigator.of(ctx).pop();
                              if (text.isNotEmpty) {
                                BackupService.importData(context, ref, text);
                              }
                            },
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),
          const SizedBox(height: 32),
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
