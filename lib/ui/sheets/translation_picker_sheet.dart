import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/translation_provider.dart';
import '../../data/models/translation_model.dart';

class TranslationPickerSheet extends ConsumerWidget {
  const TranslationPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeTranslationId = ref.watch(activeTranslationProvider);
    final availableTranslations = ref.watch(availableTranslationsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bible Translation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred Bible translation.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Group by language
          availableTranslations.when(
            data: (translations) => Column(
              children: _buildTranslationList(context, ref, theme, activeTranslationId, translations),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading translations: $e')),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTranslationList(
    BuildContext context, 
    WidgetRef ref, 
    ThemeData theme,
    String activeTranslationId,
    List<TranslationInfo> translations,
  ) {
    // We group by language
    final grouped = <String, List<TranslationInfo>>{};
    for (final t in translations) {
      final lang = t.languageName;
      grouped[lang] = grouped[lang] ?? [];
      grouped[lang]!.add(t);
    }

    final children = <Widget>[];

    for (final entry in grouped.entries) {
      final lang = entry.key;
      final list = entry.value;

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
          child: Text(
            lang,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );

      for (final t in list) {
        final isSelected = t.translationId == activeTranslationId;
        
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              color: isSelected 
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ref.read(activeTranslationProvider.notifier).setTranslation(t.translationId);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected 
                          ? theme.primaryColor.withValues(alpha: 0.5)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translationName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (t.license.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                t.license,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return children;
  }
}
