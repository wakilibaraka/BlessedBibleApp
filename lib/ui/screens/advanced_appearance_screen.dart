import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../state/read_settings_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_segmented_tile.dart';
import 'package:flutter/services.dart';

class AdvancedAppearanceScreen extends ConsumerWidget {
  const AdvancedAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readSettings = ref.watch(readSettingsProvider);
    final themeMode = ref.watch(themeProvider);
    final isMatchSystem = ref.watch(isMatchSystemProvider);
    final isSingleTheme = ref.watch(isSingleThemeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SharedAppBar(
        title: Text('Advanced Appearance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 40),
        children: [
          _buildSection(context, 'System', [
            SwitchListTile(
              title: const Text('Match system appearance'),
              subtitle: const Text('Automatically switch between light and dark themes based on your device settings'),
              value: isMatchSystem,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(themeProvider.notifier).setMatchSystem(value);
                if (value) {
                  ref.read(themeProvider.notifier).setTheme(AppThemeMode.automatic);
                }
              },
            ),
            SwitchListTile(
              title: const Text('Lock Theme'),
              subtitle: const Text('Prevent automatic rotation of themes'),
              value: isSingleTheme,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(themeProvider.notifier).setSingleTheme(value);
              },
            ),
          ]),
          
          _buildSection(context, 'Background Glow', [
            SwitchListTile(
              title: const Text('Enable Background Glow'),
              subtitle: const Text('Renders a subtle animated light behind the reader in 3D surface style'),
              value: readSettings.isGlowEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setGlowEnabled(value);
              },
            ),
            if (readSettings.isGlowEnabled) ...[
              AnimatedSegmentedTile<BackgroundGlowStyle>(
                title: 'Glow Position',
                subtitle: 'Where the glow originates on the screen',
                selectedValue: readSettings.backgroundGlowStyle,
                options: const [
                  MapEntry(BackgroundGlowStyle.top, 'Top'),
                  MapEntry(BackgroundGlowStyle.full, 'Full'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setBackgroundGlowStyle(val);
                },
              ),
              AnimatedSegmentedTile<double>(
                title: 'Glow Intensity',
                subtitle: 'Brightness of the animated light',
                selectedValue: readSettings.glowIntensity,
                options: const [
                  MapEntry(0.5, 'Subtle'),
                  MapEntry(0.75, 'Normal'),
                  MapEntry(1.0, 'Bright'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setGlowIntensity(val);
                },
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        indent: 16,
                        endIndent: 16,
                      ),
                    children[i],
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

