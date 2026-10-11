import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../state/locale_provider.dart';

/// Settings row that shows the interface language and opens the picker.
class LanguageSettingsTile extends ConsumerWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(appLocaleProvider);
    final current = locale == null ? null : appLanguageFor(locale.languageCode);
    return ListTile(
      leading:
          Icon(Icons.translate_rounded, color: Theme.of(context).primaryColor),
      title: Text(l10n.languageTitle),
      subtitle: Text(current?.nativeName ?? l10n.languageSystem),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        HapticFeedback.selectionClick();
        showLanguagePicker(context);
      },
    );
  }
}

Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appLocaleProvider)?.languageCode;
    final theme = Theme.of(context);

    Widget option(String? code, String title, {String? subtitle}) {
      final isSelected = code == selected;
      return ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        selected: isSelected,
        trailing: isSelected
            ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
            : null,
        onTap: () async {
          unawaited(HapticFeedback.selectionClick());
          await ref.read(appLocaleProvider.notifier).setLanguage(code);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Semantics(
                header: true,
                child:
                    Text(l10n.languageTitle, style: theme.textTheme.titleLarge),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.languageSubtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
            option(null, l10n.languageSystem,
                subtitle: deviceLanguage().nativeName),
            for (final language in appLanguages)
              option(language.code, language.nativeName),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
