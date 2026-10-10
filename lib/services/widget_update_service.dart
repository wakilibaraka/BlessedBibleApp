import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../state/home_provider.dart';
import '../state/streak_provider.dart';
import '../state/votd_tracker_provider.dart';
import '../state/wotd_provider.dart';
import '../state/widget_settings_provider.dart';
import 'dart:async';

final widgetUpdateServiceProvider = Provider<WidgetUpdateService>((ref) {
  final service = WidgetUpdateService(ref);
  return service;
});

class WidgetUpdateService {
  final Ref _ref;
  static const String appGroupId =
      'group.com.yourdomain.blessedbible'; // iOS App Group ID

  // Widget Names
  static const String votdWidgetName =
      'VotdWidgetProvider'; // Android class name
  static const String streakWidgetName = 'StreakWidgetProvider';

  WidgetUpdateService(this._ref) {
    _init();
  }

  Future<void> _init() async {
    // Set iOS App Group
    await HomeWidget.setAppGroupId(appGroupId);

    // Initial sync
    unawaited(syncAllWidgets());

    // Listen to HomeProvider for VOTD
    _ref.listen(homeProvider, (previous, next) {
      final votd = next.verseOfTheDay;
      HomeWidget.saveWidgetData<String>('votd_reference', votd.reference);
      HomeWidget.saveWidgetData<String>('votd_text', votd.text);
      HomeWidget.updateWidget(name: votdWidgetName, iOSName: 'VotdWidget');
    });

    // Listen to StreakProvider
    _ref.listen(streakProvider, (previous, next) {
      HomeWidget.saveWidgetData<int>('streak_count', next.count);
      HomeWidget.updateWidget(name: streakWidgetName, iOSName: 'StreakWidget');
    });

    // Listen to VOTD Tracker (to see if today is read)
    _ref.listen(votdTrackerProvider, (previous, next) {
      final isLit = next.contains(_formatDate(DateTime.now()));
      HomeWidget.saveWidgetData<bool>('streak_is_lit', isLit);
      HomeWidget.updateWidget(name: streakWidgetName, iOSName: 'StreakWidget');
    });

    // Listen to Word of the Day (WOTD)
    _ref.listen(wordOfTheDayProvider, (previous, next) {
      next.whenData((wotd) {
        if (wotd != null) {
          HomeWidget.saveWidgetData<String>('wotd_word', wotd.word);
          HomeWidget.saveWidgetData<String>('wotd_snippet', wotd.snippet);
          HomeWidget.updateWidget(
              name: streakWidgetName, iOSName: 'StreakWidget');
        }
      });
    });

    // Listen to Widget Customization Settings
    _ref.listen(widgetSettingsProvider, (previous, next) {
      syncAllWidgets();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Pushes all current state data and visual customizations to native widget storage
  Future<void> syncAllWidgets() async {
    final settings = _ref.read(widgetSettingsProvider);
    final homeData = _ref.read(homeProvider);
    final streak = _ref.read(streakProvider);
    final votdTracker = _ref.read(votdTrackerProvider);
    final wotdAsync = _ref.read(wordOfTheDayProvider);

    // 1. Save customization settings
    await HomeWidget.saveWidgetData<String>(
        'widget_bg_style', settings.backgroundStyle.id);
    await HomeWidget.saveWidgetData<String>(
        'widget_text_mode', settings.textMode.id);

    // 2. Save VOTD data
    final votd = homeData.verseOfTheDay;
    await HomeWidget.saveWidgetData<String>('votd_reference', votd.reference);
    await HomeWidget.saveWidgetData<String>('votd_text', votd.text);

    // 3. Save Streak data
    await HomeWidget.saveWidgetData<int>('streak_count', streak.count);
    final isLit = votdTracker.contains(_formatDate(DateTime.now()));
    await HomeWidget.saveWidgetData<bool>('streak_is_lit', isLit);

    // 4. Save Word of the Day data
    final wotd = wotdAsync.value;
    if (wotd != null) {
      await HomeWidget.saveWidgetData<String>('wotd_word', wotd.word);
      await HomeWidget.saveWidgetData<String>('wotd_snippet', wotd.snippet);
    } else {
      await HomeWidget.saveWidgetData<String>('wotd_word', 'Grace (Charis)');
      await HomeWidget.saveWidgetData<String>(
        'wotd_snippet',
        'The unmerited favor and divine love of God bestowed upon humanity.',
      );
    }

    // 5. Trigger Native Widget Renders
    await HomeWidget.updateWidget(
      name: votdWidgetName,
      iOSName: 'VotdWidget',
    );
    await HomeWidget.updateWidget(
      name: streakWidgetName,
      iOSName: 'StreakWidget',
    );
  }
}
