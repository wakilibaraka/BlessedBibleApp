import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/search_engine.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/animated_background.dart';
import '../widgets/shared_app_bar.dart';

class ReadingPlanBrowser extends ConsumerStatefulWidget {
  const ReadingPlanBrowser({super.key});

  @override
  ConsumerState<ReadingPlanBrowser> createState() => _ReadingPlanBrowserState();
}

class _ReadingPlanBrowserState extends ConsumerState<ReadingPlanBrowser> {
  final Set<int> _expandedDays = {};

  String _formatDayTitle(int dayNum, List<PlanChapter> chapters) {
    if (chapters.isEmpty) return 'Day $dayNum';
    Map<String, List<int>> groups = {};
    for (var c in chapters) {
      groups.putIfAbsent(c.bookName, () => []).add(c.chapterNum);
    }
    List<String> parts = [];
    for (var entry in groups.entries) {
      parts.add('${entry.key} ${entry.value.join(", ")}');
    }
    return 'Day $dayNum (${parts.join("; ")})';
  }

  void _openReading(String reading, int planDay, BuildContext context, WidgetRef ref) {
    final match = RegExp(r'^(\d?\s*[a-zA-Z\s]+)(?:\s+(\d+))?').firstMatch(reading);
    if (match != null) {
      String bookName = match.group(1)!.trim();
      if (bookName.toLowerCase() == 'song of solomon') {
        bookName = 'Song of Solomon';
      }
      int chapterNum = 1;
      if (match.group(2) != null) {
        chapterNum = int.tryParse(match.group(2)!) ?? 1;
      }
      
      final flatChapters = ref.read(flatChaptersProvider);
      final fc = flatChapters.where((c) => c.book.name.toLowerCase() == bookName.toLowerCase() || c.book.abbreviation.toLowerCase() == bookName.toLowerCase()).toList();
      
      if (fc.isNotEmpty) {
        final chapterMatch = fc.where((c) => c.chapter.number == chapterNum).toList();
        if (chapterMatch.isNotEmpty) {
          final readLoc = ref.read(readLocationProvider.notifier);
          readLoc.updateLocation(bookAbbrev: chapterMatch.first.book.abbreviation, chapter: chapterNum, verse: 1);
          ref.read(navProvider.notifier).setIndex(1);
          ref.read(activePlanContextProvider.notifier).setContext(planDay);
          Navigator.of(context).pop(); // Close the browser and go to Read
        }
      }
    }
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('Search Plan'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'e.g. Isaiah 47, The Ten Plagues',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                _handleSearch(context, ref, query);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final query = textController.text.trim();
                if (query.isNotEmpty) {
                  _handleSearch(context, ref, query);
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSearch(BuildContext context, WidgetRef ref, String query) async {
    Navigator.of(context).pop(); // Close dialog immediately
    
    final planProvider = ref.read(readingPlanProvider.notifier);
    
    // Fallback simple book jump
    if (planProvider.jumpToBook(query)) return;
    
    // Otherwise use SearchEngine
    final engine = ref.read(searchEngineProvider);
    final results = await engine.search(query, includeCommentary: false, includeNotes: false);
    
    if (results.isNotEmpty) {
      final first = results.first;
      final bookName = first.metadata['book'] as String?;
      final chapterNum = first.metadata['chapter'] as int?;
      
      if (bookName != null && chapterNum != null) {
        final foundDay = planProvider.findDayForPassage(bookName, chapterNum);
        if (foundDay != null) {
          planProvider.jumpToDay(foundDay);
          if (context.mounted) {
            _showReadOrStartDialog(context, ref, first.title, foundDay);
          }
          return;
        }
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passage '$query' not found in plan.")),
      );
    }
  }

  void _showReadOrStartDialog(BuildContext context, WidgetRef ref, String readingTitle, int dayContext) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Day $dayContext: $readingTitle'),
              subtitle: const Text('What would you like to do?'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.menu_book_rounded, color: Theme.of(context).primaryColor),
              title: const Text('Read passage'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openReading(readingTitle, dayContext, context, ref);
              },
            ),
            ListTile(
              leading: Icon(Icons.fast_forward_rounded, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Start plan from here'),
              subtitle: const Text('Days before this will be marked complete.'),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(readingPlanProvider.notifier).startPlanFromDay(dayContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Plan updated to start from Day $dayContext")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showSettingsPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final theme = Theme.of(context);
            final planState = ref.watch(readingPlanProvider);
            final totalChapters = planState.planData.fold<int>(0, (sum, d) => sum + d.chapters.length);
            final completedCount = planState.completedChapters.length;
            final percent = totalChapters == 0 ? 0.0 : (completedCount / totalChapters * 100);

            return TexturedGlassContainer(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Reading Plan Settings',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Read the whole Bible in a year, in the order events happened. ~3-4 chapters a day.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Progress Summary
                    Text('Progress', style: theme.textTheme.titleSmall?.copyWith(color: theme.primaryColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Current Day: ${planState.currentDay}\nCompleted: $completedCount of $totalChapters chapters (${percent.toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Start Mode
                    Text('Start Mode', style: theme.textTheme.titleSmall?.copyWith(color: theme.primaryColor)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start today'),
                      subtitle: const Text('Day 1 is today; read the whole Bible over the next year.'),
                      leading: Radio<PlanStartMode>(
                        value: PlanStartMode.startToday,
                        groupValue: planState.startMode,
                        onChanged: (mode) {
                          if (mode != null) ref.read(readingPlanProvider.notifier).changeStartMode(mode);
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Follow calendar year'),
                      subtitle: const Text('Day 1 is January 1; today maps to that calendar date.'),
                      leading: Radio<PlanStartMode>(
                        value: PlanStartMode.calendarYear,
                        groupValue: planState.startMode,
                        onChanged: (mode) {
                          if (mode != null) ref.read(readingPlanProvider.notifier).changeStartMode(mode);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daily Reminder
                    Text('Daily Reminder', style: theme.textTheme.titleSmall?.copyWith(color: theme.primaryColor)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Remind me to read'),
                      subtitle: Text(planState.reminderEnabled 
                          ? 'Reminding at ${TimeOfDay(hour: planState.reminderTimeHour, minute: planState.reminderTimeMinute).format(context)}' 
                          : 'Get a daily nudge to read.'),
                      value: planState.reminderEnabled,
                      onChanged: (val) {
                        ref.read(readingPlanProvider.notifier).setReminder(val, planState.reminderTimeHour, planState.reminderTimeMinute);
                      },
                    ),
                    if (planState.reminderEnabled)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.access_time_rounded),
                          label: const Text('Change Time'),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: planState.reminderTimeHour, minute: planState.reminderTimeMinute),
                            );
                            if (time != null) {
                              ref.read(readingPlanProvider.notifier).setReminder(true, time.hour, time.minute);
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Jump To Day
                    Text('Navigation', style: theme.textTheme.titleSmall?.copyWith(color: theme.primaryColor)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Go to today\'s reading'),
                      subtitle: const Text('Skip to the reading for today.'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.pop(ctx);
                        int targetDay = 1;
                        if (planState.startMode == PlanStartMode.calendarYear) {
                          final now = DateTime.now();
                          targetDay = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
                        } else {
                          final now = DateTime.now();
                          targetDay = now.difference(planState.startDate).inDays + 1;
                        }
                        if (targetDay < 1) targetDay = 1;
                        if (targetDay > planState.planData.length) targetDay = planState.planData.length;
                        ref.read(readingPlanProvider.notifier).startPlanFromDay(targetDay);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Jump to specific day'),
                      subtitle: const Text('Skip to a specific day.'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showJumpDialog(context, ref);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Restart Plan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: theme.colorScheme.surface,
                            title: const Text('Restart Plan?'),
                            content: const Text('This clears your reading progress. Continue?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(readingPlanProvider.notifier).restartPlan();
                                  Navigator.pop(c);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Restart', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Restart Plan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showJumpDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Jump to Day'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter day number (1-365)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final day = int.tryParse(controller.text);
              if (day != null && day >= 1 && day <= 365) {
                ref.read(readingPlanProvider.notifier).startPlanFromDay(day);
                Navigator.pop(c);
              }
            },
            child: const Text('Jump'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final planState = ref.watch(readingPlanProvider);

    return Scaffold(
      extendBody: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chronological Plan',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Plan',
            onPressed: () {
              _showSearchDialog(context, ref);
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today_rounded, color: theme.primaryColor),
            tooltip: 'Plan Settings',
            onPressed: () {
              _showSettingsPanel(context, ref);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          if (planState.isLoading)
            Center(child: CircularProgressIndicator(color: theme.primaryColor))
          else if (planState.planData.isEmpty)
            Center(child: Text('Failed to load plan data.', style: theme.textTheme.bodyLarge))
          else
            ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
              itemCount: planState.planData.length,
              itemBuilder: (context, index) {
                final dayData = planState.planData[index];
                final isCompleted = planState.isDayComplete(dayData.day);
                final isActive = dayData.day == planState.currentDay;
                final isExpanded = _expandedDays.contains(dayData.day) || isActive;

                return BouncyEntrance(
                  delay: Duration(milliseconds: 50 * (index % 10)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TexturedGlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            if (_expandedDays.contains(dayData.day)) {
                              _expandedDays.remove(dayData.day);
                            } else {
                              _expandedDays.add(dayData.day);
                              if (!isActive) {
                                ref.read(readingPlanProvider.notifier).jumpToDay(dayData.day);
                              }
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isActive 
                                ? Border.all(color: theme.primaryColor, width: 2) 
                                : null,
                            color: isCompleted
                                ? theme.primaryColor.withValues(alpha: 0.05)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? theme.primaryColor
                                            : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: isCompleted
                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                            : Text(
                                                '${dayData.day}',
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_formatDayTitle(dayData.day, dayData.chapters)} · ${planState.getFormattedDateForDay(dayData.day)}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted ? theme.primaryColor : null,
                                            ),
                                          ),
                                          if (!isExpanded) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              dayData.chapters.map((c) => '${c.bookName} ${c.chapterNum}').join(' • '),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        color: isCompleted ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                      ),
                                      onPressed: () {
                                        if (isCompleted) {
                                          ref.read(readingPlanProvider.notifier).markDayIncomplete(dayData.day);
                                        } else {
                                          ref.read(readingPlanProvider.notifier).markDayComplete(dayData.day);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(left: 72.0, right: 16.0, bottom: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: dayData.chapters.map((chapter) {
                                      final isChapterDone = planState.completedChapters.contains(chapter.id);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: InkWell(
                                          onTap: () => _showReadOrStartDialog(context, ref, '${chapter.bookName} ${chapter.chapterNum}', dayData.day),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isChapterDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked, 
                                                  color: isChapterDone ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.3), 
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${chapter.bookName} ${chapter.chapterNum}',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: isChapterDone ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.primaryColor,
                                                      decoration: isChapterDone ? TextDecoration.lineThrough : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: planState.isPlanComplete ? null : FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(planState.currentDay == 0 ? Icons.play_arrow_rounded : Icons.fast_forward_rounded),
        label: Text(planState.currentDay == 0 ? 'Start Plan' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          final planState = ref.read(readingPlanProvider);
          if (planState.currentDay == 0 || planState.completedChapters.isEmpty) {
            ref.read(readingPlanProvider.notifier).startPlan();
          }
          final newPlanState = ref.read(readingPlanProvider);
          if (newPlanState.currentDay > 0 && newPlanState.currentDay <= newPlanState.planData.length) {
            final dayTarget = newPlanState.planData[newPlanState.currentDay - 1];
            PlanChapter? firstUnread;
            for (final c in dayTarget.chapters) {
              if (!newPlanState.completedChapters.contains(c.id)) {
                firstUnread = c;
                break;
              }
            }
            firstUnread ??= dayTarget.chapters.last;
            _openReading('${firstUnread.bookName} ${firstUnread.chapterNum}', newPlanState.currentDay, context, ref);
          }
        },
      ),
    );
  }
}
