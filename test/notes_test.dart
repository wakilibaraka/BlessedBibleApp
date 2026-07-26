import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/notes_provider.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';

void main() {
  test('Notes persist to SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );

    // Initial state should be empty
    final initialNotes = container.read(notesProvider);
    expect(initialNotes, isEmpty);

    // Add a note
    final newNote = PersonalNote('Test Note', 'This is a test content', 'Jan 01, 2026');
    container.read(notesProvider.notifier).add(newNote);

    // Verify state changed
    final updatedNotes = container.read(notesProvider);
    expect(updatedNotes.length, 1);
    expect(updatedNotes.first.title, 'Test Note');

    // Verify it was written to SharedPreferences
    final jsonString = prefs.getString('user_notes');
    expect(jsonString, isNotNull);
    expect(jsonString!.contains('Test Note'), isTrue);

    // Simulate restart
    final container2 = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    
    final reloadedNotes = container2.read(notesProvider);
    expect(reloadedNotes.length, 1);
    expect(reloadedNotes.first.title, 'Test Note');
  });
}
