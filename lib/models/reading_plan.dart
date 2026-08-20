
class PlanRange {
  final String book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;

  PlanRange({
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
  });

  Map<String, dynamic> toJson() => {
        'book': book,
        'startChapter': startChapter,
        'startVerse': startVerse,
        'endChapter': endChapter,
        'endVerse': endVerse,
      };

  factory PlanRange.fromJson(Map<String, dynamic> json) => PlanRange(
        book: json['book'] as String,
        startChapter: json['startChapter'] as int,
        startVerse: json['startVerse'] as int,
        endChapter: json['endChapter'] as int,
        endVerse: json['endVerse'] as int,
      );
}

class PlanPortion {
  final String book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;
  final int wordCount;
  final List<String> pericopeTitles;

  PlanPortion({
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.wordCount,
    required this.pericopeTitles,
  });

  Map<String, dynamic> toJson() => {
        'book': book,
        'startChapter': startChapter,
        'startVerse': startVerse,
        'endChapter': endChapter,
        'endVerse': endVerse,
        'wordCount': wordCount,
        'pericopeTitles': pericopeTitles,
      };

  factory PlanPortion.fromJson(Map<String, dynamic> json) => PlanPortion(
        book: json['book'] as String,
        startChapter: json['startChapter'] as int,
        startVerse: json['startVerse'] as int,
        endChapter: json['endChapter'] as int,
        endVerse: json['endVerse'] as int,
        wordCount: json['wordCount'] as int,
        pericopeTitles: List<String>.from(json['pericopeTitles'] as List),
      );
}

class PlanDay {
  final int dayNumber;
  final List<PlanPortion> portions;
  int totalWords;
  final int estimatedMinutes;
  final String estimatedTimeDisplay;

  PlanDay({
    required this.dayNumber,
    required this.portions,
    required this.totalWords,
    required this.estimatedMinutes,
    required this.estimatedTimeDisplay,
  });

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'portions': portions.map((p) => p.toJson()).toList(),
        'totalWords': totalWords,
        'estimatedMinutes': estimatedMinutes,
        'estimatedTimeDisplay': estimatedTimeDisplay,
      };

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
        dayNumber: json['dayNumber'] as int,
        portions: (json['portions'] as List)
            .map((p) => PlanPortion.fromJson(p as Map<String, dynamic>))
            .toList(),
        totalWords: json['totalWords'] as int,
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
        estimatedTimeDisplay: json['estimatedTimeDisplay'] as String? ?? '<1 min',
      );
}

class ReadingPlan {
  final String id;
  final String title;
  final int days;
  final int cadence;
  final bool wasClamped;
  final String? clampReason;
  final List<PlanDay> schedule;

  ReadingPlan({
    required this.id,
    required this.title,
    required this.days,
    required this.cadence,
    required this.schedule,
    this.wasClamped = false,
    this.clampReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'days': days,
        'cadence': cadence,
        'wasClamped': wasClamped,
        'clampReason': clampReason,
        'schedule': schedule.map((d) => d.toJson()).toList(),
      };

  factory ReadingPlan.fromJson(Map<String, dynamic> json) => ReadingPlan(
        id: json['id'] as String,
        title: json['title'] as String,
        days: json['days'] as int,
        cadence: json['cadence'] as int,
        wasClamped: json['wasClamped'] as bool? ?? false,
        clampReason: json['clampReason'] as String?,
        schedule: (json['schedule'] as List)
            .map((d) => PlanDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}
