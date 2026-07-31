import '../data/models/bible_model.dart';
import '../state/reading_plan_provider.dart';

class BookChapter {
  final String bookName;
  final int chapterNum;
  BookChapter(this.bookName, this.chapterNum);
}

class CustomPlanScheduler {
  final List<BibleBook> kjvData;

  CustomPlanScheduler(this.kjvData);

  List<BookChapter> _getWholeBible() {
    List<BookChapter> chapters = [];
    for (var book in kjvData) {
      String name = book.name;
      int chapterCount = book.chapters.length;
      for (int i = 1; i <= chapterCount; i++) {
        chapters.add(BookChapter(name, i));
      }
    }
    return chapters;
  }

  List<BookChapter> buildCorpus(String type, {String? startBook, int? startChapter, List<String>? selectedBooks}) {
    final whole = _getWholeBible();
    if (type == 'whole') return whole;
    if (type == 'ot') return whole.where((c) => _isOT(c.bookName)).toList();
    if (type == 'nt') return whole.where((c) => !_isOT(c.bookName)).toList();
    if (type == 'book' && startBook != null) return whole.where((c) => c.bookName == startBook).toList();
    if (type == 'slice' && startBook != null && startChapter != null) {
      int idx = whole.indexWhere((c) => c.bookName == startBook && c.chapterNum == startChapter);
      if (idx == -1) return [];
      return whole.sublist(idx);
    }
    if (type == 'multi' && selectedBooks != null) {
      return whole.where((c) => selectedBooks.contains(c.bookName)).toList();
    }
    return [];
  }

  bool _isOT(String bookName) {
    const otBooks = [
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
      '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
      'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon',
      'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
      'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
    ];
    return otBooks.contains(bookName);
  }

  List<PlanDayData> generateSchedule(
    List<BookChapter> corpus,
    {int? durationDays, DateTime? startDate, DateTime? targetEndDate, int? restDay}
  ) {
    int totalReadingDays = 0;
    
    if (durationDays != null) {
      totalReadingDays = durationDays;
    } else if (startDate != null && targetEndDate != null) {
      DateTime current = DateTime.utc(startDate.year, startDate.month, startDate.day);
      DateTime end = DateTime.utc(targetEndDate.year, targetEndDate.month, targetEndDate.day);
      while (!current.isAfter(end)) {
        int weekday = (current.weekday % 7) + 1; // 1=Sun..7=Sat
        if (restDay == null || weekday != restDay) {
          totalReadingDays++;
        }
        current = current.add(const Duration(days: 1));
      }
    }

    if (totalReadingDays <= 0) return [];
    if (corpus.isEmpty) return [];

    int basePerDay = corpus.length ~/ totalReadingDays;
    int remainder = corpus.length % totalReadingDays;
    
    List<PlanDayData> days = [];
    int corpusIndex = 0;

    for (int i = 0; i < totalReadingDays; i++) {
      int readCount = basePerDay + (i < remainder ? 1 : 0);
      
      List<String> refs = [];
      String label = "";
      
      if (readCount > 0) {
        String startRef = "${corpus[corpusIndex].bookName} ${corpus[corpusIndex].chapterNum}";
        String endRef = "${corpus[corpusIndex + readCount - 1].bookName} ${corpus[corpusIndex + readCount - 1].chapterNum}";
        
        if (readCount == 1) {
          label = startRef;
        } else if (corpus[corpusIndex].bookName == corpus[corpusIndex + readCount - 1].bookName) {
          label = "${corpus[corpusIndex].bookName} ${corpus[corpusIndex].chapterNum}-${corpus[corpusIndex + readCount - 1].chapterNum}";
        } else {
          label = "$startRef - $endRef";
        }
        
        for (int j = 0; j < readCount; j++) {
          refs.add("${corpus[corpusIndex + j].bookName} ${corpus[corpusIndex + j].chapterNum}");
        }
        
        corpusIndex += readCount;
      }

      int dayNum = i + 1;
      int weekNum = ((dayNum - 1) ~/ (restDay == null ? 7 : 6)) + 1;
      
      days.add(PlanDayData(
        day: dayNum,
        week: weekNum,
        title: "Day $dayNum",
        passages: refs.isNotEmpty ? [PlanPassage(label: label, refs: refs)] : []
      ));
    }

    return days;
  }
}
