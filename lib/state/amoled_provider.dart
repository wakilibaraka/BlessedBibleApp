import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmoledNotifier extends Notifier<bool> {
  static const _key = 'amoled_dark_mode';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_key);
    if (value != null) {
      state = value;
    }
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final amoledProvider = NotifierProvider<AmoledNotifier, bool>(AmoledNotifier.new);
