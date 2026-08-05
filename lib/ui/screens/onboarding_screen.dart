import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../state/theme_provider.dart';
import '../../state/translation_provider.dart';
import '../../state/typography_provider.dart';
import '../../theme/app_colors.dart';
import 'main_nav_screen.dart';

// ─────────────────────────────────────────────
// Theme display metadata
// ─────────────────────────────────────────────

class _ThemeMeta {
  final AppThemeMode mode;
  final String label;
  final Color bg;
  final Color text;
  final Color accent;

  const _ThemeMeta({
    required this.mode,
    required this.label,
    required this.bg,
    required this.text,
    required this.accent,
  });
}

const List<_ThemeMeta> _kThemes = [
  _ThemeMeta(
    mode: AppThemeMode.light,
    label: 'Dawn',
    bg: AppColors.lightBackground,
    text: AppColors.lightTextPrimary,
    accent: AppColors.lightAccent,
  ),
  _ThemeMeta(
    mode: AppThemeMode.sepia,
    label: 'Fresh',
    bg: AppColors.sepiaBackground,
    text: AppColors.sepiaTextPrimary,
    accent: Color(0xFF8B6348),
  ),
  _ThemeMeta(
    mode: AppThemeMode.dark,
    label: 'Dark',
    bg: AppColors.darkBackground,
    text: AppColors.darkTextPrimary,
    accent: AppColors.goldAccent,
  ),
  _ThemeMeta(
    mode: AppThemeMode.oled,
    label: 'OLED',
    bg: Color(0xFF000000),
    text: Color(0xFFFFFFFF),
    accent: AppColors.goldAccent,
  ),
  _ThemeMeta(
    mode: AppThemeMode.dawn,
    label: 'Sun',
    bg: AppColors.dawnBackground,
    text: AppColors.dawnTextPrimary,
    accent: AppColors.dawnPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.dusk,
    label: 'Stars',
    bg: AppColors.duskBackground,
    text: AppColors.duskTextPrimary,
    accent: AppColors.duskPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.fresh,
    label: 'Moon',
    bg: AppColors.freshBackground,
    text: AppColors.freshTextPrimary,
    accent: AppColors.freshPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.lilies,
    label: 'Lilies',
    bg: AppColors.liliesBackground,
    text: AppColors.liliesTextPrimary,
    accent: AppColors.liliesPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.roses,
    label: 'Roses',
    bg: AppColors.rosesBackground,
    text: AppColors.rosesTextPrimary,
    accent: AppColors.rosesPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.olives,
    label: 'Olives',
    bg: AppColors.olivesBackground,
    text: AppColors.olivesTextPrimary,
    accent: AppColors.olivesPrimary,
  ),
  _ThemeMeta(
    mode: AppThemeMode.priestlyPurple,
    label: 'Priestly Purple',
    bg: AppColors.lightBackground,
    text: Color(0xFF673AB7),
    accent: Color(0xFF9575CD),
  ),
  _ThemeMeta(
    mode: AppThemeMode.galileeBlue,
    label: 'Galilee Blue',
    bg: AppColors.lightBackground,
    text: Color(0xFF2196F3),
    accent: Color(0xFF64B5F6),
  ),
  _ThemeMeta(
    mode: AppThemeMode.scarletRed,
    label: 'Scarlet Red',
    bg: AppColors.lightBackground,
    text: Color(0xFFE53935),
    accent: Color(0xFFEF5350),
  ),
];

// ─────────────────────────────────────────────
// Root onboarding screen
// ─────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skip() {
    // Apply sensible defaults: keep current theme, KJV translation
    ref.read(activeTranslationProvider.notifier).setTranslation('kjv');
    _completeOnboarding();
  }

  void _completeOnboarding() {
    ref.read(preferencesProvider).setOnboardingComplete(true);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MainNavScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _WelcomePage(onNext: () => _goToPage(1)),
              _ThemePage(
                onNext: () => _goToPage(2),
                onBack: () => _goToPage(0),
              ),
              _TypographyPage(
                onNext: () => _goToPage(3),
                onBack: () => _goToPage(1),
              ),
              _TranslationPage(
                onNext: () => _goToPage(4),
                onBack: () => _goToPage(2),
              ),
              _GetStartedPage(onComplete: _completeOnboarding),
            ],
          ),

          // Skip button (top-right) — hidden on last page
          if (_currentPage < 4)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Skip',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),

          // Progress dots — bottom
          if (_currentPage < 4)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared nav row: Back + Next
// ─────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final Color? accentColor;

  const _NavRow({
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.primaryColor;
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onNext();
            },
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: accent.computeLuminance() > 0.4
                  ? Colors.black87
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(nextLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Page 1: Welcome
// ─────────────────────────────────────────────

class _WelcomePage extends ConsumerWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.18),
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Hero icon
              Center(
                child: Container(
                  width: size.width * 0.38,
                  height: size.width * 0.38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      primary.withValues(alpha: 0.25),
                      primary.withValues(alpha: 0.05),
                    ]),
                    border: Border.all(
                        color: primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(Icons.auto_stories_rounded,
                      size: size.width * 0.2, color: primary),
                ),
              ),

              const Spacer(flex: 2),

              // Title
              Text(
                'Blessed\nBible',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'Your daily Word. Beautifully crafted\nfor deep, distraction-free reading.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.55,
                ),
              ),

              const Spacer(flex: 3),

              // Features hint
              _FeatureHints(accentColor: primary),

              const Spacer(flex: 1),

              // CTA
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onNext();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: primary.computeLuminance() > 0.4
                      ? Colors.black87
                      : Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),

              SizedBox(height: bottom + 64),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureHints extends StatelessWidget {
  final Color accentColor;

  const _FeatureHints({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (Icons.palette_rounded, '14 beautiful themes'),
      (Icons.translate_rounded, 'Multi-translation support'),
      (Icons.bookmark_rounded, 'Highlights & bookmarks'),
    ];

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(item.$1, size: 16, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Page 2: Theme Picker
// ─────────────────────────────────────────────

class _ThemePage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _ThemePage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    // Find the selected theme meta for accent color
    final selectedMeta = _kThemes.firstWhere(
      (t) => t.mode == currentMode,
      orElse: () => _kThemes.first,
    );
    final accent = selectedMeta.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.15),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: top + 56), // room for skip button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STEP 1 OF 3',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pick your\ntheme',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The app recolors live as you tap. Your choice is saved.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Theme grid — scrollable
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _kThemes.length,
              itemBuilder: (context, index) {
                final meta = _kThemes[index];
                final isSelected = currentMode == meta.mode;
                return _ThemeCard(
                  meta: meta,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(themeProvider.notifier).setTheme(meta.mode);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 68),
            child: _NavRow(
              onBack: onBack,
              onNext: onNext,
              nextLabel: 'Next: Typography',
              accentColor: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final _ThemeMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: meta.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? meta.accent : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? meta.accent.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Color accent bar at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: meta.accent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    meta.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: meta.text,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Check mark when selected
            if (isSelected)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: meta.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Page 3: Translation Picker
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// Page 3: Typography Picker
// ─────────────────────────────────────────────

class _TypographyPage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _TypographyPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typoState = ref.watch(typographyProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    final currentMode = ref.watch(themeProvider);
    final selectedMeta = _kThemes.firstWhere(
      (t) => t.mode == currentMode,
      orElse: () => _kThemes.first,
    );
    final accent = selectedMeta.accent;

    final fonts = [
      'Gentium Book Plus',
      'Lora',
      'Literata',
      'Inter',
      'EB Garamond',
      'Lexend',
      'OpenDyslexic',
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.15),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: top + 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STEP 2 OF 3',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pick your\nfont',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose the typeface that feels most readable to you.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: fonts.length,
              itemBuilder: (context, index) {
                final font = fonts[index];
                final isSelected = typoState.fontFamily == font;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(typographyProvider.notifier).setFontFamily(font);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withValues(alpha: 0.12)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : theme.dividerColor.withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? accent
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: accent),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 68),
            child: _NavRow(
              onBack: onBack,
              onNext: onNext,
              nextLabel: 'Next: Translation',
              accentColor: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationPage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _TranslationPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeId = ref.watch(activeTranslationProvider);
    final translationsAsync = ref.watch(availableTranslationsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;
    final primary = theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.12),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: top + 56),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STEP 3 OF 3',
                    style: TextStyle(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pick your\ntranslation',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose your primary Bible translation. More languages are downloadable in Settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Translation list
          Expanded(
            child: translationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Could not load translations',
                    style: theme.textTheme.bodyMedium),
              ),
              data: (translations) {
                // Show bundled (downloaded) translations first
                final bundled =
                    translations.where((t) => t.isDownloaded).toList();
                final displayList = bundled.isEmpty ? translations : bundled;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = displayList[i];
                    final isSelected = activeId == t.translationId;
                    return _TranslationTile(
                      translationName: t.translationName,
                      abbreviation: t.abbreviation,
                      languageName: t.languageName,
                      isSelected: isSelected,
                      accentColor: primary,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(activeTranslationProvider.notifier)
                            .setTranslation(t.translationId);
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Download note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.download_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'More languages available to download in Settings',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 68),
            child: _NavRow(
              onBack: onBack,
              onNext: onNext,
              nextLabel: 'Almost done!',
              accentColor: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationTile extends StatelessWidget {
  final String translationName;
  final String abbreviation;
  final String languageName;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _TranslationTile({
    required this.translationName,
    required this.abbreviation,
    required this.languageName,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : theme.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Abbreviation badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  abbreviation.length > 4
                      ? abbreviation.substring(0, 4)
                      : abbreviation,
                  style: TextStyle(
                    color: isSelected
                        ? (accentColor.computeLuminance() > 0.4
                            ? Colors.black87
                            : Colors.white)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translationName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    languageName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: accentColor, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Page 4: Get Started
// ─────────────────────────────────────────────

class _GetStartedPage extends ConsumerWidget {
  final VoidCallback onComplete;

  const _GetStartedPage({required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;
    final activeId = ref.watch(activeTranslationProvider);
    final currentMode = ref.watch(themeProvider);

    final themeMeta = _kThemes.firstWhere(
      (t) => t.mode == currentMode,
      orElse: () => _kThemes.first,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeMeta.accent.withValues(alpha: 0.2),
            theme.scaffoldBackgroundColor,
            primary.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Big check circle
              Center(
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.12),
                    border: Border.all(
                        color: primary.withValues(alpha: 0.3), width: 2.5),
                  ),
                  child: Icon(Icons.check_rounded,
                      size: size.width * 0.15, color: primary),
                ),
              ),

              const Spacer(flex: 2),

              Text(
                'You\'re all\nset! 🎉',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 20),

              // Summary
              _SetupSummaryCard(
                themeName: themeMeta.label,
                themeAccent: themeMeta.accent,
                translationId: activeId,
              ),

              const Spacer(flex: 3),

              // Get Started CTA
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onComplete();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: primary.computeLuminance() > 0.4
                      ? Colors.black87
                      : Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Open Blessed Bible',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.auto_stories_rounded, size: 20),
                  ],
                ),
              ),

              SizedBox(height: bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupSummaryCard extends StatelessWidget {
  final String themeName;
  final Color themeAccent;
  final String translationId;

  const _SetupSummaryCard({
    required this.themeName,
    required this.themeAccent,
    required this.translationId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.palette_rounded,
            label: 'Theme',
            value: themeName,
            accentColor: themeAccent,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.translate_rounded,
            label: 'Translation',
            value: translationId.toUpperCase(),
            accentColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
