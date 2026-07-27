import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class HintsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.read(preferencesProvider);
    return prefs.getSeenHints().toSet();
  }

  bool hasSeen(String hintId) {
    return state.contains(hintId);
  }

  void markSeen(String hintId) {
    if (!state.contains(hintId)) {
      final newState = {...state, hintId};
      state = newState;
      ref.read(preferencesProvider).saveSeenHints(newState.toList());
    }
  }

  void maybeShowHint(String hintId, void Function() showFn) {
    if (!hasSeen(hintId)) {
      showFn();
      markSeen(hintId);
    }
  }
  
  void resetHints() {
    state = {};
    ref.read(preferencesProvider).saveSeenHints([]);
  }
}

final hintsProvider = NotifierProvider<HintsNotifier, Set<String>>(() {
  return HintsNotifier();
});
