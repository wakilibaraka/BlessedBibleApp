import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../state/reading_plan_provider.dart';
import '../screens/custom_plan_builder_screen.dart';

class CustomPlanActionSheet {
  static void show(BuildContext context, WidgetRef ref, String planId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Custom Plan Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Recreate Plan (Edit)'),
                subtitle: const Text('Edit-in-place is not currently supported. You will create a new plan.'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const CustomPlanBuilderScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Plan', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Plan?'),
                      content: const Text('This will permanently delete this custom plan and all reading progress.'),
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
                    // Remove from active plans if it is active
                    ref.read(activePlanIdsProvider.notifier).removePlan(planId);
                    
                    // Remove from storage and progress
                    final prefs = ref.read(preferencesProvider);
                    prefs.deleteCustomPlan(planId);
                    
                    // Note: deleting the custom plan from preferences removes its definition.
                    // The progress is tracked by ReadingPlanNotifier using prefs.getReadingPlanState(id).
                    // We should also clear that.
                    ref.read(readingPlanProvider(planId).notifier).deletePlanProgress();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
