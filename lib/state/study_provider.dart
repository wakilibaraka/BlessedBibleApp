import 'package:flutter_riverpod/flutter_riverpod.dart';


class ActiveStudyVerseNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setVerse(String? verse) {
    state = verse;
  }
}

final activeStudyVerseProvider = NotifierProvider<ActiveStudyVerseNotifier, String?>(ActiveStudyVerseNotifier.new);

