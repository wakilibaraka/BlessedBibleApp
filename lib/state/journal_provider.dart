import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../data/models/home_data.dart';

/// Persists user journal entries to SharedPreferences.
/// Journal entries are stored as JSON under the 'user_journal' key.
class JournalNotifier extends Notifier<List<JournalEntry>> {
  static const _key = 'user_journal';

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

  void add(JournalEntry entry) {
    state = [entry, ...state];
    _save();
  }

  void update(int index, JournalEntry entry) {
    final copy = [...state];
    copy[index] = entry;
    state = copy;
    _save();
  }

  void remove(int index) {
    final copy = [...state];
    copy.removeAt(index);
    state = copy;
    _save();
  }
}

final journalProvider =
    NotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);
