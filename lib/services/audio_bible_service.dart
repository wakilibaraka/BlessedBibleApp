/// Chapter-level audio for the World English Bible.
///
/// The recording is the public-domain WEB narration by David Williams, hosted
/// chapter by chapter by publicdomainaudiobibles.com. Nothing is bundled in the
/// app: the reader streams one chapter at a time (~0.2-1.1 MB) and only keeps a
/// chapter on disk when the listener asks for it.
///
/// Each book has a folder and a filename stem; the chapter is zero padded
/// differently for Psalms (150 chapters, three digits) than elsewhere.
class AudioBookSource {
  const AudioBookSource(
    this.bookName,
    this.folder,
    this.stem,
    this.chapterPad,
    this.chapters,
  );

  final String bookName;
  final String folder;
  final String stem;
  final int chapterPad;
  final int chapters;
}

/// What happens when a chapter finishes playing.
/// - [chapter]: keep going into the next chapter, across books.
/// - [book]: continue within the current book, then stop.
/// - [off]: stop at the end of every chapter.
enum AudioAdvanceMode { chapter, book, off }

/// A resolved chapter reference, used for next/previous navigation.
class AudioChapterRef {
  const AudioChapterRef(this.bookName, this.chapter);

  final String bookName;
  final int chapter;

  String get id => AudioBibleService.chapterId(bookName, chapter);

  @override
  bool operator ==(Object other) =>
      other is AudioChapterRef &&
      other.bookName == bookName &&
      other.chapter == chapter;

  @override
  int get hashCode => Object.hash(bookName, chapter);
}

class AudioBibleService {
  const AudioBibleService._();

  static const String baseUrl =
      'https://publicdomainaudiobibles.com/content/mp3/WEBD/';

  /// Shown in the player so the voice and licence are never a mystery.
  static const String translationLabel = 'WEB';
  static const String attribution =
      'World English Bible, read by David Williams. Public domain.';

  static const List<double> speedOptions = [0.75, 1.0, 1.25, 1.5, 2.0];

  static const List<AudioBookSource> books = [
    AudioBookSource('Genesis', '01_Gen', 'Genesis', 2, 50),
    AudioBookSource('Exodus', '02_Exo', 'Exodus', 2, 40),
    AudioBookSource('Leviticus', '03_Lev', 'Leviticus', 2, 27),
    AudioBookSource('Numbers', '04_Num', 'Numbers', 2, 36),
    AudioBookSource('Deuteronomy', '05_Deu', 'Deuteronomy', 2, 34),
    AudioBookSource('Joshua', '06_Jos', 'Joshua', 2, 24),
    AudioBookSource('Judges', '07_Jdg', 'Judges', 2, 21),
    AudioBookSource('Ruth', '08_Rut', 'Ruth', 2, 4),
    AudioBookSource('1 Samuel', '09_1Sam', '1Samuel', 2, 31),
    AudioBookSource('2 Samuel', '10_2Sam', '2Samuel', 2, 24),
    AudioBookSource('1 Kings', '11_1Kings', '1Kings', 2, 22),
    AudioBookSource('2 Kings', '12_2Kings', '2Kings', 2, 25),
    AudioBookSource('1 Chronicles', '13_1Chron', '1Chronicles', 2, 29),
    AudioBookSource('2 Chronicles', '14_2Chron', '2Chronicles', 2, 36),
    AudioBookSource('Ezra', '15_Ezra', 'Ezra', 2, 10),
    AudioBookSource('Nehemiah', '16_Neh', 'Nehemiah', 2, 13),
    AudioBookSource('Esther', '17_Est', 'Esther', 2, 10),
    AudioBookSource('Job', '18_Job', 'Job', 2, 42),
    AudioBookSource('Psalms', '19_Psa', 'Psalm', 3, 150),
    AudioBookSource('Proverbs', '20_Prov', 'Proverbs', 2, 31),
    AudioBookSource('Ecclesiastes', '21_Ecc', 'Ecclesiastes', 2, 12),
    AudioBookSource('Song of Songs', '22_Song', 'Song_of_Solomon', 2, 8),
    AudioBookSource('Isaiah', '23_Isa', 'Isaiah', 2, 66),
    AudioBookSource('Jeremiah', '24_Jer', 'Jeremiah', 2, 52),
    AudioBookSource('Lamentations', '25_Lam', 'Lamentations', 2, 5),
    AudioBookSource('Ezekiel', '26_Ezk', 'Ezekiel', 2, 48),
    AudioBookSource('Daniel', '27_Dan', 'Daniel', 2, 12),
    AudioBookSource('Hosea', '28_Hos', 'Hosea', 2, 14),
    AudioBookSource('Joel', '29_Joel', 'Joel', 2, 3),
    AudioBookSource('Amos', '30_Amos', 'Amos', 2, 9),
    AudioBookSource('Obadiah', '31_Oba', 'Obadiah', 2, 1),
    AudioBookSource('Jonah', '32_Jon', 'Jonah', 2, 4),
    AudioBookSource('Micah', '33_Mic', 'Micah', 2, 7),
    AudioBookSource('Nahum', '34_Nah', 'Nahum', 2, 3),
    AudioBookSource('Habakkuk', '35_Hab', 'Habakkuk', 2, 3),
    AudioBookSource('Zephaniah', '36_Zep', 'Zephaniah', 2, 3),
    AudioBookSource('Haggai', '37_Hag', 'Haggai', 2, 2),
    AudioBookSource('Zechariah', '38_Zec', 'Zechariah', 2, 14),
    AudioBookSource('Malachi', '39_Mal', 'Malachi', 2, 4),
    AudioBookSource('Matthew', '40_Mat', 'Matthew', 2, 28),
    AudioBookSource('Mark', '41_Mark', 'Mark', 2, 16),
    AudioBookSource('Luke', '42_Luke', 'Luke', 2, 24),
    AudioBookSource('John', '43_John', 'John', 2, 21),
    AudioBookSource('Acts', '44_Acts', 'Acts', 2, 28),
    AudioBookSource('Romans', '45_Rom', 'Romans', 2, 16),
    AudioBookSource('1 Corinthians', '46_1Cor', '1Corinthians', 2, 16),
    AudioBookSource('2 Corinthians', '47_2Cor', '2Corinthians', 2, 13),
    AudioBookSource('Galatians', '48_Gal', 'Galatians', 2, 6),
    AudioBookSource('Ephesians', '49_Eph', 'Ephesians', 2, 6),
    AudioBookSource('Philippians', '50_Phi', 'Philippians', 2, 4),
    AudioBookSource('Colossians', '51_Col', 'Colossians', 2, 4),
    AudioBookSource('1 Thessalonians', '52_1Th', '1Thessalonians', 2, 5),
    AudioBookSource('2 Thessalonians', '53_2Th', '2Thessalonians', 2, 3),
    AudioBookSource('1 Timothy', '54_1Ti', '1Timothy', 2, 6),
    AudioBookSource('2 Timothy', '55_2Ti', '2Timothy', 2, 4),
    AudioBookSource('Titus', '56_Tit', 'Titus', 2, 3),
    AudioBookSource('Philemon', '57_Phm', 'Philemon', 2, 1),
    AudioBookSource('Hebrews', '58_Heb', 'Hebrews', 2, 13),
    AudioBookSource('James', '59_Jas', 'James', 2, 5),
    AudioBookSource('1 Peter', '60_1Pe', '1Peter', 2, 5),
    AudioBookSource('2 Peter', '61_2Pe', '2Peter', 2, 3),
    AudioBookSource('1 John', '62_1Jn', '1John', 2, 5),
    AudioBookSource('2 John', '63_2Jn', '2John', 2, 1),
    AudioBookSource('3 John', '64_3Jn', '3John', 2, 1),
    AudioBookSource('Jude', '65_Jud', 'Jude', 2, 1),
    AudioBookSource('Revelation', '66_Rev', 'Revelation', 2, 22),
  ];

  /// The app names the book "Song of Solomon", the recording calls it
  /// "Song of Songs"; both resolve to the same folder.
  static const Map<String, String> _aliases = {
    'song of solomon': 'Song of Songs',
    'song of songs': 'Song of Songs',
    'psalm': 'Psalms',
    'revelations': 'Revelation',
  };

  static AudioBookSource? sourceFor(String bookName) {
    final key = bookName.trim().toLowerCase();
    final resolved = _aliases[key] ?? bookName.trim();
    for (final source in books) {
      if (source.bookName.toLowerCase() == resolved.toLowerCase()) {
        return source;
      }
    }
    return null;
  }

  static String chapterId(String bookName, int chapter) =>
      '${bookName.trim().toLowerCase()}:$chapter';

  /// Chapter count for the recording, or null for a book it does not have.
  static int? chapterCount(String bookName) => sourceFor(bookName)?.chapters;

  /// The chapter URL, or null when the book/chapter is outside the recording.
  /// Returns null rather than a 404 URL so the UI can say "unavailable".
  static String? urlFor(String bookName, int chapter) {
    final source = sourceFor(bookName);
    if (source == null || chapter < 1 || chapter > source.chapters) return null;
    final ordinal = _ordinalFor(source);
    final paddedChapter = chapter.toString().padLeft(source.chapterPad, '0');
    return '$baseUrl${source.folder}/${ordinal}_${source.stem}_$paddedChapter.mp3';
  }

  /// Folder names already start with the ordinal ("01_Gen"); reuse it so the
  /// filename's numeric prefix cannot drift from the folder.
  static String _ordinalFor(AudioBookSource source) =>
      source.folder.split('_').first;

  /// The next chapter in reading order, or null at Revelation 22.
  static AudioChapterRef? next(String bookName, int chapter) {
    final source = sourceFor(bookName);
    if (source == null) return null;
    if (chapter < source.chapters) {
      return AudioChapterRef(source.bookName, chapter + 1);
    }
    final index = books.indexOf(source);
    if (index < 0 || index == books.length - 1) return null;
    return AudioChapterRef(books[index + 1].bookName, 1);
  }

  /// The previous chapter in reading order, or null at Genesis 1.
  static AudioChapterRef? previous(String bookName, int chapter) {
    final source = sourceFor(bookName);
    if (source == null) return null;
    if (chapter > 1) return AudioChapterRef(source.bookName, chapter - 1);
    final index = books.indexOf(source);
    if (index <= 0) return null;
    final before = books[index - 1];
    return AudioChapterRef(before.bookName, before.chapters);
  }

  /// The chapter a completion event should move to, or null when this event
  /// must be ignored. Completion can fire more than once for the same source
  /// and can race a manual next/previous, so a chapter's completion is
  /// consumed exactly once and no advance starts while one is already in
  /// flight.
  static AudioChapterRef? advanceAfterCompletion({
    required String? book,
    required int? chapter,
    required String? consumedFor,
    required bool navigating,
    AudioAdvanceMode mode = AudioAdvanceMode.chapter,
  }) {
    if (mode == AudioAdvanceMode.off) return null;
    if (navigating || book == null || chapter == null) return null;
    if (consumedFor == chapterId(book, chapter)) return null;
    final target = next(book, chapter);
    if (target == null) return null;
    if (mode == AudioAdvanceMode.book) {
      final source = sourceFor(book);
      if (source == null || target.bookName != source.bookName) return null;
    }
    return target;
  }

  /// Cycles 0.75x -> 1x -> 1.25x -> 1.5x -> 2x -> 0.75x, snapping whatever
  /// the player reports to the nearest option so a restored speed cannot skip.
  static double nextSpeed(double current) {
    var nearest = speedOptions.first;
    for (final option in speedOptions) {
      if ((option - current).abs() < (nearest - current).abs()) {
        nearest = option;
      }
    }
    final index = speedOptions.indexOf(nearest);
    return speedOptions[(index + 1) % speedOptions.length];
  }

  static String formatSpeed(double speed) {
    final text = speed.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    return '${text}x';
  }
}
