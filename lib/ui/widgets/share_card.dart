import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/share_service.dart';

/// Shareable image cards (1080x1350, WhatsApp-Status-friendly 4:5).
///
/// Zero-bloat capture: no new packages — a [RepaintBoundary] around the
/// card, [ShareService.shareImageFromBoundary], temp file only.
/// Backdrops reuse bundled art (lighthouse) or a procedural
/// gradient+grain; cards are always dark so text stays readable in any
/// theme (primary-color accents keep them on-brand).
enum ShareCardBackdrop { lighthouse1, lighthouse2, gradient }

class ShareCard extends StatelessWidget {
  final ShareCardBackdrop backdrop;
  final String eyebrow;
  final String title;
  final String? body;
  final String footer;

  const ShareCard._({
    required this.backdrop,
    required this.eyebrow,
    required this.title,
    this.body,
    required this.footer,
  });

  /// Verse card: reference eyebrow, serif passage, translation footer.
  factory ShareCard.verse({
    required String reference,
    required String body,
    required String translationTag,
    ShareCardBackdrop backdrop = ShareCardBackdrop.lighthouse1,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow: '$reference · $translationTag',
      title: body,
      footer: reference,
    );
  }

  /// Word card: eyebrow (e.g. WORD OF THE DAY), caps headword,
  /// definition, caps source footer.
  factory ShareCard.word({
    required String eyebrow,
    required String word,
    required String definition,
    required String source,
    ShareCardBackdrop backdrop = ShareCardBackdrop.gradient,
  }) {
    return ShareCard._(
      backdrop: backdrop,
      eyebrow: eyebrow,
      title: word.trim().toUpperCase(),
      body: definition,
      footer: source.trim().toUpperCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseFont = theme.textTheme.headlineMedium?.fontFamily;
    final titleLen = title.length;
    final titleSize = body == null
        ? (titleLen <= 140 ? 64.0 : titleLen <= 320 ? 52.0 : 44.0)
        : 92.0;

    return SizedBox(
      width: 1080,
      height: 1350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Backdrop(backdrop: backdrop),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 34,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 36),
                // Flexible + scaleDown: passages of any length shrink to
                // fit the frame instead of overflowing or clipping —
                // long verses (Ps 119, John 3) stay shareable.
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
                          textAlign: TextAlign.left,
                          maxLines: body == null ? 12 : 20,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: baseFont,
                            fontSize: titleSize,
                            height: 1.45,
                            fontWeight: body == null
                                ? FontWeight.w500
                                : FontWeight.w800,
                            color: Colors.white,
                          ),
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
                              textAlign: TextAlign.left,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 40,
                                height: 1.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 40),
                Text(
                  footer,
                  style: const TextStyle(
                    fontSize: 38,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '✦ BIBLE',
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: 5,
                    color: Colors.white70,
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

class _Backdrop extends StatelessWidget {
  final ShareCardBackdrop backdrop;

  const _Backdrop({required this.backdrop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (backdrop) {
      case ShareCardBackdrop.lighthouse1:
      case ShareCardBackdrop.lighthouse2:
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backdrop == ShareCardBackdrop.lighthouse1
                  ? 'assets/images/lighthouse_1.png'
                  : 'assets/images/lighthouse_2.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ],
        );
      case ShareCardBackdrop.gradient:
        final primary = theme.primaryColor;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF14161C),
                    Color.lerp(
                        const Color(0xFF14161C), primary, 0.35)!,
                  ],
                ),
              ),
            ),
            const CustomPaint(painter: _GrainPainter()),
          ],
        );
    }
  }
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

/// Bottom sheet: scaled card preview + backdrop picker + Share button.
/// The card renders at full 1080x1350 inside the [FittedBox]; capture
/// uses pixelRatio 1 for exact output dimensions.
Future<void> showShareCardSheet({
  required BuildContext context,
  required ShareCard Function(ShareCardBackdrop backdrop) buildCard,
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

class _ShareCardSheet extends StatefulWidget {
  final ShareCard Function(ShareCardBackdrop backdrop) buildCard;
  final String filename;
  final String? caption;

  const _ShareCardSheet({
    required this.buildCard,
    required this.filename,
    this.caption,
  });

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _boundaryKey = GlobalKey();
  ShareCardBackdrop _backdrop = ShareCardBackdrop.lighthouse1;
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
            height: 320,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.contain,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: widget.buildCard(_backdrop),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final b in ShareCardBackdrop.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(
                      b == ShareCardBackdrop.lighthouse1
                          ? 'Light 1'
                          : b == ShareCardBackdrop.lighthouse2
                              ? 'Light 2'
                              : 'Gradient',
                    ),
                    selected: _backdrop == b,
                    onSelected: (_) =>
                        setState(() => _backdrop = b),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }
}

/// Generic share-options sheet: Copy text / Share text / Image card.
Future<void> showShareOptionsSheet({
  required BuildContext context,
  required String copyText,
  required String shareText,
  ShareCard Function(ShareCardBackdrop backdrop)? buildCard,
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
