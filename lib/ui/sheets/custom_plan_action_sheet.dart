import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../state/reading_plan_provider.dart';

enum _CustomPlanAction { rename, makePrimary, togglePause, restart, delete }

class CustomPlanActionSheet {
  static Future<void> show(BuildContext context, WidgetRef ref, String planId) async {
    final prefs = ref.read(preferencesProvider);
    final activeIds = ref.read(activePlanIdsProvider);
    final isActive = activeIds.contains(planId);
    final isPrimary = activeIds.isNotEmpty && activeIds.first == planId;
    
    final action = await showModalBottomSheet<_CustomPlanAction>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Manage Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (isActive && !isPrimary)
                ListTile(
                  leading: const Icon(Icons.vertical_align_top),
                  title: const Text('Make Primary'),
                  onTap: () => Navigator.pop(context, _CustomPlanAction.makePrimary),
                ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename Plan'),
                onTap: () => Navigator.pop(context, _CustomPlanAction.rename),
              ),
              ListTile(
                leading: Icon(isActive ? Icons.pause : Icons.play_arrow),
                title: Text(isActive ? 'Pause Plan' : 'Resume Plan'),
                subtitle: Text(isActive ? 'Remove from active view.' : 'Add back to active view.'),
                onTap: () => Navigator.pop(context, _CustomPlanAction.togglePause),
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.orange),
                title: const Text('Restart Plan', style: TextStyle(color: Colors.orange)),
                onTap: () => Navigator.pop(context, _CustomPlanAction.restart),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Plan', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, _CustomPlanAction.delete),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || !context.mounted) return;

    if (action == _CustomPlanAction.makePrimary) {
      ref.read(activePlanIdsProvider.notifier).makePrimary(planId);
    } 
    else if (action == _CustomPlanAction.togglePause) {
      if (isActive) {
        ref.read(activePlanIdsProvider.notifier).removePlan(planId);
      } else {
        ref.read(activePlanIdsProvider.notifier).addPlan(planId);
      }
    } 
    else if (action == _CustomPlanAction.rename) {
      final planData = prefs.getCustomPlan(planId);
      final currentTitle = planData?['title'] ?? '';
      
      final newTitle = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: currentTitle);
          return AlertDialog(
            title: const Text('Rename Plan'),
            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Plan Title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          );
        }
      );
      
      if (newTitle != null && newTitle.isNotEmpty && newTitle != currentTitle) {
        if (planData != null) {
          planData['title'] = newTitle;
          prefs.saveCustomPlan(planId, planData);
        }
      }
    } 
    else if (action == _CustomPlanAction.restart) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restart Plan?'),
          content: const Text('This will permanently reset all your progress for this plan to Day 1.', style: TextStyle(color: Colors.red)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restart', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        ref.read(readingPlanProvider(planId).notifier).deletePlanProgress();
      }
    } 
    else if (action == _CustomPlanAction.delete) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Plan?'),
          content: const Text('This will permanently delete this custom plan and all its progress.', style: TextStyle(color: Colors.red)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        ref.read(activePlanIdsProvider.notifier).removePlan(planId);
        prefs.deleteCustomPlan(planId);
        ref.read(readingPlanProvider(planId).notifier).deletePlanProgress();
      }
    }
  }
}
