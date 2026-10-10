import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/credits.dart';
import 'settings_screen.dart' show packageInfoProvider;

/// Sources, licenses and attributions for bundled content, plus the
/// open-source licenses page.
class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(packageInfoProvider).value?.version;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits & sources'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final section in kCreditSections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                section.heading,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            if (section.note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  section.note!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            for (final item in section.items)
              ListTile(
                title: Text(item.title),
                subtitle: Text(item.detail),
              ),
            const Divider(height: 1, indent: 16),
          ],
          ListTile(
            title: const Text('Open-source licenses'),
            subtitle: const Text('Fonts and software packages'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'The Blessed Bible',
              applicationVersion: version,
            ),
          ),
        ],
      ),
    );
  }
}
