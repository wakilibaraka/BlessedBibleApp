// Editorial clean-up for the long-form text in the content packs.
//
// Commentary and devotional passages were imported from print sources, so
// they arrive hard-wrapped at roughly eighty characters and occasionally
// lose the space after a sentence. Rendered as-is, every source line became
// its own paragraph and sentences broke across the page. Everything that
// displays such prose runs it through [normalizeProse] (one paragraph) or
// [proseParagraphs] (a whole field) first.

/// Zero-width characters, the soft hyphen and typographic spaces that would
/// otherwise show up as odd gaps mid-word.
final RegExp _invisible = RegExp('[\u200b\u200c\u200d\ufeff\u00ad]');
final RegExp _hardWrap = RegExp(r'[ \t]*\n[ \t]*');
final RegExp _runs = RegExp(r'[ \t]{2,}');

/// A word split across a hard wrap at its own hyphen: "God-\ngiven" must not
/// become "God- given". The hyphen is kept, since it belongs to the word.
final RegExp _hyphenWrap = RegExp(r'([A-Za-zÀ-ÿ])-[ \t]*\n[ \t]*([a-zà-ÿ])');

final RegExp _missingSentenceSpace = RegExp(r'([.!?])([A-Z])');
final RegExp _missingClauseSpace = RegExp(r'([,;:])([A-Z])');

/// A sentence glued to the next one by the OCR pass: "asked.no" becomes
/// "asked. no". Restricted to words of four or more letters so abbreviations
/// (i.e., e.g., Dan., vs.) keep their shape.
final RegExp _gluedSentence = RegExp(r'([A-Za-zÀ-ÿ]{4,})([.!?])([a-zà-ÿ])');
final RegExp _paragraphBreak = RegExp(r'\n[ \t]*\n');

/// Collapses the prose in [text] into one flowing paragraph: hard line wraps
/// become spaces, hyphenated words broken across a wrap are rejoined, runs of
/// spaces become one, and a missing space after sentence punctuation is
/// restored.
String normalizeProse(String text) {
  var out = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\u00a0', ' ')
      .replaceAll(_invisible, '');

  out = out.replaceAllMapped(_hyphenWrap, (m) => '${m[1]}-${m[2]}');
  out = out.replaceAll(_hardWrap, ' ');
  out = out.replaceAll(_runs, ' ');
  out = out.replaceAllMapped(_missingSentenceSpace, (m) => '${m[1]} ${m[2]}');
  out = out.replaceAllMapped(_missingClauseSpace, (m) => '${m[1]} ${m[2]}');
  out = out.replaceAllMapped(_gluedSentence, (m) => '${m[1]}${m[2]} ${m[3]}');
  return out.trim();
}

/// Whether [text] still has something to show once whitespace and invisible
/// characters are dropped; the same as `normalizeProse(text).isNotEmpty`
/// without running the normalising passes.
bool hasVisibleProse(String text) =>
    text.replaceAll(_invisible, '').trim().isNotEmpty;

/// Splits [text] into paragraphs at blank lines and normalizes each one.
///
/// Single line breaks are treated as wrap artefacts (they are joined), blank
/// lines are real paragraph breaks.
List<String> proseParagraphs(String text) {
  final normalized = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(_invisible, '');
  return normalized
      .split(_paragraphBreak)
      .map(normalizeProse)
      .where((paragraph) => paragraph.isNotEmpty)
      .toList(growable: false);
}

/// Removes the straight or curly quotes around [text]; the content
/// packs already quote key verses and the reader adds its own pair.
String stripQuotes(String text) {
  const quotes = '"“”\'‘’';
  var out = text.trim();
  while (out.isNotEmpty && quotes.contains(out[0])) {
    out = out.substring(1);
  }
  while (out.isNotEmpty && quotes.contains(out[out.length - 1])) {
    out = out.substring(0, out.length - 1);
  }
  return out.trim();
}
