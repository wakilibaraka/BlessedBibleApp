import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/utils/verse_linker.dart';

void main() {
  group('VerseLinker', () {
    test('parses single simple reference', () {
      final spans = VerseLinker.parse("In the beginning, Genesis 1:1 says...");
      expect(spans.length, 3);
      expect((spans[0] as TextSpan).text, "In the beginning, ");
      expect((spans[1] as TextSpan).toPlainText(), "Genesis 1:1");
      expect((spans[2] as TextSpan).text, " says...");
    });

    test('parses reference with numbered book', () {
      final spans = VerseLinker.parse("Read 1 Kings 8:22 for more.");
      expect(spans.length, 3);
      expect((spans[0] as TextSpan).text, "Read ");
      expect((spans[1] as TextSpan).toPlainText(), "1 Kings 8:22");
      expect((spans[2] as TextSpan).text, " for more.");
    });

    test('parses reference with multi-word book name', () {
      final spans = VerseLinker.parse("Go to Song of Solomon 2:1 now.");
      expect(spans.length, 3);
      expect((spans[0] as TextSpan).text, "Go to ");
      expect((spans[1] as TextSpan).toPlainText(), "Song of Solomon 2:1");
      expect((spans[2] as TextSpan).text, " now.");
    });

    test('parses reference with verse range', () {
      final spans = VerseLinker.parse("Look at John 3:16-18.");
      expect(spans.length, 3);
      expect((spans[1] as TextSpan).toPlainText(), "John 3:16-18");
    });

    test('does not falsely match plain times or numbers', () {
      final spans = VerseLinker.parse("I woke up at 3:00 and saw 10:45 on the clock. Then I read 4:5.");
      // It should not find any matches, so it returns 1 span with the whole text.
      expect(spans.length, 1);
      expect((spans[0] as TextSpan).text, "I woke up at 3:00 and saw 10:45 on the clock. Then I read 4:5.");
    });

    test('multiple references in one string', () {
      final spans = VerseLinker.parse("See Genesis 1:1 and Revelation 22:21.");
      expect(spans.length, 5); // "See ", "Genesis 1:1", " and ", "Revelation 22:21", "."
      expect((spans[1] as TextSpan).toPlainText(), "Genesis 1:1");
      expect((spans[3] as TextSpan).toPlainText(), "Revelation 22:21");
    });
  });
}
