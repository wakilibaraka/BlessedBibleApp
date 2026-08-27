import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../state/theme_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/animated_segmented_tile.dart';

import '../widgets/textured_glass_container.dart';
import '../../state/read_settings_provider.dart';

const double kAppearanceSheetHeightFactor = 0.70;

class ThemePickerSheet extends ConsumerStatefulWidget {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemePickerSheet(),
    );
  }

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeProvider);

    final readSettings = ref.watch(readSettingsProvider);

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          // Swipe down quickly → dismiss the sheet
          if ((details.primaryVelocity ?? 0) > 400) {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          }
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * kAppearanceSheetHeightFactor,
          ),
          child: TexturedGlassContainer(
          sigmaX: 45.0,
          sigmaY: 45.0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appearance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 520.0),
                  child: Container(
                    key: const ValueKey('appearance_main'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                Consumer(builder: (context, ref, _) {
                                  final surfaceStyle =
                                      ref.watch(earthHeavenStyleProvider);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedSegmentedTile<EarthHeavenStyle>(
                                        title: 'Surface Style',
                                        subtitle:
                                            'Visual depth and material styling',
                                        selectedValue: surfaceStyle,
                                        options: const [
                                          MapEntry(EarthHeavenStyle.heaven,
                                              'Heaven'),
                                          MapEntry(
                                              EarthHeavenStyle.earth, 'Earth'),
                                          MapEntry(
                                              EarthHeavenStyle.paperlike, 'Paperlike'),
                                        ],
                                        onChanged: (val) {
                                          HapticFeedback.selectionClick();
                                          ref
                                              .read(earthHeavenStyleProvider
                                                  .notifier)
                                              .setStyle(val);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 2.0),
                                        child: Text(
                                          surfaceStyle ==
                                                  EarthHeavenStyle.heaven
                                              ? 'Layered depth'
                                              : surfaceStyle == EarthHeavenStyle.paperlike
                                                  ? 'Warm e-reader paper'
                                                  : 'Flat surfaces',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 12),
                                const SizedBox(height: 12),
                                Text(
                                  'FOUNDATIONS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Dawn',
                                        mode: AppThemeMode.light,
                                        currentMode: currentMode,
                                        fillColor: AppColors.lightBackground,
                                        textColor: AppColors.lightTextPrimary,
                                        swatchColors: const [
                                          AppColors.lightBackground,
                                          AppColors.lightSurface,
                                          AppColors.lightAccent
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Fresh',
                                        mode: AppThemeMode.sepia,
                                        currentMode: currentMode,
                                        fillColor: AppColors.sepiaBackground,
                                        textColor: AppColors.sepiaTextPrimary,
                                        swatchColors: const [
                                          AppColors.sepiaBackground,
                                          AppColors.sepiaSurface,
                                          AppColors.sepiaTextPrimary
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _DarkThemePill(
                                          currentMode: currentMode),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'FIRMAMENT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Sun',
                                        mode: AppThemeMode.dawn,
                                        currentMode: currentMode,
                                        fillColor: AppColors.dawnBackground,
                                        textColor: AppColors.dawnTextPrimary,
                                        swatchColors: const [
                                          AppColors.dawnPrimary,
                                          AppColors.dawnAccent,
                                          AppColors.dawnBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Moon',
                                        mode: AppThemeMode.fresh,
                                        currentMode: currentMode,
                                        fillColor: AppColors.freshBackground,
                                        textColor: AppColors.freshTextPrimary,
                                        swatchColors: const [
                                          AppColors.freshPrimary,
                                          AppColors.freshAccent,
                                          AppColors.freshBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Stars',
                                        mode: AppThemeMode.dusk,
                                        currentMode: currentMode,
                                        fillColor: AppColors.duskBackground,
                                        textColor: AppColors.duskTextPrimary,
                                        swatchColors: const [
                                          AppColors.duskPrimary,
                                          AppColors.duskAccent,
                                          AppColors.duskBackground
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'EDEN',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Lilies',
                                        mode: AppThemeMode.lilies,
                                        currentMode: currentMode,
                                        fillColor: AppColors.liliesBackground,
                                        textColor: AppColors.liliesTextPrimary,
                                        swatchColors: const [
                                          AppColors.liliesPrimary,
                                          AppColors.liliesAccent,
                                          AppColors.liliesBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Roses',
                                        mode: AppThemeMode.roses,
                                        currentMode: currentMode,
                                        fillColor: AppColors.rosesBackground,
                                        textColor: AppColors.rosesTextPrimary,
                                        swatchColors: const [
                                          AppColors.rosesPrimary,
                                          AppColors.rosesAccent,
                                          AppColors.rosesBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Olives',
                                        mode: AppThemeMode.olives,
                                        currentMode: currentMode,
                                        fillColor: AppColors.olivesBackground,
                                        textColor: AppColors.olivesTextPrimary,
                                        swatchColors: const [
                                          AppColors.olivesPrimary,
                                          AppColors.olivesAccent,
                                          AppColors.olivesBackground
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'SANCTUARY',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Priestly\nPurple',
                                        mode: AppThemeMode.priestlyPurple,
                                        currentMode: currentMode,
                                        fillColor: AppColors.lightBackground,
                                        textColor: const Color(0xFF673AB7),
                                        swatchColors: const [
                                          Color(0xFF673AB7),
                                          Color(0xFF9575CD),
                                          AppColors.lightBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Galilee\nBlue',
                                        mode: AppThemeMode.galileeBlue,
                                        currentMode: currentMode,
                                        fillColor: AppColors.lightBackground,
                                        textColor: const Color(0xFF2196F3),
                                        swatchColors: const [
                                          Color(0xFF2196F3),
                                          Color(0xFF64B5F6),
                                          AppColors.lightBackground
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _ThemePill(
                                        label: 'Scarlet\nRed',
                                        mode: AppThemeMode.scarletRed,
                                        currentMode: currentMode,
                                        fillColor: AppColors.lightBackground,
                                        textColor: const Color(0xFFE53935),
                                        swatchColors: const [
                                          Color(0xFFE53935),
                                          Color(0xFFEF5350),
                                          AppColors.lightBackground
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const SizedBox(height: 24),
                                const Divider(height: 16),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Enable Background Glow', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Renders a subtle animated light behind the reader in 3D surface style', style: TextStyle(fontSize: 12)),
                                  value: readSettings.isGlowEnabled,
                                  onChanged: (value) {
                                    HapticFeedback.selectionClick();
                                    ref.read(readSettingsProvider.notifier).setGlowEnabled(value);
                                  },
                                ),
                              ],
                            ),
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

class _ThemePill extends ConsumerStatefulWidget {
  final String label;
  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final Color fillColor;
  final Color textColor;
  final List<Color> swatchColors;

  const _ThemePill({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.fillColor,
    required this.textColor,
    required this.swatchColors,
  });

  @override
  ConsumerState<_ThemePill> createState() => _ThemePillState();
}

class _ThemePillState extends ConsumerState<_ThemePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _triggerSparkle() {
    _sparkleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.currentMode == widget.mode ||
        (widget.currentMode == AppThemeMode.automatic &&
            widget.mode == AppThemeMode.automatic.resolve(context) &&
            widget.mode != AppThemeMode.automatic);

    final bgLuminance =
        (isSelected ? widget.fillColor : theme.colorScheme.surface)
            .computeLuminance();
    final isDarkBg = bgLuminance < 0.4;

    final neumorphicShadows = isDarkBg
        ? [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.85),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ];

    final accentColor = widget.swatchColors.length > 1
        ? widget.swatchColors[1]
        : theme.primaryColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _triggerSparkle();
        ref.read(themeProvider.notifier).setTheme(widget.mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 46,
        decoration: BoxDecoration(
          color: isSelected
              ? widget.fillColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: neumorphicShadows,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                left: isSelected ? 6 : 40,
                right: isSelected ? 40 : 6,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  textAlign: widget.label.contains('\n')
                      ? TextAlign.left
                      : TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: isSelected
                        ? widget.textColor
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment:
                  isSelected ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [
                      ...widget.swatchColors,
                      widget.swatchColors.first
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _SparkleBurst(
                controller: _sparkleController,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppThemeMode _lastDarkVariant = AppThemeMode.dark;

class _DarkThemePill extends ConsumerStatefulWidget {
  final AppThemeMode currentMode;

  const _DarkThemePill({required this.currentMode});

  @override
  ConsumerState<_DarkThemePill> createState() => _DarkThemePillState();
}

class _DarkThemePillState extends ConsumerState<_DarkThemePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _triggerSparkle() {
    _sparkleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkActive = widget.currentMode == AppThemeMode.dark;
    final isOledActive = widget.currentMode == AppThemeMode.oled;
    final isSelected = isDarkActive || isOledActive;

    if (isDarkActive) {
      _lastDarkVariant = AppThemeMode.dark;
    } else if (isOledActive) {
      _lastDarkVariant = AppThemeMode.oled;
    }

    final activeVariant = isSelected
        ? (isOledActive ? AppThemeMode.oled : AppThemeMode.dark)
        : _lastDarkVariant;

    final fillColor = activeVariant == AppThemeMode.oled
        ? Colors.black
        : const Color(0xFF333333);
    final textColor = AppColors.darkTextPrimary;
    final swatchColors = activeVariant == AppThemeMode.oled
        ? const [Colors.black, Color(0xFF222222), Colors.black]
        : const [Color(0xFF444444), Color(0xFF222222), Color(0xFF555555)];

    final bgLuminance =
        (isSelected ? fillColor : theme.colorScheme.surface).computeLuminance();
    final isDarkBg = bgLuminance < 0.4;

    final neumorphicShadows = isDarkBg
        ? [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.85),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ];

    final accentColor =
        activeVariant == AppThemeMode.oled ? Colors.amber : Colors.cyanAccent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _triggerSparkle();
        if (isDarkActive) {
          _lastDarkVariant = AppThemeMode.oled;
          ref.read(themeProvider.notifier).setTheme(AppThemeMode.oled);
        } else if (isOledActive) {
          _lastDarkVariant = AppThemeMode.dark;
          ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
        } else {
          ref.read(themeProvider.notifier).setTheme(_lastDarkVariant);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 46,
        decoration: BoxDecoration(
          color: isSelected
              ? fillColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: neumorphicShadows,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                left: isSelected ? 6 : 40,
                right: isSelected ? 40 : 6,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  activeVariant == AppThemeMode.oled
                      ? 'OLED\nDark'
                      : 'Dusk\nOLED',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: isSelected ? textColor : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment:
                  isSelected ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                        colors: [...swatchColors, swatchColors.first]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _SparkleBurst(
                controller: _sparkleController,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleBurst extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _SparkleBurst({
    required this.controller,
    required this.color,
  });

  static const _sparkleSpecs = [
    _SparkleSpec(-0.38, -0.50, -0.6, -0.8), // Top-left
    _SparkleSpec(0.00, -0.50, 0.0, -1.0), // Top-center
    _SparkleSpec(0.38, -0.50, 0.6, -0.8), // Top-right
    _SparkleSpec(0.38, 0.50, 0.6, 0.8), // Bottom-right
    _SparkleSpec(0.00, 0.50, 0.0, 1.0), // Bottom-center
    _SparkleSpec(-0.38, 0.50, -0.6, 0.8), // Bottom-left
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        if (value == 0.0 || value == 1.0) {
          return const SizedBox.shrink();
        }

        final travelProgress = (value / 0.4).clamp(0.0, 1.0);
        final travel = 20.0 * Curves.easeOutCubic.transform(travelProgress);

        final scaleProgress = value < 0.2
            ? (value / 0.2)
            : value < 0.6
                ? 1.0
                : (1.0 - (value - 0.6) / 0.4);
        final scale = scaleProgress.clamp(0.0, 1.0);

        final fadeProgress = value <= 0.3
            ? 1.0
            : Curves.easeOut
                .transform((1.0 - (value - 0.3) / 0.7).clamp(0.0, 1.0));
        final opacity = fadeProgress;

        return ExcludeSemantics(
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    for (final spec in _sparkleSpecs)
                      Transform.translate(
                        offset: Offset(
                          (spec.relX * w) + (spec.dirX * travel),
                          (spec.relY * h) + (spec.dirY * travel),
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 11,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SparkleSpec {
  final double relX;
  final double relY;
  final double dirX;
  final double dirY;

  const _SparkleSpec(this.relX, this.relY, this.dirX, this.dirY);
}
