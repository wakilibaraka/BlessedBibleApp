import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';


import '../../state/hints_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../services/backup_service.dart';
import '../../state/reminders_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_segmented_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';
import '../../data/local_storage/preferences_service.dart';
import '../../state/translation_provider.dart';
import '../sheets/translation_picker_sheet.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const SharedAppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 120),
          children: [
            _buildSection(context, 'General', [
              Consumer(builder: (context, ref, _) {
                final defaultStartTab = ref.watch(readSettingsProvider.select((s) => s.defaultStartTab));
                return AnimatedSegmentedTile<int>(
                  title: 'Default start page',
                subtitle: 'Choose which page the app opens to on launch',
                selectedValue: defaultStartTab,
                options: const [
                  MapEntry(0, 'Home'),
                  MapEntry(1, 'Read'),
                  MapEntry(3, 'Study'),
                  MapEntry(2, 'Search'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setDefaultStartTab(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final sensitivity = ref.watch(readSettingsProvider.select((s) => s.gestureSensitivity));
              return AnimatedSegmentedTile<GestureSensitivity>(
                title: 'Gesture Sensitivity',
                subtitle: sensitivity == GestureSensitivity.instant
                    ? 'Instant: Snappy, zero-delay switching.'
                    : (sensitivity == GestureSensitivity.fluid
                        ? 'Fluid: Light, flick-responsive gestures across the app.'
                        : 'Firm: Deliberate gestures, resistant to accidental swipes.'),
                selectedValue: sensitivity,
                options: const [
                  MapEntry(GestureSensitivity.instant, 'Instant'),
                  MapEntry(GestureSensitivity.fluid, 'Fluid'),
                  MapEntry(GestureSensitivity.firm, 'Firm'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setGestureSensitivity(val);
                },
              );
            }),
          ]),
          
          _buildSection(context, 'Reading', [
            Consumer(builder: (context, ref, _) {
              final activeTranslationId = ref.watch(activeTranslationProvider);
              final allTranslations = ref.watch(availableTranslationsProvider);
              final activeTranslationName = allTranslations.maybeWhen(
                data: (list) => list.firstWhere(
                  (t) => t.translationId == activeTranslationId,
                  orElse: () => list.first,
                ).translationName,
                orElse: () => activeTranslationId.toUpperCase(),
              );
              
              return ListTile(
                title: const Text('Bible Translation'),
                subtitle: Text(activeTranslationName),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const TranslationPickerSheet(),
                  );
                },
              );
            }),

            Consumer(builder: (context, ref, _) {
              final viewMode = ref.watch(readSettingsProvider.select((s) => s.readingViewMode));
              return AnimatedSegmentedTile<ReadingViewMode>(
                title: 'Immersive Reading',
                subtitle: 'Hide navigation bars while scrolling and remove the background glow for a cleaner read',
                selectedValue: viewMode,
                options: const [
                  MapEntry(ReadingViewMode.immersive, 'On'),
                  MapEntry(ReadingViewMode.pinned, 'Off'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setReadingViewMode(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final isRedLetterEnabled = ref.watch(readSettingsProvider.select((s) => s.isRedLetterEnabled));
              return AnimatedSegmentedTile<bool>(
                title: 'Words of Jesus in red',
                subtitle: 'Render the words of Jesus in a subtle, classic red letter format',
                selectedValue: isRedLetterEnabled,
                options: const [
                  MapEntry(true, 'On'),
                  MapEntry(false, 'Off'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setRedLetterEnabled(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final actionStyle = ref.watch(readSettingsProvider.select((s) => s.verseActionStyle));
              return AnimatedSegmentedTile<VerseActionStyle>(
                title: 'Verse Action Style',
                subtitle: 'Layout for highlight & action controls when a verse is selected',
                selectedValue: actionStyle,
                options: const [
                  MapEntry(VerseActionStyle.classic, 'Classic'),
                  MapEntry(VerseActionStyle.horizontal, 'Minimal'),
                  MapEntry(VerseActionStyle.raindrop, 'Raindrop'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setVerseActionStyle(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final isRedLetter = ref.watch(readSettingsProvider.select((s) => s.isRedLetterEnabled));
              return SwitchListTile(
                title: const Text('Words of Jesus in Red'),
                subtitle: const Text('Render words spoken by Jesus in red'),
                value: isRedLetter,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setRedLetterEnabled(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final showNumbers = ref.watch(readSettingsProvider.select((s) => s.showVerseNumbers));
              return SwitchListTile(
                title: const Text('Show Verse Numbers'),
                subtitle: const Text('Display verse numbers in the text'),
                value: showNumbers,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setShowVerseNumbers(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final keepAwake = ref.watch(readSettingsProvider.select((s) => s.keepScreenAwake));
              return SwitchListTile(
                title: const Text('Keep Screen Awake'),
                subtitle: const Text('Prevent device from sleeping while reading'),
                value: keepAwake,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setKeepScreenAwake(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final prefs = ref.watch(preferencesProvider);
              return StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    title: const Text('Show reading tips'),
                    subtitle: const Text('Show guided hints for reading actions like highlighting and swiping'),
                    value: prefs.showReadingTips,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      prefs.setShowReadingTips(val);
                      setState(() {});
                      if (val) {
                         ref.read(hintsProvider.notifier).resetHints();
                      }
                    },
                  );
                }
              );
            }),

            Consumer(builder: (context, ref, _) {
              final primaryIndex = ref.watch(readSettingsProvider.select((s) => s.primaryHighlightColorIndex));
              final secondaryIndex = ref.watch(readSettingsProvider.select((s) => s.secondaryHighlightColorIndex));
              
              Widget buildColorPicker(String title, String subtitle, int selectedIndex, Function(int) onChanged) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                      ],
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(6, (index) {
                            final i = index - 1;
                            
                            Color color;
                            if (i == -1) {
                              color = Theme.of(context).cardColor;
                            } else {
                              color = AppColors.getRenderedHighlightColor(highlightPaletteSwatches[i], Theme.of(context).brightness, Theme.of(context).scaffoldBackgroundColor);
                            }
                            
                            final isSelected = i == selectedIndex;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => onChanged(i),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Theme.of(context).primaryColor : (i == -1 ? Theme.of(context).dividerColor : Colors.black.withValues(alpha: 0.2)),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: (isSelected || i == -1)
                                            ? null
                                            : [ BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, spreadRadius: 1) ],
                                      ),
                                      child: i == -1 
                                          ? Icon(Icons.question_mark_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface)
                                          : (isSelected ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor) : null),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    i == -1 ? 'Ask' : highlightPaletteNames[i],
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  buildColorPicker(
                    'Primary Highlight Color',
                    'Default color applied when tapping the Highlight action',
                    primaryIndex,
                    (i) => ref.read(readSettingsProvider.notifier).setPrimaryHighlightColorIndex(i)
                  ),
                  buildColorPicker(
                    'Secondary Highlight Color',
                    'Second color presented in quick action menus',
                    secondaryIndex,
                    (i) => ref.read(readSettingsProvider.notifier).setSecondaryHighlightColorIndex(i)
                  ),
                ],
              );
            }),
            Consumer(builder: (context, ref, _) {
              final alwaysShowNav = ref.watch(navSettingsProvider.select((s) => s.alwaysShowNav));
              return SwitchListTile(
                title: const Text('Autohide main navigation bar'),
                subtitle: const Text('Keep bottom nav visible even when verses are selected'),
                value: alwaysShowNav,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  ref.read(navSettingsProvider.notifier).setAlwaysShowNav(value);
                },
              );
            }),
          ]),



          _buildSection(context, 'Reminders', [
            Consumer(builder: (context, ref, _) {
              final remindersState = ref.watch(remindersProvider);
              final notifier = ref.read(remindersProvider.notifier);
              final theme = Theme.of(context);
              return Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Friday Sunset Reminder',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Welcome the Sabbath at your local sunset time.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: remindersState.sabbathEnabled,
                    activeTrackColor: theme.primaryColor,
                    onChanged: (val) {
                      notifier.toggleSabbath(val);
                      if (val && remindersState.sabbathLocationName == null) {
                        _showLocationPicker(context, notifier);
                      }
                    },
                  ),
                  if (remindersState.sabbathEnabled)
                    ListTile(
                      title: const Text('Location'),
                      subtitle: Text(remindersState.sabbathLocationName ?? 'Not set (Tap to set)'),
                      trailing: const Icon(Icons.edit_location_alt_rounded),
                      onTap: () => _showLocationPicker(context, notifier),
                    ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(
                      'Daily Reading Reminder',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'A daily nudge to spend time in the Word.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: remindersState.dailyEnabled,
                    activeTrackColor: theme.primaryColor,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.toggleDaily(val);
                    },
                  ),
                  if (remindersState.dailyEnabled)
                    ListTile(
                      title: const Text('Time'),
                      subtitle: Text('${remindersState.dailyHour.toString().padLeft(2, '0')}:${remindersState.dailyMinute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.access_time_rounded),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: remindersState.dailyHour, minute: remindersState.dailyMinute),
                        );
                        if (time != null) {
                          notifier.setDailyTime(time.hour, time.minute);
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(
                      'Custom Weekly Reminder',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Set a specific day and time each week for deeper study.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: remindersState.customWeeklyEnabled,
                    activeTrackColor: theme.primaryColor,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.toggleCustomWeekly(val);
                    },
                  ),
                  if (remindersState.customWeeklyEnabled)
                    ListTile(
                      title: const Text('Day & Time'),
                      subtitle: Text('${_weekdayName(remindersState.customWeeklyDay)} at ${remindersState.customWeeklyHour.toString().padLeft(2, '0')}:${remindersState.customWeeklyMinute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () async {
                        int? selectedDay = await showDialog<int>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Choose Day'),
                            children: [
                              for (int i = 1; i <= 7; i++)
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(ctx, i),
                                  child: Text(_weekdayName(i)),
                                ),
                            ],
                          ),
                        );
                        if (selectedDay != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: remindersState.customWeeklyHour, minute: remindersState.customWeeklyMinute),
                          );
                          if (time != null) {
                            notifier.setCustomWeeklyTime(selectedDay, time.hour, time.minute);
                          }
                        }
                      },
                    ),
                ],
              );
            }),
          ]),

          _buildSection(context, 'Advanced', [
            Consumer(builder: (context, ref, _) {
              final depth = ref.watch(bibleNavSettingsProvider.select((s) => s.depth));
              return AnimatedSegmentedTile<NavigationDepth>(
                title: 'Navigation Steps',
                subtitle: 'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.',
                selectedValue: depth,
                options: const [
                  MapEntry(NavigationDepth.twoPart, '2-step'),
                  MapEntry(NavigationDepth.threePart, '3-step'),
                  MapEntry(NavigationDepth.fourPart, '4-step'),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(bibleNavSettingsProvider.notifier).setDepth(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final swipeDown = ref.watch(bibleNavSettingsProvider.select((s) => s.swipeDownToNav));
              return SwitchListTile(
                title: Text(
                  'Swipe Down to Open Navigation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Pull down at the top of a chapter to quickly open the Book/Chapter selector.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: swipeDown,
                activeTrackColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(bibleNavSettingsProvider.notifier).setSwipeDown(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final autoClose = ref.watch(bibleNavSettingsProvider.select((s) => s.autoCloseOnFinalSelection));
              return SwitchListTile(
                title: const Text('Auto-close sheet on final selection'),
                subtitle: const Text('Automatically dismiss the picker after the last step'),
                value: autoClose,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  ref.read(bibleNavSettingsProvider.notifier).setAutoClose(value);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final autoOpen = ref.watch(searchSettingsProvider.select((s) => s.autoOpenSingleSearchResult));
              return SwitchListTile(
                title: const Text('Auto-open single search result'),
                subtitle: const Text('Automatically navigate when a search returns exactly one result'),
                value: autoOpen,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  ref.read(searchSettingsProvider.notifier).toggleAutoOpen(value);
                },
              );
            }),
          ]),

          _buildSection(context, 'Data & Backup', [
            Consumer(builder: (context, ref, _) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text('Back up my data'),
                    subtitle: const Text('Export notes, highlights, and settings'),
                    onTap: () => BackupService.exportData(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('Restore from backup'),
                    subtitle: const Text('Import your data from a backup JSON'),
                    onTap: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Restore from Backup'),
                          content: TextField(
                            controller: controller,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Paste your backup JSON here...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final text = controller.text.trim();
                                Navigator.of(ctx).pop();
                                if (text.isNotEmpty) {
                                  BackupService.importData(context, ref, text);
                                }
                              },
                              child: const Text('Restore'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ]),

          _buildSection(context, 'System', [
            Consumer(builder: (context, ref, _) {
              return ListTile(
                leading: Icon(Icons.restore_rounded, color: Theme.of(context).colorScheme.error),
                title: Text('Reset to Default', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                subtitle: const Text('Restore original app settings (content is kept)'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset settings?'),
                      content: const Text('Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
                            await ref.read(typographyProvider.notifier).setFontFamily('Lexend');
                            await ref.read(typographyProvider.notifier).setFontSize(18.0);
                            
                            await ref.read(readSettingsProvider.notifier).setReadingViewMode(ReadingViewMode.immersive);
                            await ref.read(readSettingsProvider.notifier).setBackgroundGlowStyle(BackgroundGlowStyle.top);
                            await ref.read(readSettingsProvider.notifier).setVerseActionStyle(VerseActionStyle.classic);
                            await ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(2);
                            await ref.read(readSettingsProvider.notifier).setManualNavHidden(false);
                            
                              await ref.read(bibleNavSettingsProvider.notifier).setSwipeDown(true);
                              
                              ref.read(hintsProvider.notifier).resetHints();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings reset to default.')));
                            }
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ], titleColor: Theme.of(context).colorScheme.error),
          
          _buildSection(context, 'ABOUT', [
            Consumer(builder: (context, ref, _) {
              final packageInfoAsync = ref.watch(packageInfoProvider);
              return ListTile(
                title: const Text('Version'),
                trailing: packageInfoAsync.when(
                  data: (info) => Text(info.version, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const Text('Unknown'),
                ),
              );
            }),
            ListTile(
              title: const Text('Send Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () async {
                final uri = Uri.parse('mailto:placeholder@example.com?subject=The Blessed Bible Feedback');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
              },
            ),
            const ListTile(
              title: Text('Bible Translations'),
              subtitle: Text(
                'Most translations (KJV, WEB, Spanish RV1909, French LSG, German Luther, Italian Diodati, Romanian BTF, Russian Synodal, Chinese CUV, Arabic Van Dyck, Korean 1910, Dutch 1917, Ukrainian Kulish) are in the Public Domain.\n\n'
                'Creative Commons:\n'
                '• Swahili ULB & Tagalog ULB (CC BY-SA 4.0)\n'
                '• Portuguese Bíblia Livre (CC BY 4.0)\n'
                '• Hindi Indian Revised Version (CC BY-SA 4.0)'
              ),
            ),
          ]),
          
          const SizedBox(height: 100), // Bottom padding to clear nav bar and FAB
        ],
      ),
      ),
    );
  }


  Widget _buildSection(BuildContext context, String title, List<Widget> children, {Color? titleColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                    color: titleColor ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const Divider(height: 1, indent: 16),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _weekdayName(int day) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (day >= 1 && day <= 7) return names[day - 1];
    return 'Unknown';
  }

  void _showLocationPicker(BuildContext context, RemindersNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set Location for Sunset', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulated GPS lock
                  notifier.setSabbathLocation('Current Location (GPS)', 34.0522, -118.2437);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Use my current location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('OR select a major city')),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    _cityTile(ctx, notifier, 'New York, USA', 40.7128, -74.0060),
                    _cityTile(ctx, notifier, 'London, UK', 51.5074, -0.1278),
                    _cityTile(ctx, notifier, 'Sydney, Australia', -33.8688, 151.2093),
                    _cityTile(ctx, notifier, 'Tokyo, Japan', 35.6762, 139.6503),
                    _cityTile(ctx, notifier, 'Johannesburg, SA', -26.2041, 28.0473),
                    _cityTile(ctx, notifier, 'São Paulo, Brazil', -23.5505, -46.6333),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _cityTile(BuildContext context, RemindersNotifier notifier, String name, double lat, double lng) {
    return ListTile(
      title: Text(name),
      onTap: () {
        notifier.setSabbathLocation(name, lat, lng);
        Navigator.pop(context);
      },
    );
  }
}
