import '../../l10n/l10n.dart';
import '../widgets/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../state/nav_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/hints_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/translation_provider.dart';
import '../sheets/translation_picker_sheet.dart';
import '../../state/read_settings_provider.dart';
import '../../state/bbe_substitutions_provider.dart';
import '../../services/firebase_setup.dart';
import '../../services/backup_service.dart';
import '../../services/bible_database_service.dart';
import '../../state/reminders_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_segmented_tile.dart';
import '../widgets/settings_pill_card.dart';
import '../sheets/appearance_settings_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'credits_screen.dart';
import 'privacy_policy_screen.dart';
import 'storage_screen.dart';
import 'onboarding_screen.dart';
import '../../data/local_storage/preferences_service.dart';
import '../sheets/widget_settings_sheet.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
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
          title: Text(context.l10n.settingsTitle),
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
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                tabs: [
                  Tab(text: context.l10n.settingsTabGeneral),
                  Tab(text: context.l10n.settingsTabNavigation),
                  Tab(text: context.l10n.settingsTabReminders),
                  Tab(text: context.l10n.settingsTabInfo),
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
      const SettingsPillCard(children: [LanguageSettingsTile()]),
      SettingsPillCard(
        children: [
          ListTile(
            leading: Icon(
              Icons.widgets_rounded,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(context.l10n.settingsWidgetsTitle),
            subtitle: Text(context.l10n.settingsWidgetsSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              WidgetSettingsSheet.show(context);
            },
          ),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final defaultStartTab = ref
                .watch(readSettingsProvider.select((s) => s.defaultStartTab));
            return AnimatedSegmentedTile<int>(
              title: context.l10n.settingsStartPageTitle,
              subtitle: context.l10n.settingsStartPageSubtitle,
              selectedValue: defaultStartTab,
              options: [
                MapEntry(0, context.l10n.settingsPageHome),
                MapEntry(1, context.l10n.settingsPageRead),
                MapEntry(3, context.l10n.settingsPageStudy),
                MapEntry(2, context.l10n.settingsPageSearch),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setDefaultStartTab(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final viewMode = ref
                .watch(readSettingsProvider.select((s) => s.readingViewMode));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(context.l10n.settingsImmersiveReading,
                      style: TextStyle(fontSize: 16)),
                ),
                _buildImmersiveTile(
                  context,
                  title: context.l10n.settingsImmersiveOffTitle,
                  subtitle: context.l10n.settingsImmersiveOffSubtitle,
                  value: ReadingViewMode.pinned,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setReadingViewMode(val);
                  },
                ),
                _buildImmersiveTile(
                  context,
                  title: context.l10n.settingsImmersivePartialTitle,
                  subtitle: context.l10n.settingsImmersivePartialSubtitle,
                  value: ReadingViewMode.partial,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setReadingViewMode(val);
                  },
                ),
                _buildImmersiveTile(
                  context,
                  title: context.l10n.settingsImmersiveFullTitle,
                  subtitle: context.l10n.settingsImmersiveFullSubtitle,
                  value: ReadingViewMode.full,
                  groupValue: viewMode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setReadingViewMode(val);
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
            final showStrongs = ref.watch(
                readSettingsProvider.select((s) => s.showStrongsNumbers));
            final strongsStyle = ref.watch(
                readSettingsProvider.select((s) => s.strongsIndicatorStyle));
            // Strong's numbers live in the downloadable "KJV with Strong's"
            // pack — without it the toggle has nothing to display. Only
            // claim "missing" once the list actually loads (no flash,
            // no duplicate error surface).
            final hasStrongsPack =
                ref.watch(availableTranslationsProvider).when(
                      data: (list) =>
                          list.any((t) => t.translationId == 'kjv_strongs'),
                      loading: () => true,
                      error: (_, __) => true,
                    );

            return Column(
              children: [
                SwitchListTile(
                  title: Text(context.l10n.settingsShowStrongs),
                  subtitle: Text(context.l10n.settingsShowStrongsSubtitle),
                  value: showStrongs,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setShowStrongsNumbers(val);
                  },
                ),
                if (!hasStrongsPack)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.settingsStrongsPackRequired('7.7 MB'),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              useRootNavigator: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const TranslationPickerSheet(),
                            );
                          },
                          child: Text(context.l10n.settingsStrongsGetIt),
                        ),
                      ],
                    ),
                  ),
                if (showStrongs)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SegmentedButton<StrongsIndicatorStyle>(
                      segments: [
                        ButtonSegment(
                          value: StrongsIndicatorStyle.asterisk,
                          label:
                              Text(context.l10n.settingsStrongsMarkerAsterisk),
                        ),
                        ButtonSegment(
                          value: StrongsIndicatorStyle.chain,
                          label: Text(context.l10n.settingsStrongsMarkerChain),
                        ),
                        ButtonSegment(
                          value: StrongsIndicatorStyle.number,
                          label: Text(context.l10n.settingsStrongsMarkerNumber),
                        ),
                      ],
                      selected: {strongsStyle},
                      onSelectionChanged: (set) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(readSettingsProvider.notifier)
                            .setStrongsIndicatorStyle(set.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
              ],
            );
          }),
          Consumer(builder: (context, ref, _) {
            final wpm =
                ref.watch(readSettingsProvider.select((s) => s.readingWpm));
            return Column(
              children: [
                ListTile(
                  title: Text(context.l10n.settingsReadingSpeed),
                  subtitle: Text(context.l10n.settingsReadingSpeedSubtitle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 100,
                        label: Text(context.l10n.settingsSpeedRelaxed),
                      ),
                      ButtonSegment(
                        value: 130,
                        label: Text(context.l10n.settingsSpeedStandard),
                      ),
                      ButtonSegment(
                        value: 200,
                        label: Text(context.l10n.settingsSpeedBrisk),
                      ),
                    ],
                    selected: {wpm},
                    onSelectionChanged: (set) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(readSettingsProvider.notifier)
                          .setReadingWpm(set.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final isEnabled = ref.watch(readSettingsProvider
                .select((s) => s.dictionaryUnderlinesEnabled));
            return SwitchListTile(
              title: Text(context.l10n.settingsDictUnderlines),
              subtitle: Text(context.l10n.settingsDictUnderlinesSubtitle),
              value: isEnabled,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(readSettingsProvider.notifier)
                    .setDictionaryUnderlinesEnabled(val);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final scope = ref
                .watch(readSettingsProvider.select((s) => s.dictionaryScope));
            final isEnabled = ref.watch(readSettingsProvider
                .select((s) => s.dictionaryUnderlinesEnabled));

            if (!isEnabled) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(context.l10n.settingsUnderlineScope,
                      style: TextStyle(fontSize: 16)),
                ),
                _buildDictScopeTile(
                  context,
                  title: context.l10n.settingsScopeNamesTitle,
                  subtitle: context.l10n.settingsScopeNamesSubtitle,
                  value: DictionaryScope.term,
                  groupValue: scope,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setDictionaryScope(val);
                  },
                ),
                _buildDictScopeTile(
                  context,
                  title: context.l10n.settingsScopeTrickyTitle,
                  subtitle: context.l10n.settingsScopeTrickySubtitle,
                  value: DictionaryScope.termAndTricky,
                  groupValue: scope,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setDictionaryScope(val);
                  },
                ),
                _buildDictScopeTile(
                  context,
                  title: context.l10n.settingsScopeEverythingTitle,
                  subtitle: context.l10n.settingsScopeEverythingSubtitle,
                  value: DictionaryScope.everything,
                  groupValue: scope,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setDictionaryScope(val);
                  },
                ),
                _buildDictScopeTile(
                  context,
                  title: context.l10n.settingsScopeDifficultTitle,
                  subtitle: context.l10n.settingsScopeDifficultSubtitle,
                  value: DictionaryScope.difficult,
                  groupValue: scope,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setDictionaryScope(val);
                  },
                ),
                _buildDictScopeTile(
                  context,
                  title: context.l10n.settingsScopeDifficultNamesTitle,
                  subtitle: context.l10n.settingsScopeDifficultNamesSubtitle,
                  value: DictionaryScope.difficultAndNames,
                  groupValue: scope,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setDictionaryScope(val);
                  },
                ),
              ],
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final mode = ref.watch(
                readSettingsProvider.select((s) => s.nonKjvDictionaryMode));
            final isEnabled = ref.watch(readSettingsProvider
                .select((s) => s.dictionaryUnderlinesEnabled));

            if (!isEnabled) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(context.l10n.settingsOtherEnglishVersions,
                      style: TextStyle(fontSize: 16)),
                ),
                _buildRadioTile<NonKjvDictionaryMode>(
                  context,
                  title: context.l10n.settingsContestedOnlyTitle,
                  subtitle: context.l10n.settingsContestedOnlySubtitle,
                  value: NonKjvDictionaryMode.contestedOnly,
                  groupValue: mode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setNonKjvDictionaryMode(val);
                  },
                ),
                _buildRadioTile<NonKjvDictionaryMode>(
                  context,
                  title: context.l10n.settingsFollowScopeTitle,
                  subtitle: context.l10n.settingsFollowScopeSubtitle,
                  value: NonKjvDictionaryMode.followScope,
                  groupValue: mode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setNonKjvDictionaryMode(val);
                  },
                ),
                _buildRadioTile<NonKjvDictionaryMode>(
                  context,
                  title: context.l10n.settingsNoUnderlinesTitle,
                  subtitle: context.l10n.settingsNoUnderlinesSubtitle,
                  value: NonKjvDictionaryMode.off,
                  groupValue: mode,
                  onTap: (val) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(readSettingsProvider.notifier)
                        .setNonKjvDictionaryMode(val);
                  },
                ),
              ],
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final popupStyle =
                ref.watch(readSettingsProvider.select((s) => s.popupStyle));
            return AnimatedSegmentedTile<PopupStyle>(
              title: context.l10n.settingsPopupStyle,
              subtitle: context.l10n.settingsPopupStyleSubtitle,
              selectedValue: popupStyle,
              options: [
                MapEntry(
                    PopupStyle.floating, context.l10n.settingsPopupFloating),
                MapEntry(PopupStyle.bottomSheet,
                    context.l10n.settingsPopupBottomSheet),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setPopupStyle(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final syncLang = ref.watch(
                readSettingsProvider.select((s) => s.syncSavedItemsLanguage));
            return SwitchListTile(
              title: Text(context.l10n.settingsSavedInMyLanguage),
              subtitle: Text(context.l10n.settingsSavedInMyLanguageSubtitle),
              value: syncLang,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(readSettingsProvider.notifier)
                    .setSyncSavedItemsLanguage(val);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final showChips = ref.watch(
                readSettingsProvider.select((s) => s.showChipsOnSavedItems));
            return SwitchListTile(
              title: Text(context.l10n.settingsTranslationChips),
              subtitle: Text(context.l10n.settingsTranslationChipsSubtitle),
              value: showChips,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(readSettingsProvider.notifier)
                    .setShowChipsOnSavedItems(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final actionStyle = ref
                .watch(readSettingsProvider.select((s) => s.verseActionStyle));
            return AnimatedSegmentedTile<VerseActionStyle>(
              title: context.l10n.settingsVerseActionStyle,
              subtitle: context.l10n.settingsVerseActionStyleSubtitle,
              selectedValue: actionStyle,
              options: [
                MapEntry(
                    VerseActionStyle.classic, context.l10n.settingsActionSheet),
                MapEntry(VerseActionStyle.classicInline,
                    context.l10n.settingsActionClassic),
                MapEntry(VerseActionStyle.horizontal,
                    context.l10n.settingsActionMinimal),
                MapEntry(VerseActionStyle.raindrop,
                    context.l10n.settingsActionRaindrop),
                MapEntry(
                    VerseActionStyle.radial, context.l10n.settingsActionRadial),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(readSettingsProvider.notifier)
                    .setVerseActionStyle(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final keepAwake = ref
                .watch(readSettingsProvider.select((s) => s.keepScreenAwake));
            return SwitchListTile(
              title: Text(context.l10n.settingsKeepAwake),
              subtitle: Text(context.l10n.settingsKeepAwakeSubtitle),
              value: keepAwake,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setKeepScreenAwake(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final theme = Theme.of(context);
            return ListTile(
              title: Text(context.l10n.settingsRestartOnboarding),
              subtitle: Text(context.l10n.settingsRestartOnboardingSubtitle),
              trailing:
                  Icon(Icons.restart_alt_rounded, color: theme.primaryColor),
              onTap: () {
                HapticFeedback.selectionClick();
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title:
                        Text(context.l10n.settingsRestartOnboardingDialogTitle),
                    content:
                        Text(context.l10n.settingsRestartOnboardingDialogBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(context.l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref
                              .read(preferencesProvider)
                              .setOnboardingComplete(false);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                                builder: (_) => const OnboardingScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(context.l10n.settingsRestart,
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          ListTile(
            leading: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(context.l10n.settingsAppearanceText),
            subtitle: Text(context.l10n.settingsAppearanceTextSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              AppearanceSettingsSheet.show(context,
                  initialTab: AppearanceTab.typography);
            },
          ),
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
                    context.l10n.settingsSabbathTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.settingsSabbathSubtitle,
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
                    title: Text(context.l10n.settingsLocation),
                    subtitle: Text(remindersState.sabbathLocationName ??
                        context.l10n.settingsLocationNotSet),
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
                    context.l10n.settingsDailyReminderTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.settingsDailyReminderSubtitle,
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
                    title: Text(context.l10n.settingsTime),
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
                    context.l10n.settingsWeeklyReminderTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.settingsWeeklyReminderSubtitle,
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
                    title: Text(context.l10n.settingsDayAndTime),
                    subtitle: Text(context.l10n.settingsDayAtTime(
                        _weekdayName(context, remindersState.customWeeklyDay),
                        '${remindersState.customWeeklyHour.toString().padLeft(2, '0')}:${remindersState.customWeeklyMinute.toString().padLeft(2, '0')}')),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final int? selectedDay = await showDialog<int>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: Text(context.l10n.settingsChooseDay),
                          children: [
                            for (int i = 1; i <= 7; i++)
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(ctx, i),
                                child: Text(_weekdayName(context, i)),
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
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final prefs = ref.watch(preferencesProvider);
            return StatefulBuilder(builder: (context, setState) {
              return SwitchListTile(
                title: Text(context.l10n.settingsShowReadingTips),
                subtitle: Text(context.l10n.settingsShowReadingTipsSubtitle),
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
              title: context.l10n.settingsNavSteps,
              subtitle: context.l10n.settingsNavStepsSubtitle,
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
            final autoClose = ref.watch(bibleNavSettingsProvider
                .select((s) => s.autoCloseOnFinalSelection));
            return SwitchListTile(
              title: Text(context.l10n.settingsAutoClose),
              subtitle: Text(context.l10n.settingsAutoCloseSubtitle),
              value: autoClose,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(bibleNavSettingsProvider.notifier).setAutoClose(value);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Consumer(builder: (context, ref, _) {
            final selectorHeight =
                ref.watch(readSettingsProvider.select((s) => s.selectorHeight));
            return AnimatedSegmentedTile<SelectorHeight>(
              title: context.l10n.settingsSelectorHeight,
              subtitle: context.l10n.settingsSelectorHeightSubtitle,
              selectedValue: selectorHeight,
              options: [
                MapEntry(
                    SelectorHeight.quarter, context.l10n.settingsHeightHalf),
                MapEntry(SelectorHeight.half, '3/4'),
                MapEntry(SelectorHeight.full, context.l10n.settingsHeightFull),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setSelectorHeight(val);
              },
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(context.l10n.settingsPageSearch,
                style: TextStyle(fontSize: 16)),
          ),
          Consumer(builder: (context, ref, _) {
            final autoOpen = ref.watch(searchSettingsProvider
                .select((s) => s.autoOpenSingleSearchResult));
            return SwitchListTile(
              title: Text(context.l10n.settingsAutoOpenSingle),
              subtitle: Text(context.l10n.settingsAutoOpenSingleSubtitle),
              value: autoOpen,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(searchSettingsProvider.notifier).toggleAutoOpen(value);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final includeNotes = ref.watch(
                searchSettingsProvider.select((s) => s.includeNotesInSearch));
            return SwitchListTile(
              title: Text(context.l10n.settingsIncludeNotes),
              subtitle: Text(context.l10n.settingsIncludeNotesSubtitle),
              value: includeNotes,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(searchSettingsProvider.notifier)
                    .toggleIncludeNotes(value);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final matchWholeWords = ref
                .watch(searchSettingsProvider.select((s) => s.matchWholeWords));
            return SwitchListTile(
              title: Text(context.l10n.settingsWholeWords),
              subtitle: Text(context.l10n.settingsWholeWordsSubtitle),
              value: matchWholeWords,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(searchSettingsProvider.notifier)
                    .toggleMatchWholeWords(value);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final fuzzy =
                ref.watch(searchSettingsProvider.select((s) => s.fuzzySearch));
            return SwitchListTile(
              title: Text(context.l10n.settingsFuzzySearch),
              subtitle: Text(context.l10n.settingsFuzzySearchSubtitle),
              value: fuzzy,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(searchSettingsProvider.notifier)
                    .toggleFuzzySearch(value);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final defaultOt = ref
                .watch(searchSettingsProvider.select((s) => s.defaultSearchOt));
            final defaultNt = ref
                .watch(searchSettingsProvider.select((s) => s.defaultSearchNt));
            final defaultComm = ref.watch(searchSettingsProvider
                .select((s) => s.defaultSearchCommentary));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(context.l10n.settingsDefaultScopes,
                      style: TextStyle(fontSize: 14)),
                ),
                SwitchListTile(
                  title: Text(context.l10n.settingsOldTestament),
                  value: defaultOt,
                  dense: true,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(searchSettingsProvider.notifier)
                        .toggleDefaultOt(value);
                  },
                ),
                SwitchListTile(
                  title: Text(context.l10n.settingsNewTestament),
                  value: defaultNt,
                  dense: true,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(searchSettingsProvider.notifier)
                        .toggleDefaultNt(value);
                  },
                ),
                SwitchListTile(
                  title: Text(context.l10n.settingsCommentary),
                  value: defaultComm,
                  dense: true,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(searchSettingsProvider.notifier)
                        .toggleDefaultCommentary(value);
                  },
                ),
              ],
            );
          }),
        ],
      ),
      SettingsPillCard(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(context.l10n.settingsGestures,
                style: TextStyle(fontSize: 16)),
          ),
          Consumer(builder: (context, ref, _) {
            final pullDown = ref.watch(
                bibleNavSettingsProvider.select((s) => s.homePullDownEnabled));
            return SwitchListTile(
              title: Text(context.l10n.settingsPullDownHome),
              subtitle: Text(context.l10n.settingsPullDownHomeSubtitle),
              value: pullDown,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(bibleNavSettingsProvider.notifier)
                    .setHomePullDown(value);
              },
            );
          }),
          Consumer(builder: (context, ref, _) {
            final target = ref.watch(
                bibleNavSettingsProvider.select((s) => s.homePullDownTarget));
            return AnimatedSegmentedTile<HomePullDownTarget>(
              title: context.l10n.settingsPullDownOpens,
              subtitle: context.l10n.settingsPullDownOpensSubtitle,
              selectedValue: target,
              options: [
                MapEntry(HomePullDownTarget.appearance,
                    context.l10n.settingsAppearance),
                MapEntry(
                    HomePullDownTarget.settings, context.l10n.settingsTitle),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(bibleNavSettingsProvider.notifier)
                    .setHomePullDownTarget(val);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final swipeLeft = ref.watch(
                bibleNavSettingsProvider.select((s) => s.homeSwipeLeftEnabled));
            return SwitchListTile(
              title: Text(context.l10n.settingsSwipeLeftHome),
              subtitle: Text(context.l10n.settingsSwipeLeftHomeSubtitle),
              value: swipeLeft,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(bibleNavSettingsProvider.notifier)
                    .setHomeSwipeLeft(value);
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          Consumer(builder: (context, ref, _) {
            final fabLongPress = ref
                .watch(readSettingsProvider.select((s) => s.fabLongPressToNav));
            return SwitchListTile(
              title: Text(
                context.l10n.settingsLongPressNav,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                context.l10n.settingsLongPressNavSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: fabLongPress,
              activeTrackColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref
                    .read(readSettingsProvider.notifier)
                    .setFabLongPressToNav(val);
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
          Consumer(
            builder: (context, ref, _) {
              final subsCount =
                  ref.watch(bbeSubstitutionsProvider).value?.length ?? 94;
              return ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(context.l10n.settingsBbeNoteTitle),
                subtitle: Text(context.l10n.settingsBbeNoteBody(subsCount)),
                isThreeLine: true,
              );
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      SettingsPillCard(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file_rounded),
            title: Text(context.l10n.settingsBackup),
            subtitle: Text(context.l10n.settingsBackupSubtitle),
            onTap: () => BackupService.exportData(context, ref),
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: Text(context.l10n.settingsRestoreBackup),
            subtitle: Text(context.l10n.settingsRestoreBackupSubtitle),
            onTap: () {
              final controller = TextEditingController();
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.l10n.settingsRestoreBackupDialogTitle),
                  content: TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: context.l10n.settingsRestoreHint,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(context.l10n.commonCancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        Navigator.of(ctx).pop();
                        if (text.isNotEmpty) {
                          BackupService.importData(context, ref, text);
                        }
                      },
                      child: Text(context.l10n.settingsRestore),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded),
            title: Text(context.l10n.settingsClearCache),
            subtitle: Text(context.l10n.settingsClearCacheSubtitle),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.settingsNotImplemented)),
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
            title: Text(context.l10n.settingsResetSettings,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: Text(context.l10n.settingsResetSettingsSubtitle),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.l10n.settingsResetDialogTitle),
                  content: Text(context.l10n.settingsResetDialogBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(context.l10n.commonCancel)),
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.l10n.settingsResetDone)));
                        }
                      },
                      child: Text(context.l10n.settingsReset),
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
              title: Text(context.l10n.settingsVersion),
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
                error: (_, __) => Text(context.l10n.settingsUnknown),
              ),
            );
          }),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: Text(context.l10n.settingsStorage),
            subtitle: Text(context.l10n.settingsStorageSubtitle),
            trailing: FutureBuilder<int>(
              future: bibleDbService.contentBytesUsed(),
              builder: (context, snapshot) {
                final mb = (snapshot.data ?? 0) / (1024 * 1024);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.hasData ? '${mb.toStringAsFixed(1)} MB' : '…',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                );
              },
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StorageScreen()),
            ),
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: Text(context.l10n.settingsSendFeedback),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () async {
              final uri = Uri.parse(
                  'mailto:wakilibar@gmail.com?subject=The Blessed Bible Feedback');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const Divider(height: 1, indent: 16),
          StatefulBuilder(builder: (context, setTileState) {
            final prefs = ref.read(preferencesProvider);
            return SwitchListTile(
              title: Text(context.l10n.settingsCrashReports),
              subtitle: Text(context.l10n.settingsCrashReportsSubtitle),
              value: prefs.crashReportsEnabled,
              onChanged: (value) async {
                await prefs.setCrashReportsEnabled(value);
                await setCrashReportingEnabled(value);
                setTileState(() {});
              },
            );
          }),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: Text(context.l10n.settingsPrivacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          const Divider(height: 1, indent: 16),
          ListTile(
            title: Text(context.l10n.settingsCredits),
            subtitle: Text(context.l10n.settingsCreditsSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CreditsScreen()),
            ),
          ),
        ],
      ),
    ]);
  }

  // --- Helper methods ---

  String _weekdayName(BuildContext context, int day) {
    final l10n = context.l10n;
    final names = [
      l10n.settingsMonday,
      l10n.settingsTuesday,
      l10n.settingsWednesday,
      l10n.settingsThursday,
      l10n.settingsFriday,
      l10n.settingsSaturday,
      l10n.settingsSunday,
    ];
    if (day >= 1 && day <= 7) return names[day - 1];
    return l10n.settingsUnknown;
  }

  void _showLocationPicker(BuildContext context, RemindersNotifier notifier) {
    showModalBottomSheet<void>(
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
              Text(context.l10n.settingsSetSunsetLocation,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulated GPS lock
                  notifier.setSabbathLocation(
                      context.l10n.settingsCurrentLocationGps,
                      34.0522,
                      -118.2437);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.my_location),
                label: Text(context.l10n.settingsUseMyLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text(context.l10n.settingsOrSelectCity)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    _cityTile(
                        ctx, notifier, 'New York, USA', 40.7128, -74.0060),
                    _cityTile(ctx, notifier, 'London, UK', 51.5074, -0.1278),
                    _cityTile(
                        ctx, notifier, 'Sydney, Australia', -33.8688, 151.2093),
                    _cityTile(ctx, notifier, 'Tokyo, Japan', 35.6762, 139.6503),
                    _cityTile(
                        ctx, notifier, 'Johannesburg, SA', -26.2041, 28.0473),
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

  Widget _cityTile(BuildContext context, RemindersNotifier notifier,
      String name, double lat, double lng) {
    return ListTile(
      title: Text(name),
      onTap: () {
        notifier.setSabbathLocation(name, lat, lng);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDictScopeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required DictionaryScope value,
    required DictionaryScope groupValue,
    required ValueChanged<DictionaryScope> onTap,
  }) {
    return _buildRadioTile<DictionaryScope>(
      context,
      title: title,
      subtitle: subtitle,
      value: value,
      groupValue: groupValue,
      onTap: onTap,
    );
  }

  /// Generic radio row shared by dictionary scope, non-KJV mode, and
  /// word-lookup choice. Matches the existing dictionary tile visuals.
  Widget _buildRadioTile<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T> onTap,
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
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: theme.primaryColor, size: 20),
          ],
        ),
      ),
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
