import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlassUiNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default to glassy

  void toggle() {
    state = !state;
  }
  
  void set(bool value) {
    state = value;
  }
}

final glassUiProvider = NotifierProvider<GlassUiNotifier, bool>(GlassUiNotifier.new);
