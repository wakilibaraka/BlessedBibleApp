import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/study_provider.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passage = ref.watch(studyPassageProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: Center(
        child: Text(
          passage != null ? 'Deep Study Mode\nLoaded: $passage' : 'Study Screen Placeholder',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
