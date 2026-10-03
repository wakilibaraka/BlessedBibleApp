import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';

enum _CuratedPlanAction { makePrimary, togglePause, toggleHide, restart }

class CuratedPlanActionSheet {
  static Future<void> show(BuildContext context, WidgetRef ref, String planId) async {
    final activeIds = ref.read(activePlanIdsProvider);
    final hiddenIds = ref.read(hiddenPlanIdsProvider);
    
    final isActive = activeIds.contains(planId);
    final isPrimary = activeIds.isNotEmpty && activeIds.first == planId;
    final isHidden = hiddenIds.contains(planId);
    
    final action = await showModalBottomSheet<_CuratedPlanAction>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Manage Curated Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (isActive && !isPrimary)
                ListTile(
                  leading: const Icon(Icons.vertical_align_top),
                  title: const Text('Make Primary'),
                  onTap: () => Navigator.pop(context, _CuratedPlanAction.makePrimary),
                ),
              if (!isHidden)
                ListTile(
                  leading: Icon(isActive ? Icons.pause : Icons.play_arrow),
                  title: Text(isActive ? 'Pause Plan' : 'Resume Plan'),
                  subtitle: Text(isActive ? 'Remove from active view.' : 'Add back to active view.'),
                  onTap: () => Navigator.pop(context, _CuratedPlanAction.togglePause),
                ),
              ListTile(
                leading: Icon(isHidden ? Icons.visibility : Icons.visibility_off),
                title: Text(isHidden ? 'Unhide Plan' : 'Hide Plan'),
                subtitle: Text(isHidden ? 'Show this plan in the Library again.' : 'Hide this plan from the Library.'),
                onTap: () => Navigator.pop(context, _CuratedPlanAction.toggleHide),
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.orange),
                title: const Text('Restart Plan', style: TextStyle(color: Colors.orange)),
                onTap: () => Navigator.pop(context, _CuratedPlanAction.restart),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || !context.mounted) return;

    if (action == _CuratedPlanAction.makePrimary) {
      ref.read(activePlanIdsProvider.notifier).makePrimary(planId);
    } 
    else if (action == _CuratedPlanAction.togglePause) {
      if (isActive) {
        ref.read(activePlanIdsProvider.notifier).removePlan(planId);
      } else {
        ref.read(activePlanIdsProvider.notifier).addPlan(planId);
      }
    } 
    else if (action == _CuratedPlanAction.toggleHide) {
      if (isHidden) {
        ref.read(hiddenPlanIdsProvider.notifier).removePlan(planId);
      } else {
        ref.read(hiddenPlanIdsProvider.notifier).addPlan(planId);
        // Also pause if active so it truly hides
        if (isActive) {
          ref.read(activePlanIdsProvider.notifier).removePlan(planId);
        }
      }
    } 
    else if (action == _CuratedPlanAction.restart) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restart Plan?'),
          content: const Text('This will permanently reset all your progress for this plan to Day 1.', style: TextStyle(color: Colors.orange)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restart', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        ref.read(readingPlanProvider(planId).notifier).deletePlanProgress();
      }
    }
  }
}
