import 'package:flutter/material.dart';

import '../../state/typography_provider.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n.dart';
import '../../utils/prose.dart';

/// The verse under discussion, as a pull-quote above the commentary.
///
/// [refined] is the editorial layout (accent rule, left-aligned quote);
/// otherwise the original centred card is rendered.
class CommentaryVerseCard extends StatelessWidget {
  final String reference;
  final String verseText;
  final VoidCallback? onTap;
  final bool refined;
  final Color ink;
  final Color accent;
  final Color surface;
  final Color border;
  final Color shadow;
  final TypographyState typography;

  const CommentaryVerseCard({
    super.key,
    required this.reference,
    required this.verseText,
    required this.ink,
    required this.accent,
    required this.surface,
    required this.border,
    required this.shadow,
    required this.typography,
    this.onTap,
    this.refined = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = normalizeProse(verseText);

    if (!refined) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(Radii.xxl),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                  color: shadow, blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\u201c$text\u201d',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.42,
                  fontSize: typography.fontSize * 1.05,
                  fontFamily: typography.fontFamily,
                  fontStyle: typography.fontStyle,
                  color: ink,
                ),
              ),
              const SizedBox(height: 12),
              _TapHint(ink: ink),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.xl),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accent.withValues(alpha: 0.7)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_quote_rounded,
                                size: 16, color: accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                reference,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.6,
                            fontSize: typography.fontSize * 1.02,
                            fontFamily: typography.fontFamily,
                            fontStyle: typography.fontStyle,
                            fontWeight: FontWeight.w500,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TapHint(ink: ink, alignStart: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  final Color ink;
  final bool alignStart;

  const _TapHint({required this.ink, this.alignStart = false});

  @override
  Widget build(BuildContext context) {
    final muted = ink.withValues(alpha: 0.55);
    final children = <Widget>[
      Text(
        context.l10n.studyTapToReadInContext,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: muted,
              letterSpacing: 0.3,
            ),
      ),
      const SizedBox(width: 4),
      Icon(Icons.open_in_new_rounded, size: 12, color: muted),
    ];
    return Row(
      mainAxisSize: alignStart ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment:
          alignStart ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: children,
    );
  }
}
