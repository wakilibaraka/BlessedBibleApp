import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/glass_ui_provider.dart';
import '../../state/nav_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(glassUiProvider);
    final navSettings = ref.watch(navSettingsProvider);

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
        ],
      ),
    );
  }
}
