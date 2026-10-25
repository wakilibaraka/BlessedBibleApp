import 'package:flutter_test/flutter_test.dart';

import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/commentary_work.dart';
import 'package:the_blessed_bible/models/study_content_category.dart';

CommentaryEntry entry({
  required String author,
  required String source,
  String? book,
  int? chapter,
  int? verse,
  String type = 'verse',
  String? topic,
}) =>
    CommentaryEntry(
      id: '$author-$source-$book-$chapter-$verse-$topic',
      author: author,
      source: source,
      scope: CommentaryScope(
        type: type,
        book: book,
        chapter: chapter,
        verse: verse,
        topic: topic,
      ),
      text: 'Text of $source.',
      category: StudyContentCategory.commentary,
    );

void main() {
  group('commentaryWorkTitle', () {
    test('drops a trailing scripture range', () {
      expect(
        commentaryWorkTitle('Daniel and the Revelation (13:11-17)'),
        'Daniel and the Revelation',
      );
      expect(
        commentaryWorkTitle('The Book of Hebrews (Hebrews 2:1-4)'),
        'The Book of Hebrews',
      );
      expect(
        commentaryWorkTitle('Daniel and the Revelation (11:7-9)'),
        'Daniel and the Revelation',
      );
      expect(
        commentaryWorkTitle('The Book of Hebrews (Hebrews 11:39)'),
        'The Book of Hebrews',
      );
    });

    test('leaves real titles alone', () {
      expect(commentaryWorkTitle('Review and Herald'), 'Review and Herald');
      expect(commentaryWorkTitle('The Glad Tidings'), 'The Glad Tidings');
      expect(
        commentaryWorkTitle('Bible Readings (Vol. 2)'),
        'Bible Readings (Vol. 2)',
      );
      expect(
        commentaryWorkTitle('The Desire of Ages'),
        'The Desire of Ages',
      );
      expect(
          commentaryWorkTitle('  Prophets and Kings  '), 'Prophets and Kings');
    });
  });

  group('buildCommentaryWorks', () {
    test('folds range-suffixed sources into a single volume', () {
      final works = buildCommentaryWorks([
        entry(
            author: 'Uriah Smith',
            source: 'Daniel and the Revelation (13:11-17)',
            book: 'Revelation',
            chapter: 13,
            verse: 11),
        entry(
            author: 'Uriah Smith',
            source: 'Daniel and the Revelation (11:1-2)',
            book: 'Daniel',
            chapter: 11,
            verse: 1),
        entry(
            author: 'Uriah Smith',
            source: 'Daniel and the Revelation (11:3-4)',
            book: 'Daniel',
            chapter: 11,
            verse: 3),
      ]);

      expect(works, hasLength(1));
      expect(works.single.title, 'Daniel and the Revelation');
      expect(works.single.entryCount, 3);
      expect(works.single.chapterCount, 2);
    });

    test('orders covered books in canonical scripture order', () {
      final works = buildCommentaryWorks([
        entry(
            author: 'Uriah Smith',
            source: 'Daniel and the Revelation',
            book: 'Revelation',
            chapter: 13),
        entry(
            author: 'Uriah Smith',
            source: 'Daniel and the Revelation',
            book: 'Daniel',
            chapter: 11),
      ]);

      expect(works.single.books, ['Daniel', 'Revelation']);
    });

    test('counts entries and chapters per volume', () {
      final works = buildCommentaryWorks([
        entry(
            author: 'Ellen G. White',
            source: 'The Desire of Ages',
            book: 'Matthew',
            chapter: 1),
        entry(
            author: 'Ellen G. White',
            source: 'The Desire of Ages',
            book: 'Matthew',
            chapter: 1),
        entry(
            author: 'Ellen G. White',
            source: 'The Desire of Ages',
            book: 'Matthew',
            chapter: 2),
      ]);

      expect(works.single.entryCount, 3);
      expect(works.single.chapterCount, 2);
      expect(works.single.coverage['Matthew'], {1: 2, 2: 1});
    });

    test('keeps the same title apart when authors differ', () {
      final works = buildCommentaryWorks([
        entry(author: 'Author A', source: 'Sermons', book: 'Mark', chapter: 1),
        entry(author: 'Author B', source: 'Sermons', book: 'Mark', chapter: 2),
      ]);

      expect(works, hasLength(2));
      expect(works.map((w) => w.author), ['Author A', 'Author B']);
    });

    test('skips volumes with no scripture coverage unless asked', () {
      final topical = entry(
        author: 'Ellen G. White',
        source: 'Review and Herald',
        type: 'topic',
        topic: 'Trinity',
      );

      expect(buildCommentaryWorks([topical]), isEmpty);
      final withTopical = buildCommentaryWorks([topical], includeTopical: true);
      expect(withTopical.single.title, 'Review and Herald');
      expect(withTopical.single.books, isEmpty);
    });

    test('sorts the shelf biggest volume first, then by title', () {
      final works = buildCommentaryWorks([
        entry(
            author: 'Ellen G. White',
            source: 'Prophets and Kings',
            book: '2 Kings',
            chapter: 1),
        entry(
            author: 'Ellen G. White',
            source: 'The Desire of Ages',
            book: 'Matthew',
            chapter: 1),
        entry(
            author: 'Ellen G. White',
            source: 'The Desire of Ages',
            book: 'Matthew',
            chapter: 2),
      ]);

      expect(works.map((w) => w.title),
          ['The Desire of Ages', 'Prophets and Kings']);
    });
  });

  test('compareBibleBookNames follows scripture order', () {
    expect(compareBibleBookNames('Genesis', 'Exodus'), lessThan(0));
    expect(compareBibleBookNames('Matthew', 'Genesis'), greaterThan(0));
    expect(compareBibleBookNames('Apocrypha', 'Genesis'), greaterThan(0));
    expect(compareBibleBookNames('Apocrypha', 'Zzz'), lessThan(0));
  });
}
