import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/home_data.dart';

class HomeNotifier extends AsyncNotifier<HomeData> {
  bool _forceEmptyState = false;

  @override
  Future<HomeData> build() async {
    // Simulate network/loading delay
    await Future.delayed(const Duration(seconds: 1));
    return _fetchData();
  }

  HomeData _fetchData() {
    final votd = VerseOfTheDay(
      "Genesis 1:3",
      "And God said, Let there be light: and there was light.",
    );

    if (_forceEmptyState) {
      return HomeData(
        verseOfTheDay: votd,
        activeStudy: null,
        quickLinks: [],
        recentNotes: [],
        mostReadVerses: [],
      );
    }

    return HomeData(
      verseOfTheDay: votd,
      activeStudy: StudyProgress("The Gospel of John", 12, 0.45),
      quickLinks: ["John 3:16", "Psalm 23:1", "Hebrews 11:1"],
      recentNotes: [
        PersonalNote("Faith and Action", "Reflection on how faith requires movement.", "Jul 21, 2026"),
        PersonalNote("Creation", "The power of God's spoken word in Genesis.", "Jul 20, 2026"),
      ],
      mostReadVerses: [
        MostReadVerse("John 11:35", 14),
        MostReadVerse("Philippians 4:13", 9),
      ],
    );
  }

  void toggleEmptyState() {
    _forceEmptyState = !_forceEmptyState;
    // Setting state to loading, then resolving with new data
    state = const AsyncValue.loading();
    Future.delayed(const Duration(milliseconds: 500), () {
      state = AsyncValue.data(_fetchData());
    });
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
