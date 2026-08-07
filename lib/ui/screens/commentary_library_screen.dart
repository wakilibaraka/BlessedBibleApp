import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../../state/commentary_provider.dart';
import 'commentary_hub_screen.dart';

/// A simple list of all books/chapters that have commentary.
/// Reachable from the CommentaryBanner on chapters with no commentary.
class CommentaryLibraryScreen extends ConsumerWidget {
  const CommentaryLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final commentaryList = ref.watch(commentaryProvider).value ?? [];

    // Build a structured map: book -> sorted unique chapter numbers
    final Map<String, Set<int>> covered = {};
    for (final entry in commentaryList) {
      final book = entry.scope.book;
      if (book == null) continue;
      final chapter = entry.scope.chapter;
      if (chapter == null) continue;
      covered.putIfAbsent(book, () => {}).add(chapter);
    }

    // Canonical display order
    const bookOrder = ['Daniel', 'Hebrews', 'Revelation'];
    final books = bookOrder.where(covered.containsKey).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.primaryColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Commentary Library',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      body: books.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No commentary available yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              separatorBuilder: (_, __) => Divider(
                indent: 20,
                endIndent: 20,
                color: theme.dividerColor.withValues(alpha: 0.25),
              ),
              itemCount: books.length,
              itemBuilder: (context, bookIndex) {
                final book = books[bookIndex];
                final chapters = (covered[book]!.toList()..sort());
                return _BookSection(
                  book: book,
                  chapters: chapters,
                  theme: theme,
                );
              },
            ),
    );
  }
}

class _BookSection extends StatelessWidget {
  final String book;
  final List<int> chapters;
  final ThemeData theme;

  const _BookSection({
    required this.book,
    required this.chapters,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.library_books_rounded,
                  size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                book,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        ...chapters.map(
          (chapter) => ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
            dense: true,
            title: Text(
              '$book $chapter',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => CommentaryHubScreen(
                  book: book,
                  chapter: chapter,
                  verse: null,
                ),
              ));
            },
          ),
        ),
      ],
    );
  }
}
