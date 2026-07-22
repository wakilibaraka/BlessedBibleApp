import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data.dart';
import '../../state/home_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<double> _bgAnimation;

  // Bounce/shimmer for the verse text
  late final AnimationController _verseController;
  late final Animation<double> _verseFade;

  @override
  void initState() {
    super.initState();

    // Slow 12-second looping gradient shift
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOutSine,
    );

    // Verse fade-in on load
    _verseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _verseFade = CurvedAnimation(
      parent: _verseController,
      curve: Curves.easeOut,
    );
    _verseController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _verseController.reset();
    // Trigger a reload via Riverpod
    ref.invalidate(homeProvider);
    await Future.delayed(const Duration(milliseconds: 900));
    _verseController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final appThemeMode = ref.watch(themeProvider);
    final isDark    = appThemeMode == AppThemeMode.dark;
    final isWarmGold = appThemeMode == AppThemeMode.sepia;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Layer 1: Animated Gradient Background ──────────────────────
          Positioned.fill(
            child: _AnimatedBackground(
              animation: _bgAnimation,
              appThemeMode: appThemeMode,
            ),
          ),

          // ── Layer 2: Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: homeState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (data) => RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFFC9A227),
                backgroundColor: isDark ? const Color(0xFF2C2A28) : Colors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: FadeTransition(
                        opacity: _verseFade,
                        child: _buildPage(context, data, appThemeMode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, HomeData data, AppThemeMode appThemeMode) {
    final theme = Theme.of(context);
    final isDark    = appThemeMode == AppThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // ── Header Row ────────────────────────────────────────────────
          Row(
            children: [
              // Left: Bible / cross logo placeholder
              Icon(
                Icons.auto_stories_rounded,
                size: 28,
                color: theme.primaryColor,
              ),

              // Center: Date
              Expanded(
                child: Text(
                  'Wednesday · July 22',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gentiumBookPlus(
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Right: Animated 3-way theme toggle
              GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: switch (appThemeMode) {
                    AppThemeMode.light    => Icon(
                        Icons.wb_sunny_outlined,
                        key: const ValueKey('light'),
                        size: 26,
                        color: theme.primaryColor,
                      ),
                    AppThemeMode.sepia => Icon(
                        Icons.auto_awesome,
                        key: const ValueKey('sepia'),
                        size: 26,
                        color: theme.primaryColor,
                      ),
                    AppThemeMode.dark     => Icon(
                        Icons.nightlight_round,
                        key: const ValueKey('dark'),
                        size: 26,
                        color: theme.primaryColor,
                      ),
                  },
                ),
              ),
            ],
          ),

          // ── Spacer pushes verse downward to balance the layout ────────────
          const SizedBox(height: 56),

          // ── Verse of the Day ──────────────────────────────────────────
          Text(
            'VERSE OF THE DAY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.primaryColor,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\u201c${data.verseOfTheDay.text}\u201d',
            textAlign: TextAlign.center,
            style: GoogleFonts.gentiumBookPlus(
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.42,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.verseOfTheDay.reference,
            style: GoogleFonts.gentiumBookPlus(
              textStyle: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Unified Reflection + Action Card ─────────────────────────
          GlassContainer(
            borderRadius: BorderRadius.circular(24),
            // Tighter vertical padding so the card fits without nav overlap
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Commentary text — reduced line height for compactness
                Text(
                  'In the opening moment of creation, God\'s first creative act was calling forth light. This wasn\'t just physical luminescence; it symbolizes the foundational impact of His Word and presence in darkness.\n\nIn our own moments of uncertainty, God continues to bring clarity and life through His voice.',
                  style: GoogleFonts.lora(
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      height: 1.60,
                      fontSize: 13.5,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.82),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Primary action row: Read + Listen
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PillButton(
                        label: 'Read the Commentary',
                        filled: true,
                        onPressed: () {
                          ref.read(activeStudyVerseProvider.notifier).setVerse(data.verseOfTheDay.reference);
                          ref.read(navProvider.notifier).setIndex(3);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _PillButton(
                        label: '\u25B6  Listen',
                        filled: false,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Secondary: full-width Save
                _PillButton(
                  label: 'Save reflection',
                  filled: false,
                  fullWidth: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Comfortable clearance above the floating nav bar (≈ 64dp)
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Animated Gradient Background
// ═══════════════════════════════════════════════════════════════════════
class _AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;
  final AppThemeMode appThemeMode;

  const _AnimatedBackground({
    required this.animation,
    required this.appThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value; // 0.0 → 1.0 loops with reverse

        // Slowly drift the focal point of the radial gradient
        final cx = lerpDouble(-0.3, 0.3, t);
        final cy = lerpDouble(-0.4, 0.1, t);

        final List<Color> colors;
        switch (appThemeMode) {
          case AppThemeMode.dark:
            // Warm amber glow at focal point, deep charcoal edges
            colors = [
              Color.lerp(const Color(0xFF3D2B0A), const Color(0xFF251800), t)!,
              Color.lerp(const Color(0xFF1E1C1A), const Color(0xFF0F0D0B), t)!,
              const Color(0xFF080706),
            ];
            break;
          case AppThemeMode.sepia:
            // Soft gold glow fading into matte sepia background
            colors = [
              Color.lerp(const Color(0xFFE5CC98), const Color(0xFFDAB875), t)!,
              const Color(0xFFF4EAD5), // Fades to matte sepia
              const Color(0xFFF4EAD5),
            ];
            break;
          case AppThemeMode.light:
          default:
            // Very subtle warm glow that fades quickly into the pure ivory background
            colors = [
              Color.lerp(const Color(0xFFFDF3D7), const Color(0xFFFDE4A9), t)!,
              const Color(0xFFFAF9F6), // Fades to Pure Ivory
              const Color(0xFFFAF9F6),
            ];
        }

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(cx, cy),
              radius: 1.6,
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  // Inline linear interpolation helper
  double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}


// ── Reusable pill-shaped button used inside the action cluster ──────────
class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool fullWidth;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    );

    if (filled) {
      return SizedBox(
        height: 48,
        width: fullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? gold.withOpacity(0.55)
                  : const Color(0xFF8C6300).withOpacity(0.8), // Deeper bronze for sharper contrast
            ),
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      );
    }
  }
}


