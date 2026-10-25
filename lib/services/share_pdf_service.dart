import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/share_content.dart';
import '../utils/log.dart';
import 'share_service.dart';

/// Builds a print-ready, book-style PDF for long-form content
/// (commentary entries and Bible stories) and hands it to the native share
/// sheet.
///
/// Layout mirrors the app's reading typography: a small-caps running head,
/// a serif title, a reference line, justified body copy and a citation, all
/// set in the bundled reading fonts so accented text (French, Italian,
/// Romanian, Swahili, Tagalog) renders correctly. Pure Dart — no native
/// plugin beyond share_plus.
class SharePdfService {
  static const _ink = PdfColor.fromInt(0xFF191714);
  static const _muted = PdfColor.fromInt(0xFF6B635A);
  static const _rule = PdfColor.fromInt(0xFFCFC6B8);
  static const _brand = 'The Blessed Bible';

  /// Long entries are clipped so a single tap can't produce a 100-page
  /// document; the tail keeps its ellipsis.
  static const _maxBodyChars =
      14000; // Cardo ships with the full Latin Extended-A set used by the app's
  // languages (Romanian ș/ț/ă, Swahili and Tagalog diacritics), unlike the
  // subsetted Literata faces. The EB Garamond semibold sets the title.
  static pw.Font? _body;
  static pw.Font? _bodyBold;
  static pw.Font? _bodyItalic;
  static pw.Font? _display;
  static bool _fontsLoaded = false;

  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return;
    _fontsLoaded = true;
    try {
      final body = await rootBundle.load('assets/fonts/Cardo-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/Cardo-Bold.ttf');
      final italic = await rootBundle.load('assets/fonts/Cardo-Italic.ttf');
      final display =
          await rootBundle.load('assets/fonts/EBGaramond-SemiBold.ttf');
      _body = pw.Font.ttf(body);
      _bodyBold = pw.Font.ttf(bold);
      _bodyItalic = pw.Font.ttf(italic);
      _display = pw.Font.ttf(display);
    } catch (e) {
      // Built-in Helvetica keeps export working if an asset is unavailable
      // (e.g. a stripped build); only Latin-1 would be affected.
      logDebug('PDF font load failed: $e');
    }
  }

  static pw.Font get _text => _body ?? pw.Font.helvetica();
  static pw.Font get _textBold => _bodyBold ?? pw.Font.helveticaBold();
  static pw.Font get _textItalic =>
      _bodyItalic ?? _body ?? pw.Font.helveticaOblique();
  static pw.Font get _titleFont => _display ?? _textBold;

  /// Builds the PDF bytes for [content]. Exposed for tests.
  static Future<Uint8List> build(ShareContent content) async {
    await _loadFonts();

    final paragraphs = <String>[];
    var used = 0;
    var clipped = false;
    for (final p in content.paragraphs) {
      if (used >= _maxBodyChars) {
        clipped = true;
        break;
      }
      final room = _maxBodyChars - used;
      final text = p.length > room ? '${p.substring(0, room).trimRight()}…' : p;
      if (p.length > room) clipped = true;
      paragraphs.add(text);
      used += text.length;
    }

    final doc = pw.Document(
      title: _docTitle(content),
      author: content.author ?? _brand,
      subject: content.eyebrow.isEmpty ? _brand : content.eyebrow,
      creator: _brand,
      producer: _brand,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(56, 54, 56, 44),
        header: (context) => _header(content),
        footer: _footer,
        build: (context) => [
          pw.SizedBox(height: 18),
          pw.Text(
            (content.kind == ShareKind.story
                    ? content.title
                    : content.reference) ??
                content.title ??
                '',
            style: pw.TextStyle(
              font: _titleFont,
              fontSize: 24,
              lineSpacing: 3,
              color: _ink,
            ),
          ),
          if (_metaLine(content) != null) ...[
            pw.SizedBox(height: 7),
            pw.Text(
              _metaLine(content)!,
              style: pw.TextStyle(
                font: _textItalic,
                fontSize: 10.5,
                color: _muted,
                lineSpacing: 2,
              ),
            ),
          ],
          pw.SizedBox(height: 14),
          pw.Container(height: 1.1, color: _rule),
          pw.SizedBox(height: 20),
          if (content.keyVerse != null && content.keyVerse!.isNotEmpty) ...[
            // Key verse sits in a quiet accent rule, like a pull quote.
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: _rule, width: 2.4),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '“${content.keyVerse!}”',
                    style: pw.TextStyle(
                      font: _textItalic,
                      fontSize: 13,
                      lineSpacing: 5,
                      color: _ink,
                    ),
                  ),
                  if (content.keyVerseRef != null &&
                      content.keyVerseRef!.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      content.keyVerseRef!,
                      style: pw.TextStyle(
                        font: _textBold,
                        fontSize: 8.5,
                        letterSpacing: 0.4,
                        color: _muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 18),
          ],
          // Ragged-right body: the pdf package only stretches spaces on
          // lines it marks justifiable, so left alignment keeps every line
          // even instead of half-justified.
          for (final p in paragraphs) ...[
            pw.Text(
              p,
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: _text,
                fontSize: 11.2,
                lineSpacing: 5,
                color: _ink,
              ),
            ),
            pw.SizedBox(height: 12),
          ],
          if (clipped)
            pw.Text(
              '…',
              style: pw.TextStyle(font: _text, fontSize: 11, color: _muted),
            ),
          // Stories already carry their reference under the title; the
          // closing citation is for commentary (author + work).
          if (content.attribution != null &&
              content.kind != ShareKind.story) ...[
            pw.SizedBox(height: 12),
            pw.Container(height: 0.8, width: 64, color: _rule),
            pw.SizedBox(height: 8),
            pw.Text(
              '— ${content.attribution!}',
              style: pw.TextStyle(
                font: _textItalic,
                fontSize: 9.5,
                color: _muted,
                lineSpacing: 2,
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// Builds and shares the PDF for [content]. Returns false on failure so
  /// the caller can offer a retry.
  static Future<bool> share(ShareContent content) async {
    try {
      final bytes = await build(content);
      return await ShareService.shareFileBytes(
        bytes: bytes,
        filename: '${content.imageFilename}.pdf',
        mimeType: 'application/pdf',
        subject: _docTitle(content),
      );
    } catch (e) {
      logDebug('PDF share failed: $e');
      return false;
    }
  }

  static String _docTitle(ShareContent content) {
    final base = content.kind == ShareKind.story
        ? (content.title ?? '')
        : (content.reference ?? content.title ?? '');
    return base.isEmpty ? _brand : base;
  }

  /// Byline under the title: the passage for a story, the date for a daily
  /// entry. Authors and works sign the closing citation instead, so they
  /// never appear twice.
  static String? _metaLine(ShareContent content) {
    final parts = <String>[];
    if (content.kind == ShareKind.story) {
      final ref = content.reference;
      if (ref != null && ref.isNotEmpty) parts.add(ref);
    }
    if (content.date != null && content.date!.isNotEmpty) {
      parts.add(content.date!);
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static pw.Widget _header(ShareContent content) {
    final eyebrow = content.eyebrow.isEmpty
        ? content.kind.name.toUpperCase()
        : content.eyebrow.toUpperCase();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              eyebrow,
              style: pw.TextStyle(
                font: _textBold,
                fontSize: 8,
                letterSpacing: 2.4,
                color: _muted,
              ),
            ),
            pw.Text(
              _brand.toUpperCase(),
              style: pw.TextStyle(
                font: _text,
                fontSize: 7.5,
                letterSpacing: 1.8,
                color: _muted,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 7),
        pw.Container(height: 0.6, color: _rule),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.6)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              _brand,
              style: pw.TextStyle(font: _text, fontSize: 7.5, color: _muted),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(font: _text, fontSize: 7.5, color: _muted),
            ),
          ],
        ),
      );
}
