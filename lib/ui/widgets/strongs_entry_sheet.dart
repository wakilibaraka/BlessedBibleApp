import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../state/strongs_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/read_settings_provider.dart';

void showStrongsEntrySheet(BuildContext context, String strongsId) {
  final ref = ProviderScope.containerOf(context);
  final style = ref.read(readSettingsProvider).popupStyle;
  final isFloating = style == PopupStyle.floating;

  if (isFloating) {
    showDialog(
      context: context,
      builder: (context) => _StrongsEntrySheet(strongsId: strongsId, isFloating: true),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StrongsEntrySheet(strongsId: strongsId, isFloating: false),
    );
  }
}

class _StrongsEntrySheet extends ConsumerWidget {
  final String strongsId;
  final bool isFloating;

  const _StrongsEntrySheet({required this.strongsId, this.isFloating = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entryAsync = ref.watch(strongsProvider(strongsId));
    final typography = ref.watch(typographyProvider);

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
                  IconButton(
                    onPressed: () {
                      final entry = entryAsync.asData?.value;
                      if (entry != null) {
                        final textToShare = "${entry.id} - ${entry.lemma}\n\nTransliteration: ${entry.transliteration}\nPronunciation: ${entry.pronunciation}\n\nDefinition:\n${entry.definition}";
                        Share.share(textToShare);
                      }
                    },
                    icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 24),
                  ),
                ],
              ),
            ),
            
            // ── Content ──────────────────────────────────────────
            Flexible(
              child: entryAsync.when(
                data: (entry) {
                  if (entry == null) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('No entry found for $strongsId.'),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // Hero Word
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SelectableText(
                            entry.lemma,
                            style: TextStyle(
                              fontFamily: typography.fontFamily,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1.0,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              entry.id,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Transliteration & Pronunciation tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (entry.transliteration.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                entry.transliteration,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (entry.pronunciation.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.pronunciation,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'STRONG\'S LEXICON',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: theme.dividerColor.withValues(alpha: 0.3), height: 1),
                      const SizedBox(height: 16),
                      
                      SelectableText(
                        entry.definition,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: typography.lineHeight,
                          fontSize: typography.fontSize,
                          fontFamily: typography.fontFamily,
                          fontWeight: typography.fontWeight,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      
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
}
