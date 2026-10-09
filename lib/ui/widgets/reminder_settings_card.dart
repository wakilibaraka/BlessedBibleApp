import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reminders_provider.dart';

class ReminderSettingsCard extends ConsumerWidget {
  final ThemeData theme;
  const ReminderSettingsCard({super.key, required this.theme});

  Future<void> _pickTime(BuildContext context, WidgetRef ref, bool isReading, TimeOfDay initialTime) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.colorScheme.surface,
              hourMinuteTextColor: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      if (isReading) {
        ref.read(remindersProvider.notifier).setDailyTime(newTime.hour, newTime.minute);
      } else {
        ref.read(remindersProvider.notifier).setCustomWeeklyTime(DateTime.now().weekday, newTime.hour, newTime.minute);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);

    final readingTime = TimeOfDay(hour: state.dailyHour, minute: state.dailyMinute);
    final prayerTime = TimeOfDay(hour: state.customWeeklyHour, minute: state.customWeeklyMinute);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildRow(
            context,
            ref,
            icon: Icons.menu_book_rounded,
            title: 'Daily Reading',
            enabled: state.dailyEnabled,
            time: readingTime,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleDaily(v),
            onTimeTap: () => _pickTime(context, ref, true, readingTime),
          ),
          Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
          _buildRow(
            context,
            ref,
            icon: Icons.volunteer_activism_rounded,
            title: 'Custom Reminder',
            enabled: state.customWeeklyEnabled,
            time: prayerTime,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleCustomWeekly(v),
            onTimeTap: () => _pickTime(context, ref, false, prayerTime),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, {
    required IconData icon,
    required String title,
    required bool enabled,
    required TimeOfDay time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: GestureDetector(
        onTap: onTimeTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            time.format(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      trailing: Switch.adaptive(
        value: enabled,
        activeTrackColor: theme.colorScheme.primary,
        onChanged: onToggle,
      ),
    );
  }
}
