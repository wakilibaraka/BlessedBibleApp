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
import '../../state/auth_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/reading_plan_provider.dart'
    show readingPlanProvider, activePlanIdsProvider, appWeekday;
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../sheets/book_chapter_selector_sheet.dart';

class _TrackDraftV2 {
  BibleBook? startBook;
  int startChapter = 1;
  int startVerse = 1;
  BibleBook? endBook;
  int endChapter = 1;
  int endVerse = 1;

  bool get isValid => startBook != null && endBook != null;

  List<PlanRange> toRanges(List<BibleBook> allBooks) {
    if (!isValid) return [];
    final startIndex =
        allBooks.indexWhere((b) => b.name == startBook!.name);
    final endIndex = allBooks.indexWhere((b) => b.name == endBook!.name);
    if (startIndex > endIndex || startIndex < 0 || endIndex < 0) {
      return [];
    }
    if (startIndex == endIndex) {
      if (startChapter > endChapter ||
          (startChapter == endChapter && startVerse > endVerse)) {
        return [];
      }
    }
    final result = <PlanRange>[];
    for (var i = startIndex; i <= endIndex; i++) {
      final b = allBooks[i];
      final sCh = (i == startIndex) ? startChapter : 1;
      final sV = (i == startIndex) ? startVerse : 1;
      final eCh =
          (i == endIndex) ? endChapter : b.chapters.last.number;
      final eV = (i == endIndex)
          ? endVerse
          : b.chapters.last.verses.length;
      result.add(PlanRange(
        book: b.name,
        startChapter: sCh,
        startVerse: sV,
        endChapter: eCh,
        endVerse: eV,
      ));
    }
    return result;
  }
}

/// Redesigned custom-plan builder (V2).
///
/// Same generation engine as V1 ([PlanGenerator]) — the redesign adds what
/// V1 forced users to hunt for after creation:
/// - start date, rest day and reminder live on this screen and are passed
///   into `startPlan`/`setReminder` on save;
/// - duration has a slider *and* an exact-number field;
/// - clamp results rewrite the title honestly (`… in N days`);
/// - overlapping tracks warn instead of silently double-counting.
class CustomPlanBuilderV2Screen extends ConsumerStatefulWidget {
  /// Optional preset: open the builder with a duration already set.
  final int? initialDays;

  /// Optional preset: pre-fill one track spanning the whole Bible
  /// (used by the paced-generator shortcut).
  final bool wholeBible;

  const CustomPlanBuilderV2Screen(
      {super.key, this.initialDays, this.wholeBible = false});

  @override
  ConsumerState<CustomPlanBuilderV2Screen> createState() =>
      _CustomPlanBuilderV2ScreenState();
}

class _CustomPlanBuilderV2ScreenState
    extends ConsumerState<CustomPlanBuilderV2Screen> {
  final _titleController = TextEditingController();
  final _daysController = TextEditingController(text: '60');
  bool _titleTouched = false;
  final List<_TrackDraftV2> _drafts = [];
  double _days = 60;

  DateTime _startDate = DateTime.now();
  int? _restDay = 7; // app weekday: 1=Sun..7=Sat, null = none
  bool _reminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 30);

  PlanGenerator? _generator;
  ReadingPlan? _preview;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  int _previewToken = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialDays != null) {
      _days = widget.initialDays!.clamp(1, 730).toDouble();
      _daysController.text = _days.toInt().toString();
    }
    _initGenerator();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _initGenerator() async {
    try {
      final wcs = ref.read(wordCountServiceProvider);
      await wcs.init();
      final pJson =
          await rootBundle.loadString('assets/data/pericopes.json');
      final allPericopes = await compute(parsePericopesJson, pJson);
      if (!mounted) return;
      final allBooks = ref.read(bibleProvider).books;
      setState(() {
        _generator =
            PlanGenerator(wordCountService: wcs, allPericopes: allPericopes);
        _isLoading = false;
        if (widget.wholeBible && allBooks.length > 1) {
          // Paced-generator shortcut: one track across the whole canon.
          final first = allBooks.first;
          final last = allBooks.last;
          _drafts.add(_TrackDraftV2()
            ..startBook = first
            ..startChapter = 1
            ..startVerse = 1
            ..endBook = last
            ..endChapter = last.chapters.last.number
            ..endVerse = last.chapters.last.verses.length);
        } else {
          _drafts.add(_TrackDraftV2());
        }
      });
      _schedulePreview();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Debounced so slider drags don't synchronously chunk 31k verses.
  void _schedulePreview() {
    final token = ++_previewToken;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted || token != _previewToken) return;
      _updatePreview();
    });
  }

  void _updatePreview() {
    if (_generator == null) return;
    final allBooks = ref.read(bibleProvider).books;
    final tracks = _drafts
        .where((d) => d.isValid)
        .map((d) => d.toRanges(allBooks))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tracks.isEmpty) {
      setState(() => _preview = null);
      return;
    }
    try {
      final plan = _generator!.generatePlan(
        id: 'preview',
        title: _titleController.text.isEmpty
            ? 'Custom Plan'
            : _titleController.text,
        tracks: tracks,
        days: _days.toInt().clamp(1, 730),
        cadence: 7,
      );
      setState(() => _preview = plan);
      _autoName(plan);
    } catch (_) {
      setState(() => _preview = null);
    }
  }

  void _autoName(ReadingPlan plan) {
    if (_titleTouched) return;
    final valid = _drafts.where((d) => d.isValid).toList();
    if (valid.isEmpty) return;
    String base;
    if (valid.length == 1 && valid.first.startBook != null) {
      final d = valid.first;
      base = d.startBook!.name == d.endBook!.name
          ? d.startBook!.name
          : '${d.startBook!.name} to ${d.endBook!.name}';
    } else {
      base = valid.first.startBook?.name ?? 'Custom';
      if (valid.length > 1) base += ' +${valid.length - 1}';
    }
    // Honest clamp: title uses the actual day count, not the request.
    final name = '$base in ${plan.days} Days';
    if (_titleController.text != name) {
      _titleController.text = name;
    }
  }

  bool _overlaps() {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return false;
    int idx(String book, int ch, int v) {
      final bi = allBooks.indexWhere((b) => b.name == book);
      return bi * 1000000 + ch * 1000 + v;
    }

    final spans = <List<int>>[];
    for (final d in _drafts.where((d) => d.isValid)) {
      for (final r in d.toRanges(allBooks)) {
        spans.add([
          idx(r.book, r.startChapter, r.startVerse),
          idx(r.book, r.endChapter, r.endVerse),
        ]);
      }
    }
    spans.sort((a, b) => a[0].compareTo(b[0]));
    for (var i = 1; i < spans.length; i++) {
      if (spans[i][0] <= spans[i - 1][1]) return true;
    }
    return false;
  }

  void _pickStart(int index) {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return;
    final draft = _drafts[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BookChapterSelectorSheet(
        books: allBooks,
        selectedBookAbbrev:
            draft.startBook?.abbreviation ?? allBooks.first.abbreviation,
        selectedChapter: draft.startChapter,
        onSelectionChanged:
            (abbrev, name, chapter, verse, {bool autoClose = true}) {
          final book =
              allBooks.firstWhere((b) => b.abbreviation == abbrev);
          setState(() {
            draft.startBook = book;
            draft.startChapter = chapter;
            draft.startVerse = verse ?? 1;
            if (draft.endBook == null ||
                allBooks.indexOf(draft.endBook!) <
                    allBooks.indexOf(book)) {
              draft.endBook = book;
              draft.endChapter = book.chapters.last.number;
              draft.endVerse = book.chapters.last.verses.length;
            }
          });
          _schedulePreview();
          if (autoClose && mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _pickEnd(int index) {
    final allBooks = ref.read(bibleProvider).books;
    if (allBooks.isEmpty) return;
    final draft = _drafts[index];
    if (draft.startBook == null) return;
    final startIndex = allBooks.indexOf(draft.startBook!);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BookChapterSelectorSheet(
        books: allBooks.sublist(startIndex),
        selectedBookAbbrev: draft.endBook?.abbreviation ??
            draft.startBook!.abbreviation,
        selectedChapter: draft.endChapter,
        onSelectionChanged:
            (abbrev, name, chapter, verse, {bool autoClose = true}) {
          final book =
              allBooks.firstWhere((b) => b.abbreviation == abbrev);
          setState(() {
            draft.endBook = book;
            draft.endChapter = chapter;
            // End defaults to the chapter's last verse (V1 truncated to 1).
            draft.endVerse = verse ??
                book.chapters
                    .firstWhere((c) => c.number == chapter,
                        orElse: () => book.chapters.last)
                    .verses
                    .length;
          });
          _schedulePreview();
          if (autoClose && mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_preview == null ||
        _titleController.text.trim().isEmpty ||
        _isSaving) {
      return;
    }
    // Slot guard before saving (V1 saved, then silently failed to activate).
    if (ref.read(activePlanIdsProvider).length >= 3 &&
        !ref.read(activePlanIdsProvider).contains(_preview!.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'All 3 plan slots are in use. Pause a plan first — progress is kept.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final allBooks = ref.read(bibleProvider).books;
      final tracks = _drafts
          .where((d) => d.isValid)
          .map((d) => d.toRanges(allBooks))
          .where((t) => t.isNotEmpty)
          .toList();
      final finalPlan = _generator!.generatePlan(
        id: const Uuid().v4(), // never collides (V1 paced IDs did)
        title: _titleController.text.trim(),
        tracks: tracks,
        days: _days.toInt().clamp(1, 730),
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
      }
      ref
          .read(preferencesProvider)
          .saveCustomPlan(finalPlan.id, finalPlan.toJson());
      ref.read(activePlanIdsProvider.notifier).addPlan(finalPlan.id);
      // Start inline with the chosen date/rest — no post-start hunt.
      ref.read(readingPlanProvider(finalPlan.id).notifier).startPlan(
            planId: finalPlan.id,
            paceMode: 'scheduled',
            restDay: _restDay,
            startDate: _startDate,
          );
      if (_reminder) {
        ref.read(readingPlanProvider(finalPlan.id).notifier).setReminder(
            true, _reminderTime.hour, _reminderTime.minute);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save plan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar:
            const SharedAppBar(title: Text('Custom Plan Builder')),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : ListView(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 140),
                    children: [
                      Text('Plan name',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Genesis in 30 Days',
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: theme.dividerColor),
                          ),
                        ),
                        onChanged: (_) {
                          _titleTouched = true;
                          _schedulePreview();
                        },
                      ),
                      const V2SectionLabel('Reading tracks'),
                      for (var i = 0;
                          i < _drafts.length;
                          i++)
                        _TrackCard(
                          draft: _drafts[i],
                          onStart: () => _pickStart(i),
                          onEnd: () => _pickEnd(i),
                          onRemove: _drafts.length > 1
                              ? () => setState(() {
                                    _drafts.removeAt(i);
                                    _schedulePreview();
                                  })
                              : null,
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _drafts.add(_TrackDraftV2());
                          _schedulePreview();
                        }),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add track'),
                      ),
                      if (_overlaps())
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error
                                  .withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                  color: theme.colorScheme.error
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '⚠ Tracks overlap — shared verses are counted once in the preview below.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      const V2SectionLabel('Duration'),
                      V2Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: _days,
                                    min: 1,
                                    max: 730,
                                    divisions: 730,
                                    label: '${_days.toInt()} days',
                                    onChanged: (v) {
                                      setState(() {
                                        _days = v;
                                        _daysController.text =
                                            v.toInt().toString();
                                      });
                                      _schedulePreview();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 76,
                                  child: TextField(
                                    controller: _daysController,
                                    keyboardType:
                                        TextInputType.number,
                                    decoration: InputDecoration(
                                      suffixText: 'days',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10),
                                    ),
                                    onChanged: (v) {
                                      final n =
                                          int.tryParse(v) ?? 0;
                                      if (n >= 1 && n <= 730) {
                                        setState(
                                            () => _days = n.toDouble());
                                        _schedulePreview();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: [30, 60, 90, 180, 365]
                                  .map((d) => ChoiceChip(
                                        label: Text('$d'),
                                        selected:
                                            _days.toInt() == d,
                                        onSelected: (_) {
                                          setState(() {
                                            _days = d.toDouble();
                                            _daysController.text =
                                                '$d';
                                          });
                                          _schedulePreview();
                                        },
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const V2SectionLabel('Start, rest & reminder'),
                      V2Card(
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                  Icons.calendar_month_rounded),
                              title: const Text('Start date'),
                              subtitle: Text(
                                  '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')} (${_weekdayShort(appWeekday(_startDate))})'),
                              trailing: const Icon(
                                  Icons.chevron_right_rounded),
                              onTap: () async {
                                final picked =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(
                                          days: 30)),
                                  lastDate: DateTime.now().add(
                                      const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(
                                      () => _startDate = picked);
                                }
                              },
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              child: Row(
                                children: [
                                  const Expanded(
                                      child:
                                          Text('Rest days (neutral)')),
                                  _RestChip(
                                      label: 'None',
                                      selected: _restDay == null,
                                      onTap: () => setState(
                                          () => _restDay = null)),
                                  const SizedBox(width: 6),
                                  _RestChip(
                                      label: 'Sat',
                                      selected: _restDay == 7,
                                      onTap: () => setState(
                                          () => _restDay = 7)),
                                  const SizedBox(width: 6),
                                  _RestChip(
                                      label: 'Sun',
                                      selected: _restDay == 1,
                                      onTap: () => setState(
                                          () => _restDay = 1)),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Daily reminder'),
                              subtitle: Text(_reminder
                                  ? 'At ${_reminderTime.format(context)}'
                                  : 'Off'),
                              value: _reminder,
                              onChanged: (v) async {
                                if (v) {
                                  final picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: _reminderTime,
                                  );
                                  if (picked == null) return;
                                  setState(() {
                                    _reminder = true;
                                    _reminderTime = picked;
                                  });
                                } else {
                                  setState(
                                      () => _reminder = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const V2SectionLabel('Live preview'),
                      V2Card(
                        featured: true,
                        child: _preview == null
                            ? Text(
                                'Add at least one track above to preview the word-balanced schedule.',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const V2Eyebrow(
                                      'Word-balanced · pericope-aware'),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_preview!.days} days · ${_preview!.schedule.length} reading days',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_preview!.wasClamped &&
                                      _preview!.clampReason !=
                                          null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '⚠ ${_preview!.clampReason} Title updated to the real day count.',
                                      style: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.error,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  for (var i = 0;
                                      i <
                                          _preview!.schedule.length
                                              .clamp(0, 3);
                                      i++)
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 3),
                                      child: Text(
                                        'Day ${_preview!.schedule[i].dayNumber}: ${_preview!.schedule[i].portions.map((p) => '${p.book} ${p.startChapter}').join(' · ')}',
                                        style: theme
                                            .textTheme.bodySmall,
                                      ),
                                    ),
                                  if (_preview!.schedule.length > 3)
                                    Text(
                                      '⋯ ${_preview!.schedule.length - 3} more balanced days',
                                      style: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (_preview == null ||
                                  _titleController.text
                                      .trim()
                                      .isEmpty ||
                                  _isSaving)
                              ? null
                              : _save,
                          child: Text(_isSaving
                              ? 'Saving…'
                              : 'Generate & save plan →'),
                        ),
                      ),
                      if (_preview == null ||
                          _titleController.text.trim().isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(
                            'Name the plan and add at least one track to continue.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
      ),
    );
  }

  String _weekdayShort(int appDay) {
    const names = ['', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return (appDay >= 1 && appDay <= 7) ? names[appDay] : '';
  }
}

class _TrackCard extends StatelessWidget {
  final _TrackDraftV2 draft;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback? onRemove;
  const _TrackCard({
    required this.draft,
    required this.onStart,
    required this.onEnd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String fmt(BibleBook? b, int c, int v, bool end) {
      if (b == null) return end ? 'End…' : 'Start…';
      return '${b.name} $c:$v';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _RefBox(
                    label: 'START',
                    value: fmt(draft.startBook,
                        draft.startChapter, draft.startVerse, false),
                    onTap: onStart),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RefBox(
                    label: 'END',
                    value: fmt(draft.endBook, draft.endChapter,
                        draft.endVerse, true),
                    onTap: onEnd),
              ),
            ],
          ),
          if (onRemove != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRemove,
                child: Text('Remove track',
                    style: TextStyle(
                        color: theme.colorScheme.error)),
              ),
            ),
        ],
      ),
    );
  }
}

class _RefBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _RefBox(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.55),
                )),
            const SizedBox(height: 2),
            Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

class _RestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RestChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.primaryColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
