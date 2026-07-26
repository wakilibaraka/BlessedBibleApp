import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/animated_background.dart';

class ReadingPlanBrowser extends ConsumerWidget {
  const ReadingPlanBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          PopupMenuButton<PlanStartMode>(
            icon: Icon(Icons.settings_rounded, color: theme.primaryColor),
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
                          // Jump to this day
                          ref.read(readingPlanProvider.notifier).jumpToDay(dayData.day);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isActive 
                                ? Border.all(color: theme.primaryColor, width: 2) 
                                : null,
                            color: isCompleted
                                ? theme.primaryColor.withValues(alpha: 0.05)
                                : null,
                          ),
                          child: Padding(
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
                                      const SizedBox(height: 4),
                                      Text(
                                        dayData.readings.join(' • '),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
