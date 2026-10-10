import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final String date;
  final String content;
  final List<String> detectedEmotions;
  final List<String> prayerPoints;
  final List<String> recommendedVerses;

  JournalEntry({
    String? id,
    required this.date,
    required this.content,
    this.detectedEmotions = const [],
    this.prayerPoints = const [],
    this.recommendedVerses = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'content': content,
        'detectedEmotions': detectedEmotions,
        'prayerPoints': prayerPoints,
        'recommendedVerses': recommendedVerses,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String?,
      date: json['date'] as String,
      content: json['content'] as String,
      detectedEmotions:
          List<String>.from((json['detectedEmotions'] as List?) ?? const []),
      prayerPoints:
          List<String>.from((json['prayerPoints'] as List?) ?? const []),
      recommendedVerses:
          List<String>.from((json['recommendedVerses'] as List?) ?? const []),
    );
  }
}
