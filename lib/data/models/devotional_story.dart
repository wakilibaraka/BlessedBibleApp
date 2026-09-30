/// A single story from The Bible Stories devotional collection.
///
/// Data source: exported from graham-devotional (KJV public domain text;
/// narrative summaries adapted from The Graham Bible, AI-assisted/human
/// reviewed; included per the project owner's decision).
class DevotionalStory {
  final String id; // e.g. GEN-001, GSP-042
  final String title;
  final String ref; // e.g. "Genesis 1:1-2:3"
  final String keyVerseRef;
  final String keyVerse;
  final String text; // full KJV passage, newline-separated verses
  final String retelling; // narrative summary

  // Enriched at load time by DevotionalService.
  final String book; // display name, e.g. "Genesis" or "The Gospels"
  final String prefix; // spread prefix, e.g. GEN
  final String testament; // OT / NT
  final String grouping; // Torah, History, Gospels, ...
  final int order; // chronological section order
  final int indexInBook;
  final String? plateSlug; // Doré engraving asset slug
  final String? plateCaption;

  DevotionalStory({
    required this.id,
    required this.title,
    required this.ref,
    required this.keyVerseRef,
    required this.keyVerse,
    required this.text,
    required this.retelling,
    required this.book,
    required this.prefix,
    required this.testament,
    required this.grouping,
    required this.order,
    required this.indexInBook,
    this.plateSlug,
    this.plateCaption,
  });

  /// Whether the story belongs to the four Gospels (chronological GSP series).
  bool get isGospel => prefix == 'GSP';

  /// Position label like "3 / 35".
  String positionLabel(int bookCount) => '${indexInBook + 1} / $bookCount';

  /// Copies this story with enriched metadata (used by the service).
  DevotionalStory copyWithEnriched({
    int? indexInBook,
    String? plateSlug,
    String? plateCaption,
  }) {
    return DevotionalStory(
      id: id,
      title: title,
      ref: ref,
      keyVerseRef: keyVerseRef,
      keyVerse: keyVerse,
      text: text,
      retelling: retelling,
      book: book,
      prefix: prefix,
      testament: testament,
      grouping: grouping,
      order: order,
      indexInBook: indexInBook ?? this.indexInBook,
      plateSlug: plateSlug ?? this.plateSlug,
      plateCaption: plateCaption ?? this.plateCaption,
    );
  }

  factory DevotionalStory.fromJson(
    Map<String, dynamic> json, {
    required String book,
    required String prefix,
    required String testament,
    required String grouping,
    required int order,
  }) {
    return DevotionalStory(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      ref: (json['ref'] as String?) ?? '',
      keyVerseRef: (json['keyVerseRef'] as String?) ?? '',
      keyVerse: (json['keyVerse'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      retelling: (json['retelling'] as String?) ?? '',
      book: book,
      prefix: prefix,
      testament: testament,
      grouping: grouping,
      order: order,
      indexInBook: 0,
    );
  }
}

/// Light index entry describing one book file (no story bodies).
class DevotionalBookInfo {
  final String prefix;
  final String book;
  final String testament;
  final String grouping;
  final int order;
  final int count;

  DevotionalBookInfo({
    required this.prefix,
    required this.book,
    required this.testament,
    required this.grouping,
    required this.order,
    required this.count,
  });

  factory DevotionalBookInfo.fromJson(Map<String, dynamic> json) {
    return DevotionalBookInfo(
      prefix: json['prefix'] as String,
      book: json['book'] as String,
      testament: json['testament'] as String,
      grouping: json['grouping'] as String,
      order: (json['order'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );
  }
}
