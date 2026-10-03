import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/typography_controls.dart';
import 'theme_picker_sheet.dart';

const double kAppearanceSheetHeightFactor = 0.70;

enum AppearanceTab { typography, theme }

class AppearanceSettingsSheet extends ConsumerStatefulWidget {
  final AppearanceTab initialTab;
  const AppearanceSettingsSheet({super.key, this.initialTab = AppearanceTab.typography});

  static Future<void> show(BuildContext context, {AppearanceTab initialTab = AppearanceTab.typography}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppearanceSettingsSheet(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<AppearanceSettingsSheet> createState() => _AppearanceSettingsSheetState();
}

class _AppearanceSettingsSheetState extends ConsumerState<AppearanceSettingsSheet> {
  late AppearanceTab _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 400) {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * kAppearanceSheetHeightFactor,
        ),
        child: TexturedGlassContainer(
          sigmaX: 45.0,
          sigmaY: 45.0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 20,
                  right: 20,
                  bottom: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tab toggle
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _TabButton(
                            label: 'Typography',
                            icon: Icons.text_fields_rounded,
                            isSelected: _activeTab == AppearanceTab.typography,
                            onTap: () {
                              if (_activeTab != AppearanceTab.typography) {
                                HapticFeedback.selectionClick();
                                setState(() => _activeTab = AppearanceTab.typography);
                              }
                            },
                          ),
                          _TabButton(
                            label: 'Theme',
                            icon: Icons.palette_rounded,
                            isSelected: _activeTab == AppearanceTab.theme,
                            onTap: () {
                              if (_activeTab != AppearanceTab.theme) {
                                HapticFeedback.selectionClick();
                                setState(() => _activeTab = AppearanceTab.theme);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _activeTab == AppearanceTab.typography
                      ? _TypographyTabBody(key: const ValueKey('typography'))
                      : _ThemeTabBody(key: const ValueKey('theme')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Typography tab (wraps the existing TypographyControls) ────────────────────
class _TypographyTabBody extends StatelessWidget {
  const _TypographyTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: const TypographyControls(),
    );
  }
}

// ── Theme tab (embeds the ThemePickerSheet body content) ─────────────────────
// We import and render the theme body content directly from ThemePickerSheet
// by exposing its inner Column as a separate widget.
class _ThemeTabBody extends ConsumerWidget {
  const _ThemeTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 0,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: const ThemePickerBody(),
    );
  }
}

// ── Tab Button ────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13,
                color: isSelected ? AppColors.lightTextPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 5),
              Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.lightTextPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
