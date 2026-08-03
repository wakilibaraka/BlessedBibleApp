class CommentaryScope {
  final String type;
  final String? book;
  final int? chapter;
  final int? verse;
  final String? topic;
  final String? custom;

  CommentaryScope({
    required this.type,
    this.book,
    this.chapter,
    this.verse,
    this.topic,
    this.custom,
  });

  factory CommentaryScope.fromJson(Map<String, dynamic> json) {
    return CommentaryScope(
      type: json['type'] as String? ?? 'custom',
      book: json['book'] as String?,
      chapter: _parseInt(json['chapter']),
      verse: _parseInt(json['verse']),
      topic: json['topic'] as String?,
      custom: json['custom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (book != null) 'book': book,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (topic != null) 'topic': topic,
      if (custom != null) 'custom': custom,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}

class CommentaryEntry {
  final String id;
  final String author;
  final String source;
  final CommentaryScope scope;
  final String text;
  final String? dateAdded;

  CommentaryEntry({
    required this.id,
    required this.author,
    required this.source,
    required this.scope,
    required this.text,
    this.dateAdded,
  });

  factory CommentaryEntry.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as String? ?? 'Unknown';
    final source = json['source'] as String? ?? '';
    final text = json['text'] as String? ?? '';

    final scopeMap = json['scope'] as Map<String, dynamic>? ?? {};
    final scope = CommentaryScope.fromJson(scopeMap);

    String id = json['id'] as String? ?? '';
    if (id.isEmpty) {
      // Generate stable ID if missing using hashCode of key fields
      id =
          '${author.hashCode ^ scope.toJson().toString().hashCode ^ text.hashCode}';
    }

    return CommentaryEntry(
      id: id,
      author: author,
      source: source,
      scope: scope,
      text: text,
      dateAdded: json['dateAdded'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'source': source,
      'scope': scope.toJson(),
      'text': text,
      if (dateAdded != null) 'dateAdded': dateAdded,
    };
  }
}
