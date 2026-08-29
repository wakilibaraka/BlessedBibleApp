import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pericope_entry.dart';

Map<String, List<PericopeEntry>> _parsePericopes(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString);
  final map = <String, List<PericopeEntry>>{};
  for (final item in data) {
    final entry = PericopeEntry.fromJson(item as Map<String, dynamic>);
    final key = '${entry.book}_${entry.startChapter}';
    map.putIfAbsent(key, () => []).add(entry);
  }
  return map;
}

class PericopesNotifier extends Notifier<Map<String, List<PericopeEntry>>> {
  @override
  Map<String, List<PericopeEntry>> build() {
    _loadData();
    return {};
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/pericopes.json');
      final data = await compute(_parsePericopes, jsonString);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final webStr = prefs.getString('pericopes_web');
        if (webStr != null) {
          final webData = await compute(_parsePericopes, webStr);
          for (final key in webData.keys) {
            data.putIfAbsent(key, () => []).addAll(webData[key]!);
          }
        }
      } catch (e) {
        debugPrint('Failed to load local pericopes: $e');
      }

      state = data;
    } catch (e) {
      debugPrint('Failed to load pericopes: $e');
    }
  }

  /// O(1)-ish lookup for pericopes in a specific book and chapter.
  /// The resulting list usually contains 0-5 items, making startVerse scanning trivial.
  List<PericopeEntry> getPericopesForChapter(String book, int chapter, {String? translationId}) {
    final all = state['${book}_$chapter'] ?? const [];
    
    if (translationId != null) {
      final translationSpecific = all.where((p) => p.translationId == translationId).toList();
      if (translationSpecific.isNotEmpty) {
        return translationSpecific;
      }
    }
    
    return all.where((p) => p.translationId == null).toList();
  }
}

final pericopesProvider = NotifierProvider<PericopesNotifier, Map<String, List<PericopeEntry>>>(
  PericopesNotifier.new,
);
