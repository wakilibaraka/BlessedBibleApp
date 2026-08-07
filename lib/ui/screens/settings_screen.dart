import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../state/nav_provider.dart';
import '../../state/hints_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../services/backup_service.dart';
import '../../state/reminders_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_segmented_tile.dart';
import '../widgets/settings_pill_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';
import 'onboarding_screen.dart';
import '../../data/local_storage/preferences_service.dart';
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          if (_tabController.index == 0) {
            ref.read(navProvider.notifier).goBack();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: 'General'),
                  Tab(text: 'Navigation'),
                  Tab(text: 'Reminders'),
                  Tab(text: 'Info'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralPage(context, ref),
                    _buildNavigationPage(context, ref),
                    _buildRemindersPage(context, ref),
                    _buildInfoPage(context, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContainer(BuildContext context, List<Widget> children) {
    return ListView(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: MediaQuery.of(context).padding.bottom + 120,
      ),
      children: children,
    );
  }

  // --- Page 1: General ---
  Widget _buildGeneralPage(BuildContext context, WidgetRef ref) {
    return _buildPageContainer(context, [
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final defaultStartTab =
                ref.watch(readSettingsProvider.select((s) => s.defaultStartTab));
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
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final autoOpen = ref.watch(
                searchSettingsProvider.select((s) => s.autoOpenSingleSearchResult));
            return SwitchListTile(
              title: const Text('Auto-open single search result'),
              subtitle: const Text(
                  'Automatically navigate when a search returns exactly one result'),
              value: autoOpen,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(searchSettingsProvider.notifier).toggleAutoOpen(value);
              },
            );
          }),
        ],
      ),

      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final viewMode =
                ref.watch(readSettingsProvider.select((s) => s.readingViewMode));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('Immersive Reading', style: TextStyle(fontSize: 16)),
                ),
                _buildImmersiveTile(
                  context,
                  title: 'Anchored (Off)',
                  subtitle: 'Navigation remains visible at all times',
                  value: ReadingViewMode.pinned,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref.read(readSettingsProvider.notifier).setReadingViewMode(val);
                  },
                ),
                _buildImmersiveTile(
                  context,
                  title: 'Guided (Partial)',
                  subtitle:
                      'Auto-hides main navigation, but leaves the book & chapter pill',
                  value: ReadingViewMode.partial,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref.read(readSettingsProvider.notifier).setReadingViewMode(val);
                  },
                ),
                _buildImmersiveTile(
                  context,
                  title: 'Deep Waters (Full)',
                  subtitle: 'Total immersion. All menus hide when scrolling',
                  value: ReadingViewMode.full,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref.read(readSettingsProvider.notifier).setReadingViewMode(val);
                  },
                ),
              ],
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final isRedLetter =
                ref.watch(readSettingsProvider.select((s) => s.isRedLetterEnabled));
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
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final showNumbers =
                ref.watch(readSettingsProvider.select((s) => s.showVerseNumbers));
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
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final actionStyle =
                ref.watch(readSettingsProvider.select((s) => s.verseActionStyle));
            return AnimatedSegmentedTile<VerseActionStyle>(
              title: 'Verse Action Style',
              subtitle:
                  'Layout for highlight & action controls when a verse is selected',
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
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final primaryIndex = ref.watch(
                readSettingsProvider.select((s) => s.primaryHighlightColorIndex));
            final secondaryIndex = ref.watch(
                readSettingsProvider.select((s) => s.secondaryHighlightColorIndex));
            return Column(
              children: [
                _buildColorPicker(
                    context,
                    'Primary Highlight Color',
                    'Default color applied when tapping the Highlight action',
                    primaryIndex,
                    (i) => ref
                        .read(readSettingsProvider.notifier)
                        .setPrimaryHighlightColorIndex(i)),
                _buildColorPicker(
                    context,
                    'Secondary Highlight Color',
                    'Second color presented in quick action menus',
                    secondaryIndex,
                    (i) => ref
                        .read(readSettingsProvider.notifier)
                        .setSecondaryHighlightColorIndex(i)),
              ],
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final keepAwake =
                ref.watch(readSettingsProvider.select((s) => s.keepScreenAwake));
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
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final prefs = ref.watch(preferencesProvider);
            return StatefulBuilder(builder: (context, setState) {
              return SwitchListTile(
                title: const Text('Show reading tips'),
                subtitle: const Text(
                    'Show guided hints for reading actions like highlighting and swiping'),
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
            });
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final theme = Theme.of(context);
            return ListTile(
              title: const Text('Restart onboarding'),
              subtitle: const Text('Replay the first-time setup'),
              trailing: Icon(Icons.restart_alt_rounded, color: theme.primaryColor),
              onTap: () {
                HapticFeedback.selectionClick();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Restart onboarding?'),
                    content: const Text(
                        'This will replay the first-time setup. Your current theme, font, and translation stay unless you change them.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(preferencesProvider).setOnboardingComplete(false);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                            (route) => false,
                          );
                        },
                        child: Text('Restart', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    ]);
  }

  // --- Page 2: Reminders ---
  Widget _buildRemindersPage(BuildContext context, WidgetRef ref) {
    return _buildPageContainer(context, [
      Consumer(builder: (context, ref, _) {
        final remindersState = ref.watch(remindersProvider);
        final notifier = ref.read(remindersProvider.notifier);
        final theme = Theme.of(context);
        return Column(
          children: [
            SettingsPillCard(
              children: [
                SwitchListTile(
                  title: Text(
                    'Friday Sunset Reminder',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                if (remindersState.sabbathEnabled) ...[
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Location'),
                    subtitle: Text(
                        remindersState.sabbathLocationName ?? 'Not set (Tap to set)'),
                    trailing: const Icon(Icons.edit_location_alt_rounded),
                    onTap: () => _showLocationPicker(context, notifier),
                  ),
                ]
              ],
            ),
            SettingsPillCard(
              children: [
                SwitchListTile(
                  title: Text(
                    'Daily Reading Reminder',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                if (remindersState.dailyEnabled) ...[
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(
                        '${remindersState.dailyHour.toString().padLeft(2, '0')}:${remindersState.dailyMinute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time_rounded),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: remindersState.dailyHour,
                            minute: remindersState.dailyMinute),
                      );
                      if (time != null) {
                        notifier.setDailyTime(time.hour, time.minute);
                      }
                    },
                  ),
                ]
              ],
            ),
            SettingsPillCard(
              children: [
                SwitchListTile(
                  title: Text(
                    'Custom Weekly Reminder',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                if (remindersState.customWeeklyEnabled) ...[
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Day & Time'),
                    subtitle: Text(
                        '${_weekdayName(remindersState.customWeeklyDay)} at ${remindersState.customWeeklyHour.toString().padLeft(2, '0')}:${remindersState.customWeeklyMinute.toString().padLeft(2, '0')}'),
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
                          initialTime: TimeOfDay(
                              hour: remindersState.customWeeklyHour,
                              minute: remindersState.customWeeklyMinute),
                        );
                        if (time != null) {
                          notifier.setCustomWeeklyTime(
                              selectedDay, time.hour, time.minute);
                        }
                      }
                    },
                  ),
                ]
              ],
            ),
          ],
        );
      }),
    ]);
  }

  // --- Page 3: Navigation ---
  Widget _buildNavigationPage(BuildContext context, WidgetRef ref) {
    return _buildPageContainer(context, [
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final depth =
                ref.watch(bibleNavSettingsProvider.select((s) => s.depth));
            return AnimatedSegmentedTile<NavigationDepth>(
              title: 'Navigation Steps',
              subtitle:
                  'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.',
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
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final swipeDown =
                ref.watch(bibleNavSettingsProvider.select((s) => s.swipeDownToNav));
            return SwitchListTile(
              title: Text(
                'Swipe Down to Open Navigation',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
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
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final autoClose = ref.watch(
                bibleNavSettingsProvider.select((s) => s.autoCloseOnFinalSelection));
            return SwitchListTile(
              title: const Text('Auto-close sheet on final selection'),
              subtitle:
                  const Text('Automatically dismiss the picker after the last step'),
              value: autoClose,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(bibleNavSettingsProvider.notifier).setAutoClose(value);
              },
            );
          }),
        ],
      ),
    ]);
  }

  // --- Page 4: Info ---
  Widget _buildInfoPage(BuildContext context, WidgetRef ref) {
    return _buildPageContainer(context, [
      SettingsPillCard(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file_rounded),
            title: const Text('Back up my data'),
            subtitle: const Text('Export notes, highlights, and settings'),
            onTap: () => BackupService.exportData(context, ref),
          ),
          const Divider(height: 1, indent: 16),
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
          const Divider(height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded),
            title: const Text('Clear cache/downloaded data'),
            subtitle: const Text('Free up space by removing cached files'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not yet implemented')),
              );
            },
          ),
        ],
      ),
      SettingsPillCard(
        children: [
          ListTile(
            leading: Icon(Icons.restore_rounded,
                color: Theme.of(context).colorScheme.error),
            title: Text('Reset to Default',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: const Text('Restore original app settings (content is kept)'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset settings?'),
                  content: const Text(
                      'Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.light);
                        await ref
                            .read(typographyProvider.notifier)
                            .setFontFamily('Lexend');
                        await ref
                            .read(typographyProvider.notifier)
                            .setFontSize(18.0);
                        await ref
                            .read(readSettingsProvider.notifier)
                            .setReadingViewMode(ReadingViewMode.full);
                        await ref
                            .read(readSettingsProvider.notifier)
                            .setBackgroundGlowStyle(BackgroundGlowStyle.top);
                        await ref
                            .read(readSettingsProvider.notifier)
                            .setVerseActionStyle(VerseActionStyle.classic);
                        await ref
                            .read(readSettingsProvider.notifier)
                            .setActiveHighlightColorIndex(2);
                        await ref
                            .read(readSettingsProvider.notifier)
                            .setManualNavHidden(false);
                        await ref
                            .read(bibleNavSettingsProvider.notifier)
                            .setSwipeDown(true);

                        ref.read(hintsProvider.notifier).resetHints();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Settings reset to default.')));
                        }
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final packageInfoAsync = ref.watch(packageInfoProvider);
            return ListTile(
              title: const Text('Version'),
              trailing: packageInfoAsync.when(
                data: (info) => Text(info.version,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6))),
                loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('Unknown'),
              ),
            );
          }),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () async {
              final uri = Uri.parse(
                  'mailto:placeholder@example.com?subject=The Blessed Bible Feedback');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          const Divider(height: 1, indent: 16),
          const ListTile(
            title: Text('Bible Translations'),
            subtitle: Text(
                'Most translations (KJV, WEB, Spanish RV1909, French LSG, German Luther, Italian Diodati, Romanian BTF, Russian Synodal, Chinese CUV, Arabic Van Dyck, Korean 1910, Dutch 1917, Ukrainian Kulish) are in the Public Domain.\n\n'
                'Creative Commons:\n'
                '• Swahili ULB & Tagalog ULB (CC BY-SA 4.0)\n'
                '• Portuguese Bíblia Livre (CC BY 4.0)\n'
                '• Hindi Indian Revised Version (CC BY-SA 4.0)'),
          ),
        ],
      ),
    ]);
  }

  // --- Helper methods ---

  Widget _buildColorPicker(BuildContext context, String title, String subtitle,
      int selectedIndex, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
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
                  color = AppColors.getRenderedHighlightColor(
                      highlightPaletteSwatches[i],
                      Theme.of(context).brightness,
                      Theme.of(context).scaffoldBackgroundColor);
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
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : (i == -1
                                      ? Theme.of(context).dividerColor
                                      : Colors.black.withValues(alpha: 0.2)),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: (isSelected || i == -1)
                                ? null
                                : [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1)
                                  ],
                          ),
                          child: i == -1
                              ? Icon(Icons.question_mark_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface)
                              : (isSelected
                                  ? Icon(Icons.check,
                                      size: 16,
                                      color: Theme.of(context).primaryColor)
                                  : null),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i == -1 ? 'Ask' : highlightPaletteNames[i],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
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

  String _weekdayName(int day) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    if (day >= 1 && day <= 7) return names[day - 1];
    return 'Unknown';
  }

  void _showLocationPicker(BuildContext context, RemindersNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set Location for Sunset',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulated GPS lock
                  notifier.setSabbathLocation(
                      'Current Location (GPS)', 34.0522, -118.2437);
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
                    _cityTile(
                        ctx, notifier, 'Sydney, Australia', -33.8688, 151.2093),
                    _cityTile(ctx, notifier, 'Tokyo, Japan', 35.6762, 139.6503),
                    _cityTile(ctx, notifier, 'Johannesburg, SA', -26.2041, 28.0473),
                    _cityTile(
                        ctx, notifier, 'São Paulo, Brazil', -23.5505, -46.6333),
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

  Widget _cityTile(BuildContext context, RemindersNotifier notifier, String name,
      double lat, double lng) {
    return ListTile(
      title: Text(name),
      onTap: () {
        notifier.setSabbathLocation(name, lat, lng);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImmersiveTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ReadingViewMode value,
    required ReadingViewMode groupValue,
    required ValueChanged<ReadingViewMode> onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? theme.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.primaryColor)
            else
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
