import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../data/models/translation_model.dart';
import '../services/bible_database_service.dart';

class TranslationNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.watch(preferencesProvider);
    return prefs.getActiveTranslation();
  }

  Future<void> setTranslation(String translationId) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.setActiveTranslation(translationId);
    state = translationId;
  }
}

final activeTranslationProvider = NotifierProvider<TranslationNotifier, String>(TranslationNotifier.new);

final availableTranslationsProvider = FutureProvider<List<TranslationInfo>>((ref) async {
  return await bibleDbService.getTranslations();
});
