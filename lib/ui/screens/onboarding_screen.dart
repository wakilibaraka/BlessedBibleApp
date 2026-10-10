import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../l10n/l10n.dart';
import '../../state/locale_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/translation_provider.dart';
import '../../state/typography_provider.dart';
import '../../theme/app_colors.dart';
import 'main_nav_screen.dart';

// Onboarding keeps its own warm sepia look whatever theme is picked, so the
// first impression is the same for everyone.
const Color _bg = AppColors.warmGoldBackground;
const Color _surface = AppColors.warmGoldSurface;
const Color _ink = AppColors.warmGoldTextPrimary;
const Color _muted = AppColors.sepiaTextPrimary;
const Color _accent = AppColors.warmGoldAccent;
const Color _amber = Color(0xFFD49A36);
const Color _terracotta = Color(0xFFB56553);
const Color _olive = Color(0xFF7D8C61);
const Color _slate = Color(0xFF5E7A8C);
const Color _cream = Color(0xFFF9F4E8);

/// First-run flow: language, Bible, reading comfort, then a short tour.
///
/// Every step is optional — "Skip" keeps sensible defaults (the device
/// language and its matching Bible) so nobody is forced through setup.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pageCount = 4;
  final PageController _pages = PageController();
  int _page = 0;
  late AppLanguage _language;
  bool _showParallel = true;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(appLocaleProvider);
    _language = (saved == null ? null : appLanguageFor(saved.languageCode)) ??
        deviceLanguage();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _chooseLanguage(AppLanguage language) async {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _language = language);
    // Switch the interface straight away so the rest of the flow is
    // readable in the chosen language.
    await ref.read(appLocaleProvider.notifier).setLanguage(language.code);
  }

  Future<void> _applyBible() async {
    final translations = ref.read(activeTranslationProvider.notifier);
    final secondary = ref.read(secondaryTranslationProvider.notifier);
    await translations.setTranslation(_language.bibleId);
    if (_language.code == 'en') {
      await secondary.setTranslation(null);
    } else {
      // A second, English column helps people comparing with study tools,
      // which are in English.
      await secondary.setTranslation(_showParallel ? 'kjv' : null);
    }
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page == 1) unawaited(_applyBible());
    if (_page < _pageCount - 1) {
      _pages.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    unawaited(HapticFeedback.mediumImpact());
    // Skipping early still sets up the Bible that matches the language,
    // so the app opens the way the flow suggested. The interface language
    // keeps following the device unless one was tapped.
    if (_page < 2) await _applyBible();
    ref.read(preferencesProvider).setOnboardingComplete(true);
    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainNavScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = _page == _pageCount - 1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bg, _surface],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (_page > 0)
                        IconButton(
                          tooltip: l10n.commonBack,
                          color: _muted,
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => _pages.previousPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic),
                        ),
                      const Spacer(),
                      if (!last)
                        TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(foregroundColor: _muted),
                          child: Text(l10n.commonSkip),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) {
                      if (_page == 1 && i > 1) unawaited(_applyBible());
                      setState(() => _page = i);
                    },
                    children: [
                      _LanguagePage(
                          selected: _language, onSelect: _chooseLanguage),
                      _BiblePage(
                        language: _language,
                        showParallel: _showParallel,
                        onParallel: (v) => setState(() => _showParallel = v),
                      ),
                      const _ComfortPage(),
                      const _FeaturesPage(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      Semantics(
                        label: l10n.onboardingStep(_page + 1, _pageCount),
                        child: ExcludeSemantics(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < _pageCount; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _page ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? _terracotta
                                        : _muted.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: _terracotta,
                          foregroundColor: _cream,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        child: Text(
                            last ? l10n.onboardingBegin : l10n.commonContinue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.title, this.body, required this.child});

  final String title;
  final String? body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'EB Garamond',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: _ink,
              height: 1.1,
            ),
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 10),
          Text(body!,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: _muted.withValues(alpha: 0.75))),
        ],
        const SizedBox(height: 24),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: Material(
          color: selected ? _cream : _cream.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected ? _terracotta : _muted.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          if (subtitle != null)
                            Text(subtitle!,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: _muted.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected ? 1 : 0,
                      child: const Icon(Icons.check_circle_rounded,
                          color: _terracotta),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.selected, required this.onSelect});

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 4),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.wb_sunny_rounded,
                  size: 96, color: _accent.withValues(alpha: 0.12)),
              Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(l10n.onboardingTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17, color: _muted.withValues(alpha: 0.7))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(l10n.onboardingPickLanguage,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 12),
        for (final language in appLanguages)
          _ChoiceTile(
            title: language.nativeName,
            selected: language.code == selected.code,
            onTap: () => onSelect(language),
          ),
        const SizedBox(height: 4),
        Text(l10n.onboardingLanguageHint,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, color: _muted.withValues(alpha: 0.6))),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _BiblePage extends ConsumerWidget {
  const _BiblePage({
    required this.language,
    required this.showParallel,
    required this.onParallel,
  });

  final AppLanguage language;
  final bool showParallel;
  final ValueChanged<bool> onParallel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final translations = ref.watch(availableTranslationsProvider).value ?? [];
    String nameOf(String id) {
      for (final t in translations) {
        if (t.translationId == id) return t.translationName;
      }
      return id.toUpperCase();
    }

    return _PageFrame(
      title: l10n.onboardingBibleTitle,
      body: l10n.onboardingBibleBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChoiceTile(
            title: nameOf(language.bibleId),
            subtitle: language.nativeName,
            selected: true,
            onTap: () {},
          ),
          if (language.code != 'en')
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              activeTrackColor: _terracotta,
              value: showParallel,
              onChanged: onParallel,
              title: Text(l10n.onboardingParallel(nameOf('kjv')),
                  style: const TextStyle(fontSize: 16, color: _ink)),
            ),
        ],
      ),
    );
  }
}

class _ComfortPage extends ConsumerWidget {
  const _ComfortPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ref.watch(themeProvider);
    final size = ref.watch(typographyProvider).fontSize;
    final options = [
      (
        AppThemeMode.light,
        l10n.onboardingThemeLight,
        Colors.white,
        const Color(0xFF1C1C1E)
      ),
      (
        AppThemeMode.sepia,
        l10n.onboardingThemeSepia,
        AppColors.warmGoldBackground,
        AppColors.warmGoldTextPrimary
      ),
      (
        AppThemeMode.dark,
        l10n.onboardingThemeDark,
        const Color(0xFF1C1C1E),
        const Color(0xFFEDEDED)
      ),
    ];
    final current =
        options.firstWhere((o) => o.$1 == theme, orElse: () => options[1]);

    return _PageFrame(
      title: l10n.onboardingLookTitle,
      body: l10n.onboardingLookBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final o in options)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Semantics(
                      button: true,
                      selected: o.$1 == theme,
                      label: o.$2,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(themeProvider.notifier).setTheme(o.$1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 72,
                          decoration: BoxDecoration(
                            color: o.$3,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: o.$1 == theme
                                  ? _terracotta
                                  : _muted.withValues(alpha: 0.2),
                              width: o.$1 == theme ? 2.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: ExcludeSemantics(
                            child: Text(o.$2,
                                style: TextStyle(
                                    color: o.$4, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.onboardingTextSize,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _ink)),
          Row(
            children: [
              const ExcludeSemantics(
                  child:
                      Text('A', style: TextStyle(fontSize: 14, color: _ink))),
              Expanded(
                child: Slider(
                  value: size.clamp(14, 30),
                  min: 14,
                  max: 30,
                  divisions: 8,
                  activeColor: _terracotta,
                  label: size.round().toString(),
                  semanticFormatterCallback: (v) => '${v.round()}',
                  onChanged: (v) =>
                      ref.read(typographyProvider.notifier).setFontSize(v),
                ),
              ),
              const ExcludeSemantics(
                  child:
                      Text('A', style: TextStyle(fontSize: 24, color: _ink))),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: current.$3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _muted.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.onboardingPreviewVerse,
                    style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: size,
                        height: 1.45,
                        color: current.$4)),
                const SizedBox(height: 8),
                Text(l10n.onboardingPreviewRef,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: current.$4.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageFrame(
      title: l10n.onboardingFeaturesTitle,
      child: Column(
        children: [
          _FeatureRow(
              icon: Icons.menu_book_rounded,
              color: _amber,
              title: l10n.onboardingFeatureWordTitle,
              body: l10n.onboardingFeatureWordBody),
          _FeatureRow(
              icon: Icons.calendar_month_rounded,
              color: _terracotta,
              title: l10n.onboardingFeaturePlansTitle,
              body: l10n.onboardingFeaturePlansBody),
          _FeatureRow(
              icon: Icons.lightbulb_rounded,
              color: _olive,
              title: l10n.onboardingFeatureStudyTitle,
              body: l10n.onboardingFeatureStudyBody),
          _FeatureRow(
              icon: Icons.cloud_done_rounded,
              color: _slate,
              title: l10n.onboardingFeatureSyncTitle,
              body: l10n.onboardingFeatureSyncBody),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 26, color: _cream),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'EB Garamond',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          color: _muted.withValues(alpha: 0.65))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
