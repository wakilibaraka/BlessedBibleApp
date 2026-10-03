import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../data/models/journal_entry.dart';
import '../services/ai_journal_service.dart';

class JournalNotifier extends Notifier<List<JournalEntry>> {
  static const _key = 'user_journal_entries';

  @override
  List<JournalEntry> build() {
    return _load();
  }

  List<JournalEntry> _load() {
    final json = ref.read(preferencesProvider).prefs.getString(_key);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _save() {
    final json = jsonEncode(state.map((n) => n.toJson()).toList());
    ref.read(preferencesProvider).prefs.setString(_key, json);
  }

  Future<void> add(String content) async {
    final aiService = ref.read(aiJournalServiceProvider);
    final reflection = await aiService.analyzeEntry(content);

    final entry = JournalEntry(
      date: DateTime.now().toIso8601String(),
      content: content,
      detectedEmotions: reflection.emotions,
      prayerPoints: reflection.prayerPoints,
      recommendedVerses: reflection.recommendedVerses,
    );

    state = [entry, ...state];
    _save();
  }

  void remove(String id) {
    final index = state.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final copy = [...state];
    copy.removeAt(index);
    state = copy;
    _save();
  }
}

final journalProvider =
    NotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);
