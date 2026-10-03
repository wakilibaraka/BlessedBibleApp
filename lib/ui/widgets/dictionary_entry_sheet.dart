import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../state/dictionary_provider.dart';
import '../../state/typography_provider.dart';
import '../dialogs/verse_preview_dialog.dart';

class DictionaryEntrySheet extends ConsumerWidget {
  final String normalizedWord;
  final bool isFloating;

  const DictionaryEntrySheet({super.key, required this.normalizedWord, this.isFloating = false});

  String _formatSourceName(String source) {
    if (source.toLowerCase().contains('easton')) return "Easton's Bible Dictionary";
    if (source.toLowerCase().contains('smith')) return "Smith's Bible Dictionary";
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

    Widget content = Container(
      width: isFloating ? MediaQuery.sizeOf(context).width * 0.9 : double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.3,
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        maxWidth: isFloating ? 500 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: isFloating 
            ? BorderRadius.circular(24) 
            : const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: isFloating ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 8,
          )
        ] : null,
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
                        String formattedDef = def.definition.replaceAllMapped(
                          RegExp(r'\s(\(\d+\.?\)|\d+\.|[IVX]+\.)\s'),
                          (match) => '\n\n${match.group(1)} '
                        );
                        final paragraphs = formattedDef.split(RegExp(r'\n+'))
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
                                children: _parseRichText(context, p, theme),
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
                  child: CircularProgressIndicator(),
                )),
                error: (e, __) => Center(child: Text('Failed to load: $e')),
              ),
            ),
          ],
        ),
      ),
    );

    if (isFloating) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: content,
      );
    }
    return content;
  }

  List<TextSpan> _parseRichText(BuildContext context, String text, ThemeData theme) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\[\[(\d+)\]([^\]]+)\]|([1-3]?\s?[A-Z][a-z]+\.?\s+\d+:\d+(?:-\d+)?)');
    final matches = regex.allMatches(text);
    
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      
      if (match.group(1) != null) {
        // It's a Strong's reference: [[1072]Slave]
        
        final word = match.group(2)!;
        
        spans.add(TextSpan(
          text: word,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () {
             // Depending on whether it's Greek or Hebrew, the ID might need prefixing,
             // but Easton/Smith uses Strongs. Wait, the Strongs DB uses H1072 or G1072.
             // If we don't have H or G, we might need to guess based on context, but let's just use it directly
             // Actually, if we just pass 'H$strongsId' or 'G$strongsId' it might be better, or we can look it up.
             // Since we can't tell, let's just pass 'G$strongsId' as most Smith dictionary references are NT.
             // Actually, maybe it's fine to just show the DictionaryEntrySheet for the word instead of Strongs!
             // Let's launch DictionaryEntrySheet for 'word'
             showDialog(
                context: context,
                builder: (ctx) => DictionaryEntrySheet(normalizedWord: word.toLowerCase(), isFloating: true),
             );
          },
        ));
      } else if (match.group(3) != null) {
        // It's a Verse reference: 1 Cor. 4:4
        final verseRef = match.group(3)!;
        
        spans.add(TextSpan(
          text: verseRef,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()..onTap = () {
             final parts = verseRef.split(RegExp(r'\s+'));
             final cv = parts.last.split(':');
             if (cv.length >= 2) {
                final ch = int.tryParse(cv[0]);
                final vPart = cv[1].split('-').first;
                final v = int.tryParse(vPart);
                final bookAbbrev = parts.sublist(0, parts.length - 1).join(' ');
                
                if (ch != null && v != null) {
                   showDialog(
                     context: context,
                     builder: (ctx) => VersePreviewDialog(
                       reference: verseRef,
                       bookAbbrev: bookAbbrev,
                       chapter: ch,
                       verseNum: v,
                     ),
                   );
                }
             }
          },
        ));
      }
      
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }
}
