import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class StudyCardConfig {
  final String id;
  final bool isExpanded;

  StudyCardConfig({required this.id, required this.isExpanded});

  Map<String, dynamic> toJson() => {
        'id': id,
        'isExpanded': isExpanded,
      };

  factory StudyCardConfig.fromJson(Map<String, dynamic> json) {
    return StudyCardConfig(
      id: json['id'] as String,
      isExpanded: json['isExpanded'] as bool,
    );
  }
}

class StudyLayoutNotifier extends Notifier<List<StudyCardConfig>> {
  static final List<StudyCardConfig> _defaultLayout = [
    StudyCardConfig(id: 'your_space', isExpanded: true),
    StudyCardConfig(id: 'reading_plan', isExpanded: true),
    StudyCardConfig(id: 'commentary', isExpanded: true),
    StudyCardConfig(id: 'saved_verses', isExpanded: false),
  ];

  @override
  List<StudyCardConfig> build() {
    final prefsJson = ref.read(preferencesProvider).getStudyLayout();
    if (prefsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(prefsJson);
        final loaded = decoded.map((e) => StudyCardConfig.fromJson(e as Map<String, dynamic>)).toList();
        
        // Ensure all default cards are present (in case of updates)
        final loadedIds = loaded.map((c) => c.id).toSet();
        for (final defCard in _defaultLayout) {
          if (!loadedIds.contains(defCard.id)) {
            loaded.add(defCard);
          }
        }
        return loaded;
      } catch (e) {
        return List.from(_defaultLayout);
      }
    }
    return List.from(_defaultLayout);
  }

  void _save() {
    final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
    ref.read(preferencesProvider).saveStudyLayout(jsonStr);
  }

  void reorder(int oldIndex, int newIndex) {
    final newState = [...state];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);
    state = newState;
    _save();
  }

  void toggleExpanded(String id) {
    state = state.map((card) {
      if (card.id == id) {
        return StudyCardConfig(id: card.id, isExpanded: !card.isExpanded);
      }
      return card;
    }).toList();
    _save();
  }
}

final studyLayoutProvider = NotifierProvider<StudyLayoutNotifier, List<StudyCardConfig>>(StudyLayoutNotifier.new);
