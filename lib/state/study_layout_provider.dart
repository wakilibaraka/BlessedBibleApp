import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

enum CardSize { small, medium, large }

/// Layout-v2 span: how many grid columns a Study hub card occupies.
/// full = full-width row, half = 2-across, quarter = 4-across compact tile.
/// V1 keeps reading [CardSize]; V2 reads [span] + list order from the same
/// persisted JSON (version 3 migrates size → span).
enum CardSpan { quarter, half, full }

CardSpan _spanFromSize(CardSize size) {
  switch (size) {
    case CardSize.small:
      return CardSpan.half;
    case CardSize.medium:
      return CardSpan.half;
    case CardSize.large:
      return CardSpan.full;
  }
}

class StudyCardConfig {
  final String id;
  final CardSize size;
  final CardSpan span;

  StudyCardConfig({required this.id, required this.size, CardSpan? span})
      : span = span ?? _spanFromSize(size);

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size.name,
        'span': span.name,
        'version': 3,
      };

  factory StudyCardConfig.fromJson(Map<String, dynamic> json) {
    // Migration from old `isExpanded` boolean
    if (json.containsKey('isExpanded')) {
      final isExpanded = json['isExpanded'] as bool;
      final size =
          isExpanded ? CardSize.medium : CardSize.small;
      return StudyCardConfig(id: json['id'] as String, size: size);
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

    // Span: explicit since v3, otherwise derived from size.
    CardSpan span = _spanFromSize(size);
    final spanStr = json['span'] as String?;
    if (version >= 3 && spanStr != null) {
      span = CardSpan.values.firstWhere(
        (e) => e.name == spanStr,
        orElse: () => span,
      );
    }

    return StudyCardConfig(
      id: json['id'] as String,
      size: size,
      span: span,
    );
  }
}

class StudyLayoutNotifier extends Notifier<List<StudyCardConfig>> {
  static final List<StudyCardConfig> _defaultLayout = [
    StudyCardConfig(id: 'your_space', size: CardSize.large),
    StudyCardConfig(id: 'cloud_sync', size: CardSize.large),
    StudyCardConfig(id: 'reading_plan', size: CardSize.large),
    StudyCardConfig(id: 'bible_stories', size: CardSize.large),
    StudyCardConfig(id: 'dictionary', size: CardSize.medium),
    StudyCardConfig(id: 'commentary', size: CardSize.large),
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

  /// Layout-v2 grid move: drop [draggedId] onto [targetId]'s slot.
  /// Moving down inserts after the target, moving up inserts before it.
  void move(String draggedId, String targetId) {
    final oldIndex = state.indexWhere((c) => c.id == draggedId);
    final targetIndex = state.indexWhere((c) => c.id == targetId);
    if (oldIndex < 0 || targetIndex < 0 || oldIndex == targetIndex) {
      return;
    }
    final newState = [...state];
    final item = newState.removeAt(oldIndex);
    // After removal the target shifted down by one when moving down.
    newState.insert(targetIndex, item);
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

  /// Layout-v2 resize. Keeps the V1 [size] in sync (large for full,
  /// medium otherwise) so the fallback hub keeps rendering sanely.
  void setSpan(String id, CardSpan newSpan) {
    state = state.map((card) {
      if (card.id == id) {
        return StudyCardConfig(
          id: card.id,
          size: newSpan == CardSpan.full
              ? CardSize.large
              : CardSize.medium,
          span: newSpan,
        );
      }
      return card;
    }).toList();
    _save();
  }

  /// Layout-v2 default order: Your Space banner first, plan second.
  static List<StudyCardConfig> defaultLayoutV2() => [
        StudyCardConfig(
            id: 'your_space',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'reading_plan',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'commentary',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'plans',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'dictionary',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'bible_stories',
            size: CardSize.medium,
            span: CardSpan.half),
      ];
}

final studyLayoutProvider =
    NotifierProvider<StudyLayoutNotifier, List<StudyCardConfig>>(
        StudyLayoutNotifier.new);
