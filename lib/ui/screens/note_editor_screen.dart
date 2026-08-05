import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/home_data.dart';
import '../../state/notes_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/animated_background.dart';

class _ParsedVerseData {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int verseNum;
  final String text;
  _ParsedVerseData({required this.bookAbbrev, required this.bookName, required this.chapter, required this.verseNum, required this.text});
}

_ParsedVerseData? _parseVerseRef(String refStr, List<FlatChapter> flatChapters) {
  final underscoreIdx = refStr.indexOf('_');
  if (underscoreIdx == -1) return null;
  final abbrevUpper = refStr.substring(0, underscoreIdx);
  final cvStr = refStr.substring(underscoreIdx + 1);
  final cvParts = cvStr.split(':');
  if (cvParts.length != 2) return null;
  final chapter = int.tryParse(cvParts[0]);
  final verseNum = int.tryParse(cvParts[1]);
  if (chapter == null || verseNum == null) return null;
  final fcIndex = flatChapters.indexWhere((c) => c.book.abbreviation.toUpperCase() == abbrevUpper && c.chapter.number == chapter);
  if (fcIndex == -1) return null;
  final fc = flatChapters[fcIndex];
  final vIndex = fc.chapter.verses.indexWhere((v) => v.number == verseNum);
  if (vIndex == -1) return null;
  return _ParsedVerseData(bookAbbrev: fc.book.abbreviation, bookName: fc.book.name, chapter: chapter, verseNum: verseNum, text: fc.chapter.verses[vIndex].text);
}

class AppleNotesController extends TextEditingController {
  AppleNotesController({super.text});

  List<TextSpan> _parseMarkdown(String text, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    final RegExp exp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|__.*?__)');
    int start = 0;
    
    for (final match in exp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: baseStyle));
      }
      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (matchedText.startsWith('__') && matchedText.endsWith('__')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle?.copyWith(decoration: TextDecoration.underline) ?? const TextStyle(decoration: TextDecoration.underline),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle?.copyWith(fontStyle: FontStyle.italic) ?? const TextStyle(fontStyle: FontStyle.italic),
        ));
      }
      start = match.end;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    return spans;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final String text = this.text;
    if (text.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    final lines = text.split('\n');
    final title = lines.first;
    final rest = lines.length > 1 ? '\n${lines.skip(1).join('\n')}' : '';

    final titleStyle = style?.copyWith(
          fontFamily: 'EB Garamond',
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontFamily: 'EB Garamond', fontSize: 28, fontWeight: FontWeight.w600);

    return TextSpan(
      children: [
        ..._parseMarkdown(title, titleStyle),
        if (rest.isNotEmpty) ..._parseMarkdown(rest, style),
      ],
    );
  }
}

class NoteEditorScreen extends ConsumerStatefulWidget {
  final PersonalNote? initialNote;
  final int? noteIndex;

  const NoteEditorScreen({super.key, this.initialNote, this.noteIndex});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late AppleNotesController _controller;
  late String _dateStamp;

  @override
  void initState() {
    super.initState();
    String initialText = '';
    if (widget.initialNote != null) {
      final title = widget.initialNote!.title;
      final content = widget.initialNote!.content;
      if (title.isNotEmpty) {
        initialText = title;
        if (content.isNotEmpty) {
          initialText += '\n$content';
        }
      } else {
        initialText = content;
      }
      _dateStamp = widget.initialNote!.date;
    } else {
      final now = DateTime.now();
      const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final month = months[now.month - 1];
      var hour = now.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) hour = 12;
      if (hour > 12) hour -= 12;
      final minute = now.minute.toString().padLeft(2, '0');
      _dateStamp = '$month ${now.day}, ${now.year} at $hour:$minute $ampm';
    }
    
    _controller = AppleNotesController(text: initialText);
  }

  @override
  void dispose() {
    _saveNote();
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty && widget.noteIndex == null) return;
    if (text.isEmpty && widget.noteIndex != null) {
       ref.read(notesProvider.notifier).remove(widget.noteIndex!);
       return;
    }

    final lines = text.split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : '';
    final content = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';

    final note = PersonalNote(title, content, _dateStamp, reference: widget.initialNote?.reference);

    if (widget.noteIndex != null) {
      ref.read(notesProvider.notifier).update(widget.noteIndex!, note);
    } else {
      ref.read(notesProvider.notifier).add(note);
    }
  }

  void _insertMarkdown(String tag) {
    final text = _controller.text;
    final selection = _controller.selection;
    if (selection.start == -1) return;
    
    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(selection.start, selection.end, '$tag$selectedText$tag');
    
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectedText.isEmpty ? selection.start + tag.length : selection.end + (tag.length * 2)),
    );
  }

  Widget _buildContextualVerseCard(BuildContext context, WidgetRef ref, String refStr, ThemeData theme) {
    final flatChapters = ref.watch(flatChaptersProvider);
    final data = _parseVerseRef(refStr, flatChapters);
    if (data == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 16, color: theme.primaryColor.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text('${data.bookName} ${data.chapter}:${data.verseNum}', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(data.text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          TextButton(
            onPressed: () => FocusScope.of(context).unfocus(),
            child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          SafeArea(
            child: Column(
              children: [
                if (widget.initialNote?.reference != null)
                  _buildContextualVerseCard(context, ref, widget.initialNote!.reference!, theme),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    _dateStamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'EB Garamond',
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.deepOrangeAccent.withValues(alpha: 0.5),
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'EB Garamond',
                        fontSize: 18,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
                        hintText: 'Start typing...',
                        hintStyle: TextStyle(
                          fontFamily: 'EB Garamond',
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.scaffoldBackgroundColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold_rounded),
                    onPressed: () => _insertMarkdown('**'),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic_rounded),
                    onPressed: () => _insertMarkdown('*'),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underlined_rounded),
                    onPressed: () => _insertMarkdown('__'),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
