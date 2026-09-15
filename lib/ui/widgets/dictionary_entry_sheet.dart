import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../state/dictionary_provider.dart';
import '../../state/typography_provider.dart';

class DictionaryEntrySheet extends ConsumerWidget {
  final String normalizedWord;

  const DictionaryEntrySheet({super.key, required this.normalizedWord});

  String _formatSourceName(String source) {
    if (source.toLowerCase().contains('easton')) return "Easton's Bible Dictionary";
    if (source.toLowerCase().contains('kjv')) return "KJV Archaic Word";
    return source;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final definitionsAsync = ref.watch(dictionaryDefinitionProvider(normalizedWord));
    final typography = ref.watch(typographyProvider);
    final bookmarkedWords = ref.watch(bookmarkedWordsProvider).asData?.value ?? {};
    final isBookmarked = bookmarkedWords.contains(normalizedWord);

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.5,
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Navigation Bar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 16, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.primaryColor),
                    label: Text('Back', style: TextStyle(fontSize: 16, color: theme.primaryColor)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.read(bookmarkedWordsProvider.notifier).toggleBookmark(normalizedWord);
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isBookmarked ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          final defs = definitionsAsync.asData?.value;
                          if (defs != null && defs.isNotEmpty) {
                            final displayWord = defs.first.displayHeadword;
                            final textToShare = "$displayWord\n\n" + defs.map((d) {
                              return "${_formatSourceName(d.source).toUpperCase()}:\n${d.definition.trim()}";
                            }).join('\n\n');
                            Share.share(textToShare);
                          }
                        },
                        icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ── Content ──────────────────────────────────────────
            Flexible(
              child: definitionsAsync.when(
                data: (defs) {
                  if (defs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No definition found.'),
                    );
                  }

                  final displayWord = defs.first.displayHeadword;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // Hero Word
                      SelectableText(
                        displayWord,
                        style: TextStyle(
                          fontFamily: typography.fontFamily,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.0,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Definition Blocks
                      ...defs.expand((def) {
                        final paragraphs = def.definition.split(RegExp(r'\n+'))
                            .map((p) => p.trim())
                            .where((p) => p.isNotEmpty)
                            .toList();
                            
                        return [
                          Text(
                            _formatSourceName(def.source).toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: theme.dividerColor.withValues(alpha: 0.3), height: 1),
                          const SizedBox(height: 16),
                          ...paragraphs.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: SelectableText.rich(
                              TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: typography.lineHeight,
                                  fontSize: typography.fontSize,
                                  fontFamily: typography.fontFamily,
                                  fontWeight: typography.fontWeight,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                ),
                                children: _parseRichText(p, theme),
                              ),
                            ),
                          )),
                          if (def != defs.last) const SizedBox(height: 16),
                        ];
                      }),
                      
                      const SizedBox(height: 40),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
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

  List<TextSpan> _parseRichText(String text, ThemeData theme) {
    final spans = <TextSpan>[];
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
          fontWeight: FontWeight.w600,
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
