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

    const canonicalOrder = [
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
      '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
      'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
      'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
      'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
      'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy',
      'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation',
    ];

    final availableBooks = canonicalOrder.where(covered.containsKey).toList();
    
    final otBooks = availableBooks.where((b) => canonicalOrder.indexOf(b) < 39).toList();
    final ntBooks = availableBooks.where((b) => canonicalOrder.indexOf(b) >= 39).toList();

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
      body: availableBooks.isEmpty
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
          : CustomScrollView(
              slivers: [
                if (otBooks.isNotEmpty)
                  _buildSectionHeader(context, 'Old Testament'),
                if (otBooks.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = otBooks[index];
                        return _BookSection(
                          book: book,
                          chapters: covered[book]!.toList()..sort(),
                          theme: theme,
                        );
                      },
                      childCount: otBooks.length,
                    ),
                  ),
                if (ntBooks.isNotEmpty)
                  _buildSectionHeader(context, 'New Testament'),
                if (ntBooks.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = ntBooks[index];
                        return _BookSection(
                          book: book,
                          chapters: covered[book]!.toList()..sort(),
                          theme: theme,
                        );
                      },
                      childCount: ntBooks.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _BookSection extends StatefulWidget {
  final String book;
  final List<int> chapters;
  final ThemeData theme;

  const _BookSection({
    required this.book,
    required this.chapters,
    required this.theme,
  });

  @override
  State<_BookSection> createState() => _BookSectionState();
}

class _BookSectionState extends State<_BookSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.library_books_rounded,
                  size: 18,
                  color: widget.theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.book,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.chapters.length} ch',
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: widget.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          ...widget.chapters.map(
            (chapter) => ListTile(
              contentPadding: const EdgeInsets.only(left: 52, right: 20),
              dense: true,
              title: Text(
                'Chapter $chapter',
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => CommentaryHubScreen(
                    book: widget.book,
                    chapter: chapter,
                    verse: null,
                  ),
                ));
              },
            ),
          ),
        Divider(
          indent: 20,
          endIndent: 20,
          height: 1,
          color: widget.theme.dividerColor.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
