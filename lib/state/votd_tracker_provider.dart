import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class VotdTrackerNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(preferencesProvider);
    return prefs.getVotdViewedDays().toSet();
  }

  void markViewed(DateTime date) {
    // Format date to yyyy-MM-dd using basic string manipulation to avoid intl dependency
    final String dateString = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    if (!state.contains(dateString)) {
      final newState = Set<String>.from(state)..add(dateString);
      state = newState;
      _persist(newState);
    }
  }

  void _persist(Set<String> data) {
    final prefs = ref.read(preferencesProvider);
    prefs.saveVotdViewedDays(data.toList());
  }
}

final votdTrackerProvider = NotifierProvider<VotdTrackerNotifier, Set<String>>(VotdTrackerNotifier.new);
