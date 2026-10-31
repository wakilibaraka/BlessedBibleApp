import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/theme_provider.dart';

Future<ProviderContainer> _container(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    preferencesProvider.overrideWithValue(PreferencesService(prefs)),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily rotation', () {
    test('day number follows the local calendar day', () {
      final morning = DateTime(2026, 10, 31, 0, 5);
      final night = DateTime(2026, 10, 31, 23, 55);
      expect(AutoTheme.dayNumber(morning), AutoTheme.dayNumber(night));
      expect(AutoTheme.dayNumber(DateTime(2026, 11, 1, 0, 1)),
          AutoTheme.dayNumber(night) + 1);
    });

    test('picks only dark themes on a dark phone and light ones otherwise', () {
      for (var day = 0; day < 30; day++) {
        expect(AutoTheme.pick(day, Brightness.dark).isDark, isTrue);
        expect(AutoTheme.pick(day, Brightness.light).isDark, isFalse);
      }
    });

    test('visits every theme in the pool before repeating', () {
      final picks = {
        for (var day = 0; day < AutoTheme.lightCycle.length; day++)
          AutoTheme.pick(day, Brightness.light)
      };
      expect(picks, AutoTheme.lightCycle.toSet());
    });
  });

  group('ThemeNotifier', () {
    test('saved theme is there on the first read, with no async gap', () async {
      final c = await _container({'app_theme_mode': AppThemeMode.olives.index});
      expect(c.read(themeProvider), AppThemeMode.olives);
      expect(c.read(resolvedThemeProvider), AppThemeMode.olives);
    });

    test('defaults to Daily rotation and resolves to a real theme', () async {
      final c = await _container({});
      expect(c.read(themeProvider), AppThemeMode.automatic);
      expect(c.read(resolvedThemeProvider), isNot(AppThemeMode.automatic));
    });

    test('old time-based engine migrates to Daily rotation', () async {
      final c = await _container({
        'theme_engine_mode': 1,
        'app_theme_mode': AppThemeMode.roses.index,
      });
      expect(c.read(themeProvider), AppThemeMode.automatic);
    });

    test('a choice is persisted', () async {
      final c = await _container({});
      await c.read(themeProvider.notifier).setTheme(AppThemeMode.dusk);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme_mode'), AppThemeMode.dusk.index);
    });
  });
}
