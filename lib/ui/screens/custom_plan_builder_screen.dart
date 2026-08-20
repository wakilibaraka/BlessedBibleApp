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
  BibleBook? book;
  int startChapter = 1;
  int startVerse = 1;
  int endChapter = 1;
  int endVerse = 1;

  bool get isValid => book != null;
  
  PlanRange toRange() {
    return PlanRange(
      book: book!.name,
      startChapter: startChapter,
      startVerse: startVerse,
      endChapter: endChapter,
      endVerse: endVerse
    );
  }
}

class CustomPlanBuilderScreen extends ConsumerStatefulWidget {
  const CustomPlanBuilderScreen({super.key});

  @override
  ConsumerState<CustomPlanBuilderScreen> createState() => _CustomPlanBuilderScreenState();
}

class _CustomPlanBuilderScreenState extends ConsumerState<CustomPlanBuilderScreen> {
  final _titleController = TextEditingController();
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
      final plan = _generator!.generatePlan(
        id: 'preview',
        title: _titleController.text.isEmpty ? 'Custom Plan' : _titleController.text,
        ranges: validDrafts.map((d) => d.toRange()).toList(),
        days: _days.toInt(),
        cadence: 7,
      );
      setState(() => _previewPlan = plan);
    } catch (e) {
      setState(() => _previewPlan = null);
    }
  }

  void _pickStart(int index) {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return;
    
    final draft = _drafts[index];
    final initialAbbrev = draft.book?.abbreviation ?? allBooks.first.abbreviation;
    
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
               draft.book = selectedBook;
               draft.startChapter = chapter;
               draft.startVerse = verse ?? 1;
               
               if (draft.endChapter < chapter) {
                 draft.endChapter = selectedBook.chapters.last.number;
                 draft.endVerse = selectedBook.chapters.last.verses.length;
               }
             });
             _updatePreview();
             if (autoClose) Navigator.pop(context);
          },
        );
      }
    );
  }

  void _pickEnd(int index) {
    final draft = _drafts[index];
    if (draft.book == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return BookChapterSelectorSheet(
          books: [draft.book!], 
          selectedBookAbbrev: draft.book!.abbreviation,
          selectedChapter: draft.endChapter,
          onSelectionChanged: (abbrev, name, chapter, verse, {bool autoClose = true}) {
             setState(() {
               draft.endChapter = chapter;
               draft.endVerse = verse ?? 1;
             });
             _updatePreview();
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

    final finalPlan = _generator!.generatePlan(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      ranges: _drafts.where((d) => d.isValid).map((d) => d.toRange()).toList(),
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
                        onChanged: (_) => _updatePreview(),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _pickStart(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(draft.isValid ? 'Start: ${draft.book!.name} ${draft.startChapter}:${draft.startVerse}' : 'Select Start Reference')
                  )
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickEnd(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(draft.isValid ? 'End: ${draft.book!.name} ${draft.endChapter}:${draft.endVerse}' : 'Select End Reference')
                  )
                ),
              ],
            ),
          ),
          if (_drafts.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _removeTrack(index),
            )
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
              }
            }
          )).toList(),
        ),
        const SizedBox(height: 16),
        if (_previewPlan != null && _previewPlan!.schedule.isNotEmpty) ...[
           Row(
             children: [
               Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
               const SizedBox(width: 4),
               Text('Average pace: ~${_previewPlan!.schedule.first.estimatedTimeDisplay} / day', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8))),
             ],
           ),
           if (_previewPlan!.wasClamped)
             Container(
               margin: const EdgeInsets.only(top: 12),
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
        ]
      ]
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
