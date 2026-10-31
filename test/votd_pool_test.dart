import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/study_content_category.dart';
import 'package:the_blessed_bible/state/bible_provider.dart';
import 'package:the_blessed_bible/state/commentary_provider.dart';
import 'package:the_blessed_bible/state/home_provider.dart';

class _FakeBible extends BibleNotifier {
  @override
  BibleState build() => BibleState(books: [
        BibleBook(name: 'John', abbreviation: 'John', chapters: [
          BibleChapter(number: 3, verses: [
            for (var v = 1; v <= 17; v++)
              BibleVerse(number: v, text: 'John 3:$v text'),
          ]),
        ]),
      ]);
}

class _FakeCommentary extends CommentaryNotifier {
  _FakeCommentary(this.entries);
  final List<CommentaryEntry> entries;
  @override
  Future<List<CommentaryEntry>> build() async => entries;
}

CommentaryEntry _entry(String book, int c, int v, String text,
        {String source = 'Commentary', String type = 'verse'}) =>
    CommentaryEntry(
      id: '$book$c$v$text',
      author: 'A',
      source: source,
      scope: CommentaryScope(type: type, book: book, chapter: c, verse: v),
      text: text,
      category: StudyContentCategory.fromSource(source),
    );

void main() {
  test('pool keeps the first usable entry per verse, sorted, lazily', () async {
    final container = ProviderContainer(overrides: [
      bibleProvider.overrideWith(_FakeBible.new),
      commentaryProvider.overrideWith(() => _FakeCommentary([
            _entry('John', 3, 16, '  \u200b** '), // blank excerpt: skipped
            _entry('John', 3, 16, 'Second. Wins.'),
            _entry('John', 3, 16, 'Third loses.'),
            _entry('john', 3, 16, 'Lower case.'), // book lookup ignores case
            _entry('John', 3, 2, 'A note.', source: 'Study Note'), // skipped
            _entry('John', 3, 3, 'Devotion.', source: 'Daily devotional'),
            _entry('John', 3, 99, 'No such verse.'),
            _entry('Mark', 1, 1, 'No such book.'),
            _entry('John', 3, 0, 'Chapter.', type: 'chapter'),
          ])),
    ]);
    addTearDown(container.dispose);
    await container.read(commentaryProvider.future);

    final pool = container.read(votdPoolProvider);
    expect(
        pool.map((v) => v.reference), ['John 3:16', 'John 3:3', 'john 3:16']);
    expect(pool.first.text, 'John 3:16 text');
    expect(pool.first.commentarySnippet, 'Second. Wins.');
    expect(pool[1].isDevotional, isTrue);
    expect(pool.last.text, 'John 3:16 text');
  });
}
