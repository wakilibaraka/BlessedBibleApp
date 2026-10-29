import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blessed_account/blessed_account.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/theme_provider.dart';
import 'state/surface_style_provider.dart';
import 'theme/app_theme.dart';
import 'ui/screens/main_nav_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/local_storage/preferences_service.dart';
import 'ui/screens/splash_loading_screen.dart';
import 'state/bible_provider.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/widgets/restore_prompt.dart';
import 'state/profile_provider.dart';
import 'theme/design_tokens.dart';

import 'package:flutter/foundation.dart';
import 'ui/widgets/app_error_fallback.dart';

import 'data/credits.dart';
import 'services/firebase_setup.dart';
import 'services/widget_update_service.dart';
import 'sync/bible_sync.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/l10n.dart';
import 'state/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = PreferencesService(await SharedPreferences.getInstance());
  await initCrashReporting(enabled: prefs.crashReportsEnabled);
  await activateAppCheck();
  registerFontLicenses();

  // Branded fallback instead of the red error screen in release builds.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return AppErrorFallback(details: details);
  };

  final authGateway = FirebaseAuthGateway();
  await authGateway.initialize();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(prefs),
        authGatewayProvider.overrideWithValue(authGateway),
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
  Widget build(BuildContext context) {
    final hasCompletedOnboarding = ref.watch(onboardingCompleteProvider);

    // Onboarding needs none of this: the whole-KJV load, the home-screen
    // widget syncs and the account listeners are pure background cost, and
    // starting them at launch makes the first taps stutter on a cold device.
    // They start together with the splash that waits for the Bible instead.
    final bool isBibleLoading;
    if (hasCompletedOnboarding) {
      ref.watch(widgetUpdateServiceProvider);
      // Account sync (bookmarks, highlights, notes): kept alive for the app's
      // lifetime without rebuilding it on every status change.
      ref.listen(syncControllerProvider, (_, __) {});
      isBibleLoading = ref.watch(bibleProvider.select((s) => s.isLoading));
    } else {
      isBibleLoading = false;
    }

    final themeMode = ref.watch(themeProvider);
    final resolvedTheme = themeMode.resolve(context);
    final surfaceStyle = ref.watch(surfaceStyleProvider);

    ThemeData lightBase = resolvedTheme == AppThemeMode.lilies
        ? AppTheme.liliesTheme(14.0)
        : resolvedTheme == AppThemeMode.roses
            ? AppTheme.rosesTheme(14.0)
            : resolvedTheme == AppThemeMode.olives
                ? AppTheme.olivesTheme(14.0)
                : resolvedTheme == AppThemeMode.priestlyPurple
                    ? AppTheme.priestlyPurpleTheme(14.0)
                    : resolvedTheme == AppThemeMode.galileeBlue
                        ? AppTheme.galileeBlueTheme(14.0)
                        : resolvedTheme == AppThemeMode.scarletRed
                            ? AppTheme.scarletRedTheme(14.0)
                            : resolvedTheme == AppThemeMode.sepia
                                ? AppTheme.sepiaTheme(14.0)
                                : resolvedTheme == AppThemeMode.dawn
                                    ? AppTheme.dawnTheme(14.0)
                                    : resolvedTheme == AppThemeMode.fresh
                                        ? AppTheme.freshTheme(14.0)
                                        : AppTheme.lightTheme(14.0);

    ThemeData darkBase = resolvedTheme == AppThemeMode.dawn
        ? AppTheme.dawnTheme(14.0)
        : resolvedTheme == AppThemeMode.dusk
            ? AppTheme.duskTheme(14.0)
            : resolvedTheme == AppThemeMode.fresh
                ? AppTheme.freshTheme(14.0)
                : resolvedTheme == AppThemeMode.oled
                    ? AppTheme.darkTheme(14.0, isAmoled: true)
                    : AppTheme.darkTheme(14.0);

    final prefsService = ref.watch(preferencesProvider);
    final hasExplicitSurface =
        prefsService.prefs.containsKey('app_surface_style');
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

    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: resolveAppLocale,
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 600),
      themeAnimationCurve: Curves.easeInOut,
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
      // One gate for the whole app: onboarding, then the splash until the
      // offline Bible is ready, then home. Screens flip these states
      // instead of replacing the root route, so there is always a page.
      home: AnimatedSwitcher(
        duration: Motion.of(context, Motion.slow),
        child: !hasCompletedOnboarding
            ? const OnboardingScreen(key: ValueKey('onboarding'))
            : (isBibleLoading
                ? const SplashLoadingScreen(key: ValueKey('splash'))
                : const RestorePromptHost(
                    key: ValueKey('home'), child: MainNavScreen())),
      ),
    );
  }
}
