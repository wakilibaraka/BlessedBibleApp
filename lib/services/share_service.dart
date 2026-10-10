import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bible_books.dart';
import '../state/translation_provider.dart';
import 'bible_database_service.dart';
import '../utils/log.dart';

/// A centralized service for formatting and sharing Bible content.
///
/// Two text flavors:
/// - Clipboard: clean typographic layout, no markup (renders raw
///   everywhere, including Notes and SMS).
/// - Share sheet: WhatsApp-aware (`_italics_` on the reference lines;
///   WhatsApp renders them, other targets show faint underscores).
/// Image cards are rendered from widgets (no new packages).
class ShareService {
  /// Strips rendering markup from verse text before sharing:
  /// - Strong's tags `[H123]` / `[G245]` (viewer setting dependent)
  /// - KJV supplied-word brackets `[God]` — word kept, brackets dropped
  /// - red-letter delimiters `‹ ›` and paragraph marks `¶`
  /// - collapsed whitespace
  /// These exist for on-screen rendering; they must never leak into
  /// copied or shared text.
  static String cleanVerseText(String raw) {
    return raw
        // Strong's tags ship as "[H123]" or "[ G123 ]" depending on pack.
        .replaceAll(RegExp(r'\[\s*[HG]\s*\d+\s*\]'), '')
        .replaceAllMapped(RegExp(r'\[([^\]]*)\]'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp('[‹›¶]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Formats verses for copy/share.
  ///
  /// Plain (clipboard):
  ///   "For God so loved the world…"
  ///
  ///   — John 3:16 (KJV)
  ///
  /// With [secondaryTexts]/[secondaryReference]/[secondaryTag], the
  /// second language follows in its own quoted block (italicised in
  /// the WhatsApp flavor). Missing secondary verses are skipped
  /// silently — primary only, no apology text.
  static String formatVerse({
    required List<String> texts,
    required String reference,
    required String translationTag,
    List<String>? secondaryTexts,
    String? secondaryReference,
    String? secondaryTag,
    bool whatsapp = false,
  }) {
    final cleaned =
        texts.map(cleanVerseText).where((t) => t.isNotEmpty).toList();
    if (cleaned.isEmpty) return '';
    final body = cleaned.length > 1
        ? cleaned
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join(' ')
        : cleaned.first;

    final refLine = '— $reference ($translationTag)';
    final buf = StringBuffer()
      ..writeln('"$body"')
      ..writeln()
      ..writeln(whatsapp ? '_${refLine}_' : refLine);

    final sec = (secondaryTexts ?? [])
        .map(cleanVerseText)
        .where((t) => t.isNotEmpty)
        .toList();
    if (sec.isNotEmpty &&
        secondaryReference != null &&
        secondaryReference.isNotEmpty &&
        secondaryTag != null &&
        secondaryTag.isNotEmpty) {
      final secBody = sec.join(' ');
      final secRef = '— $secondaryReference ($secondaryTag)';
      buf
        ..writeln()
        ..writeln(whatsapp ? '_"$secBody"_' : '"$secBody"')
        ..writeln()
        ..writeln(whatsapp ? '_${secRef}_' : secRef);
    }
    return buf.toString().trimRight();
  }

  /// Formats a dictionary/WOTD word for copy/share. Headword and
  /// source render in capitals:
  ///   GRACE
  ///   "Unmerited favour…"
  ///
  ///   — EASTON'S BIBLE DICTIONARY
  static String formatWord({
    required String word,
    required String definition,
    required String sourceName,
    int maxDefinitionLength = 600,
  }) {
    var def = definition.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (def.length > maxDefinitionLength) {
      def = '${def.substring(0, maxDefinitionLength).trimRight()}…';
    }
    return '${word.trim().toUpperCase()}\n"$def"\n\n— ${sourceName.trim().toUpperCase()}';
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
        const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 2)),
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

  /// Captures the widget behind [boundaryKey] as a 1080-wide PNG and
  /// shares it via the native sheet. Temp file only — nothing is added
  /// to the bundle and the OS may purge the cache copy.
  static Future<void> shareImageFromBoundary({
    required GlobalKey boundaryKey,
    required String filename,
    String? caption,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/$filename-${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance
          .share(ShareParams(files: [XFile(file.path)], text: caption));
    } catch (e) {
      logDebug('Share image failed: $e');
    }
  }
}
