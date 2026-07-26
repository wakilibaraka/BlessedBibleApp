import re

with open('lib/ui/screens/new_search_screen.dart', 'r') as f:
    content = f.read()

# Change to ConsumerWidget
content = content.replace("class NewSearchScreen extends ConsumerStatefulWidget", "class NewSearchScreen extends ConsumerWidget")
content = content.replace("""  @override
  ConsumerState<NewSearchScreen> createState() => _NewSearchScreenState();
}

class _NewSearchScreenState extends ConsumerState<NewSearchScreen> with SingleTickerProviderStateMixin {""", """  @override
  Widget build(BuildContext context, WidgetRef ref) {""")

# Remove initState and dispose
content = re.sub(r'  late TextEditingController _controller;.*?@override\n  void dispose\(\) \{.*?super\.dispose\(\);\n  \}', '', content, flags=re.DOTALL)

# Fix _onResultTap and _buildResultBadge by passing ref and theme
content = content.replace("void _onResultTap(SearchResult result)", "void _onResultTap(SearchResult result, WidgetRef ref)")
content = content.replace("Widget _buildResultBadge(SearchResult result, ThemeData theme)", "Widget _buildResultBadge(SearchResult result, ThemeData theme)")

# Replace the build method start (since we moved it up)
content = re.sub(r'  @override\n  Widget build\(BuildContext context\) \{.*?    final searchState = ref\.watch\(searchStateProvider\);', '    final searchState = ref.watch(searchStateProvider);', content, flags=re.DOTALL)

# Fix TOP HEADER
header_start = content.find('            // TOP HEADER')
header_end = content.find('            // RESULTS LIST')
new_header = """            // TOP HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
                  const Spacer(),
                  if (searchState.isSearching)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (searchState.isSearching) const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 28),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
"""
content = content[:header_start] + new_header + content[header_end:]

# Fix Bottom Padding and TextField removal
bottom_search_start = content.find('            // FIXED BOTTOM SEARCH BAR')
bottom_search_end = content.find('  }', bottom_search_start)

# We want to keep the ADVANCED FILTERS PANEL, but remove the TEXT FIELD.
# So we'll just rewrite that whole section.
new_bottom = """            // FIXED BOTTOM AREA (Filters only)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 116.0, // clear nav bar
                left: 16,
                right: 16,
                top: 8,
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: searchState.showFilters
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Advanced Filters',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => ref.read(searchStateProvider.notifier).toggleFilters(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  label: const Text('Old Testament'),
                                  selected: searchState.filterOt,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleOtFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.primaryContainer,
                                ),
                                FilterChip(
                                  label: const Text('New Testament'),
                                  selected: searchState.filterNt,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleNtFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.primaryContainer,
                                ),
                                FilterChip(
                                  label: const Text('Commentary'),
                                  selected: searchState.filterCommentary,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleCommentaryFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: Colors.purple.shade100,
                                ),
                                FilterChip(
                                  label: const Text('Notes'),
                                  selected: searchState.filterNotes,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleNotesFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: Colors.orange.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
"""
content = content[:bottom_search_start] + new_bottom + content[bottom_search_end:]

# Update _onResultTap calls
content = content.replace("onTap: () => _onResultTap(result),", "onTap: () => _onResultTap(result, ref),")

with open('lib/ui/screens/new_search_screen.dart', 'w') as f:
    f.write(content)

