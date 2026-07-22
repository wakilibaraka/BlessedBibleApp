import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadSelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int index) {
    if (state.contains(index)) {
      state = {...state}..remove(index);
    } else {
      state = {...state, index};
    }
  }

  void clear() => state = {};
  
  void setSingle(int index) => state = {index};
}

final readSelectionProvider = NotifierProvider<ReadSelectionNotifier, Set<int>>(ReadSelectionNotifier.new);
