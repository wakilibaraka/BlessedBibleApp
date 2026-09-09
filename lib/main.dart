import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' as dart_io;

import 'state/theme_provider.dart';
import 'state/surface_style_provider.dart';
import 'theme/app_theme.dart';
import 'ui/screens/main_nav_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/local_storage/preferences_service.dart';
import 'ui/screens/splash_loading_screen.dart';
import 'state/bible_provider.dart';
import 'ui/screens/onboarding_screen.dart';

import 'package:flutter/foundation.dart';
import 'ui/widgets/app_error_fallback.dart';

import 'utils/startup_stopwatch.dart';

void main() async {
  // Global Flutter framework error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
    try {
      final file = dart_io.File('crash_log.txt');
      file.writeAsStringSync(
          'FlutterError: ${details.exception}\n${details.stack}\n',
          mode: dart_io.FileMode.append);
    } catch (_) {}
  };

  // Global Platform/Async uncaught error handling
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('Uncaught async error: $error\n$stack');
    }
    try {
      final file = dart_io.File('crash_log.txt');
      file.writeAsStringSync('Uncaught async error: $error\n$stack\n',
          mode: dart_io.FileMode.append);
    } catch (_) {}
    return true; // Handled, prevent process termination
  };

  // Override ErrorWidget.builder to render branded fallback in release mode
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return AppErrorFallback(details: details);
  };

  if (kStartupTrace) {
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kStartupTrace) {
  }
  final prefs = await SharedPreferences.getInstance();
  if (kStartupTrace) {
  }

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
      child: const TheBlessedBibleApp(),
    ),
  );
}

class TheBlessedBibleApp extends ConsumerStatefulWidget {
  const TheBlessedBibleApp({super.key});

  @override
  ConsumerState<TheBlessedBibleApp> createState() => _TheBlessedBibleAppState();
}

class _TheBlessedBibleAppState extends ConsumerState<TheBlessedBibleApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kStartupTrace) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final isBibleLoading = ref.watch(bibleProvider.select((s) => s.isLoading));

    ThemeData lightBase = themeMode == AppThemeMode.lilies
        ? AppTheme.liliesTheme(14.0)
        : themeMode == AppThemeMode.roses
            ? AppTheme.rosesTheme(14.0)
            : themeMode == AppThemeMode.olives
                ? AppTheme.olivesTheme(14.0)
                : themeMode == AppThemeMode.priestlyPurple
                    ? AppTheme.priestlyPurpleTheme(14.0)
                    : themeMode == AppThemeMode.galileeBlue
                        ? AppTheme.galileeBlueTheme(14.0)
                        : themeMode == AppThemeMode.scarletRed
                            ? AppTheme.scarletRedTheme(14.0)
                            : themeMode == AppThemeMode.sepia
                                ? AppTheme.sepiaTheme(14.0)
                                : themeMode == AppThemeMode.automatic
                                    ? AppTheme.freshTheme(14.0)
                                    : AppTheme.lightTheme(14.0);

    ThemeData darkBase = themeMode == AppThemeMode.dawn
        ? AppTheme.dawnTheme(14.0)
        : themeMode == AppThemeMode.dusk
            ? AppTheme.duskTheme(14.0)
            : themeMode == AppThemeMode.fresh
                ? AppTheme.freshTheme(14.0)
                : themeMode == AppThemeMode.automatic
                    ? AppTheme.duskTheme(14.0)
                    : AppTheme.darkTheme(14.0,
                        isAmoled: themeMode == AppThemeMode.oled);

    final prefsService = ref.watch(preferencesProvider);
    final hasExplicitSurface = prefsService.prefs.containsKey('app_surface_style');
    final applyPaperlikeToLight = surfaceStyle == SurfaceStyle.paperlike;
    final applyPaperlikeToDark = surfaceStyle == SurfaceStyle.paperlike || 
                                (themeMode == AppThemeMode.automatic && !hasExplicitSurface);

    if (applyPaperlikeToLight) {
      lightBase = lightBase.applyPaperlike();
    }
    
    if (applyPaperlikeToDark) {
      darkBase = themeMode == AppThemeMode.fresh
          ? darkBase.applyFreshPaperlike()
          : darkBase.applyPaperlike();
    }

    final hasCompletedOnboarding = prefsService.hasCompletedOnboarding();

    return MaterialApp(
      title: 'The Blessed Bible',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeOut,
      themeMode: switch (themeMode) {
        AppThemeMode.automatic => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.sepia => ThemeMode.light,
        AppThemeMode.dawn => ThemeMode.dark,
        AppThemeMode.lilies => ThemeMode.light,
        AppThemeMode.roses => ThemeMode.light,
        AppThemeMode.olives => ThemeMode.light,
        AppThemeMode.priestlyPurple => ThemeMode.light,
        AppThemeMode.galileeBlue => ThemeMode.light,
        AppThemeMode.scarletRed => ThemeMode.light,
        AppThemeMode.dusk => ThemeMode.dark,
        AppThemeMode.fresh => ThemeMode.dark,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.oled => ThemeMode.dark,
      },
      theme: lightBase,
      darkTheme: darkBase,
      home: !hasCompletedOnboarding
          ? const OnboardingScreen()
          : (isBibleLoading ? const SplashLoadingScreen() : const MainNavScreen()),
    );
  }
}
