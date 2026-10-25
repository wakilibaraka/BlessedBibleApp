import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../models/share_content.dart';
import '../../services/share_service.dart';
import '../../theme/design_tokens.dart';

/// Shareable image cards. 1080 wide in every format, so the PNG stays crisp
/// and consistent across WhatsApp status, chats and prints.
///
/// Zero-bloat capture: no new packages — a [RepaintBoundary] around the
/// card, [ShareService.shareImageFromBoundary], temp file only.
///
/// Backdrops are theme-derived: [ShareCardBackdrop.dawn] and [dusk] mix
/// the active theme's primary with a warm/cool base so a card always looks
/// like it came from the app the user was reading in. [artwork] reuses the
/// bundled public-domain Doré plates. Cards stay dark so white text holds
/// AA contrast in every theme.
enum ShareCardBackdrop { dawn, dusk, artwork, gradient }

/// Export shape: chat portrait, feed square, or full-screen story.
enum ShareCardFormat {
  /// 1080×1350 — the chat/feed default (4:5).
  portrait(1080, 1350),

  /// 1080×1080 — squares for feeds and group posts.
  square(1080, 1080),

  /// 1080×1920 — WhatsApp status and Instagram stories (9:16).
  story(1080, 1920);

  final double width;
  final double height;

  const ShareCardFormat(this.width, this.height);

  double get aspectRatio => width / height;

  /// Vertical breathing room, so the shorter square doesn't crowd.
  EdgeInsets get padding => switch (this) {
        ShareCardFormat.portrait =>
          const EdgeInsets.symmetric(horizontal: 96, vertical: 110),
        ShareCardFormat.square =>
          const EdgeInsets.symmetric(horizontal: 90, vertical: 88),
        ShareCardFormat.story =>
          const EdgeInsets.symmetric(horizontal: 96, vertical: 168),
      };
}

/// Typography, alignment and export-shape controls for the card, persisted
/// as the default for new cards.
@immutable
class ShareCardStyle {
  /// App reading font family, or null for the theme default.
  final String? fontFamily;

  /// Multiplier on the base sizes (0.85 / 1.0 / 1.2).
  final double scale;

  /// Extra tracking in logical pixels (0 / 1 / 2).
  final double letterSpacing;

  /// Multiplier on line height (1.3 / 1.45 / 1.6).
  final double lineHeight;

  /// Left or centred passage.
  final TextAlign align;

  /// Export shape.
  final ShareCardFormat format;

  const ShareCardStyle({
    this.fontFamily,
    this.scale = 1.0,
    this.letterSpacing = 0,
    this.lineHeight = 1.45,
    this.align = TextAlign.left,
    this.format = ShareCardFormat.portrait,
  });

  ShareCardStyle copyWith({
    String? fontFamily,
    double? scale,
    double? letterSpacing,
    double? lineHeight,
    TextAlign? align,
    ShareCardFormat? format,
    bool clearFont = false,
  }) =>
      ShareCardStyle(
        fontFamily: clearFont ? null : (fontFamily ?? this.fontFamily),
        scale: scale ?? this.scale,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        lineHeight: lineHeight ?? this.lineHeight,
        align: align ?? this.align,
        format: format ?? this.format,
      );

  static const defaults = ShareCardStyle();
}

/// The app's reading fonts, offered for card typography. Mirrors the
/// reader's font list so a card can match what the user was reading in.
const List<String> kShareCardFonts = [
  'EB Garamond',
  'Gentium Book Plus',
  'Literata',
  'Lora',
  'Bitter',
  'Cardo',
  'Noto Serif',
  'Alegreya',
  'Inter',
  'Lexend',
  'Source Sans 3',
  'OpenDyslexic',
];

class ShareCardStyleNotifier extends Notifier<ShareCardStyle> {
  @override
  ShareCardStyle build() {
    _load();
    return ShareCardStyle.defaults;
  }

  void _load() {
    final raw = ref.read(preferencesProvider).getShareCardStyleJson();
    if (raw == null || raw.isEmpty) return;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final formatName = map['format'] as String?;
      state = ShareCardStyle(
        fontFamily: map['font'] as String?,
        scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
        letterSpacing: (map['spacing'] as num?)?.toDouble() ?? 0,
        lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.45,
        align: (map['align'] as String?) == 'center'
            ? TextAlign.center
            : TextAlign.left,
        format: ShareCardFormat.values.firstWhere(
          (f) => f.name == formatName,
          orElse: () => ShareCardFormat.portrait,
        ),
      );
    } catch (_) {
      state = ShareCardStyle.defaults;
    }
  }

  Future<void> update(ShareCardStyle next) async {
    state = next;
    await ref.read(preferencesProvider).saveShareCardStyleJson(
          jsonEncode({
            'font': next.fontFamily,
            'scale': next.scale,
            'spacing': next.letterSpacing,
            'lineHeight': next.lineHeight,
            'align': next.align == TextAlign.center ? 'center' : 'left',
            'format': next.format.name,
          }),
        );
  }
}

final shareCardStyleProvider =
    NotifierProvider<ShareCardStyleNotifier, ShareCardStyle>(
        ShareCardStyleNotifier.new);

/// Shareable card content (verse, word, story or commentary) + the chosen
/// style.
class ShareCard extends StatelessWidget {
  final ShareCardBackdrop backdrop;
  final String eyebrow;
  final String title;
  final String? body;
  final String footer;

  /// Artwork plate asset path when [backdrop] is [ShareCardBackdrop.artwork].
  final String? artworkPath;

  final ShareCardStyle style;

  /// Drives the decorative quote mark (quoted kinds only).
  final bool quoted;

  const ShareCard._({
    required this.backdrop,
    required this.eyebrow,
    required this.title,
    this.body,
    required this.footer,
    this.artworkPath,
    required this.style,
    this.quoted = false,
  });

  /// Verse card: reference eyebrow, serif passage, reference footer.
  factory ShareCard.verse({
    required String reference,
    required String body,
    required String translationTag,
    ShareCardBackdrop backdrop = ShareCardBackdrop.dawn,
    ShareCardStyle style = ShareCardStyle.defaults,
    String? artworkPath,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow:
          translationTag.isEmpty ? reference : '$reference · $translationTag',
      title: body,
      footer: reference,
      artworkPath: artworkPath,
      style: style,
      quoted: true,
    );
  }

  /// Word card: eyebrow, caps headword, definition, caps source footer.
  factory ShareCard.word({
    required String eyebrow,
    required String word,
    required String definition,
    required String source,
    ShareCardBackdrop backdrop = ShareCardBackdrop.gradient,
    ShareCardStyle style = ShareCardStyle.defaults,
    String? artworkPath,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow: eyebrow,
      title: word.trim().toUpperCase(),
      body: definition,
      footer: source.trim().toUpperCase(),
      artworkPath: artworkPath,
      style: style,
    );
  }

  /// Story card: eyebrow, title, narrative excerpt, reference footer.
  factory ShareCard.story({
    required String eyebrow,
    required String title,
    required String summary,
    required String reference,
    ShareCardBackdrop backdrop = ShareCardBackdrop.gradient,
    ShareCardStyle style = ShareCardStyle.defaults,
    String? artworkPath,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow: eyebrow,
      title: title.trim().toUpperCase(),
      body: summary,
      footer: reference,
      artworkPath: artworkPath,
      style: style,
    );
  }

  /// Commentary card: source eyebrow, quoted insight, attribution footer.
  factory ShareCard.commentary({
    required String eyebrow,
    required String insight,
    required String attribution,
    ShareCardBackdrop backdrop = ShareCardBackdrop.gradient,
    ShareCardStyle style = ShareCardStyle.defaults,
    String? artworkPath,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow: eyebrow,
      title: '“${insight.trim()}”',
      footer: attribution,
      artworkPath: artworkPath,
      style: style,
      quoted: false,
    );
  }

  /// Builds the card for any [ShareContent], so every entry point (verses,
  /// VOTD, WOTD, stories, commentary) shares the same visual language.
  factory ShareCard.fromContent(
    ShareContent content, {
    ShareCardBackdrop backdrop = ShareCardBackdrop.dawn,
    ShareCardStyle style = ShareCardStyle.defaults,
  }) {
    final excerpt = content.excerpt();
    switch (content.kind) {
      case ShareKind.verse:
        return ShareCard.verse(
          reference: content.reference ?? '',
          body: content.paragraphs.join(' '),
          translationTag: content.translation ?? '',
          backdrop: backdrop,
          style: style,
          artworkPath: content.artworkPath,
        );
      case ShareKind.word:
        return ShareCard.word(
          eyebrow: content.eyebrow,
          word: content.title ?? '',
          definition: excerpt,
          source: content.source ?? '',
          backdrop: backdrop,
          style: style,
          artworkPath: content.artworkPath,
        );
      case ShareKind.story:
        return ShareCard.story(
          eyebrow: content.eyebrow,
          title: content.title ?? '',
          summary: shareExcerpt(excerpt, 320),
          reference: content.reference ?? '',
          backdrop: backdrop,
          style: style,
          artworkPath: content.artworkPath,
        );
      case ShareKind.commentary:
        return ShareCard.commentary(
          eyebrow: content.reference ?? content.eyebrow,
          insight: shareExcerpt(excerpt, 260),
          attribution: content.attribution ?? content.source ?? '',
          backdrop: backdrop,
          style: style,
          artworkPath: content.artworkPath,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = style;
    final format = s.format;
    // Squares sit tighter; stories get more air. Passages shrink to fit via
    // FittedBox, so this only sets the starting point.
    final base = switch (format) {
      ShareCardFormat.square => 0.94,
      ShareCardFormat.story => 1.04,
      ShareCardFormat.portrait => 1.0,
    };

    final hasBody = body != null;
    final titleSize = (hasBody
            ? (title.length <= 24
                ? 92.0
                : title.length <= 60
                    ? 68.0
                    : 52.0)
            : (title.length <= 140
                ? 64.0
                : title.length <= 320
                    ? 52.0
                    : 44.0)) *
        s.scale *
        base;

    // Exported image: fixed white-on-dark styling, independent of app theme.
    // `even` leading distributes space above/below glyphs so multi-line
    // passages stay optically centred instead of sinking into the box.
    TextStyle textStyle(double size, FontWeight weight) => TextStyle(
          fontFamily: s.fontFamily,
          fontSize: size,
          height: s.lineHeight,
          leadingDistribution: TextLeadingDistribution.even,
          letterSpacing: s.letterSpacing,
          fontWeight: weight,
          color: Colors.white,
        );

    // One hairline expression for the frame and the footer rule, so the
    // exported art stays consistent.
    final hairline = Colors.white.withValues(alpha: 0.16);
    // Long attributions (commentary sources, long dictionary names) drop a
    // step and wrap to two lines rather than being truncated.
    final footerSize = footer.length > 34 ? 29.0 * base : 38.0 * base;

    return SizedBox(
      width: format.width,
      height: format.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Backdrop(backdrop: backdrop, artworkPath: artworkPath),
          // Hairline frame: gives the export a finished, printed feel.
          Padding(
            padding: const EdgeInsets.all(34),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: hairline, width: 1.5),
              ),
            ),
          ),
          Padding(
            padding: format.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: textStyle(34, FontWeight.w700)
                      .copyWith(color: theme.primaryColor, letterSpacing: 6),
                ),
                if (quoted) ...[
                  SizedBox(height: 20 * base),
                  Text(
                    '“',
                    style: textStyle(150 * base, FontWeight.w700).copyWith(
                      color: theme.primaryColor.withValues(alpha: 0.55),
                      height: 0.7,
                    ),
                  ),
                ],
                SizedBox(height: quoted ? 6 : 36),
                // Flexible + scaleDown: passages of any length shrink to
                // fit the frame instead of overflowing or clipping.
                Expanded(
                  child: Align(
                    alignment:
                        hasBody ? Alignment.topLeft : Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                          hasBody ? Alignment.topLeft : Alignment.centerLeft,
                      child: SizedBox(
                        width: 888,
                        child: Text(
                          title,
                          textAlign: s.align,
                          maxLines: hasBody ? 12 : 20,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                              titleSize,
                              quoted
                                  ? FontWeight.w500
                                  : (hasBody
                                      ? FontWeight.w800
                                      : FontWeight.w500)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasBody) ...[
                  const SizedBox(height: 40),
                  Container(height: 3, width: 140, color: theme.primaryColor),
                  const SizedBox(height: 40),
                ],
                Flexible(
                  child: hasBody
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 888,
                            child: Text(
                              body!,
                              textAlign: s.align,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(40 * base, FontWeight.w400),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 34),
                Container(height: 1, color: hairline),
                const SizedBox(height: 22),
                Text(
                  footer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle(footerSize, FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  '✦ THE BLESSED BIBLE',
                  style: textStyle(25 * base, FontWeight.w400).copyWith(
                    color: Colors.white70,
                    letterSpacing: 5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Backdrop preview (small swatch) for the share sheet's picker.
class ShareBackdropSwatch extends StatelessWidget {
  final ShareCardBackdrop backdrop;
  final String? artworkPath;

  const ShareBackdropSwatch(
      {super.key, required this.backdrop, this.artworkPath});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(Radii.sm),
        child: SizedBox(
          width: 26,
          height: 32,
          child: _Backdrop(backdrop: backdrop, artworkPath: artworkPath),
        ),
      );
}

/// Theme-derived backdrops. No hardcoded artwork for the gradients, so
/// each of the 14 themes produces its own card.
class _Backdrop extends StatelessWidget {
  final ShareCardBackdrop backdrop;
  final String? artworkPath;

  const _Backdrop({required this.backdrop, this.artworkPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    switch (backdrop) {
      case ShareCardBackdrop.artwork:
        if (artworkPath == null) return _gradient(theme, primary, 0.35, 0.9);
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              artworkPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _gradient(theme, primary, 0.35, 0.9),
            ),
            // Strong directional scrim: Doré plates are light engravings,
            // so white text needs a heavy wash to stay legible.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ],
        );

      // Backdrop tints below are fixed art for the exported image.
      case ShareCardBackdrop.dawn:
        // Warm: primary lifted toward a sunrise amber.
        return _gradient(
          theme,
          Color.lerp(primary, const Color(0xFFFFB74D), 0.45)!,
          0.42,
          0.85,
        );

      case ShareCardBackdrop.dusk:
        // Cool: primary pulled toward a deep twilight blue.
        return _gradient(
          theme,
          Color.lerp(primary, const Color(0xFF1A237E), 0.55)!,
          0.5,
          0.95,
        );

      case ShareCardBackdrop.gradient:
        return _gradient(theme, primary, 0.35, isDark ? 0.9 : 0.78);
    }
  }

  Widget _gradient(
          ThemeData theme, Color accent, double mix, double topAlpha) =>
      Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF14161C),
                  Color.lerp(const Color(0xFF14161C), accent, mix)!,
                  Color.lerp(const Color(0xFF0B0D11), accent, mix * 0.5)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Opacity(
              opacity: topAlpha.clamp(0.0, 1.0),
              child: const CustomPaint(painter: _GrainPainter())),
        ],
      );
}

/// Seeded film grain: static, cheap, no assets.
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(7);
    // Grain is part of the exported image's fixed look.
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (var i = 0; i < 2200; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 2.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
