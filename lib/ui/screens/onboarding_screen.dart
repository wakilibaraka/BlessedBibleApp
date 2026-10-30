import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../l10n/l10n.dart';
import '../../state/auth_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/locale_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/reminders_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/translation_provider.dart';
import '../../state/typography_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../widgets/account_menu.dart';
import '../../theme/design_tokens.dart';
import '../../utils/log.dart';

// Onboarding keeps its own warm sepia look whatever theme is picked, so the
// first impression is the same for everyone.
const Color _bg = AppColors.warmGoldBackground;
const Color _surface = AppColors.warmGoldSurface;
const Color _ink = AppColors.warmGoldTextPrimary;
const Color _muted = AppColors.sepiaTextPrimary;
const Color _accent = AppColors.warmGoldAccent;
// Decorative display size for the welcome title; larger than the type scale.
const double _kWelcomeTitleSize = 36;

const Color _amber = Color(0xFFD49A36);
const Color _terracotta = Color(0xFFB56553);
const Color _olive = Color(0xFF7D8C61);
const Color _slate = Color(0xFF5E7A8C);
const Color _cream = Color(0xFFF9F4E8);

/// First-run flow: language, Bible, reading comfort, a daily reminder, a
/// short tour, then optional sign-in.
///
/// Every step is optional — "Skip" keeps sensible defaults (the device
/// language and its matching Bible) so nobody is forced through setup.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  /// Where an interrupted onboarding resumes.
  static const String pageKey = 'onboarding_page';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pageCount = 5;

  late final PageController _pages;
  late int _page;
  late AppLanguage _language;
  late String _primaryTranslation;
  late ReadingLayout _readingLayout;
  late String _secondaryTranslation;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final saved =
        ref.read(preferencesProvider).prefs.getInt(OnboardingScreen.pageKey) ??
            0;
    _page = saved.clamp(0, _pageCount - 1);
    _pages = PageController(initialPage: _page);
    final locale = ref.read(appLocaleProvider);
    _language = (locale == null ? null : appLanguageFor(locale.languageCode)) ??
        deviceLanguage();
    _primaryTranslation = _language.bibleId;
    _readingLayout = ref.read(readSettingsProvider).readingLayout;
    _secondaryTranslation = _language.code == 'en' ? 'bbe' : 'kjv';
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _chooseLanguage(AppLanguage language) async {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _language = language;
      _primaryTranslation = language.bibleId;
      _secondaryTranslation = language.code == 'en' ? 'bbe' : 'kjv';
    });
    // Switch the interface straight away so the rest of the flow is
    // readable in the chosen language.
    await ref.read(appLocaleProvider.notifier).setLanguage(language.code);
  }

  Future<void> _applyBible() async {
    final translations = ref.read(activeTranslationProvider.notifier);
    final secondary = ref.read(secondaryTranslationProvider.notifier);
    final readSettings = ref.read(readSettingsProvider.notifier);
    await translations.setTranslation(_primaryTranslation);
    await readSettings.setReadingLayout(_readingLayout);
    if (_readingLayout == ReadingLayout.single) {
      await secondary.setTranslation(null);
    } else {
      await secondary.setTranslation(_secondaryTranslation);
    }
  }

  /// Animates to [page], or jumps when the system asks to reduce motion.
  void _goToPage(int page, Duration duration) {
    final d = Motion.of(context, duration);
    if (d == Duration.zero) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(page, duration: d, curve: Curves.easeOutCubic);
    }
  }

  void _next() {
    HapticFeedback.lightImpact();
    // Leaving the Bible page applies the choice in onPageChanged; doing it
    // here as well ran two overlapping translation switches.
    if (_page < _pageCount - 1) {
      _goToPage(_page + 1, const Duration(milliseconds: 380));
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // A double tap (or Skip then Begin) must not apply and finish twice.
    if (_finishing) return;
    _finishing = true;
    unawaited(HapticFeedback.mediumImpact());
    // Skipping early still sets up the Bible that matches the language,
    // so the app opens the way the flow suggested. The interface language
    // keeps following the device unless one was tapped.
    // A failed save must not trap anyone here: the app's defaults still
    // work, so finish anyway.
    try {
      if (_page < 2) await _applyBible();
      await ref
          .read(preferencesProvider)
          .prefs
          .remove(OnboardingScreen.pageKey);
    } catch (e) {
      logDebug('Onboarding finish: $e');
    }
    if (!mounted) return;
    // The app's home switches to the splash (until the offline Bible is
    // ready) and then Home; replacing the root route here skipped both.
    ref.read(onboardingCompleteProvider.notifier).set(true);
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
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      if (_page > 0)
                        IconButton(
                          tooltip: l10n.commonBack,
                          color: _muted,
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => _goToPage(
                              _page - 1, const Duration(milliseconds: 320)),
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
                      unawaited(ref
                          .read(preferencesProvider)
                          .prefs
                          .setInt(OnboardingScreen.pageKey, i));
                    },
                    children: [
                      _LanguagePage(
                          selected: _language, onSelect: _chooseLanguage),
                      _BiblePage(
                        language: _language,
                        primaryTranslation: _primaryTranslation,
                        onSelectPrimary: (id) => setState(() {
                          _primaryTranslation = id;
                          if (_secondaryTranslation == id) {
                            _secondaryTranslation = id == 'kjv' ? 'bbe' : 'kjv';
                          }
                        }),
                        readingLayout: _readingLayout,
                        onChangeLayout: (layout) => setState(() {
                          _readingLayout = layout;
                        }),
                        secondaryTranslation: _secondaryTranslation,
                        onSelectSecondary: (id) => setState(() {
                          _secondaryTranslation = id;
                        }),
                      ),
                      const _ComfortPage(),
                      const _ReminderPage(),
                      const _FeaturesAndAccountPage(),
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
                                  duration: Motion.of(context, Motion.normal),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _page ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? _terracotta
                                        : _muted.withValues(alpha: 0.25),
                                    borderRadius:
                                        BorderRadius.circular(Radii.xs),
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
                              borderRadius: BorderRadius.circular(Radii.lg)),
                          textStyle: const TextStyle(
                              fontSize: TypeScale.title,
                              fontWeight: FontWeight.w600),
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
              fontSize: TypeScale.display,
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
                  fontSize: TypeScale.bodyLarge,
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
            borderRadius: BorderRadius.circular(Radii.lg),
            side: BorderSide(
              color: selected ? _terracotta : _muted.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.lg),
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
                                  fontSize: TypeScale.title,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          if (subtitle != null)
                            Text(subtitle!,
                                style: TextStyle(
                                    fontSize: TypeScale.body,
                                    color: _muted.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration:
                          Motion.of(context, const Duration(milliseconds: 200)),
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
                        fontSize: _kWelcomeTitleSize,
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
                          fontSize: TypeScale.title,
                          color: _muted.withValues(alpha: 0.7))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(l10n.onboardingPickLanguage,
            style: const TextStyle(
                fontSize: TypeScale.titleLarge,
                fontWeight: FontWeight.w700,
                color: _ink)),
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
            style: TextStyle(
                fontSize: TypeScale.body,
                color: _muted.withValues(alpha: 0.6))),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _BiblePage extends ConsumerWidget {
  const _BiblePage({
    required this.language,
    required this.primaryTranslation,
    required this.onSelectPrimary,
    required this.readingLayout,
    required this.onChangeLayout,
    required this.secondaryTranslation,
    required this.onSelectSecondary,
  });

  final AppLanguage language;
  final String primaryTranslation;
  final ValueChanged<String> onSelectPrimary;
  final ReadingLayout readingLayout;
  final ValueChanged<ReadingLayout> onChangeLayout;
  final String secondaryTranslation;
  final ValueChanged<String> onSelectSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final available = ref.watch(availableTranslationsProvider).value ?? [];

    final knownMeta = <String, ({String name, String sub})>{
      'kjv': (
        name: 'King James Version',
        sub: 'Traditional • KJV',
      ),
      'bbe': (
        name: 'Bible in Basic English',
        sub: 'Simple Vocabulary • BBE',
      ),
      'swh_ulb': (
        name: 'Swahili Unlocked Literal Bible',
        sub: 'Kiswahili • ULB',
      ),
      'fra_lsg': (
        name: 'Louis Segond 1910',
        sub: 'Français • LSG',
      ),
      'ita_dio': (
        name: 'Diodati 1885',
        sub: 'Italiano • DIO',
      ),
      'ron_btf': (
        name: 'Biblia Traducerea Fidelă',
        sub: 'Română • BTF',
      ),
      'tgl_ulb': (
        name: 'Tagalog Unlocked Literal Bible',
        sub: 'Tagalog • ULB',
      ),
    };

    String nameOf(String id) {
      for (final t in available) {
        if (t.translationId == id) return t.translationName;
      }
      return knownMeta[id]?.name ?? id.toUpperCase();
    }

    String subOf(String id) {
      for (final t in available) {
        if (t.translationId == id) {
          return '${t.abbreviation} • ${t.languageName}';
        }
      }
      return knownMeta[id]?.sub ?? id.toUpperCase();
    }

    final primaryIds = <String>[];
    if (language.bibleId != 'kjv' && language.bibleId != 'bbe') {
      primaryIds.add(language.bibleId);
    }
    primaryIds.addAll(['kjv', 'bbe']);
    for (final t in available) {
      if (!primaryIds.contains(t.translationId)) {
        primaryIds.add(t.translationId);
      }
    }

    final secondaryIds = <String>[];
    for (final id in primaryIds) {
      if (id != primaryTranslation) {
        secondaryIds.add(id);
      }
    }

    final isDual = readingLayout != ReadingLayout.single;

    return _PageFrame(
      title: l10n.onboardingBibleTitle,
      body: l10n.onboardingBibleBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingPrimaryVersion,
            style: const TextStyle(
              fontSize: TypeScale.titleLarge,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          for (final id in primaryIds)
            _ChoiceTile(
              title: nameOf(id),
              subtitle: subOf(id),
              selected: primaryTranslation == id,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectPrimary(id);
              },
            ),
          const SizedBox(height: 20),
          Text(
            l10n.readLayoutTitle,
            style: const TextStyle(
              fontSize: TypeScale.titleLarge,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          _LayoutTile(
            icon: Icons.menu_book_rounded,
            title: l10n.readLayoutSingle,
            subtitle: l10n.readLayoutSingleDesc,
            selected: readingLayout == ReadingLayout.single,
            onTap: () {
              HapticFeedback.selectionClick();
              onChangeLayout(ReadingLayout.single);
            },
          ),
          _LayoutTile(
            icon: Icons.view_column_rounded,
            title: l10n.readLayoutParallel,
            subtitle: l10n.readLayoutParallelDesc,
            selected: readingLayout == ReadingLayout.sideBySide,
            onTap: () {
              HapticFeedback.selectionClick();
              onChangeLayout(ReadingLayout.sideBySide);
            },
          ),
          _LayoutTile(
            icon: Icons.table_rows_rounded,
            title: l10n.readLayoutBilingual,
            subtitle: l10n.readLayoutBilingualDesc,
            selected: readingLayout == ReadingLayout.interleaved,
            onTap: () {
              HapticFeedback.selectionClick();
              onChangeLayout(ReadingLayout.interleaved);
            },
          ),
          AnimatedCrossFade(
            duration: Motion.of(context, Motion.normal),
            crossFadeState:
                isDual ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.onboardingSecondaryVersion,
                  style: const TextStyle(
                    fontSize: TypeScale.titleLarge,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.onboardingSecondaryDesc,
                  style: TextStyle(
                    fontSize: TypeScale.body,
                    color: _muted.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                for (final id in secondaryIds)
                  _ChoiceTile(
                    title: nameOf(id),
                    subtitle: subOf(id),
                    selected: secondaryTranslation == id,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelectSecondary(id);
                    },
                  ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LayoutTile extends StatelessWidget {
  const _LayoutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
            borderRadius: BorderRadius.circular(Radii.lg),
            side: BorderSide(
              color: selected ? _terracotta : _muted.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.lg),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? _terracotta.withValues(alpha: 0.12)
                            : _muted.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: selected ? _terracotta : _muted,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: TypeScale.title,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: TypeScale.body,
                              color: _muted.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration:
                          Motion.of(context, const Duration(milliseconds: 200)),
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

class _ComfortPage extends ConsumerWidget {
  const _ComfortPage();

  static const _previewFonts = [
    'Alegreya',
    'EB Garamond',
    'Literata',
    'Inter',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ref.watch(themeProvider);
    final typography = ref.watch(typographyProvider);
    final size = typography.fontSize;
    final currentFont = typography.fontFamily;

    final resolvedMode = theme.resolve(context);
    final preview = AppTheme.previewColors(resolvedMode);

    final classicThemes = [
      (AppThemeMode.light, l10n.onboardingThemeLight),
      (AppThemeMode.sepia, l10n.onboardingThemeSepia),
      (AppThemeMode.dark, l10n.onboardingThemeDark),
    ];

    final isCustomTheme = theme != AppThemeMode.automatic &&
        theme != AppThemeMode.light &&
        theme != AppThemeMode.sepia &&
        theme != AppThemeMode.dark;

    return _PageFrame(
      title: l10n.onboardingLookTitle,
      body: l10n.onboardingLookBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Daily rotation card (Automatic mode - default)
          Semantics(
            selected: theme == AppThemeMode.automatic,
            inMutuallyExclusiveGroup: true,
            button: true,
            child: Material(
              color: theme == AppThemeMode.automatic
                  ? _cream
                  : _cream.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.lg),
                side: BorderSide(
                  color: theme == AppThemeMode.automatic
                      ? _terracotta
                      : _muted.withValues(alpha: 0.15),
                  width: theme == AppThemeMode.automatic ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.lg),
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.automatic);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme == AppThemeMode.automatic
                                ? _terracotta.withValues(alpha: 0.12)
                                : _muted.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(Radii.md),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 22,
                            color: theme == AppThemeMode.automatic
                                ? _terracotta
                                : _muted,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l10n.onboardingThemeDaily,
                                    style: const TextStyle(
                                      fontSize: TypeScale.title,
                                      fontWeight: FontWeight.w600,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _terracotta.withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(Radii.sm),
                                    ),
                                    child: Text(
                                      _themeDisplayName(resolvedMode, l10n),
                                      style: const TextStyle(
                                        fontSize: TypeScale.caption,
                                        fontWeight: FontWeight.w600,
                                        color: _terracotta,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.onboardingThemeDailyDesc,
                                style: TextStyle(
                                  fontSize: TypeScale.body,
                                  color: _muted.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          duration: Motion.of(
                              context, const Duration(milliseconds: 200)),
                          opacity: theme == AppThemeMode.automatic ? 1 : 0,
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
          const SizedBox(height: 12),

          // 2. The three classic themes
          Row(
            children: [
              for (final (mode, name) in classicThemes) ...[
                Expanded(
                  child: _ClassicThemeButton(
                    mode: mode,
                    name: name,
                    selected: theme == mode,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(themeProvider.notifier).setTheme(mode);
                    },
                  ),
                ),
                if (mode != AppThemeMode.dark) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // 3. Shuffle / Surprise me button
          Material(
            color: isCustomTheme ? _cream : _cream.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
              side: BorderSide(
                color: isCustomTheme
                    ? _terracotta
                    : _muted.withValues(alpha: 0.15),
                width: isCustomTheme ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.lg),
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(themeProvider.notifier).shuffleTheme();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.shuffle_rounded,
                          size: 20, color: _terracotta),
                      const SizedBox(width: 10),
                      Text(
                        l10n.settingsSurpriseMe,
                        style: const TextStyle(
                          fontSize: TypeScale.bodyLarge,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      const Spacer(),
                      if (isCustomTheme) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: preview.background,
                            borderRadius: BorderRadius.circular(Radii.sm),
                            border: Border.all(
                                color: _muted.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            _themeDisplayName(theme, l10n),
                            style: TextStyle(
                              fontSize: TypeScale.caption,
                              fontWeight: FontWeight.bold,
                              color: preview.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: _terracotta),
                      ] else ...[
                        Text(
                          l10n.onboardingShuffleHint,
                          style: TextStyle(
                            fontSize: TypeScale.caption,
                            color: _muted.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Typography Font family selector
          Text(
            l10n.onboardingFontFamily,
            style: const TextStyle(
              fontSize: TypeScale.titleLarge,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final font in _previewFonts) ...[
                Expanded(
                  child: _FontChip(
                    fontFamily: font,
                    selected: currentFont == font,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(typographyProvider.notifier).setFontFamily(font);
                    },
                  ),
                ),
                if (font != _previewFonts.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // 5. Text size slider
          Text(
            l10n.onboardingTextSize,
            style: const TextStyle(
              fontSize: TypeScale.titleLarge,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const ExcludeSemantics(
                child: Text('A',
                    style: TextStyle(fontSize: TypeScale.body, color: _ink)),
              ),
              Expanded(
                child: Slider(
                  value: size.clamp(14, 30),
                  min: 14,
                  max: 30,
                  divisions: 8,
                  activeColor: _terracotta,
                  label: size.round().toString(),
                  semanticFormatterCallback: (v) => '${v.round()}',
                  // Drag events repeat the same snapped value; only a real
                  // change needs a rebuild and a preferences write.
                  onChanged: (v) {
                    if (v != size) {
                      ref.read(typographyProvider.notifier).setFontSize(v);
                    }
                  },
                ),
              ),
              const ExcludeSemantics(
                child: Text('A',
                    style:
                        TextStyle(fontSize: TypeScale.headline, color: _ink)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6. Live preview card
          AnimatedContainer(
            duration: Motion.of(context, const Duration(milliseconds: 200)),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: preview.background,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: _muted.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme == AppThemeMode.automatic
                          ? '${l10n.onboardingThemeDaily} • ${_themeDisplayName(resolvedMode, l10n)}'
                          : _themeDisplayName(theme, l10n),
                      style: TextStyle(
                        fontSize: TypeScale.micro,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: preview.textSecondary,
                      ),
                    ),
                    Text(
                      currentFont,
                      style: TextStyle(
                        fontFamily: currentFont,
                        fontSize: TypeScale.micro,
                        fontWeight: FontWeight.w600,
                        color: preview.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.onboardingPreviewVerse,
                  style: TextStyle(
                    fontFamily: currentFont,
                    fontSize: size,
                    height: 1.45,
                    color: preview.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingPreviewRef,
                  style: TextStyle(
                    fontFamily: currentFont,
                    fontSize: TypeScale.body,
                    fontWeight: FontWeight.w600,
                    color: preview.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassicThemeButton extends StatelessWidget {
  const _ClassicThemeButton({
    required this.mode,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.previewColors(mode);
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.of(context, const Duration(milliseconds: 200)),
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: selected ? _terracotta : _muted.withValues(alpha: 0.2),
              width: selected ? 2.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TypeScale.body,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _terracotta : AppColors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  final String fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: fontFamily,
      child: Material(
        color: selected ? _cream : _cream.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(
            color: selected ? _terracotta : _muted.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Center(
                child: Text(
                  fontFamily.split(' ').first,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: TypeScale.body,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    color: selected ? _terracotta : _ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _themeDisplayName(AppThemeMode mode, AppLocalizations l10n) {
  switch (mode) {
    case AppThemeMode.automatic:
      return l10n.onboardingThemeDaily;
    case AppThemeMode.light:
      return l10n.onboardingThemeLight;
    case AppThemeMode.sepia:
      return l10n.onboardingThemeSepia;
    case AppThemeMode.dark:
      return l10n.onboardingThemeDark;
    case AppThemeMode.oled:
      return l10n.settingsThemeOledDark;
    case AppThemeMode.dawn:
      return l10n.settingsThemeDawn;
    case AppThemeMode.fresh:
      return l10n.settingsThemeMoon;
    case AppThemeMode.dusk:
      return l10n.settingsThemeStars;
    case AppThemeMode.lilies:
      return l10n.settingsThemeLilies;
    case AppThemeMode.roses:
      return l10n.settingsThemeRoses;
    case AppThemeMode.olives:
      return l10n.settingsThemeOlives;
    case AppThemeMode.priestlyPurple:
      return l10n.settingsThemePurple;
    case AppThemeMode.galileeBlue:
      return l10n.settingsThemeBlue;
    case AppThemeMode.scarletRed:
      return l10n.settingsThemeRed;
  }
}

class _ReminderPage extends ConsumerWidget {
  const _ReminderPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reminders = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);
    final time =
        TimeOfDay(hour: reminders.dailyHour, minute: reminders.dailyMinute);
    return _PageFrame(
      title: l10n.onboardingReminderTitle,
      body: l10n.onboardingReminderBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: _cream.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(Radii.lg),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  activeTrackColor: _terracotta,
                  value: reminders.dailyEnabled,
                  // Turning it on is what asks for notification permission,
                  // so the request comes right after this explanation.
                  onChanged: notifier.toggleDaily,
                  secondary: const Icon(Icons.notifications_active_outlined,
                      color: _terracotta),
                  title: Text(l10n.onboardingReminderToggle,
                      style: const TextStyle(
                          fontSize: TypeScale.bodyLarge, color: _ink)),
                ),
                AnimatedSize(
                  duration:
                      Motion.of(context, const Duration(milliseconds: 200)),
                  child: reminders.dailyEnabled
                      ? ListTile(
                          leading:
                              const Icon(Icons.schedule_rounded, color: _muted),
                          title: Text(l10n.onboardingReminderTime,
                              style: const TextStyle(color: _ink)),
                          trailing: Text(time.format(context),
                              style: const TextStyle(
                                  fontSize: TypeScale.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                  color: _terracotta)),
                          onTap: () async {
                            final picked = await showTimePicker(
                                context: context, initialTime: time);
                            if (picked != null) {
                              notifier.setDailyTime(picked.hour, picked.minute);
                            }
                          },
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.onboardingReminderPermission,
              style: TextStyle(
                  fontSize: TypeScale.body,
                  color: _muted.withValues(alpha: 0.65))),
        ],
      ),
    );
  }
}

class _FeaturesAndAccountPage extends ConsumerWidget {
  const _FeaturesAndAccountPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(accountUserProvider).value;
    final apple = ref.watch(appleSignInAvailableProvider);
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: _ink,
      backgroundColor: _cream,
      minimumSize: const Size.fromHeight(52),
      side: BorderSide(color: _muted.withValues(alpha: 0.25)),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
    );
    return _PageFrame(
      title: l10n.onboardingFeaturesTitle,
      body: l10n.onboardingAccountBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeatureRow(
            icon: Icons.menu_book_rounded,
            color: _amber,
            title: l10n.onboardingFeatureWordTitle,
            body: l10n.onboardingFeatureWordBody,
          ),
          _FeatureRow(
            icon: Icons.calendar_month_rounded,
            color: _terracotta,
            title: l10n.onboardingFeaturePlansTitle,
            body: l10n.onboardingFeaturePlansBody,
          ),
          _FeatureRow(
            icon: Icons.lightbulb_rounded,
            color: _olive,
            title: l10n.onboardingFeatureStudyTitle,
            body: l10n.onboardingFeatureStudyBody,
          ),
          _FeatureRow(
            icon: Icons.cloud_done_rounded,
            color: _slate,
            title: l10n.onboardingFeatureSyncTitle,
            body: l10n.onboardingFeatureSyncBody,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingAccountTitle,
            style: const TextStyle(
              fontFamily: 'EB Garamond',
              fontSize: TypeScale.titleLarge,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          user != null
              ? _ChoiceTile(
                  title: l10n.onboardingSignedInAs(
                      user.displayName ?? user.email ?? ''),
                  selected: true,
                  onTap: () {},
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      style: buttonStyle,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: Text(l10n.accountSignInGoogle),
                      onPressed: () => runSignIn(context, ref, google: true),
                    ),
                    if (apple) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: buttonStyle,
                        icon: const Icon(Icons.apple),
                        label: Text(l10n.accountSignInApple),
                        onPressed: () => runSignIn(context, ref, google: false),
                      ),
                    ],
                  ],
                ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 18),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(Radii.lg)),
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
                          fontSize: TypeScale.title,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: TextStyle(
                          fontSize: TypeScale.bodyLarge,
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
