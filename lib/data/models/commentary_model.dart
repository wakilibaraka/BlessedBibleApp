class CommentaryEntry {
  final String id;
  final String title;
  final String text;

  CommentaryEntry({
    required this.id,
    required this.title,
    required this.text,
  });

  factory CommentaryEntry.fromJson(Map<String, dynamic> json) {
    return CommentaryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
    );
  }
}
