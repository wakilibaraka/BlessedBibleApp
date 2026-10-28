// Concordance query rules: the screen used to reject anything that wasn't
// pure ASCII (so Spanish, Portuguese, Romanian and Tagalog users could never
// search anything) and could only match single words. Pure unit test — no
// database, no providers.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/screens/concordance_screen.dart';

void main() {
  group('isSearchableQuery', () {
    test('accepts plain and accented words', () {
      for (final q in [
        'grace',
        'GRACE',
        'gracia', // es
        'graça', // pt
        'înțelepciune', // ro
        'kahapon', // tl
        'ufahamu', // sw
      ]) {
        expect(ConcordanceScreen.isSearchableQuery(q), isTrue, reason: q);
      }
    });

    test('accepts short phrases and internal apostrophes/hyphens', () {
      for (final q in [
        'eternal life',
        "don't",
        'au-dessus',
        '  spaced   out  ',
      ]) {
        expect(ConcordanceScreen.isSearchableQuery(q), isTrue, reason: q);
      }
    });

    test('rejects empty, punctuation-only and wildcard queries', () {
      for (final q in ['', '   ', '%', '___', '*', '"', '-']) {
        expect(ConcordanceScreen.isSearchableQuery(q), isFalse, reason: q);
      }
    });
  });

  group('phraseMatcher', () {
    test('matches whole words only, not substrings', () {
      final m = ConcordanceScreen.phraseMatcher('grace');
      expect(m.hasMatch('For by grace are you saved'), isTrue);
      expect(m.hasMatch('GRACE and peace'), isTrue);
      expect(m.hasMatch('disgraced conduct'), isFalse);
      expect(m.hasMatch('graceless'), isFalse);
    });

    test('single word does not match inside an accented word', () {
      final m = ConcordanceScreen.phraseMatcher('gracia');
      expect(m.hasMatch('Porque de tal manera amó Dios al mundo'), isFalse);
      expect(m.hasMatch('la gracia de Dios'), isTrue);
    });

    test('phrases tolerate runs of whitespace', () {
      final m = ConcordanceScreen.phraseMatcher('eternal life');
      expect(m.hasMatch('the eternal life of man'), isTrue);
      expect(m.hasMatch('eternal   life'), isTrue);
      expect(m.hasMatch('eternally life'), isFalse);
    });

    test('apostrophes stay inside the word', () {
      final m = ConcordanceScreen.phraseMatcher("don't");
      expect(m.hasMatch("please don't worry"), isTrue);
      expect(m.hasMatch('dont worry'), isFalse);
    });
  });
}
