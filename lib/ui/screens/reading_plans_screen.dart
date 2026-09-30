import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/dynamic_reading_plan_provider.dart';
import '../../state/read_location_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/shared_app_bar.dart';

class ReadingPlansScreen extends ConsumerWidget {
  const ReadingPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(dynamicReadingPlanProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: SharedAppBar(
        title: const Text('Dynamic Plans'),
      ),
      body: plan == null
          ? _buildSelectionView(context, ref, theme)
          : _buildActivePlanView(context, ref, theme, plan),
    );
  }

  Widget _buildSelectionView(BuildContext context, WidgetRef ref, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Start a New Journey',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how many days you want to read the entire Bible in, and we will dynamically assign chapters for you.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 32),
        _buildPlanCard(context, ref, theme, 30, '30 Days', 'Intense pace, ~40 chapters a day.'),
        const SizedBox(height: 16),
        _buildPlanCard(context, ref, theme, 90, '90 Days', 'Fast pace, ~13 chapters a day.'),
        const SizedBox(height: 16),
        _buildPlanCard(context, ref, theme, 365, '1 Year', 'Steady pace, ~3 chapters a day.'),
        const SizedBox(height: 16),
        _buildCustomPlanCard(context, ref, theme),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, ThemeData theme, int days, String title, String subtitle) {
    return InkWell(
      onTap: () => ref.read(dynamicReadingPlanProvider.notifier).startNewPlan(days),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
          color: theme.primaryColor.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlanCard(BuildContext context, WidgetRef ref, ThemeData theme) {
    return InkWell(
      onTap: () async {
        String input = '';
        final days = await showDialog<int>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Custom Duration'),
            content: TextField(
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Number of days (e.g. 180)'),
              onChanged: (v) => input = v,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(c, int.tryParse(input)), child: const Text('Start')),
            ],
          ),
        );
        if (days != null && days > 0) {
          ref.read(dynamicReadingPlanProvider.notifier).startNewPlan(days);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Custom Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Enter a custom number of days.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlanView(BuildContext context, WidgetRef ref, ThemeData theme, DynamicReadingPlan plan) {
    if (plan.isCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: AppColors.goldAccent),
            const SizedBox(height: 16),
            Text('Plan Completed!', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(dynamicReadingPlanProvider.notifier).clearPlan(),
              child: const Text('Start a New Plan'),
            ),
          ],
        ),
      );
    }

    final todayChunks = plan.dailyChunks[plan.currentDay - 1];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Day ${plan.currentDay} of ${plan.totalDays}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: plan.currentDay / plan.totalDays,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 32),
        Text(
          'Today\'s Reading',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...todayChunks.map((chunk) => ListTile(
          title: Text('${chunk.book.name} ${chunk.chapter.number}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            openReaderAtVerse(ref, bookName: chunk.book.name, chapter: chunk.chapter.number);
          },
        )),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => ref.read(dynamicReadingPlanProvider.notifier).completeDay(),
          icon: const Icon(Icons.check),
          label: const Text('Mark Day as Complete'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final del = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancel Plan?'),
        content: const Text('Are you sure you want to stop this reading plan? Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
        ],
      ),
    );
    if (del == true) {
      ref.read(dynamicReadingPlanProvider.notifier).clearPlan();
    }
  }
}
