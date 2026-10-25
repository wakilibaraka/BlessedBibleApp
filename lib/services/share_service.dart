import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bible_books.dart';
import '../l10n/l10n.dart';
import '../models/share_content.dart';
import '../state/translation_provider.dart';
import 'bible_database_service.dart';
import 'gallery_service.dart';
import '../utils/log.dart';

/// A centralized service for formatting and sharing Bible content.
///
/// Two text flavors:
/// - Clipboard plain text: no markup, renders cleanly in Notes, SMS and
///   email.
/// - WhatsApp: WhatsApp's own markup (bold headings, italic citations),
///   which the target renders natively and other apps show unobtrusively.
///
/// Layouts live in [ShareContent]; this service keeps the historical
/// formatter helpers, clipboard/share plumbing and image capture.
/// Image cards and PDFs are rendered from widgets/vectors (no extra
/// native plugins).
class ShareService {
  /// Strips rendering markup from verse text before sharing. See
  /// [cleanShareText] for the full list of tags removed.
  static String cleanVerseText(String raw) => cleanShareText(raw);

  /// Formats verses for copy/share.
  ///
  /// Plain (clipboard):
  ///   “For God so loved the world…”
  ///
  ///   — John 3:16 (KJV)
  ///
  /// With [secondaryTexts]/[secondaryReference]/[secondaryTag], the second
  /// language follows in its own quoted block (italicised in the WhatsApp
  /// flavor). Missing secondary verses are skipped silently — primary only,
  /// no apology text.
  static String formatVerse({
    required List<String> texts,
    required String reference,
    required String translationTag,
    List<String>? secondaryTexts,
    String? secondaryReference,
    String? secondaryTag,
    List<int>? verseNumbers,
    bool whatsapp = false,
  }) {
    return ShareContent.verse(
      reference: reference,
      texts: texts,
      translationTag: translationTag,
      verseNumbers: verseNumbers,
      secondaryTexts: secondaryTexts ?? const [],
      secondaryReference: secondaryReference,
      secondaryTag: secondaryTag,
    ).text(
      flavor: whatsapp ? ShareFlavor.whatsapp : ShareFlavor.plain,
    );
  }

  /// Formats a dictionary/WOTD word for copy/share. Headword and
  /// source render in capitals:
  ///   GRACE
  ///   “Unmerited favour…”
  ///
  ///   — EASTON'S BIBLE DICTIONARY
  static String formatWord({
    required String word,
    required String definition,
    required String sourceName,
    int maxDefinitionLength = 600,
    bool whatsapp = false,
  }) {
    final def = shareExcerpt(definition, maxDefinitionLength);
    return ShareContent.word(
      word: word,
      definition: def,
      sourceName: sourceName,
    ).text(flavor: whatsapp ? ShareFlavor.whatsapp : ShareFlavor.plain);
  }

  /// Formats a Bible story for copy/share:
  ///   THE CREATION OF THE WORLD
  ///   “In the beginning...”
  ///
  ///   — Genesis 1:1-2:3
  static String formatStory({
    required String title,
    required String summary,
    required String reference,
    int maxSummaryLength = 600,
    bool whatsapp = false,
  }) {
    final s = shareExcerpt(summary, maxSummaryLength);
    return ShareContent.story(
      title: title,
      body: s,
      reference: reference,
    ).text(flavor: whatsapp ? ShareFlavor.whatsapp : ShareFlavor.plain);
  }

  /// Formats a commentary entry for copy/share:
  ///   Genesis 1:2
  ///
  ///   Is it possible to imagine a time when nothing existed? …
  ///
  ///   — Ellen G. White, Patriarchs and Prophets
  static String formatCommentary({
    required String text,
    required String reference,
    String? source,
    String? author,
    bool whatsapp = false,
  }) {
    return ShareContent.commentary(
      text: text,
      reference: reference,
      source: source,
      author: author,
    ).text(flavor: whatsapp ? ShareFlavor.whatsapp : ShareFlavor.plain);
  }

  /// Reference string for a verse selection: `John 3:16`,
  /// `John 3:16-18`, or `John 3:16, 18`.
  static String referenceFor(
      String bookName, int chapterNum, List<int> targetVerses) {
    final sorted = targetVerses.toList()..sort();
    if (sorted.isEmpty) return '$bookName $chapterNum';
    if (sorted.length == 1) {
      return '$bookName $chapterNum:${sorted.first}';
    }
    var contiguous = true;
    for (var i = 0; i < sorted.length - 1; i++) {
      if (sorted[i + 1] - sorted[i] != 1) {
        contiguous = false;
        break;
      }
    }
    if (contiguous) {
      return '$bookName $chapterNum:${sorted.first}-${sorted.last}';
    }
    return '$bookName $chapterNum:${sorted.join(', ')}';
  }

  /// Shared copy/share payload: primary texts + reference + tags, plus
  /// the secondary translation when one is active and holds the verses
  /// (missing secondary verses fall back to primary-only, silently).
  /// Pass already-loaded primary [texts] when the caller has them
  /// (avoids a redundant chapter fetch).
  static Future<
      ({
        List<String> texts,
        String reference,
        String tag,
        List<String> secondaryTexts,
        String secondaryTag,
      })> collectVerseShare(
    WidgetRef ref, {
    required String bookName,
    required int chapterNum,
    required List<int> targetVerses,
    List<String>? texts,
  }) async {
    final sorted = targetVerses.toList()..sort();
    final activeTrans = ref.read(activeTranslationProvider);
    var tag = activeTrans.toUpperCase();
    try {
      final infos = await bibleDbService.getTranslations();
      final match = infos.where((t) => t.translationId == activeTrans);
      if (match.isNotEmpty) tag = match.first.abbreviation.toUpperCase();
    } catch (_) {}

    var secondaryTexts = <String>[];
    var secondaryTag = '';
    final secondaryId = ref.read(secondaryTranslationProvider);
    if (secondaryId != null && secondaryId != activeTrans) {
      try {
        final bookNumber = kBibleBookNames.indexOf(bookName) + 1;
        if (bookNumber > 0) {
          final secChapter = await bibleDbService.getChapter(
              secondaryId, bookNumber, chapterNum);
          final byNumber = {for (final v in secChapter) v.number: v.text};
          secondaryTexts = [
            for (final v in sorted)
              if (byNumber[v] != null) byNumber[v]!,
          ];
          if (secondaryTexts.isNotEmpty) {
            final infos = await bibleDbService.getTranslations();
            final match = infos.where((t) => t.translationId == secondaryId);
            secondaryTag = match.isNotEmpty
                ? match.first.abbreviation.toUpperCase()
                : secondaryId.toUpperCase();
          }
        }
      } catch (_) {}
    }

    return (
      texts: texts ?? [],
      reference: referenceFor(bookName, chapterNum, sorted),
      tag: tag,
      secondaryTexts: secondaryTexts,
      secondaryTag: secondaryTag,
    );
  }

  /// Copies text to clipboard and shows a confirmation SnackBar.
  static Future<void> copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.l10n.searchCopied),
            duration: const Duration(seconds: 2)),
      );
    }
  }

  /// Shares text via native share sheet using share_plus.
  static Future<void> shareText({required String body, String? subject}) async {
    try {
      await SharePlus.instance.share(ShareParams(text: body, subject: subject));
    } catch (e) {
      logDebug('Share failed: $e');
    }
  }

  /// Renders the widget behind [boundaryKey] to PNG bytes at its design
  /// size. Returns null when capture is not possible yet (widget off-screen).
  static Future<Uint8List?> captureBoundaryPng(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // Cards are laid out at their export size (1080 wide), so pixelRatio
      // 1 keeps the PNG exactly at design dimensions.
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return bytes?.buffer.asUint8List();
    } catch (e) {
      logDebug('Capture failed: $e');
      return null;
    }
  }

  /// Captures the card behind [boundaryKey] as a PNG and shares it via
  /// the native sheet. Temp file only — nothing is added to the bundle and
  /// the OS may purge the cache copy.
  ///
  /// Returns false when the capture could not be produced, so the sheet
  /// can surface a retry instead of closing silently.
  static Future<bool> shareImageFromBoundary({
    required GlobalKey boundaryKey,
    required String filename,
    String? caption,
  }) async {
    try {
      final bytes = await captureBoundaryPng(boundaryKey);
      if (bytes == null) return false;
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/$filename-${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: caption),
      );
      return true;
    } catch (e) {
      logDebug('Share image failed: $e');
      return false;
    }
  }

  /// Captures the card and writes it to the device photo library.
  static Future<GallerySaveResult> saveImageFromBoundary({
    required GlobalKey boundaryKey,
    required String filename,
  }) async {
    final bytes = await captureBoundaryPng(boundaryKey);
    if (bytes == null) return GallerySaveResult.failed;
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    return GalleryService.savePng(bytes, name: '$filename-$stamp');
  }

  /// Writes [bytes] to a temporary file and opens the native share sheet for
  /// it. Used by the PDF exporter.
  static Future<bool> shareFileBytes({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    String? subject,
    String? text,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final base = filename.toLowerCase().endsWith('.pdf')
          ? filename.substring(0, filename.length - 4)
          : filename;
      final file = File(
          '${dir.path}/$base-${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType)],
          subject: subject,
          text: text,
        ),
      );
      return true;
    } catch (e) {
      logDebug('Share file failed: $e');
      return false;
    }
  }
}
