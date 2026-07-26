import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/home_data.dart';

class NotesNotifier extends Notifier<List<PersonalNote>> {
  static const _key = 'personal_notes';

  @override
  List<PersonalNote> build() {
    _loadNotes();
    return [];
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(_key);
    if (notesString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(notesString);
        state = decoded.map((e) => PersonalNote.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        // Handle parsing errors quietly
      }
    }
  }

  Future<void> addNote(PersonalNote note) async {
    final newState = [...state, note];
    state = newState;
    await _saveNotes(newState);
  }

  Future<void> _saveNotes(List<PersonalNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<PersonalNote>>(NotesNotifier.new);
