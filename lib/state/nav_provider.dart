import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class NavNotifier extends Notifier<int> {
  @override
  int build() {
    // 0 = Home, 1 = Read, 2 = Search, 3 = Study, 4 = Settings
    // First ever launch defaults to 0 (Home tab)
    return ref.watch(preferencesProvider).getLastTab() ?? 0;
  }

  void setIndex(int index) {
    state = index;
    ref.read(preferencesProvider).saveLastTab(index);
  }
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);
