import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/textured_glass_container.dart';
import '../../state/notes_provider.dart';
import '../../state/user_data_provider.dart';
import '../screens/read_screen.dart' show VerseActionLogic;
import '../../state/bible_provider.dart';
import 'package:flutter/cupertino.dart';
import '../screens/commentary_hub_screen.dart';

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

    final targetVerses = [verseNumber];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _MenuButton(
                          icon: const Icon(Icons.comment_bank_outlined, size: 24),
                          label: 'Commentary',
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => CommentaryHubScreen(
                                book: bookName,
                                chapter: chapterNum,
                                verse: verseNumber,
                              ),
                            ));
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
                      Expanded(
                        child: _MenuButton(
                          icon: Icon(Icons.crop_free_rounded, size: 24),
                          label: 'Select Text',
                          onTap: () {
                            Navigator.of(context).pop();
                            onCustomSelection();
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
    ));
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
