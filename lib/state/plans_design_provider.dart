import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

/// Dual-design rollout flag for the Plans Library redesign.
///
/// When true (default), plan entry points render the new Reading / Books /
/// My Plans library. When false, the previous plans hub is used as the
/// fallback. Both designs share the same underlying providers/prefs, so
/// toggling never loses progress — it only switches presentation.
class PlansDesignNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(preferencesProvider).getPlansRedesign();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(preferencesProvider).setPlansRedesign(enabled);
  }

  Future<void> toggle() => setEnabled(!state);
}

final plansDesignProvider =
    NotifierProvider<PlansDesignNotifier, bool>(PlansDesignNotifier.new);
