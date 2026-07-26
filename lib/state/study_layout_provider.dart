import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

enum CardSize { small, medium, large }

class StudyCardConfig {
  final String id;
  final CardSize size;

  StudyCardConfig({required this.id, required this.size});

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size.name,
        'version': 2,
      };

  factory StudyCardConfig.fromJson(Map<String, dynamic> json) {
    // Migration from old `isExpanded` boolean
    if (json.containsKey('isExpanded')) {
      final isExpanded = json['isExpanded'] as bool;
      return StudyCardConfig(
        id: json['id'] as String,
        size: isExpanded ? CardSize.medium : CardSize.small,
      );
    }

    final sizeStr = json['size'] as String?;
    final version = json['version'] as int? ?? 1;

    CardSize size;
    if (version < 2) {
      // Migrate old sizing:
      // old Small -> new Small
      // old Medium -> new Small
      // old Large -> new Medium
      if (sizeStr == 'small' || sizeStr == 'medium') {
        size = CardSize.small;
      } else if (sizeStr == 'large') {
        size = CardSize.medium;
      } else {
        size = CardSize.medium; // Fallback
      }
    } else {
      size = CardSize.values.firstWhere(
        (e) => e.name == sizeStr,
        orElse: () => CardSize.medium,
      );
    }

    return StudyCardConfig(
      id: json['id'] as String,
      size: size,
    );
  }
}

class StudyLayoutNotifier extends Notifier<List<StudyCardConfig>> {
  static final List<StudyCardConfig> _defaultLayout = [
    StudyCardConfig(id: 'your_space', size: CardSize.large),
    StudyCardConfig(id: 'reading_plan', size: CardSize.medium),
    StudyCardConfig(id: 'commentary', size: CardSize.medium),
    StudyCardConfig(id: 'saved_verses', size: CardSize.medium),
  ];

  @override
  List<StudyCardConfig> build() {
    final prefsJson = ref.read(preferencesProvider).getStudyLayout();
    if (prefsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(prefsJson);
        final loaded = decoded
            .map((e) => StudyCardConfig.fromJson(e as Map<String, dynamic>))
            .toList();

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

  void setSize(String id, CardSize newSize) {
    state = state.map((card) {
      if (card.id == id) {
        return StudyCardConfig(id: card.id, size: newSize);
      }
      return card;
    }).toList();
    _save();
  }
}

final studyLayoutProvider =
    NotifierProvider<StudyLayoutNotifier, List<StudyCardConfig>>(
        StudyLayoutNotifier.new);
