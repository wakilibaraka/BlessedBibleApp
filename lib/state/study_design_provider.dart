import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

/// Dual-design rollout flag for the Study redesign.
///
/// When true (default), the Study tab and all study flows render the
/// redesigned V2 screens. When false, the original V1 screens are used as
/// the fallback. Both designs share the same underlying providers/prefs, so
/// toggling never loses progress — it only switches presentation.
class StudyDesignNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(preferencesProvider).getStudyRedesign();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(preferencesProvider).setStudyRedesign(enabled);
  }

  Future<void> toggle() => setEnabled(!state);
}

final studyDesignProvider =
    NotifierProvider<StudyDesignNotifier, bool>(StudyDesignNotifier.new);
