class BibleBook {
  final String name;
  final String abbreviation;
  final List<BibleChapter> chapters;

  BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    var chaptersList = json['chapters'] as List;
    List<BibleChapter> parsedChapters = [];
    
    for (int i = 0; i < chaptersList.length; i++) {
      var versesList = chaptersList[i] as List;
      List<BibleVerse> parsedVerses = [];
      
      for (int j = 0; j < versesList.length; j++) {
        parsedVerses.add(
          BibleVerse(
            number: j + 1,
            text: versesList[j] as String,
          ),
        );
      }
      
      parsedChapters.add(
        BibleChapter(
          number: i + 1,
          verses: parsedVerses,
        ),
      );
    }

    return BibleBook(
      name: json['name'] as String,
      abbreviation: json['abbrev'] as String,
      chapters: parsedChapters,
    );
  }
}

class BibleChapter {
  final int number;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.number,
    required this.verses,
  });
}

class BibleVerse {
  final int number;
  final String text;
  bool isBookmarked;
  bool isHighlighted;

  BibleVerse({
    required this.number,
    required this.text,
    this.isBookmarked = false,
    this.isHighlighted = false,
  });
}
