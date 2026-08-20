import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class PlansHubStyleNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(preferencesProvider).getUseNewPlansHub();
  }

  void setUseNewHub(bool useNew) {
    ref.read(preferencesProvider).setUseNewPlansHub(useNew);
    state = useNew;
  }
}

final plansHubStyleProvider = NotifierProvider<PlansHubStyleNotifier, bool>(PlansHubStyleNotifier.new);
