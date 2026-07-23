import re

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

start_idx = content.find('class _CommentaryBottomSheetContent extends ConsumerStatefulWidget {')
end_idx = len(content)

if start_idx == -1:
    print("Could not find class boundary")
    exit(1)

new_class = """class _CommentaryBottomSheetContent extends ConsumerWidget {
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String verseText;

  const _CommentaryBottomSheetContent({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
  });

  void _showShareMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.bookmark_add_rounded, color: theme.primaryColor),
                  title: const Text('Save to Notes'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(f'Saved {bookName} {chapter}:{verseNumber} to Notes')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.ios_share_rounded, color: theme.primaryColor),
                  title: const Text('Share to other apps'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share dialog opened')),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      snap: true,
      builder: (context, scrollController) {
        return TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
          padding: EdgeInsets.zero,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Handlebar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header Row (Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    f'{bookName} {chapter}:{verseNumber}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Highlighted Verse Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TexturedGlassContainer(
                    padding: const EdgeInsets.all(20.0),
                    borderRadius: BorderRadius.circular(24),
                    child: Text(
                      f'{verseNumber} "{verseText}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Content & Floating CTA
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildCommentaryContent(commentaryDataAsync, theme, typography, scrollController),
                        ),
                      ),
                      
                      // Floating Action Pill
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 16,
                        child: TexturedGlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          borderRadius: BorderRadius.circular(30),
                          child: TextButton.icon(
                            onPressed: () => _showShareMenu(context, theme),
                            icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withOpacity(0.8), size: 20),
                            label: Text(
                              'Share',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget _buildCommentaryContent(AsyncValue<CombinedCommentaryState> commentaryDataAsync, ThemeData theme, TypographyState typography, ScrollController scrollController) {
    return commentaryDataAsync.when(
      data: (state) {
        final entries = state.data[bookName]?[chapter.toString()]?[verseNumber.toString()];
        
        if (entries == null || entries.isEmpty) {
          return ListView(
            controller: scrollController,
            children: const [
              SizedBox(height: 40),
              Center(child: Text('No commentary available.')),
            ],
          );
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 8.0, bottom: 100.0),
          itemCount: entries.length + (state.isEgwMissing ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == entries.length) {
              if (state.isEgwMissing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: Text(
                    'Local EGW module not found. Place EGW JSON files in your local directory to enable this commentary.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => ListView(controller: scrollController, children: const [SizedBox(height: 40), Center(child: CircularProgressIndicator())]),
      error: (error, stack) => ListView(controller: scrollController, children: const [SizedBox(height: 40), Center(child: Text('Error loading commentary'))]),
    );
  }
}
"""

new_class = new_class.replace("f'{bookName} {chapter}:{verseNumber}'", "'${bookName} ${chapter}:${verseNumber}'")
new_class = new_class.replace("f'{verseNumber} \"{verseText}\"'", "'${verseNumber} \"${verseText}\"'")
new_class = new_class.replace("f'Saved {bookName} {chapter}:{verseNumber} to Notes'", "'Saved ${bookName} ${chapter}:${verseNumber} to Notes'")

# Flutter 3.x uses withValues(alpha: ...) instead of withOpacity for Colors, but we'll use withValues(alpha:)
new_class = new_class.replace(".withOpacity(", ".withValues(alpha: ")

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content[:start_idx] + new_class + '\n')

print("Successfully replaced _CommentaryBottomSheetContent")
