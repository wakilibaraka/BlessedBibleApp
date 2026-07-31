import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
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
  String _corpusType = 'whole'; // whole, ot, nt, book, slice, multi
  String? _selectedBook;
  int? _selectedChapter;
  final List<String> _selectedBooks = [];
  
  // Timeframe State
  bool _useDuration = true;
  final _durationController = TextEditingController(text: '30');
  DateTime _targetEndDate = DateTime.now().add(const Duration(days: 30));
  
  // Rest Day & Pace State
  int? _restDay = 7; // 7 = Saturday, null = None
  String _paceMode = 'scheduled'; // scheduled, flexible

  String _restDayName(int? day) {
    if (day == null) return 'None';
    switch (day) {
      case 1: return 'Sunday';
      case 2: return 'Monday';
      case 3: return 'Tuesday';
      case 4: return 'Wednesday';
      case 5: return 'Thursday';
      case 6: return 'Friday';
      case 7: return 'Saturday';
      default: return 'Unknown';
    }
  }

  String _getMultiBookSummary() {
    if (_selectedBooks.isEmpty) return 'Choose books...';
    if (_selectedBooks.length <= 2) return _selectedBooks.join(', ');
    return '${_selectedBooks[0]}, ${_selectedBooks[1]} and ${_selectedBooks.length - 2} more';
  }

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
    final bookCorpus = scheduler.buildCorpus('book', startBook: _selectedBook, startChapter: 1);
    final sliceCorpus = scheduler.buildCorpus('slice', startBook: _selectedBook, startChapter: _selectedChapter);
    final multiCorpus = scheduler.buildCorpus('multi', selectedBooks: _selectedBooks);
    
    final corpus = scheduler.buildCorpus(
      _corpusType,
      startBook: _selectedBook,
      startChapter: _selectedChapter,
      selectedBooks: _selectedBooks,
    );
    
    int? durationDays;
    if (_useDuration) {
      durationDays = int.tryParse(_durationController.text);
    }
    
    int requestedReadingDays = 0;
    if (_useDuration && durationDays != null) {
      requestedReadingDays = durationDays;
    } else if (!_useDuration && !_targetEndDate.isBefore(DateTime.now())) {
      DateTime current = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime end = DateTime.utc(_targetEndDate.year, _targetEndDate.month, _targetEndDate.day);
      while (!current.isAfter(end)) {
        int weekday = (current.weekday % 7) + 1;
        if (_restDay == null || weekday != _restDay) {
          requestedReadingDays++;
        }
        current = current.add(const Duration(days: 1));
      }
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

    int totalReadingDays = schedule.length;
    double avgPerDay = totalReadingDays > 0 ? (corpus.length / totalReadingDays) : 0;

    final appThemeMode = ref.watch(themeProvider);

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.pop:
          return const Color(0xFFF4F5F7);
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return theme.scaffoldBackgroundColor;
      }
    }

    Color getThemeSurfaceColor() {
      switch (appThemeMode) {
        case AppThemeMode.pop:
          return Colors.white;
        case AppThemeMode.dusk:
          return const Color(0xFF3F3965);
        case AppThemeMode.fresh:
          return const Color(0xFF1D3B42);
        default:
          return theme.colorScheme.surface.withValues(alpha: 0.6);
      }
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      extendBodyBehindAppBar: true,
      appBar: const SharedAppBar(
        title: Text('Create Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
          bottom: 40,
        ),
        children: [
          _buildSectionHeader('Plan Name', theme),
          _buildIOSBox([
            _buildIOSInputRow(placeholder: 'e.g. John in 30 Days', controller: _nameController, theme: theme),
          ], theme, surfaceColor: getThemeSurfaceColor()),

          _buildSectionHeader('What to read', theme),
          _buildIOSBox([
            _buildCheckRow('Whole Bible', _corpusType == 'whole', () => setState(() => _corpusType = 'whole'), theme, subtitle: 'Genesis to Revelation · 1189 chapters'),
            _buildCheckRow('Old Testament', _corpusType == 'ot', () => setState(() => _corpusType = 'ot'), theme, subtitle: 'Genesis to Malachi · 929 chapters'),
            _buildCheckRow('New Testament', _corpusType == 'nt', () => setState(() => _corpusType = 'nt'), theme, subtitle: 'Matthew to Revelation · 260 chapters'),
            
            _buildCheckRow(_selectedBook != null && _corpusType == 'book' ? '$_selectedBook' : 'Choose a book', _corpusType == 'book', () {
              setState(() => _corpusType = 'book');
            }, theme, subtitle: _selectedBook != null && _corpusType == 'book' ? '${bookCorpus.length} chapters' : 'e.g. Genesis · 50 chapters'),
            if (_corpusType == 'book')
              _buildIOSRow('Select Book', value: _selectedBook ?? 'None', onTap: () {
                _showBookPicker(context, bibleState.books.map((b) => b.name).toList(), (val) => setState(() => _selectedBook = val));
              }, theme: theme),

            _buildCheckRow(_selectedBook != null && _selectedChapter != null && _corpusType == 'slice' ? 'From $_selectedBook $_selectedChapter to Revelation 22' : 'Start from a chapter...', _corpusType == 'slice', () {
              setState(() => _corpusType = 'slice');
            }, theme, subtitle: _selectedBook != null && _selectedChapter != null && _corpusType == 'slice' ? '${sliceCorpus.length} chapters' : 'e.g. from Isaiah 47 to the end'),
            if (_corpusType == 'slice') ...[
              _buildIOSRow('Start Book', value: _selectedBook ?? 'None', onTap: () {
                _showBookPicker(context, bibleState.books.map((b) => b.name).toList(), (val) => setState(() {
                  _selectedBook = val;
                  _selectedChapter = 1;
                }));
              }, theme: theme),
              if (_selectedBook != null)
                _buildIOSRow('Start Chapter', value: 'Chapter ${_selectedChapter ?? 1}', onTap: () {
                  int count = bibleState.books.firstWhere((b) => b.name == _selectedBook, orElse: () => bibleState.books.first).chapters.length;
                  _showChapterPicker(context, count, (val) => setState(() => _selectedChapter = val));
                }, theme: theme),
            ],

            _buildCheckRow(_selectedBooks.isNotEmpty && _corpusType == 'multi' ? _getMultiBookSummary() : 'Choose books', _corpusType == 'multi', () {
              setState(() => _corpusType = 'multi');
            }, theme, subtitle: _selectedBooks.isNotEmpty && _corpusType == 'multi' ? '${multiCorpus.length} chapters' : 'e.g. Genesis, Exodus · 90 chapters'),
            if (_corpusType == 'multi')
              _buildIOSRow('Select Books', value: '${_selectedBooks.length} selected', onTap: () {
                _showMultiBookPicker(context, bibleState.books.map((b) => b.name).toList());
              }, theme: theme),
          ], theme, surfaceColor: getThemeSurfaceColor()),

          _buildSectionHeader('How long', theme),
          _buildIOSBox([
            _buildCheckRow('By Duration', _useDuration, () => setState(() => _useDuration = true), theme),
            if (_useDuration)
              _buildIOSInputRow(placeholder: 'Number of days', prefix: 'Days', controller: _durationController, keyboardType: TextInputType.number, theme: theme),
            _buildCheckRow('By Target Date', !_useDuration, () => setState(() => _useDuration = false), theme),
            if (!_useDuration)
              _buildIOSRow('End Date', value: "${_targetEndDate.year}-${_targetEndDate.month.toString().padLeft(2, '0')}-${_targetEndDate.day.toString().padLeft(2, '0')}", onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetEndDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 1095)),
                );
                if (date != null) setState(() => _targetEndDate = date);
              }, theme: theme),
          ], theme, surfaceColor: getThemeSurfaceColor()),

          _buildSectionHeader('Rest Day', theme),
          _buildIOSBox([
            _buildCheckRow('Saturday', _restDay == 7, () => setState(() => _restDay = 7), theme),
            _buildCheckRow(_restDay != 7 && _restDay != null ? _restDayName(_restDay) : 'Choose a day...', _restDay != 7 && _restDay != null, () {
              _showRestDayPicker();
            }, theme),
            _buildCheckRow('None', _restDay == null, () => setState(() => _restDay = null), theme),
          ], theme, surfaceColor: getThemeSurfaceColor()),

          _buildSectionHeader('Reading style', theme),
          _buildIOSBox([
            _buildCheckRow('Scheduled (Assigned to dates)', _paceMode == 'scheduled', () => setState(() => _paceMode = 'scheduled'), theme),
            _buildCheckRow('Flexible (Read at own pace)', _paceMode == 'flexible', () => setState(() => _paceMode = 'flexible'), theme),
          ], theme, surfaceColor: getThemeSurfaceColor()),

          const SizedBox(height: 24),
          _buildPreviewBox(corpus, isValid, avgPerDay, totalReadingDays, requestedReadingDays, theme),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(
            onPressed: isValid ? () => _createPlan(scheduler) : () {},
            label: 'Create Plan',
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIOSBox(List<Widget> children, ThemeData theme, {Color? surfaceColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor ?? theme.colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: children.asMap().entries.map((e) {
            return Column(
              children: [
                e.value,
                if (e.key < children.length - 1)
                  Divider(height: 1, indent: 16, color: theme.dividerColor.withValues(alpha: 0.1)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCheckRow(String title, bool selected, VoidCallback onTap, ThemeData theme, {String? subtitle}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? theme.primaryColor : theme.colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check, color: theme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSRow(String title, {String? value, VoidCallback? onTap, ThemeData? theme}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(title, style: theme!.textTheme.bodyLarge),
            const Spacer(),
            if (value != null)
              Text(value, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildIOSInputRow({required String placeholder, required TextEditingController controller, TextInputType? keyboardType, ThemeData? theme, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(prefix, style: theme!.textTheme.bodyLarge),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              padding: const EdgeInsets.symmetric(vertical: 10),
              style: TextStyle(color: theme!.colorScheme.onSurface, fontSize: 16),
              decoration: const BoxDecoration(color: Colors.transparent),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBox(List<dynamic> corpus, bool isValid, double avgPerDay, int totalReadingDays, int requestedReadingDays, ThemeData theme) {
    String planNameStr = _corpusType == 'book' ? (_selectedBook ?? 'This plan') : 'This plan';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Preview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
              const SizedBox(height: 12),
              if (corpus.isEmpty)
                const Text('Please select a valid reading range.')
              else if (!isValid)
                const Text('Please enter a valid timeframe (1 to 1095 days).', style: TextStyle(color: Colors.red))
              else ...[
                Text('• $totalReadingDays reading days', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('• ${corpus.length} chapters total', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('• ~${avgPerDay.toStringAsFixed(1)} chapters per reading day', style: theme.textTheme.bodyMedium),
                
                if (requestedReadingDays > corpus.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('$planNameStr has ${corpus.length} chapters — this plan will run $totalReadingDays reading days (shorter than the $requestedReadingDays you entered).', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      ),
                    ),
                  ),

                if (avgPerDay > 8)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Intensive — about ${avgPerDay.toStringAsFixed(0)} chapters/day.', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      ),
                    ),
                  ),
                if (avgPerDay < 0.2)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text('Note: This plan is very relaxed, with many rest days.', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
                  ),
              ]
            ],
          ),
        ),
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

  void _showRestDayPicker() {
    final allDays = [
      {'val': 1, 'label': 'Sunday'},
      {'val': 2, 'label': 'Monday'},
      {'val': 3, 'label': 'Tuesday'},
      {'val': 4, 'label': 'Wednesday'},
      {'val': 5, 'label': 'Thursday'},
      {'val': 6, 'label': 'Friday'},
      {'val': 7, 'label': 'Saturday'},
    ];
    
    int initialIndex = allDays.indexWhere((d) => d['val'] == _restDay);
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
          onSelectedItemChanged: (idx) {
            setState(() => _restDay = allDays[idx]['val'] as int);
          },
          children: allDays.map((d) => Text(d['label'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))).toList(),
        ),
      ),
    );
  }

  void _showMultiBookPicker(BuildContext context, List<String> allBooks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Choose Books', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Done'),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allBooks.length,
                      itemBuilder: (context, index) {
                        final book = allBooks[index];
                        final isSelected = _selectedBooks.contains(book);
                        return CheckboxListTile(
                          title: Text(book, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          value: isSelected,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                _selectedBooks.add(book);
                              } else {
                                _selectedBooks.remove(book);
                              }
                            });
                            setState(() {}); // Update preview live
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }
}
