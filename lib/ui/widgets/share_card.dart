import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../services/devotional_service.dart';
import '../../services/share_service.dart';
import '../../state/devotional_provider.dart';
import '../../state/read_settings_provider.dart';

/// Shareable image cards (1080x1350, WhatsApp-Status-friendly 4:5).
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

/// Typography + alignment controls for the card, persisted as the default
/// for new cards. Zero-size steps keep it to one tap each.
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

  const ShareCardStyle({
    this.fontFamily,
    this.scale = 1.0,
    this.letterSpacing = 0,
    this.lineHeight = 1.45,
    this.align = TextAlign.left,
  });

  ShareCardStyle copyWith({
    String? fontFamily,
    double? scale,
    double? letterSpacing,
    double? lineHeight,
    TextAlign? align,
    bool clearFont = false,
  }) =>
      ShareCardStyle(
        fontFamily: clearFont ? null : (fontFamily ?? this.fontFamily),
        scale: scale ?? this.scale,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        lineHeight: lineHeight ?? this.lineHeight,
        align: align ?? this.align,
      );

  static const defaults = ShareCardStyle();
}

/// The app's reading fonts, offered for card typography. Mirrors the
/// reader's font list so a card can match what the user was reading in.
const List<String> kShareCardFonts = [
  'EB Garamond', 'Gentium Book Plus', 'Literata', 'Lora', 'Bitter', 'Cardo',
  'Noto Serif', 'Alegreya', 'Inter', 'Lexend', 'Source Sans 3', 'OpenDyslexic',
];

class ShareCardStyleNotifier extends Notifier<ShareCardStyle> {
  static const _key = 'share_card_style';

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
      state = ShareCardStyle(
        fontFamily: map['font'] as String?,
        scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
        letterSpacing: (map['spacing'] as num?)?.toDouble() ?? 0,
        lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.45,
        align: (map['align'] as String?) == 'center'
            ? TextAlign.center
            : TextAlign.left,
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
          }),
        );
  }
}

final shareCardStyleProvider =
    NotifierProvider<ShareCardStyleNotifier, ShareCardStyle>(
        ShareCardStyleNotifier.new);

/// Shareable card content (verse or word) + the chosen style.
class ShareCard extends StatelessWidget {
  final ShareCardBackdrop backdrop;
  final String eyebrow;
  final String title;
  final String? body;
  final String footer;

  /// Artwork plate asset path when [backdrop] is [ShareCardBackdrop.artwork].
  final String? artworkPath;

  final ShareCardStyle style;

  const ShareCard._({
    required this.backdrop,
    required this.eyebrow,
    required this.title,
    this.body,
    required this.footer,
    this.artworkPath,
    required this.style,
  });

  /// Verse card: reference eyebrow, serif passage, translation footer.
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
      eyebrow: '$reference · $translationTag',
      title: body,
      footer: reference,
      artworkPath: artworkPath,
      style: style,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = style;
    final titleSize = (body == null
            ? (title.length <= 140 ? 64.0 : title.length <= 320 ? 52.0 : 44.0)
            : 92.0) *
        s.scale;

    TextStyle textStyle(double size, FontWeight weight) => TextStyle(
          fontFamily: s.fontFamily,
          fontSize: size,
          height: s.lineHeight,
          letterSpacing: s.letterSpacing,
          fontWeight: weight,
          color: Colors.white,
        );

    return SizedBox(
      width: 1080,
      height: 1350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Backdrop(backdrop: backdrop, artworkPath: artworkPath),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: textStyle(34, FontWeight.w700)
                      .copyWith(color: theme.primaryColor, letterSpacing: 6),
                ),
                const SizedBox(height: 36),
                // Flexible + scaleDown: passages of any length shrink to
                // fit the frame instead of overflowing or clipping.
                Expanded(
                  child: Align(
                    alignment: body == null
                        ? Alignment.centerLeft
                        : Alignment.topLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: body == null
                          ? Alignment.centerLeft
                          : Alignment.topLeft,
                      child: SizedBox(
                        width: 888,
                        child: Text(
                          title,
                          textAlign: s.align,
                          maxLines: body == null ? 12 : 20,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                              titleSize,
                              body == null
                                  ? FontWeight.w500
                                  : FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 40),
                  Container(
                      height: 3, width: 140, color: theme.primaryColor),
                  const SizedBox(height: 40),
                ],
                Flexible(
                  child: body == null
                      ? const SizedBox.shrink()
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 888,
                            child: Text(
                              body!,
                              textAlign: s.align,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(40, FontWeight.w400),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 40),
                Text(footer, style: textStyle(38, FontWeight.w600)),
                const SizedBox(height: 18),
                Text(
                  '✦ BIBLE',
                  style: textStyle(28, FontWeight.w400)
                      .copyWith(color: Colors.white70, letterSpacing: 5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
            // so white text needs a heavy left wash to stay legible.
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
          Opacity(opacity: topAlpha.clamp(0.0, 1.0), child: const CustomPaint(painter: _GrainPainter())),
        ],
      );
}

/// Seeded film grain: static, cheap, no assets.
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (var i = 0; i < 2200; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width,
            rand.nextDouble() * size.height),
        rand.nextDouble() * 2.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom sheet: scaled card preview + backdrop/style pickers + Share.
/// The card renders at full 1080x1350 inside the [FittedBox]; capture
/// uses pixelRatio 1 for exact output dimensions.
Future<void> showShareCardSheet({
  required BuildContext context,
  required ShareCard Function(ShareCardBackdrop backdrop, ShareCardStyle style)
      buildCard,
  required String filename,
  String? caption,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ShareCardSheet(
      buildCard: buildCard,
      filename: filename,
      caption: caption,
    ),
  );
}

class _ShareCardSheet extends ConsumerStatefulWidget {
  final ShareCard Function(ShareCardBackdrop backdrop, ShareCardStyle style)
      buildCard;
  final String filename;
  final String? caption;

  const _ShareCardSheet({
    required this.buildCard,
    required this.filename,
    this.caption,
  });

  @override
  ConsumerState<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends ConsumerState<_ShareCardSheet> {
  final _boundaryKey = GlobalKey();
  ShareCardBackdrop _backdrop = ShareCardBackdrop.dawn;
  ShareCardStyle _style = ShareCardStyle.defaults;
  bool _sharing = false;
  bool _initStyle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initStyle) return;
    _initStyle = true;
    _style = ref.read(shareCardStyleProvider);
  }

  void _set(ShareCardStyle next) {
    setState(() => _style = next);
    HapticFeedback.selectionClick();
    ref.read(shareCardStyleProvider.notifier).update(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget chips<T>(
      List<T> values,
      T selected,
      String Function(T) label,
      void Function(T) onTap,
    ) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (final v in values)
            ChoiceChip(
              label: Text(label(v)),
              selected: v == selected,
              onSelected: (_) => onTap(v),
            ),
        ],
      );
    }

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.buildCard(_backdrop, _style),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Backdrop',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 6),
            chips<ShareCardBackdrop>(
                ShareCardBackdrop.values, _backdrop,
                (b) => switch (b) {
                  ShareCardBackdrop.dawn => 'Dawn',
                  ShareCardBackdrop.dusk => 'Dusk',
                  ShareCardBackdrop.artwork => 'Artwork',
                  ShareCardBackdrop.gradient => 'Gradient',
                }, (b) => setState(() => _backdrop = b)),
            const SizedBox(height: 12),
            Text('Font',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 6),
            chips<String>(
              ['', ...kShareCardFonts],
              _style.fontFamily ?? '',
              (f) => f.isEmpty ? 'Theme' : f,
              (f) => _set(_style.copyWith(
                  fontFamily: f.isEmpty ? null : f,
                  clearFont: f.isEmpty)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ControlLabel('Size'),
                      chips<double>(const [0.85, 1.0, 1.2], _style.scale,
                          (v) => '${(v * 100).round()}%',
                          (v) => _set(_style.copyWith(scale: v))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ControlLabel('Spacing'),
                      chips<double>(const [0, 1, 2], _style.letterSpacing,
                          (v) => v == 0 ? 'Normal' : 'Wide ${v.toInt()}',
                          (v) => _set(_style.copyWith(letterSpacing: v))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ControlLabel('Line height'),
                      chips<double>(const [1.3, 1.45, 1.6], _style.lineHeight,
                          (v) => v.toStringAsFixed(2),
                          (v) => _set(_style.copyWith(lineHeight: v))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ControlLabel('Alignment'),
                      chips<TextAlign>(
                          const [TextAlign.left, TextAlign.center],
                          _style.align,
                          (v) => v == TextAlign.center ? 'Center' : 'Left',
                          (v) => _set(_style.copyWith(align: v))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sharing
                    ? null
                    : () async {
                        setState(() => _sharing = true);
                        HapticFeedback.mediumImpact();
                        await ShareService.shareImageFromBoundary(
                          boundaryKey: _boundaryKey,
                          filename: widget.filename,
                          caption: widget.caption,
                        );
                        if (context.mounted) {
                          setState(() => _sharing = false);
                          Navigator.of(context).pop();
                        }
                      },
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(_sharing ? 'Preparing…' : 'Share image'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlLabel extends StatelessWidget {
  final String text;
  const _ControlLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Generic share-options sheet: Copy text / Share text / Image card.
Future<void> showShareOptionsSheet({
  required BuildContext context,
  required String copyText,
  required String shareText,
  ShareCard Function(ShareCardBackdrop backdrop, ShareCardStyle style)?
      buildCard,
  String? imageFilename,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      Widget row({
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
        return ListTile(
          leading: Icon(icon, color: theme.primaryColor),
          title: Text(label),
          onTap: onTap,
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.only(top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            row(
              icon: Icons.copy_rounded,
              label: 'Copy text',
              onTap: () {
                Navigator.of(ctx).pop();
                ShareService.copyText(context, copyText);
              },
            ),
            row(
              icon: Icons.ios_share_rounded,
              label: 'Share text',
              onTap: () {
                Navigator.of(ctx).pop();
                ShareService.shareText(body: shareText);
              },
            ),
            if (buildCard != null)
              row(
                icon: Icons.image_rounded,
                label: 'Share image card',
                onTap: () {
                  Navigator.of(ctx).pop();
                  showShareCardSheet(
                    context: context,
                    buildCard: buildCard,
                    filename: imageFilename ?? 'bible-card',
                    caption: shareText,
                  );
                },
              ),
          ],
        ),
      );
    },
  );
}