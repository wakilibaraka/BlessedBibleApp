import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/reading_plan.dart';
import '../../services/plan_generator.dart';
import '../../services/word_count_service.dart';
import '../../utils/isolate_parsers.dart';
import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/auth_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/textured_glass_container.dart';
import '../sheets/book_chapter_selector_sheet.dart';

class _TrackDraft {
  BibleBook? startBook;
  int startChapter = 1;
  int startVerse = 1;

  BibleBook? endBook;
  int endChapter = 1;
  int endVerse = 1;

  bool get isValid => startBook != null && endBook != null;
  
  List<PlanRange> toRanges(List<BibleBook> allBooks) {
    if (!isValid) return [];
    int startIndex = allBooks.indexWhere((b) => b.name == startBook!.name);
    int endIndex = allBooks.indexWhere((b) => b.name == endBook!.name);
    if (startIndex > endIndex) return [];
    if (startIndex == endIndex) {
      if (startChapter > endChapter || (startChapter == endChapter && startVerse > endVerse)) return [];
    }
    
    List<PlanRange> result = [];
    for (int i = startIndex; i <= endIndex; i++) {
      final b = allBooks[i];
      int sCh = (i == startIndex) ? startChapter : 1;
      int sV = (i == startIndex) ? startVerse : 1;
      int eCh = (i == endIndex) ? endChapter : b.chapters.last.number;
      int eV = (i == endIndex) ? endVerse : b.chapters.last.verses.length;
      result.add(PlanRange(book: b.name, startChapter: sCh, startVerse: sV, endChapter: eCh, endVerse: eV));
    }
    return result;
  }
}

class CustomPlanBuilderScreen extends ConsumerStatefulWidget {
  const CustomPlanBuilderScreen({super.key});

  @override
  ConsumerState<CustomPlanBuilderScreen> createState() => _CustomPlanBuilderScreenState();
}

class _CustomPlanBuilderScreenState extends ConsumerState<CustomPlanBuilderScreen> {
  final _titleController = TextEditingController();
  bool _isTitleEditedByUser = false;
  final List<_TrackDraft> _drafts = [];
  double _days = 30; 
  
  PlanGenerator? _generator;
  ReadingPlan? _previewPlan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initGenerator();
  }

  Future<void> _initGenerator() async {
    try {
      final wcs = ref.read(wordCountServiceProvider);
      await wcs.init(); 

      final pJson = await rootBundle.loadString('assets/data/pericopes.json');
      final allPericopes = await compute(parsePericopesJson, pJson);

      setState(() {
        _generator = PlanGenerator(wordCountService: wcs, allPericopes: allPericopes);
        _isLoading = false;
        _drafts.add(_TrackDraft());
      });
      _updatePreview();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addTrack() {
    setState(() {
      _drafts.add(_TrackDraft());
    });
    _updatePreview();
  }

  void _removeTrack(int index) {
    setState(() {
      _drafts.removeAt(index);
    });
    _updatePreview();
  }

  void _updatePreview() {
    if (_generator == null) return;
    
    final validDrafts = _drafts.where((d) => d.isValid).toList();
    if (validDrafts.isEmpty) {
      setState(() => _previewPlan = null);
      return;
    }

    try {
      final allBooks = ref.read(bibleProvider).books;
      final tracks = validDrafts.map((d) => d.toRanges(allBooks)).where((t) => t.isNotEmpty).toList();
      if (tracks.isEmpty) {
        setState(() => _previewPlan = null);
        return;
      }

      final plan = _generator!.generatePlan(
        id: 'preview',
        title: _titleController.text.isEmpty ? 'Custom Plan' : _titleController.text,
        tracks: tracks,
        days: _days.toInt(),
        cadence: 7,
      );
      setState(() => _previewPlan = plan);
    } catch (e) {
      setState(() => _previewPlan = null);
    }
  }

  void _autoNamePlan() {
    if (_isTitleEditedByUser) return;
    final validDrafts = _drafts.where((d) => d.isValid).toList();
    if (validDrafts.isEmpty) return;

    String baseName = '';
    if (validDrafts.length == 1) {
      final d = validDrafts.first;
      if (d.startBook!.name == d.endBook!.name) {
        baseName = d.startBook!.name;
      } else {
        baseName = '${d.startBook!.name} to ${d.endBook!.name}';
      }
    } else {
      baseName = '${validDrafts.first.startBook!.name} & ${validDrafts[1].startBook!.name}';
      if (validDrafts.length > 2) baseName += ' +${validDrafts.length - 2}';
    }

    final newName = '$baseName in ${_days.toInt()} Days';
    if (_titleController.text != newName) {
      _titleController.text = newName;
      setState(() {});
    }
  }

  void _pickStart(int index) {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return;
    
    final draft = _drafts[index];
    final initialAbbrev = draft.startBook?.abbreviation ?? allBooks.first.abbreviation;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return BookChapterSelectorSheet(
          books: allBooks,
          selectedBookAbbrev: initialAbbrev,
          selectedChapter: draft.startChapter,
          onSelectionChanged: (abbrev, name, chapter, verse, {bool autoClose = true}) {
             final selectedBook = allBooks.firstWhere((b) => b.abbreviation == abbrev);
             setState(() {
               draft.startBook = selectedBook;
               draft.startChapter = chapter;
               draft.startVerse = verse ?? 1;
               
               // Auto-adjust end ref if it's currently invalid (e.g. before start)
               if (draft.endBook == null || allBooks.indexOf(draft.endBook!) < allBooks.indexOf(selectedBook)) {
                 draft.endBook = selectedBook;
                 draft.endChapter = selectedBook.chapters.last.number;
                 draft.endVerse = selectedBook.chapters.last.verses.length;
               }
             });
             _updatePreview();
             _autoNamePlan();
             if (autoClose) Navigator.pop(context);
          },
        );
      }
    );
  }

  void _pickEnd(int index) {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return;
    
    final draft = _drafts[index];
    if (draft.startBook == null) return;
    
    // Only allow books from startBook onwards
    final startIndex = allBooks.indexOf(draft.startBook!);
    final validEndBooks = allBooks.sublist(startIndex);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return BookChapterSelectorSheet(
          books: validEndBooks, 
          selectedBookAbbrev: draft.endBook?.abbreviation ?? draft.startBook!.abbreviation,
          selectedChapter: draft.endChapter,
          onSelectionChanged: (abbrev, name, chapter, verse, {bool autoClose = true}) {
             final selectedBook = allBooks.firstWhere((b) => b.abbreviation == abbrev);
             setState(() {
               draft.endBook = selectedBook;
               draft.endChapter = chapter;
               draft.endVerse = verse ?? 1;
             });
             _updatePreview();
             _autoNamePlan();
             if (autoClose) Navigator.pop(context);
          },
        );
      }
    );
  }

  void _savePlan() async {
    if (_previewPlan == null || _titleController.text.trim().isEmpty) return;
    if (_drafts.where((d) => d.isValid).isEmpty) return;

    setState(() => _isLoading = true);

    final allBooks = ref.read(bibleProvider).books;
    final finalPlan = _generator!.generatePlan(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      tracks: _drafts.where((d) => d.isValid).map((d) => d.toRanges(allBooks)).where((t) => t.isNotEmpty).toList(),
      days: _days.toInt(),
      cadence: 7,
    );

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('plans')
          .doc(finalPlan.id)
          .set(finalPlan.toJson());
    } else {
      final prefs = ref.read(preferencesProvider);
      prefs.saveCustomPlan(finalPlan.id, finalPlan.toJson());
    }
    
    ref.read(activePlanIdsProvider.notifier).addPlan(finalPlan.id);
    
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const SharedAppBar(title: Text('Custom Plan Builder')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null 
          ? Center(child: Text('Error: $_error'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Plan Name', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Genesis in 30 Days',
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) {
                          _isTitleEditedByUser = true;
                          _updatePreview();
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('Reading Tracks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._drafts.asMap().entries.map((e) => _buildTrackCard(e.key, e.value, theme)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _addTrack,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Track'),
                      ),
                      const SizedBox(height: 24),
                      _buildDaysSlider(theme),
                    ],
                  ),
                ),
                _buildBottomBar(theme),
              ],
            ),
    );
  }

  Widget _buildTrackCard(int index, _TrackDraft draft, ThemeData theme) {
    return TexturedGlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Track ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (_drafts.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _removeTrack(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
            ]
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickStart(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Reference', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(height: 4),
                        Text(draft.startBook == null ? 'Select Start' : '${draft.startBook!.name} ${draft.startChapter}:${draft.startVerse}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _pickEnd(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Reference', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(height: 4),
                        Text(draft.endBook == null ? 'Select End' : '${draft.endBook!.name} ${draft.endChapter}:${draft.endVerse}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _buildDaysSlider(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Duration (Days)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('${_days.toInt()}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
          ],
        ),
        Slider(
          value: _days,
          min: 1,
          max: 730,
          divisions: 730,
          activeColor: theme.primaryColor,
          label: _days.toInt().toString(),
          onChanged: (val) {
            setState(() => _days = val);
            _updatePreview();
            _autoNamePlan();
          },
        ),
        Wrap(
          spacing: 8,
          children: [30, 90, 180, 365].map((d) => ChoiceChip(
            label: Text('$d Days'),
            selected: _days == d.toDouble(),
            onSelected: (sel) {
              if (sel) {
                setState(() => _days = d.toDouble());
                _updatePreview();
                _autoNamePlan();
              }
            }
          )).toList(),
        ),
        const SizedBox(height: 24),
        if (_previewPlan != null && _previewPlan!.schedule.isNotEmpty) ...[
           Text('Plan Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
           const SizedBox(height: 12),
           _buildPlanOverviewCard(theme),
        ]
      ]
    );
  }

  Widget _buildPlanOverviewCard(ThemeData theme) {
    final totalWords = _previewPlan!.schedule.fold(0, (s, day) => s + day.totalWords);
    final totalMins = _previewPlan!.schedule.fold(0, (s, day) => s + day.estimatedMinutes);
    
    return TexturedGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol('Days', '${_previewPlan!.days}', theme),
              _buildStatCol('Words', '${(totalWords / 1000).toStringAsFixed(1)}k', theme),
              _buildStatCol('Total Time', '${(totalMins / 60).toStringAsFixed(1)}h', theme),
              _buildStatCol('Pace', '~${_previewPlan!.schedule.first.estimatedTimeDisplay}/day', theme),
            ],
          ),
          const Divider(height: 32),
          Text('First few days preview:', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          ..._previewPlan!.schedule.take(3).map((day) {
            final refs = day.portions.map((p) => '${p.book} ${p.startChapter}:${p.startVerse} - ${p.endChapter}:${p.endVerse}').join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Day ${day.dayNumber}: $refs', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }),
          if (_previewPlan!.schedule.length > 3)
            Text('... and ${_previewPlan!.schedule.length - 3} more days', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          if (_previewPlan!.wasClamped)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
              child: Row(
                children: [
                   const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                   const SizedBox(width: 8),
                   Expanded(child: Text(_previewPlan!.clampReason ?? '', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            )
        ],
      )
    );
  }

  Widget _buildStatCol(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final canSave = _titleController.text.trim().isNotEmpty && _previewPlan != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: 'Generate & Save Plan',
          onPressed: canSave ? _savePlan : null,
        ),
      ),
    );
  }
}
