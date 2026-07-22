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

  bool get isEmpty => activeStudy == null && recentNotes.isEmpty && mostReadVerses.isEmpty;
}

class VerseOfTheDay {
  final String reference;
  final String text;
  VerseOfTheDay(this.reference, this.text);
}

class StudyProgress {
  final String title;
  final int chaptersRemaining;
  final double progress;
  StudyProgress(this.title, this.chaptersRemaining, this.progress);
}

class PersonalNote {
  final String title;
  final String content;
  final String date;
  PersonalNote(this.title, this.content, this.date);
}

class MostReadVerse {
  final String reference;
  final int count;
  MostReadVerse(this.reference, this.count);
}
