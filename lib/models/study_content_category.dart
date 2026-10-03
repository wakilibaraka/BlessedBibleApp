import 'package:flutter/material.dart';

enum StudyContentCategory {
  commentary,
  devotional,
  studyNote;

  String get displayName {
    switch (this) {
      case StudyContentCategory.commentary:
        return 'Commentary';
      case StudyContentCategory.devotional:
        return 'Devotional';
      case StudyContentCategory.studyNote:
        return 'Study Note';
    }
  }

  IconData get icon {
    switch (this) {
      case StudyContentCategory.commentary:
        return Icons.library_books_rounded;
      case StudyContentCategory.devotional:
        return Icons.favorite_rounded;
      case StudyContentCategory.studyNote:
        return Icons.edit_note_rounded;
    }
  }

  static StudyContentCategory fromSource(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('devotional')) {
      return StudyContentCategory.devotional;
    }
    if (lower.contains('study note')) {
      return StudyContentCategory.studyNote;
    }
    return StudyContentCategory.commentary;
  }
}
