import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/animated_background.dart';

class ReadingPlanBrowser extends ConsumerStatefulWidget {
  const ReadingPlanBrowser({super.key});

  @override
  ConsumerState<ReadingPlanBrowser> createState() => _ReadingPlanBrowserState();
}

class _ReadingPlanBrowserState extends ConsumerState<ReadingPlanBrowser> {
  final Set<int> _expandedDays = {};

  void _openReading(String reading, BuildContext context) {
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
          Navigator.of(context).pop(); // Close the browser and go to Read
        }
      }
    }
  }

  void _showJumpToBookDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('Jump to Book'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'e.g. Numbers, Luke',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                final found = ref.read(readingPlanProvider.notifier).jumpToBook(query);
                Navigator.of(context).pop();
                if (!found) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Book '$query' not found in plan.")),
                  );
                }
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
                final query = textController.text;
                if (query.isNotEmpty) {
                  final found = ref.read(readingPlanProvider.notifier).jumpToBook(query);
                  Navigator.of(context).pop();
                  if (!found) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Book '$query' not found in plan.")),
                    );
                  }
                }
              },
              child: const Text('Jump'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final planState = ref.watch(readingPlanProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chronological Plan',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.primaryColor),
            tooltip: 'Search Plan',
            onPressed: () {
              _showJumpToBookDialog(context, ref);
            },
          ),
          PopupMenuButton<PlanStartMode>(
            icon: Icon(Icons.calendar_today_rounded, color: theme.primaryColor),
            tooltip: 'Plan Settings',
            onSelected: (mode) {
              ref.read(readingPlanProvider.notifier).changeStartMode(mode);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PlanStartMode>>[
              PopupMenuItem<PlanStartMode>(
                value: PlanStartMode.startToday,
                child: Row(
                  children: [
                    Icon(
                      planState.startMode == PlanStartMode.startToday ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Start Today'),
                  ],
                ),
              ),
              PopupMenuItem<PlanStartMode>(
                value: PlanStartMode.calendarYear,
                child: Row(
                  children: [
                    Icon(
                      planState.startMode == PlanStartMode.calendarYear ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Follow Calendar Year'),
                  ],
                ),
              ),
            ],
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
                final isCompleted = planState.completedDays.contains(dayData.day);
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
                                            'Day ${dayData.day} · ${planState.getFormattedDateForDay(dayData.day)}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted ? theme.primaryColor : null,
                                            ),
                                          ),
                                          if (!isExpanded) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              dayData.readings.join(' • '),
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
                                    children: dayData.readings.map((reading) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: InkWell(
                                          onTap: () => _openReading(reading, context),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.menu_book_rounded, color: theme.primaryColor, size: 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    reading,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.primaryColor,
                                                      decoration: TextDecoration.underline,
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
    );
  }
}
