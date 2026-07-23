import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/glass_ui_provider.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/bible_nav_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(glassUiProvider);
    final navSettings = ref.watch(navSettingsProvider);
    final searchSettings = ref.watch(searchSettingsProvider);
    final bibleNavSettings = ref.watch(bibleNavSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Frosted Glass UI'),
            subtitle: const Text('Enable ultra-thin Apple-style liquid glass'),
            value: isGlassy,
            onChanged: (value) => ref.read(glassUiProvider.notifier).set(value),
          ),
          SwitchListTile(
            title: const Text('Always show navigation bar'),
            subtitle: const Text('Keep bottom nav visible even when verses are selected'),
            value: navSettings.alwaysShowNav,
            onChanged: (value) => ref.read(navSettingsProvider.notifier).setAlwaysShowNav(value),
          ),
          SwitchListTile(
            title: const Text('Auto-open single search result'),
            subtitle: const Text('Automatically navigate when a search returns exactly one result'),
            value: searchSettings.autoOpenSingleSearchResult,
            onChanged: (value) => ref.read(searchSettingsProvider.notifier).toggleAutoOpen(value),
          ),
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
          ListTile(
            title: const Text('Testament Layout'),
            subtitle: const Text('How Old/New Testament books are arranged'),
            trailing: DropdownButton<TestamentLayout>(
              value: bibleNavSettings.layout,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: TestamentLayout.sideBySide,
                  child: Text('Side-by-side'),
                ),
                DropdownMenuItem(
                  value: TestamentLayout.stickySections,
                  child: Text('Sticky sections'),
                ),
                DropdownMenuItem(
                  value: TestamentLayout.filterTabs,
                  child: Text('Filter tabs'),
                ),
              ],
              onChanged: (val) {
                if (val != null) ref.read(bibleNavSettingsProvider.notifier).setLayout(val);
              },
            ),
          ),
          ListTile(
            title: const Text('Navigation Depth'),
            subtitle: const Text('Steps to reach a verse'),
            trailing: DropdownButton<NavigationDepth>(
              value: bibleNavSettings.depth,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: NavigationDepth.twoPart,
                  child: Text('2-part (Bk \u2192 Ch)'),
                ),
                DropdownMenuItem(
                  value: NavigationDepth.threePart,
                  child: Text('3-part (Bk \u2192 Ch \u2192 Vs)'),
                ),
                DropdownMenuItem(
                  value: NavigationDepth.fourPart,
                  child: Text('4-part (Test \u2192 Bk)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) ref.read(bibleNavSettingsProvider.notifier).setDepth(val);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-close sheet on final selection'),
            subtitle: const Text('Automatically dismiss the picker after the last step'),
            value: bibleNavSettings.autoCloseOnFinalSelection,
            onChanged: (value) => ref.read(bibleNavSettingsProvider.notifier).setAutoClose(value),
          ),
        ],
      ),
    );
  }
}
