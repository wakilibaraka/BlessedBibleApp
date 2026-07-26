import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import 'search_engine.dart';

class MostReadItem {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int verse;
  final int visits;

  MostReadItem({
    required this.bookAbbrev,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.visits,
  });

  /// The unique key used in SharedPreferences
  String get key => '$bookAbbrev|$bookName|$chapter|$verse';

  factory MostReadItem.fromKey(String key, int visits) {
    final parts = key.split('|');
    if (parts.length == 4) {
      return MostReadItem(
        bookAbbrev: parts[0],
        bookName: parts[1],
        chapter: int.tryParse(parts[2]) ?? 1,
        verse: int.tryParse(parts[3]) ?? 1,
        visits: visits,
      );
    }
    // Fallback if formatting is weird
    return MostReadItem(
      bookAbbrev: 'Gen',
      bookName: 'Genesis',
      chapter: 1,
      verse: 1,
      visits: visits,
    );
  }

  // Convert to a SearchResult for easy reuse in SearchScreen
  SearchResult toSearchResult() {
    return SearchResult(
      title: '$bookName $chapter:$verse',
      subtitle: '$bookName $chapter',
      snippet: 'Frequently read passage ($visits visits)',
      type: SearchResultType.bible,
      metadata: {
        'bookAbbrev': bookAbbrev,
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
      },
    );
  }
}

class MostReadNotifier extends Notifier<List<MostReadItem>> {
  @override
  List<MostReadItem> build() {
    final prefs = ref.watch(preferencesProvider);
    final map = prefs.getVerseVisits();
    
    final List<MostReadItem> items = [];
    map.forEach((key, visits) {
      items.add(MostReadItem.fromKey(key, visits));
    });
    
    // Sort descending by visits
    items.sort((a, b) => b.visits.compareTo(a.visits));
    
    return items;
  }

  void incrementVisit(String bookAbbrev, String bookName, int chapter, int verse) {
    final prefs = ref.read(preferencesProvider);
    final map = prefs.getVerseVisits();
    
    final key = '$bookAbbrev|$bookName|$chapter|$verse';
    final currentVisits = map[key] ?? 0;
    map[key] = currentVisits + 1;
    
    prefs.saveVerseVisits(map);
    
    // Update state to trigger UI refresh (e.g. in SearchScreen empty state)
    // We recreate the list so it sorts correctly.
    final List<MostReadItem> items = [];
    map.forEach((k, v) {
      items.add(MostReadItem.fromKey(k, v));
    });
    items.sort((a, b) => b.visits.compareTo(a.visits));
    
    state = items;
  }
}

final mostReadProvider = NotifierProvider<MostReadNotifier, List<MostReadItem>>(MostReadNotifier.new);
