import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data.dart';
import '../../state/home_provider.dart';
import '../../state/votd_tracker_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/nav_provider.dart';
import '../widgets/shared_top_header.dart';
import '../widgets/glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/commentary_view.dart';
import 'today_screen.dart';
import '../../services/share_service.dart';
import '../sheets/theme_picker_sheet.dart';

class StrictHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  Offset _totalDelta = Offset.zero;

  StrictHorizontalDragGestureRecognizer();

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _totalDelta = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _totalDelta += event.delta;
      final dy = _totalDelta.dy.abs();
      final dx = _totalDelta.dx.abs();

      // Strict threshold: mostly horizontal (at least 45 deg angle)
      if (dy > 3 && dy >= dx * 1.2) {
        resolve(GestureDisposition.rejected);
      }
    }
    super.handleEvent(event);
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // Bounce/shimmer for the verse text
  late final AnimationController _verseController;
  late final Animation<double> _verseFade;

  bool _hasFiredArmedHaptic = false;
  double _overscrollAccum = 0.0;
  static const double _kOverscrollThreshold = 80.0;
  
  double _dragStartY = 0.0;
  bool _isDragging = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(votdTrackerProvider.notifier).markViewed(DateTime.now());
    });

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
    _verseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final appThemeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Layer 2: Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                StrictHorizontalDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        StrictHorizontalDragGestureRecognizer>(
                  () => StrictHorizontalDragGestureRecognizer(),
                  (StrictHorizontalDragGestureRecognizer instance) {
                    instance
                      ..onUpdate = (details) {}
                      ..onEnd = (details) {
                        if (details.primaryVelocity == null) return;
                        if (details.primaryVelocity!.abs() > 300) {
                          // Swipe Left/Right -> Appearance Sheet
                          ThemePickerSheet.show(context);
                        }
                      };
                  },
                ),
              },
              child: Listener(
                onPointerDown: (e) {
                  _dragStartY = e.position.dy;
                  _isDragging = true;
                },
                onPointerMove: (e) {
                  if (!_isDragging) return;

                  bool isAtTop = true;
                  if (_scrollController.hasClients) {
                    isAtTop = _scrollController.offset <= 16.0;
                  }
                  if (!isAtTop) return;

                  final dy = e.position.dy - _dragStartY;
                  if (dy < -10) {
                    _isDragging = false;
                    _overscrollAccum = 0.0;
                    if (mounted) setState(() {});
                    return;
                  }
                  
                  // Map drag delta to overscroll accumulator for the indicator
                  if (dy > 0) {
                    _overscrollAccum = dy;
                    if (_overscrollAccum >= _kOverscrollThreshold && !_hasFiredArmedHaptic) {
                      _hasFiredArmedHaptic = true;
                      HapticFeedback.mediumImpact();
                    }
                    if (mounted) setState(() {});
                  }
                },
                onPointerUp: (e) {
                  _isDragging = false;
                  if (_overscrollAccum >= _kOverscrollThreshold) {
                    ref.read(navProvider.notifier).setIndex(4); // 4 = Settings
                  }
                  _overscrollAccum = 0.0;
                  _hasFiredArmedHaptic = false;
                  if (mounted) setState(() {});
                },
                onPointerCancel: (e) {
                  _isDragging = false;
                  _overscrollAccum = 0.0;
                  _hasFiredArmedHaptic = false;
                  if (mounted) setState(() {});
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: FadeTransition(
                    opacity: _verseFade,
                    child: _buildPage(context, homeState, appThemeMode),
                  ),
                ),
              ),
            ),
          ),
          // Pull-to-Settings Indicator
          if (_overscrollAccum > 0)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: (_overscrollAccum / _kOverscrollThreshold)
                      .clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.5 +
                        0.5 *
                            (_overscrollAccum / _kOverscrollThreshold)
                                .clamp(0.0, 1.0),
                    child: Icon(
                      Icons.settings_rounded,
                      color: appThemeMode == AppThemeMode.dark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.5),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, HomeData data, AppThemeMode appThemeMode) {
    final theme = Theme.of(context);

    // Get dynamic commentary snippet for VOTD
    String? excerpt = data.verseOfTheDay.commentarySnippet;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // ── Header Row ────────────────────────────────────────────────
          SharedTopHeader(
            centerContent: Text(
              'Wednesday · July 22',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // ── Temporary "Today" preview entry point ─────────────────────
          // REMOVE IN STAGE 2 once Today is wired as a real tab/destination.
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const TodayScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFC9A227).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFFC9A227).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      size: 14, color: Color(0xFFC9A227)),
                  const SizedBox(width: 6),
                  Text(
                    'Preview Today Hub  ✦',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFC9A227),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Spacer pushes verse downward to balance the layout ────────────
          const SizedBox(height: 56),

          // ── Verse of the Day ──────────────────────────────────────────
          BouncyEntrance(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'VERSE OF THE DAY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          BouncyEntrance(
            delay: const Duration(milliseconds: 200),
            child: Text(
              '\u201c${data.verseOfTheDay.text}\u201d',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.42,
              ),
            ),
          ),
          const SizedBox(height: 10),
          BouncyEntrance(
            delay: const Duration(milliseconds: 300),
            child: Text(
              data.verseOfTheDay.reference,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Unified Reflection + Action Card ─────────────────────────
          BouncyEntrance(
            delay: const Duration(milliseconds: 400),
            child: GlassContainer(
              isScrollable: true,
              borderRadius: BorderRadius.circular(24),
              // Tighter vertical padding so the card fits without nav overlap
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Commentary text excerpt (fallback to omitted if none exists)
                  if (excerpt != null) ...[
                    Text(
                      excerpt,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.60,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Primary action row: Go Deeper + Share
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _PillButton(
                          label: 'Go Deeper',
                          filled: true,
                          onPressed: () {
                            final refStr = data.verseOfTheDay.reference;
                            final lastSpaceIdx = refStr.lastIndexOf(' ');
                            final bookName = lastSpaceIdx != -1
                                ? refStr.substring(0, lastSpaceIdx)
                                : refStr;
                            final refParts = lastSpaceIdx != -1
                                ? refStr.substring(lastSpaceIdx + 1).split(':')
                                : [];
                            final chapterNum = refParts.isNotEmpty
                                ? (int.tryParse(refParts[0]) ?? 1)
                                : 1;
                            final verseNum = refParts.length > 1
                                ? int.tryParse(refParts[1])
                                : null;

                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) => Scaffold(
                                      body: CommentaryView(
                                        book: bookName,
                                        chapter: chapterNum,
                                        verse: verseNum,
                                        verseText: data.verseOfTheDay.text,
                                        isCompact: false,
                                      ),
                                    )));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _PillButton(
                          label: 'Share',
                          filled: false,
                          onPressed: () {
                            ShareService.shareText(
                                body:
                                    '"${data.verseOfTheDay.text}" — ${data.verseOfTheDay.reference}');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Pill Watch & Listen Liquid Glass Buttons ──────────────
          BouncyEntrance(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                Expanded(
                  child: _PillGlassButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'Watch',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Media features coming in a future update')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PillGlassButton(
                    icon: Icons.headphones_rounded,
                    label: 'Listen',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Media features coming in a future update')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Clearance above the floating nav bar
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

// ── Reusable pill-shaped button used inside the action cluster ──────────
class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
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
            style: theme.textTheme.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? gold.withValues(alpha: 0.55)
                  : const Color(0xFF8C6300).withValues(
                      alpha: 0.8), // Deeper bronze for sharper contrast
            ),
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: gold, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  }
}

// ── Pill Liquid Glass Button for Watch / Listen ─────────────────────
class _PillGlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillGlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: GlassContainer(
          isScrollable: true,
          borderRadius: BorderRadius.circular(50),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: gold,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
