import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudyPassageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setPassage(String? passage) {
    state = passage;
  }
}

final studyPassageProvider = NotifierProvider<StudyPassageNotifier, String?>(StudyPassageNotifier.new);
