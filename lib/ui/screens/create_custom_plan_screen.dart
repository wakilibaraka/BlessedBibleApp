import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../../services/custom_plan_scheduler.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/textured_glass_container.dart';
import 'reading_plan_browser.dart';

class CreateCustomPlanScreen extends ConsumerStatefulWidget {
  const CreateCustomPlanScreen({super.key});

  @override
  ConsumerState<CreateCustomPlanScreen> createState() => _CreateCustomPlanScreenState();
}

class _CreateCustomPlanScreenState extends ConsumerState<CreateCustomPlanScreen> {
  final _nameController = TextEditingController();
  
  // Corpus State
  String _corpusType = 'whole'; // whole, ot, nt, book, slice
  String? _selectedBook = 'Genesis';
  int? _selectedChapter = 1;
  
  // Timeframe State
  bool _useDuration = true;
  final _durationController = TextEditingController(text: '30');
  DateTime _targetEndDate = DateTime.now().add(const Duration(days: 30));
  
  // Rest Day & Pace State
  int? _restDay = 7; // 7 = Saturday, null = None
  String _paceMode = 'scheduled'; // scheduled, flexible

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _createPlan(CustomPlanScheduler scheduler) {
    final corpus = scheduler.buildCorpus(
      _corpusType,
      startBook: _selectedBook,
      startChapter: _selectedChapter,
    );

    int? durationDays;
    if (_useDuration) {
      durationDays = int.tryParse(_durationController.text);
      if (durationDays == null || durationDays < 1) return;
    }

    final schedule = scheduler.generateSchedule(
      corpus,
      durationDays: _useDuration ? durationDays : null,
      startDate: _useDuration ? null : DateTime.now(),
      targetEndDate: _useDuration ? null : _targetEndDate,
      restDay: _restDay,
    );

    if (schedule.isEmpty) return;

    final String planId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    String title = _nameController.text.trim();
    if (title.isEmpty) {
      if (_corpusType == 'whole') { title = 'My Bible Plan'; }
      else if (_corpusType == 'ot') { title = 'My OT Plan'; }
      else if (_corpusType == 'nt') { title = 'My NT Plan'; }
      else if (_corpusType == 'book') { title = '$_selectedBook Plan'; }
      else { title = 'My Custom Plan'; }
    }

    final planData = {
      'id': planId,
      'title': title,
      'description': 'A custom reading plan.',
      'paceMode': _paceMode,
      'restDay': _restDay,
      'readings': schedule.map((e) => e.toJson()).toList(),
    };

    ref.read(preferencesProvider).saveCustomPlan(planId, planData);

    // Start plan instantly and inject the planData directly to avoid async loading gaps
    ref.read(readingPlanProvider(planId).notifier).startPlan(
      planId: planId,
      paceMode: _paceMode,
      restDay: _restDay,
      customPlanData: schedule,
    );

    // Make it active
    ref.read(activePlanIdsProvider.notifier).addPlan(planId);
    ref.read(currentActivePlanIdProvider.notifier).setContext(planId);

    // Pop the creation screen and push the browser
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => ReadingPlanBrowser(planId: planId))
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibleState = ref.watch(bibleProvider);
    
    if (bibleState.books.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scheduler = CustomPlanScheduler(bibleState.books);
    final corpus = scheduler.buildCorpus(
      _corpusType,
      startBook: _selectedBook,
      startChapter: _selectedChapter,
    );
    
    int? durationDays;
    if (_useDuration) {
      durationDays = int.tryParse(_durationController.text);
    }
    
    final schedule = scheduler.generateSchedule(
      corpus,
      durationDays: _useDuration ? durationDays : null,
      startDate: _useDuration ? null : DateTime.now(),
      targetEndDate: _useDuration ? null : _targetEndDate,
      restDay: _restDay,
    );

    bool isValid = corpus.isNotEmpty && schedule.isNotEmpty;
    if (_useDuration && (durationDays == null || durationDays < 1 || durationDays > 1095)) isValid = false;
    if (!_useDuration && _targetEndDate.isBefore(DateTime.now())) isValid = false;

    // Compute preview stats
    int totalReadingDays = schedule.length;
    double avgPerDay = totalReadingDays > 0 ? (corpus.length / totalReadingDays) : 0;

    return Scaffold(
      appBar: SharedAppBar(
        title: const Text('Create Custom Plan'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan Name', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'e.g. John in 30 Days',
                    padding: const EdgeInsets.all(12),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('What to Read (Corpus)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _corpusType,
                    children: const {
                      'whole': Text('Whole Bible'),
                      'ot': Text('OT'),
                      'nt': Text('NT'),
                      'book': Text('Single Book'),
                      'slice': Text('Slice'),
                    },
                    onValueChanged: (v) {
                      setState(() {
                        _corpusType = v!;
                        if ((_corpusType == 'book' || _corpusType == 'slice') && _selectedBook == null) {
                          _selectedBook = 'Genesis';
                        }
                      });
                    },
                  ),
                  
                  if (_corpusType == 'book' || _corpusType == 'slice') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Book: '),
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text(_selectedBook ?? 'Select Book'),
                            onPressed: () {
                              _showBookPicker(context, bibleState.books.map((b) => b.name).toList(), (val) {
                                setState(() => _selectedBook = val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_corpusType == 'slice') ...[
                    Row(
                      children: [
                        const Text('Start Chapter: '),
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text('Chapter $_selectedChapter'),
                            onPressed: () {
                              int chapterCount = bibleState.books.firstWhere((b) => b.name == _selectedBook, orElse: () => bibleState.books.first).chapters.length;
                              _showChapterPicker(context, chapterCount, (val) {
                                setState(() => _selectedChapter = val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Text('Corpus size: ${corpus.length} chapters', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  ),

                  Text('Timeframe', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _useDuration,
                    children: const {
                      true: Text('Duration (Days)'),
                      false: Text('Target End Date'),
                    },
                    onValueChanged: (v) {
                      setState(() => _useDuration = v!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_useDuration)
                    Row(
                      children: [
                        const Text('Days: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            padding: const EdgeInsets.all(12),
                            style: TextStyle(color: theme.colorScheme.onSurface),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Text('End Date: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text("${_targetEndDate.year}-${_targetEndDate.month.toString().padLeft(2, '0')}-${_targetEndDate.day.toString().padLeft(2, '0')}"),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _targetEndDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 1095)),
                              );
                              if (date != null) {
                                setState(() => _targetEndDate = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                  const SizedBox(height: 24),
                  
                  Text('Rest Day', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _restDay?.toString() ?? '0',
                    children: const {
                      '7': Text('Saturday'),
                      '1': Text('Sunday'),
                      '0': Text('None'),
                    },
                    onValueChanged: (v) {
                      setState(() => _restDay = v == '0' ? null : int.tryParse(v!));
                    },
                  ),

                  const SizedBox(height: 24),
                  
                  Text('Pace Mode', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _paceMode,
                    children: const {
                      'scheduled': Text('Scheduled'),
                      'flexible': Text('Flexible'),
                    },
                    onValueChanged: (v) {
                      setState(() => _paceMode = v!);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Live Preview
                  TexturedGlassContainer(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Preview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        const SizedBox(height: 8),
                        if (corpus.isEmpty)
                          const Text('Please select a valid corpus.')
                        else if (!isValid)
                          const Text('Please enter a valid timeframe (1 to 1095 days).', style: TextStyle(color: Colors.red))
                        else ...[
                          Text('• $totalReadingDays reading days'),
                          Text('• ${corpus.length} chapters total'),
                          Text('• ~${avgPerDay.toStringAsFixed(1)} chapters per reading day'),
                          if (avgPerDay > 8)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('⚠️ Intensive — about ${avgPerDay.toStringAsFixed(0)} chapters/day.', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                          if (avgPerDay < 0.2)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Note: This plan is very relaxed, with many rest days.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                            ),
                        ]
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  PrimaryButton(
                    onPressed: isValid ? () => _createPlan(scheduler) : () {},

                    label: 'Create Custom Plan',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  void _showBookPicker(BuildContext context, List<String> books, ValueChanged<String> onSelected) {
    int initialIndex = books.indexOf(_selectedBook ?? books.first);
    if (initialIndex == -1) initialIndex = 0;
    
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: CupertinoPicker(
          backgroundColor: Theme.of(context).colorScheme.surface,
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: initialIndex),
          onSelectedItemChanged: (idx) => onSelected(books[idx]),
          children: books.map((b) => Text(b, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))).toList(),
        ),
      ),
    );
  }

  void _showChapterPicker(BuildContext context, int chapterCount, ValueChanged<int> onSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: CupertinoPicker(
          backgroundColor: Theme.of(context).colorScheme.surface,
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: (_selectedChapter ?? 1) - 1),
          onSelectedItemChanged: (idx) => onSelected(idx + 1),
          children: List.generate(chapterCount, (i) => Text('Chapter ${i + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
        ),
      ),
    );
  }
}
