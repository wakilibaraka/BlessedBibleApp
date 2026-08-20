class PericopeEntry {
  final String id;
  final String book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;
  final String title;
  final String confidence;

  PericopeEntry({
    required this.id,
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.title,
    required this.confidence,
  });

  factory PericopeEntry.fromJson(Map<String, dynamic> json) {
    return PericopeEntry(
      id: json['id'] as String? ??
          '${json['book']}_${json['startChapter']}_${json['startVerse']}',
      book: json['book'] as String,
      startChapter: json['startChapter'] as int,
      startVerse: json['startVerse'] as int,
      endChapter: json['endChapter'] as int,
      endVerse: json['endVerse'] as int,
      title: json['title'] as String,
      confidence: json['confidence'] as String? ?? 'low',
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
    };
  }
}
