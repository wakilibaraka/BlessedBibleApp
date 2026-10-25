import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../l10n/l10n.dart';
import '../../models/share_content.dart';
import '../../services/gallery_service.dart';
import '../../services/share_pdf_service.dart';
import '../../services/share_service.dart';
import '../../theme/design_tokens.dart';
import 'pill_segmented_control.dart';
import 'share_card.dart';
import 'share_document_preview.dart';

/// One share sheet for every kind of content.
///
/// Text mode previews the exact string that will be copied or shared and
/// lets the user pick plain text or WhatsApp markup, with or without the
/// reference. Image mode previews the card and its export shape (portrait,
/// square, story) plus typography. PDF mode exports the long-form kinds
/// (commentary, stories) as a page-ready document.
Future<void> showShareSheet({
  required BuildContext context,
  required ShareContent content,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShareSheet(content: content),
  );
}

enum _ShareMode { text, image, pdf }

class _ShareSheet extends ConsumerStatefulWidget {
  final ShareContent content;

  const _ShareSheet({required this.content});

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _boundaryKey = GlobalKey();
  _ShareMode _mode = _ShareMode.text;
  ShareFlavor _flavor = ShareFlavor.whatsapp;
  bool _includeReference = true;
  bool _busy = false;
  bool _init = false;
  late ShareCardBackdrop _backdrop;
  late ShareCardStyle _style;

  /// Inline result line (saved, permission denied, failed). A SnackBar would
  /// sit behind the sheet, so feedback lives in the sheet itself.
  String? _note;
  bool _noteIsError = false;

  ShareContent get _content => widget.content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _style = ref.read(shareCardStyleProvider);
    _flavor = ref.read(preferencesProvider).getShareFlavor() == 'plain'
        ? ShareFlavor.plain
        : ShareFlavor.whatsapp;
    _backdrop = _content.artworkPath != null
        ? ShareCardBackdrop.artwork
        : switch (_content.kind) {
            ShareKind.verse => ShareCardBackdrop.dawn,
            _ => ShareCardBackdrop.gradient,
          };
  }

  String get _text =>
      _content.text(flavor: _flavor, includeReference: _includeReference);

  void _setStyle(ShareCardStyle next) {
    setState(() => _style = next);
    ref.read(shareCardStyleProvider.notifier).update(next);
  }

  Future<void> _copy() async {
    final text = _text;
    await ShareService.copyText(context, text);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _shareText() async {
    final text = _text;
    final subject = _content.title ?? _content.reference;
    Navigator.of(context).pop();
    await ShareService.shareText(body: text, subject: subject);
  }

  Future<void> _shareImage() async {
    setState(() => _busy = true);
    unawaited(HapticFeedback.mediumImpact());
    final ok = await ShareService.shareImageFromBoundary(
      boundaryKey: _boundaryKey,
      filename: _content.imageFilename,
      caption: _content.caption,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _failed();
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _busy = true);
    unawaited(HapticFeedback.mediumImpact());
    final ok = await SharePdfService.share(_content);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _failed();
    }
  }

  Future<void> _saveImage() async {
    setState(() {
      _busy = true;
      _note = null;
    });
    unawaited(HapticFeedback.mediumImpact());
    final result = await ShareService.saveImageFromBoundary(
      boundaryKey: _boundaryKey,
      filename: _content.imageFilename,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case GallerySaveResult.saved:
          _note = context.l10n.shareSavedToGallery;
          _noteIsError = false;
          break;
        case GallerySaveResult.permissionDenied:
          _note = context.l10n.shareGalleryDenied;
          _noteIsError = true;
          break;
        case GallerySaveResult.failed:
          _note = context.l10n.shareSaveFailed;
          _noteIsError = true;
          break;
      }
    });
  }

  void _failed() {
    setState(() {
      _note = context.l10n.shareFailed;
      _noteIsError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final modes = [
      _ShareMode.text,
      _ShareMode.image,
      if (_content.offersPdf) _ShareMode.pdf,
    ];
    final modeIndex = modes.indexOf(_mode).clamp(0, modes.length - 1);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: Radii.sheet,
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(_content.kind),
                  size: 20, color: theme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_content.eyebrow.isNotEmpty)
                      Text(
                        _content.eyebrow.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    Text(
                      _content.title ?? _content.reference ?? l10n.commonShare,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PillSegmentedControl(
            segments: [
              l10n.shareModeText,
              l10n.shareModeImage,
              if (_content.offersPdf) l10n.shareModePdf,
            ],
            selectedIndex: modeIndex,
            onSegmentSelected: (i) {
              HapticFeedback.selectionClick();
              setState(() {
                _mode = modes[i];
                _note = null;
              });
            },
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: switch (_mode) {
                _ShareMode.text => _buildText(context),
                _ShareMode.image => _buildImage(context),
                _ShareMode.pdf => _buildPdf(context),
              },
            ),
          ),
          if (_note != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    _noteIsError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 18,
                    color: _noteIsError
                        ? theme.colorScheme.error
                        : theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _note!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _noteIsError
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Text ──────────────────────────────────────────────────────────────
  Widget _buildText(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: TypeScale.bodyLarge,
                  height: 1.7,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ControlLabel(l10n.shareFormat),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final flavor in ShareFlavor.values)
                ChoiceChip(
                  label: Text(flavor == ShareFlavor.plain
                      ? l10n.shareFlavorPlain
                      : l10n.shareFlavorWhatsapp),
                  selected: _flavor == flavor,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _flavor = flavor;
                      _note = null;
                    });
                    // Remember the choice for the next share, not just this
                    // session.
                    ref.read(preferencesProvider).saveShareFlavor(
                          flavor == ShareFlavor.plain ? 'plain' : 'whatsapp',
                        );
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _flavor == ShareFlavor.plain
                ? l10n.shareFlavorPlainHint
                : l10n.shareFlavorWhatsappHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (_content.kind != ShareKind.word) ...[
            const SizedBox(height: 4),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.shareIncludeReference,
                  style: theme.textTheme.bodyMedium),
              value: _includeReference,
              onChanged: (v) => setState(() => _includeReference = v),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _copy,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  label: Text(l10n.spaceCopyText),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.lg),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _shareText,
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                  label: Text(l10n.shareText),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.lg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image ─────────────────────────────────────────────────────────────
  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            height: 300,
            child: FittedBox(
              fit: BoxFit.contain,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: ShareCard.fromContent(
                  _content,
                  backdrop: _backdrop,
                  style: _style,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${_style.format.width.toInt()} × '
            '${_style.format.height.toInt()} px',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _ControlLabel(l10n.shareFormat),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final format in ShareCardFormat.values)
              ChoiceChip(
                label: Text(switch (format) {
                  ShareCardFormat.portrait => l10n.shareFormatPortrait,
                  ShareCardFormat.square => l10n.shareFormatSquare,
                  ShareCardFormat.story => l10n.shareFormatStory,
                }),
                selected: _style.format == format,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  _setStyle(_style.copyWith(format: format));
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ControlLabel(l10n.shareBackdrop),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final backdrop in ShareCardBackdrop.values)
              ChoiceChip(
                avatar: ShareBackdropSwatch(
                  backdrop: backdrop,
                  artworkPath: _content.artworkPath,
                ),
                label: Text(switch (backdrop) {
                  ShareCardBackdrop.dawn => l10n.shareBackdropDawn,
                  ShareCardBackdrop.dusk => l10n.shareBackdropDusk,
                  ShareCardBackdrop.artwork => l10n.shareBackdropArtwork,
                  ShareCardBackdrop.gradient => l10n.shareBackdropGradient,
                }),
                selected: _backdrop == backdrop,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _backdrop = backdrop);
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        Material(
          type: MaterialType.transparency,
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(
                l10n.shareStyle,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              children: [
                _ControlLabel(l10n.shareFont),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final font in ['', ...kShareCardFonts])
                      ChoiceChip(
                        label: Text(font.isEmpty ? l10n.shareFontTheme : font),
                        selected: (_style.fontFamily ?? '') == font,
                        onSelected: (_) => _setStyle(_style.copyWith(
                            fontFamily: font.isEmpty ? null : font,
                            clearFont: font.isEmpty)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ControlLabel(l10n.shareSize),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final size in const [0.85, 1.0, 1.2])
                                ChoiceChip(
                                  label: Text('${(size * 100).round()}%'),
                                  selected: _style.scale == size,
                                  onSelected: (_) =>
                                      _setStyle(_style.copyWith(scale: size)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ControlLabel(l10n.shareSpacing),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final spacing in const [0.0, 1.0, 2.0])
                                ChoiceChip(
                                  label: Text(spacing == 0
                                      ? l10n.shareSpacingNormal
                                      : l10n.shareSpacingWide(
                                          '${spacing.toInt()}')),
                                  selected: _style.letterSpacing == spacing,
                                  onSelected: (_) => _setStyle(
                                      _style.copyWith(letterSpacing: spacing)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ControlLabel(l10n.shareLineHeight),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final height in const [1.3, 1.45, 1.6])
                                ChoiceChip(
                                  label: Text(height.toStringAsFixed(2)),
                                  selected: _style.lineHeight == height,
                                  onSelected: (_) => _setStyle(
                                      _style.copyWith(lineHeight: height)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ControlLabel(l10n.shareAlignment),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final align in const [
                                TextAlign.left,
                                TextAlign.center
                              ])
                                ChoiceChip(
                                  label: Text(align == TextAlign.center
                                      ? l10n.shareAlignCenter
                                      : l10n.shareAlignLeft),
                                  selected: _style.align == align,
                                  onSelected: (_) =>
                                      _setStyle(_style.copyWith(align: align)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _saveImage,
                icon: const Icon(Icons.download_outlined, size: 20),
                label: Text(
                  l10n.shareSaveImage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.lg),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _shareImage,
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: Text(
                  _busy ? l10n.sharePreparing : l10n.shareImage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.lg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PDF ───────────────────────────────────────────────────────────────
  Widget _buildPdf(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A page-shaped preview of the exported document, so the user knows
        // exactly what the PDF will look like before sharing it.
        Center(
          child: SizedBox(
            height: 330,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ShareDocumentPreview(content: _content),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.sharePdfPreviewNote,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.sharePdfTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.sharePdfBody,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _sharePdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_busy ? l10n.shareBuildingPdf : l10n.shareSharePdf),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
          ),
        ),
      ],
    );
  }

  static IconData _iconFor(ShareKind kind) => switch (kind) {
        ShareKind.verse => Icons.menu_book_rounded,
        ShareKind.word => Icons.translate_rounded,
        ShareKind.story => Icons.auto_stories_rounded,
        ShareKind.commentary => Icons.lightbulb_outline_rounded,
      };
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
