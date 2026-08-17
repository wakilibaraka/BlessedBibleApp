import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../data/models/home_data.dart';

/// Persists user notes to SharedPreferences.
/// Notes are stored as JSON under the 'user_notes' key.
class NotesNotifier extends Notifier<List<PersonalNote>> {
  static const _key = 'user_notes';

  @override
  List<PersonalNote> build() {
    return _load();
  }

  List<PersonalNote> _load() {
    final json = ref.read(preferencesProvider).prefs.getString(_key);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      final notes = list
          .map((e) => PersonalNote.fromJson(e as Map<String, dynamic>))
          .toList();

      // Non-destructive migration: if any note lacked an 'id' in JSON, fromJson assigned one.
      // Save them back to persist the new IDs.
      final needsMigration = list.any((e) => !(e as Map<String, dynamic>).containsKey('id'));
      if (needsMigration) {
        if (notes.length == list.length) {
          Future.microtask(() {
            final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());
            ref.read(preferencesProvider).prefs.setString(_key, jsonStr);
          });
        }
      }

      return notes;
    } catch (_) {
      return [];
    }
  }

  void _save() {
    final json = jsonEncode(state.map((n) => n.toJson()).toList());
    ref.read(preferencesProvider).prefs.setString(_key, json);
  }

  void add(PersonalNote note) {
    state = [note, ...state];
    _save();
  }

  void update(String id, PersonalNote note) {
    final index = state.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final copy = [...state];
    copy[index] = note;
    state = copy;
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

final notesProvider =
    NotifierProvider<NotesNotifier, List<PersonalNote>>(NotesNotifier.new);
