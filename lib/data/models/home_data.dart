import 'package:uuid/uuid.dart';

class HomeData {
  final VerseOfTheDay verseOfTheDay;
  final StudyProgress? activeStudy;
  final List<String> quickLinks;
  final List<PersonalNote> recentNotes;
  final List<MostReadVerse> mostReadVerses;

  HomeData({
    required this.verseOfTheDay,
    this.activeStudy,
    required this.quickLinks,
    required this.recentNotes,
    required this.mostReadVerses,
  });

  bool get isEmpty =>
      activeStudy == null && recentNotes.isEmpty && mostReadVerses.isEmpty;
}

class VerseOfTheDay {
  final String reference;
  final String text;
  final String? author;
  final String? sourceTitle;
  final bool isDevotional;

  final String? _snippet;
  final String Function()? _buildSnippet;

  VerseOfTheDay(
    this.reference,
    this.text, {
    String? commentarySnippet,
    this.author,
    this.sourceTitle,
    this.isDevotional = false,
  })  : _snippet = commentarySnippet,
        _buildSnippet = null;

  /// A verse whose commentary excerpt is only worked out when something
  /// reads it. The pool holds thousands of verses but a screen shows one or
  /// a few, so building every excerpt up front was wasted work on launch.
  VerseOfTheDay.lazy(
    this.reference,
    this.text, {
    required String Function() commentarySnippet,
    this.author,
    this.sourceTitle,
    this.isDevotional = false,
  })  : _snippet = null,
        _buildSnippet = commentarySnippet;

  late final String? commentarySnippet = _snippet ?? _buildSnippet?.call();
}

class StudyProgress {
  final String title;
  final int chaptersRemaining;
  final double progress;
  StudyProgress(this.title, this.chaptersRemaining, this.progress);
}

class PersonalNote {
  final String id;
  final String title;
  final String content;
  final String date;
  final String? reference;

  PersonalNote(this.id, this.title, this.content, this.date, {this.reference});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date,
        if (reference != null) 'reference': reference,
      };

  factory PersonalNote.fromJson(Map<String, dynamic> json) => PersonalNote(
        json['id'] as String? ?? const Uuid().v4(),
        json['title'] as String,
        json['content'] as String,
        json['date'] as String,
        reference: json['reference'] as String?,
      );
}

class MostReadVerse {
  final String reference;
  final int count;
  MostReadVerse(this.reference, this.count);
}
