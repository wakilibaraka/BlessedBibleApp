class PericopeEntry {
  final String id;
  final String book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;
  final String title;
  final String confidence;
  final String? translationId; // Null means it's a shared/curated pericope for all translations

  PericopeEntry({
    required this.id,
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.title,
    required this.confidence,
    this.translationId,
  });

  /// Slugification rule: remove all spaces from the book name.
  /// "1 Samuel" → "1Samuel", "Song of Solomon" → "SongofSolomon".
  /// The `book` field keeps the display name; only `id` is slugified.
  static String buildId(String book, int startChapter, int startVerse) {
    final slug = book.replaceAll(' ', '');
    return '${slug}_${startChapter}_$startVerse';
  }

  factory PericopeEntry.fromJson(Map<String, dynamic> json) {
    final book = json['book'] as String;
    final sc = json['startChapter'] as int;
    final sv = json['startVerse'] as int;
    // Prefer the stored id; fall back to building one that matches the slug rule.
    final storedId = json['id'] as String?;
    final expectedId = buildId(book, sc, sv);
    return PericopeEntry(
      id: (storedId != null && storedId.isNotEmpty) ? storedId : expectedId,

      book: json['book'] as String,
      startChapter: json['startChapter'] as int,
      startVerse: json['startVerse'] as int,
      endChapter: json['endChapter'] as int,
      endVerse: json['endVerse'] as int,
      title: json['title'] as String,
      confidence: json['confidence'] as String? ?? 'low',
      translationId: json['translationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'startChapter': startChapter,
      'startVerse': startVerse,
      'endChapter': endChapter,
      'endVerse': endVerse,
      'title': title,
      'confidence': confidence,
      if (translationId != null) 'translationId': translationId,
    };
  }
}
