import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/textured_glass_container.dart';
import '../../state/notes_provider.dart';
import '../../state/user_data_provider.dart';
import '../screens/read_screen.dart' show VerseActionLogic;
import '../widgets/highlight_torch_icon.dart';
import '../../state/bible_provider.dart';

class VerseContextMenuSheet extends ConsumerWidget {
  final int verseNumber;
  final String bookName;
  final int chapterNum;
  final VoidCallback onCustomSelection;

  const VerseContextMenuSheet({
    super.key,
    required this.verseNumber,
    required this.bookName,
    required this.chapterNum,
    required this.onCustomSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookAbbrev = _getBookAbbrev(ref, bookName);
    final verseKey = generateVerseKey(bookAbbrev, chapterNum, verseNumber);


    final hasNote = ref.watch(notesProvider).any((n) => n.reference == verseKey);
    final isHighlighted = ref.watch(highlightsProvider).containsKey(verseKey);

    final targetVerses = [verseNumber];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$bookName $chapterNum:$verseNumber',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _MenuButton(
                        icon: const HighlightTorchIcon(size: 24),
                        label: isHighlighted ? 'Highlighted' : 'Highlight',
                        color: isHighlighted ? Colors.amber.shade600 : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          VerseActionLogic.handleHighlightInteraction(
                            context: context,
                            ref: ref,
                            theme: theme,
                            bookName: bookName,
                            chapterNum: chapterNum,
                            targetVerses: targetVerses,
                            isLongPress: false,
                            onClearSelection: () {},
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _MenuButton(
                        icon: Icon(Icons.text_format_rounded, size: 24),
                        label: 'Selection',
                        onTap: () {
                          Navigator.of(context).pop();
                          onCustomSelection();
                        },
                      ),
                    ),
                    Expanded(
                      child: _MenuButton(
                        icon: Icon(Icons.edit_document, size: 24),
                        label: hasNote ? 'Edit Note' : 'Note',
                        color: hasNote ? Colors.blue.shade600 : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          VerseActionLogic.handleNote(
                            context, ref, theme, bookName, chapterNum, targetVerses,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _MenuButton(
                        icon: Icon(Icons.ios_share_rounded, size: 24),
                        label: 'Share',
                        onTap: () {
                          Navigator.of(context).pop();
                          VerseActionLogic.handleShare(
                            context, ref, bookName, chapterNum, targetVerses,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getBookAbbrev(WidgetRef ref, String fullBookName) {
    final bibleState = ref.read(bibleProvider);
    if (!bibleState.isLoading && bibleState.books.isNotEmpty) {
      for (final book in bibleState.books) {
        if (book.name == fullBookName) return book.abbreviation;
      }
    }
    // Fallback if not found
    return fullBookName.substring(0, 3).toUpperCase();
  }


}

class _MenuButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color != null
                  ? color!.withValues(alpha: 0.15)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: color ?? theme.colorScheme.onSurface,
                size: 24,
              ),
              child: icon,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
