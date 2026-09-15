import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/dictionary_provider.dart';
import '../../state/typography_provider.dart';

class DictionaryEntrySheet extends ConsumerWidget {
  final String normalizedWord;

  const DictionaryEntrySheet({super.key, required this.normalizedWord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final definitionsAsync = ref.watch(dictionaryDefinitionProvider(normalizedWord));
    final typography = ref.watch(typographyProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: definitionsAsync.when(
                      data: (defs) => Text(
                        defs.isNotEmpty ? defs.first.displayHeadword : normalizedWord.toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, __) => const Text('Error'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: definitionsAsync.when(
                data: (defs) {
                  if (defs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No definition found.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: defs.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                    itemBuilder: (context, index) {
                      final def = defs[index];
                      return _buildDefinitionBlock(context, ref, def, theme, typography);
                    },
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CupertinoActivityIndicator(),
                )),
                error: (e, __) => Center(child: Text('Failed to load: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionBlock(BuildContext context, WidgetRef ref, DictionaryDefinition def, ThemeData theme, TypographyState typography) {
    // Break into paragraphs
    final paragraphs = def.definition.split(RegExp(r'\\n+'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            def.source.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...paragraphs.map((p) {
          if (p.trim().isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: typography.fontSize,
                  fontFamily: typography.fontFamily,
                  color: theme.colorScheme.onSurface,
                ),
                children: _parseRichText(p, theme),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<TextSpan> _parseRichText(String text, ThemeData theme) {
    final spans = <TextSpan>[];
    // Simple regex to find text in parentheses, e.g. (Dan. 11:1) or (1.)
    final regex = RegExp(r'\([^)]+\)');
    final matches = regex.allMatches(text);
    
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ));
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }
}
