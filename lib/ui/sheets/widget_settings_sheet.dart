import '../../l10n/l10n.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/widget_settings_provider.dart';
import '../../state/home_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/wotd_provider.dart';
import '../../services/widget_update_service.dart';
import '../widgets/dynamic_toast.dart';
import '../../theme/design_tokens.dart';

class WidgetSettingsSheet extends ConsumerWidget {
  const WidgetSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WidgetSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(widgetSettingsProvider);
    final homeData = ref.watch(homeProvider);
    final streak = ref.watch(streakProvider);
    final wotdAsync = ref.watch(wordOfTheDayProvider);
    final wotd = wotdAsync.value;

    final votdRef = homeData.verseOfTheDay.reference;
    final votdText = homeData.verseOfTheDay.text;
    final wotdWord = wotd?.word ?? 'Grace (Charis)';
    final wotdSnippet = wotd?.snippet ??
        'The unmerited favor and divine love of God bestowed upon humanity.';

    final isDark = settings.textMode == WidgetTextMode.dark ||
        (settings.textMode == WidgetTextMode.auto &&
            settings.backgroundStyle != WidgetBackgroundStyle.solidLight &&
            settings.backgroundStyle != WidgetBackgroundStyle.glassLight);

    // The previews mimic the home-screen widget, which has its own fixed
    // palette (chosen in widget settings), so these stay literal and do not
    // follow the app theme.
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF18181B);
    final secondaryTextColor =
        isDark ? const Color(0xFFD4D4D8) : const Color(0xFF52525B);
    final labelColor =
        isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706);
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Radii.xxxl)),
        boxShadow: [
          BoxShadow(
            color: context.palette.shadow.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Radii.xs),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Radii.lg),
                    ),
                    child: Icon(Icons.widgets_rounded,
                        color: theme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.settingsWidgetsTitle,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          context.l10n.settingsWidgetsLivePreview,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Live Previews
              Text(
                context.l10n.settingsWidgetPreviewHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Streak & WOTD Widget Preview
              _buildWidgetContainer(
                settings: settings,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🔥',
                            style: TextStyle(fontSize: TypeScale.headline)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.studyStreakDays(streak.count),
                                style: TextStyle(
                                  fontSize: TypeScale.bodyLarge,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              Text(
                                context.l10n.settingsWidgetStreak,
                                style: TextStyle(
                                  fontSize: TypeScale.caption,
                                  color: isDark
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: dividerColor),
                    ),
                    Text(
                      context.l10n.settingsWidgetWotd,
                      style: TextStyle(
                        fontSize: TypeScale.micro,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wotdWord,
                      style: TextStyle(
                        fontSize: TypeScale.body,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wotdSnippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: TypeScale.caption,
                        color: secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // VOTD Widget Preview
              _buildWidgetContainer(
                settings: settings,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.settingsWidgetVotd,
                      style: TextStyle(
                        fontSize: TypeScale.micro,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: labelColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: dividerColor),
                    ),
                    Text(
                      '"$votdText"',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: TypeScale.body,
                        color: primaryTextColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— $votdRef',
                        style: TextStyle(
                          fontSize: TypeScale.caption,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section: Style Selection
              Text(
                context.l10n.settingsWidgetBackgroundHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WidgetBackgroundStyle.values.map((style) {
                  final isSelected = settings.backgroundStyle == style;
                  return ChoiceChip(
                    avatar: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: style.previewColors.length > 1
                            ? LinearGradient(colors: style.previewColors)
                            : null,
                        color: style.previewColors.length == 1
                            ? style.previewColors.first
                            : (style == WidgetBackgroundStyle.transparent
                                ? Colors.grey.withValues(alpha: 0.3)
                                : null),
                        border: Border.all(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    label: Text(style.label(context.l10n)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(widgetSettingsProvider.notifier)
                            .setBackgroundStyle(style);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Section: Text Contrast Mode
              Text(
                context.l10n.settingsWidgetContrastHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              SegmentedButton<WidgetTextMode>(
                segments: WidgetTextMode.values.map((mode) {
                  return ButtonSegment(
                    value: mode,
                    label: Text(
                      mode == WidgetTextMode.auto
                          ? context.l10n.settingsWidgetTextAuto
                          : (mode == WidgetTextMode.light
                              ? context.l10n.settingsWidgetTextDark
                              : context.l10n.settingsWidgetTextWhite),
                    ),
                  );
                }).toList(),
                selected: {settings.textMode},
                onSelectionChanged: (newSelection) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(widgetSettingsProvider.notifier)
                      .setTextMode(newSelection.first);
                },
              ),

              const SizedBox(height: 28),

              // Apply & Update Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    unawaited(HapticFeedback.mediumImpact());
                    await ref
                        .read(widgetUpdateServiceProvider)
                        .syncAllWidgets();
                    if (context.mounted) {
                      DynamicToast.show(
                        context,
                        context.l10n.settingsWidgetSynced,
                        icon: Icons.check_circle_rounded,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(context.l10n.settingsWidgetApply),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.xl),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetContainer({
    required WidgetSettingsState settings,
    required Widget child,
  }) {
    final style = settings.backgroundStyle;
    final isTransparent = style == WidgetBackgroundStyle.transparent;

    // Fixed preview styling (matches the home-screen widget, not the theme).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.xxl),
        gradient: style.previewColors.length > 1
            ? LinearGradient(
                colors: style.previewColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: style.previewColors.length == 1
            ? style.previewColors.first
            : (isTransparent ? Colors.black.withValues(alpha: 0.08) : null),
        border: Border.all(
          color: isTransparent
              ? Colors.white.withValues(alpha: 0.3)
              : (style == WidgetBackgroundStyle.glassLight ||
                      style == WidgetBackgroundStyle.glassDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.08)),
          width: 1.5,
        ),
        boxShadow: isTransparent
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }
}
