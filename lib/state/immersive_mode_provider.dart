import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImmersiveModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final immersiveModeProvider = NotifierProvider<ImmersiveModeNotifier, bool>(ImmersiveModeNotifier.new);

class NavHiddenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final navHiddenProvider = NotifierProvider<NavHiddenNotifier, bool>(NavHiddenNotifier.new);
