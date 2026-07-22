import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/glass_ui_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(glassUiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Frosted Glass UI'),
            subtitle: const Text('Enable ultra-thin Apple-style liquid glass'),
            value: isGlassy,
            onChanged: (value) => ref.read(glassUiProvider.notifier).set(value),
          ),
        ],
      ),
    );
  }
}
