import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

enum CardSize { small, medium, large }

/// Layout-v2 span: how many grid columns a Study hub card occupies.
/// full = full-width row, half = 2-across. Quarter tiles were retired:
/// every card defaults to Large (full). [expanded] marks Extra Large
/// (full width + roomier content). V1 keeps reading [CardSize]; V2 reads
/// [span] + [expanded] + list order from the persisted JSON
/// (version 4 resets all cards to Large once).
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

  /// Extra Large: full width with expanded content. Only meaningful
  /// with [span] == full (the size sheet enforces this).
  final bool expanded;

  StudyCardConfig(
      {required this.id,
      required this.size,
      CardSpan? span,
      this.expanded = false})
      : span = span ?? _spanFromSize(size);

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size.name,
        'span': span.name,
        'expanded': expanded,
        'version': 5,
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

    // Version 4: uniform Large default. Anything stored before v4
    // (quarters, halves, customs) resets to full width once so every
    // widget renders the same size; users re-customize afterwards.
    if (version < 4) {
      return StudyCardConfig(
        id: json['id'] as String,
        size: CardSize.large,
        span: CardSpan.full,
      );
    }

    // Span: explicit since v3, otherwise derived from size.
    CardSpan span = _spanFromSize(size);
    final spanStr = json['span'] as String?;
    if (spanStr != null) {
      span = CardSpan.values.firstWhere(
        (e) => e.name == spanStr,
        orElse: () => span,
      );
    }
    if (span == CardSpan.quarter) span = CardSpan.full;

    return StudyCardConfig(
      id: json['id'] as String,
      size: size,
      span: span,
      expanded: json['expanded'] as bool? ?? false,
    );
  }
}

class StudyLayoutNotifier extends Notifier<List<StudyCardConfig>> {

  @override
  List<StudyCardConfig> build() {
    final prefsJson = ref.read(preferencesProvider).getStudyLayout();
    if (prefsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(prefsJson);
        final loaded = decoded
            .map((e) => StudyCardConfig.fromJson(e as Map<String, dynamic>))
            .toList();

        // Version 5: reset to the default view once (order + sizes:
        // stories+dictionary pair, commentary full, votd+streak pair).
        // Recomputed idempotently on every launch until a v5 save lands,
        // so no write is needed here. Unknown future ids are preserved.
        final needsReset = decoded.any((e) =>
            ((e as Map<String, dynamic>)['version'] as int? ?? 1) < 5);
        if (needsReset) {
          final byId = {for (final c in loaded) c.id: c};
          final defaults = {
            for (final d in defaultLayoutV2()) d.id: d
          };
          final ordered = <StudyCardConfig>[];
          for (final def in defaultLayoutV2()) {
            ordered.add(byId.containsKey(def.id) &&
                    (byId[def.id]!.span != CardSpan.full ||
                        byId[def.id]!.expanded)
                ? byId.remove(def.id)!
                : def);
          }
          // Unknown future ids go last, untouched.
          for (final c in byId.values) {
            if (!defaults.containsKey(c.id)) ordered.add(c);
          }
          return ordered;
        }

        // Ensure all default cards are present (in case of updates)
        final loadedIds = loaded.map((c) => c.id).toSet();
        for (final defCard in defaultLayoutV2()) {
          if (!loadedIds.contains(defCard.id)) {
            loaded.add(defCard);
          }
        }
        return loaded;
      } catch (e) {
        return defaultLayoutV2();
      }
    }
    return defaultLayoutV2();
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

  /// Layout-v2 resize (Large / Extra Large / Half). Keeps the V1 [size]
  /// in sync (large for full, medium otherwise) so the fallback hub
  /// keeps rendering sanely. Extra Large is full width + expanded.
  void setCardSize(String id,
      {required CardSpan span, required bool expanded}) {
    final safeSpan = span == CardSpan.quarter ? CardSpan.full : span;
    final safeExpanded = expanded && safeSpan == CardSpan.full;
    state = state.map((card) {
      if (card.id == id) {
        return StudyCardConfig(
          id: card.id,
          size: safeSpan == CardSpan.full
              ? CardSize.large
              : CardSize.medium,
          span: safeSpan,
          expanded: safeExpanded,
        );
      }
      return card;
    }).toList();
    _save();
  }

  /// Layout-v2 default order and sizes: full-width banners up top,
  /// stories + dictionary share a row, commentary full, then the VOTD
  /// archive + streak pair. Users can pick Extra Large or Half per card
  /// via long-press and reorder via the same sheet.
  static List<StudyCardConfig> defaultLayoutV2() => [
        StudyCardConfig(
            id: 'your_space',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'plans_live',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'bible_stories',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'dictionary',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'concordance',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'commentary',
            size: CardSize.large,
            span: CardSpan.full),
        StudyCardConfig(
            id: 'votd_archive',
            size: CardSize.medium,
            span: CardSpan.half),
        StudyCardConfig(
            id: 'streak',
            size: CardSize.medium,
            span: CardSpan.half),
      ];
}

final studyLayoutProvider =
    NotifierProvider<StudyLayoutNotifier, List<StudyCardConfig>>(
        StudyLayoutNotifier.new);
