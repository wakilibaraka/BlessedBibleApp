import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../state/strongs_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';
import 'state_views.dart';

/// Decorative size for the headword at the top of the sheet.
const double _kHeroWordSize = 40;

void showStrongsEntrySheet(BuildContext context, String strongsId) {
  final ref = ProviderScope.containerOf(context);
  final style = ref.read(readSettingsProvider).popupStyle;
  final isFloating = style == PopupStyle.floating;

  if (isFloating) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _StrongsEntrySheet(strongsId: strongsId, isFloating: true),
    );
  } else {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _StrongsEntrySheet(strongsId: strongsId, isFloating: false),
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

    final Widget content = Container(
      width:
          isFloating ? MediaQuery.sizeOf(context).width * 0.9 : double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.3,
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        maxWidth: isFloating ? 500 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: isFloating
            ? BorderRadius.circular(Radii.xxl)
            : const BorderRadius.vertical(top: Radius.circular(Radii.xxxl)),
        boxShadow: isFloating
            ? [
                BoxShadow(
                  color: context.palette.shadow,
                  blurRadius: 24,
                  spreadRadius: 8,
                )
              ]
            : null,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Navigation Bar ──────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 16, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: theme.primaryColor),
                    label: Text(context.l10n.commonBack,
                        style: TextStyle(
                            fontSize: TypeScale.bodyLarge,
                            color: theme.primaryColor)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.commonShare,
                    onPressed: () {
                      final entry = entryAsync.asData?.value;
                      if (entry != null) {
                        final textToShare = context.l10n.studyStrongsShareText(
                            entry.id,
                            entry.lemma,
                            entry.transliteration,
                            entry.pronunciation,
                            entry.definition);
                        SharePlus.instance
                            .share(ShareParams(text: textToShare));
                      }
                    },
                    icon: Icon(Icons.ios_share_rounded,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 24),
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
                      child: Text(context.l10n.studyNoStrongsEntry(strongsId)),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    children: [
                      // Hero Word
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SelectableText(
                            entry.lemma,
                            style: TextStyle(
                              fontFamily: typography.fontFamily,
                              fontSize: _kHeroWordSize,
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
                                fontSize: TypeScale.title,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Radii.lg),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(Radii.lg),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up_rounded,
                                      size: 16,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.pronunciation,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.8),
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
                        context.l10n.studyStrongsLexicon,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                          height: 1),
                      const SizedBox(height: 16),

                      SelectableText(
                        entry.definition,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: typography.lineHeight,
                          fontSize: typography.fontSize,
                          fontFamily: typography.fontFamily,
                          fontWeight: typography.fontWeight,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.85),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: LoadingView(),
                ),
                error: (e, __) => ErrorState(
                  error: e,
                  message: context.l10n.studyEntryLoadFailed,
                  onRetry: () => ref.invalidate(strongsProvider(strongsId)),
                ),
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
