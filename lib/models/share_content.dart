import 'package:flutter/foundation.dart';

import '../utils/prose.dart';

/// What is being shared. Drives the text layout, the image card and which
/// export formats (text / image / PDF) the share sheet offers.
enum ShareKind { verse, word, story, commentary }

/// Text flavor for copying and sharing.
///
/// - [plain] carries no markup, so it pastes readably into Notes, SMS,
///   email and any plain-text field.
/// - [whatsapp] uses WhatsApp's own markup: bold for headings and italics
///   for the citation lines, the two styles WhatsApp renders natively.
enum ShareFlavor { plain, whatsapp }

/// Strips rendering markup from verse text so it never leaks into copied or
/// shared text:
/// - Strong's tags `[H123]` / `[G245]` (viewer setting dependent)
/// - KJV supplied-word brackets `[God]` — word kept, brackets dropped
/// - red-letter delimiters `‹ ›`, paragraph marks `¶` and bold markers `**`
/// - collapsed whitespace
String cleanShareText(String raw) {
  return raw
      // Strong's tags ship as "[H123]" or "[ G123 ]" depending on pack.
      .replaceAll(RegExp(r'\[\s*[HG]\s*\d+\s*\]'), '')
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]'), (m) => m.group(1) ?? '')
      .replaceAll(RegExp('[‹›¶]'), '')
      .replaceAll('**', '')
      .replaceAll('__', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Splits a multi-paragraph body into clean paragraphs.
///
/// Print-sourced text is hard-wrapped, so single line breaks are wrap
/// artefacts (joined); blank lines separate real paragraphs.
List<String> shareParagraphs(String raw) => proseParagraphs(raw)
    .map(cleanShareText)
    .where((p) => p.isNotEmpty)
    .toList();

/// Trims [raw] to a sentence-ish [maxChars], ending on a word boundary with
/// an ellipsis. Already-short text is returned untouched.
String shareExcerpt(String raw, int maxChars) {
  final text = cleanShareText(raw);
  if (text.length <= maxChars) return text;
  final cut = text.substring(0, maxChars);
  final space = cut.lastIndexOf(' ');
  final body = (space > maxChars * 0.6 ? cut.substring(0, space) : cut)
      .replaceAll(RegExp(r'[,;:.\s]+$'), '');
  return '$body…';
}

/// Lowercase URL-ish slug used for generated file names.
String shareSlug(String raw) => raw
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String _stripWrappingQuotes(String raw) {
  var s = raw.trim();
  const pairs = {
    '"': '"',
    '\u201c': '\u201d',
    "'": "'",
    '\u2018': '\u2019',
  };
  while (s.length >= 2 &&
      pairs.containsKey(s[0]) &&
      s[s.length - 1] == pairs[s[0]]) {
    s = s.substring(1, s.length - 1).trim();
  }
  return s;
}

/// One unit of shareable content — a verse selection, a word, a story or a
/// commentary entry — plus the formatting rules for every export.
///
/// Text layout is kind-specific but follows one scheme:
///
/// ```
/// TITLE (caps, bold in WhatsApp)
/// “body in typographic quotes” (verses and words)
///
/// — citation (italics in WhatsApp)
/// ```
///
/// The image card and the PDF are both built from the same fields, so what
/// the user previews, copies, shares and prints always match.
@immutable
class ShareContent {
  final ShareKind kind;

  /// Small-caps label used by the card and the PDF running head
  /// (e.g. "VERSE OF THE DAY", "COMMENTARY").
  final String eyebrow;

  /// Heading: story title, dictionary headword. Verses use [reference].
  final String? title;

  /// Passage reference ("John 3:16", "Genesis 1:1-2:3").
  final String? reference;

  /// Translation abbreviation ("KJV") for verse content.
  final String? translation;

  /// Work a definition or commentary comes from.
  final String? source;

  /// Person behind the commentary.
  final String? author;

  /// Optional date line for daily content ("January 1").
  final String? date;

  /// Body paragraphs, already clean of rendering markup.
  final List<String> paragraphs;

  /// Verse numbers matching [paragraphs], when known.
  final List<int>? verseNumbers;

  /// Story key verse and its reference (quoted above the retelling).
  final String? keyVerse;
  final String? keyVerseRef;

  /// Second-language block for bilingual verse sharing.
  final List<String> secondaryParagraphs;
  final String? secondaryReference;
  final String? secondaryTag;

  /// Doré plate used by the artwork image backdrop.
  final String? artworkPath;

  /// Base file name for generated images and PDFs.
  final String imageFilename;

  const ShareContent({
    required this.kind,
    this.eyebrow = '',
    this.title,
    this.reference,
    this.translation,
    this.source,
    this.author,
    this.date,
    this.paragraphs = const [],
    this.verseNumbers,
    this.keyVerse,
    this.keyVerseRef,
    this.secondaryParagraphs = const [],
    this.secondaryReference,
    this.secondaryTag,
    this.artworkPath,
    this.imageFilename = 'blessed-bible',
  });

  /// A verse selection (also used by Verse of the Day).
  factory ShareContent.verse({
    required String reference,
    required List<String> texts,
    required String translationTag,
    String eyebrow = '',
    List<int>? verseNumbers,
    List<String> secondaryTexts = const [],
    String? secondaryReference,
    String? secondaryTag,
    String? artworkPath,
    String imageFilename = 'verse',
  }) {
    return ShareContent(
      kind: ShareKind.verse,
      eyebrow: eyebrow,
      reference: reference,
      translation: translationTag,
      paragraphs: texts.map(cleanShareText).where((t) => t.isNotEmpty).toList(),
      verseNumbers: verseNumbers,
      secondaryParagraphs: secondaryTexts
          .map(cleanShareText)
          .where((t) => t.isNotEmpty)
          .toList(),
      secondaryReference: secondaryReference,
      secondaryTag: secondaryTag,
      artworkPath: artworkPath,
      imageFilename: imageFilename.isEmpty
          ? 'verse-${shareSlug(reference)}'
          : imageFilename,
    );
  }

  /// A dictionary / Word of the Day entry.
  factory ShareContent.word({
    required String word,
    required String definition,
    required String sourceName,
    String eyebrow = '',
    String imageFilename = 'word',
  }) {
    return ShareContent(
      kind: ShareKind.word,
      eyebrow: eyebrow,
      title: cleanShareText(word),
      source: cleanShareText(sourceName),
      paragraphs: shareParagraphs(definition),
      imageFilename: imageFilename,
    );
  }

  /// A Bible story, from the daily card or the full story reader.
  factory ShareContent.story({
    required String title,
    required String body,
    required String reference,
    String eyebrow = '',
    String? keyVerse,
    String? keyVerseRef,
    String? source,
    String? artworkPath,
    String imageFilename = 'story',
  }) {
    final cleanKey = keyVerse == null ? '' : _stripWrappingQuotes(keyVerse);
    return ShareContent(
      kind: ShareKind.story,
      eyebrow: eyebrow,
      title: cleanShareText(title),
      reference: cleanShareText(reference),
      source: source == null ? null : cleanShareText(source),
      keyVerse: cleanKey.isEmpty ? null : cleanShareText(cleanKey),
      keyVerseRef: keyVerseRef == null ? null : cleanShareText(keyVerseRef),
      paragraphs: shareParagraphs(body),
      artworkPath: artworkPath,
      imageFilename: imageFilename,
    );
  }

  /// A commentary entry (verse, chapter or book scope).
  factory ShareContent.commentary({
    required String text,
    required String reference,
    String? source,
    String? author,
    String date = '',
    String eyebrow = 'Commentary',
  }) {
    return ShareContent(
      kind: ShareKind.commentary,
      eyebrow: eyebrow,
      title: cleanShareText(reference),
      reference: cleanShareText(reference),
      source: source == null ? null : cleanShareText(source),
      author: author == null ? null : cleanShareText(author),
      date: date.isEmpty ? null : date,
      paragraphs: shareParagraphs(text),
      imageFilename: 'commentary-${shareSlug(reference)}',
    );
  }

  /// Whether this content has enough body to be worth exporting.
  bool get hasBody => paragraphs.isNotEmpty;

  /// Offers a PDF: the long-form kinds, where text bubbles and images can't
  /// hold the whole thing.
  bool get offersPdf => kind == ShareKind.commentary || kind == ShareKind.story;

  /// The attribution line without the leading dash, e.g.
  /// "John 3:16 (KJV)" or "Ellen G. White, The Desire of Ages".
  String? get attribution {
    if (kind == ShareKind.commentary) {
      final parts = [author, source]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
      return parts.isEmpty ? null : parts.join(', ');
    }
    if (kind == ShareKind.word) {
      // Dictionaries sign their entries in caps, matching the card.
      return (source == null || source!.isEmpty) ? null : source!.toUpperCase();
    }
    if (reference == null || reference!.isEmpty) return null;
    final tag = translation;
    return (tag == null || tag.isEmpty) ? reference : '$reference ($tag)';
  }

  /// Short caption attached to shared images.
  String get caption {
    final line = attribution;
    if (line == null) return 'The Blessed Bible';
    return '$line · The Blessed Bible';
  }

  /// The exact text that will be copied or shared.
  ///
  /// [flavor] picks plain text or WhatsApp markup; [includeReference] drops
  /// the reference/citation line for people who only want the passage.
  String text({
    ShareFlavor flavor = ShareFlavor.plain,
    bool includeReference = true,
  }) {
    final w = flavor == ShareFlavor.whatsapp;
    final out = StringBuffer();

    void gap() {
      if (out.isEmpty) return;
      out.write('\n\n');
    }

    void block(String value) {
      if (value.isEmpty) return;
      gap();
      out.write(value);
    }

    void heading(String value) {
      final t = cleanShareText(value);
      if (t.isEmpty) return;
      gap();
      out.write(w ? '*${t.toUpperCase()}*' : t.toUpperCase());
    }

    void cite(String value) {
      final t = cleanShareText(value);
      if (t.isEmpty) return;
      gap();
      out.write(w ? '_— ${t}_' : '— $t');
    }

    String quoted(List<String> body) {
      if (body.isEmpty) return '';
      return '“${body.first}”';
    }

    switch (kind) {
      case ShareKind.verse:
        final body = paragraphs;
        if (body.isEmpty) return '';
        if (body.length == 1) {
          out.write(quoted(body));
        } else {
          for (var i = 0; i < body.length; i++) {
            if (i > 0) out.write('\n');
            final nums = verseNumbers;
            final n = (nums != null && i < nums.length) ? '${nums[i]} ' : '';
            out.write('$n${body[i]}');
          }
        }
        if (includeReference) cite(attribution ?? '');
        // Second language: kept in its own block, italic in WhatsApp so the
        // two translations stay visually distinct.
        if (secondaryParagraphs.isNotEmpty) {
          final sec = secondaryParagraphs.join(' ');
          gap();
          out.write(w ? '_“$sec”_' : '“$sec”');
          if (includeReference &&
              secondaryReference != null &&
              secondaryReference!.isNotEmpty) {
            final tag = secondaryTag;
            final line = (tag == null || tag.isEmpty)
                ? secondaryReference!
                : '${secondaryReference!} ($tag)';
            cite(line);
          }
        }
        break;

      case ShareKind.word:
        heading(title ?? '');
        final body = paragraphs;
        if (body.isNotEmpty) block('“${body.join(' ')}”');
        cite(attribution ?? '');
        break;

      case ShareKind.story:
        heading(title ?? '');
        if (keyVerse != null && keyVerse!.isNotEmpty) {
          final verseRef = keyVerseRef;
          block(verseRef == null || verseRef.isEmpty
              ? '“${keyVerse!}”'
              : '“${keyVerse!}”\n$verseRef');
        }
        for (final p in paragraphs) {
          block(p);
        }
        if (includeReference) cite(attribution ?? '');
        break;

      case ShareKind.commentary:
        if (includeReference && reference != null && reference!.isNotEmpty) {
          out.write(w ? '_${reference!}_' : reference!);
        }
        if (date != null && date!.isNotEmpty) heading(date!);
        for (final p in paragraphs) {
          block(p);
        }
        cite(attribution ?? '');
        break;
    }
    return out.toString().trim();
  }

  /// Plain-text flavor, for clipboard use in any app.
  String get plain => text();

  /// WhatsApp flavor, with its native bold/italic markup.
  String get whatsapp => text(flavor: ShareFlavor.whatsapp);

  /// Image-card copy of the body: the first [maxChars] characters, on a word
  /// boundary, so long entries stay legible inside the card.
  String excerpt({int maxChars = 420}) =>
      shareExcerpt(paragraphs.isEmpty ? '' : paragraphs.join('\n\n'), maxChars);

  ShareContent copyWith({
    String? eyebrow,
    String? reference,
    String? translation,
    String? artworkPath,
    String? imageFilename,
  }) =>
      ShareContent(
        kind: kind,
        eyebrow: eyebrow ?? this.eyebrow,
        title: title,
        reference: reference ?? this.reference,
        translation: translation ?? this.translation,
        source: source,
        author: author,
        date: date,
        paragraphs: paragraphs,
        verseNumbers: verseNumbers,
        keyVerse: keyVerse,
        keyVerseRef: keyVerseRef,
        secondaryParagraphs: secondaryParagraphs,
        secondaryReference: secondaryReference,
        secondaryTag: secondaryTag,
        artworkPath: artworkPath ?? this.artworkPath,
        imageFilename: imageFilename ?? this.imageFilename,
      );
}
