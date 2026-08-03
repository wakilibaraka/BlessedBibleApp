import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChromeHiddenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final chromeHiddenProvider =
    NotifierProvider<ChromeHiddenNotifier, bool>(ChromeHiddenNotifier.new);

class NavHiddenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final navHiddenProvider =
    NotifierProvider<NavHiddenNotifier, bool>(NavHiddenNotifier.new);
