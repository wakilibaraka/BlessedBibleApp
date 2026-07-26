import sys

with open('lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

# 1. Update the ListView padding for immersive mode
content = content.replace(
    'top: MediaQuery.of(context).padding.top + 80.0,\n                                              left: 24.0, right: 24.0, bottom: 400.0),',
    'top: MediaQuery.of(context).padding.top + (isImmersive ? 16.0 : 64.0),\n                                              left: 24.0, right: 24.0, bottom: 400.0),'
)

# 2. Extract the header code that needs replacing
start_str = """                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? 0.0 : 1.0,
                      child: ClipRRect("""
                      
end_str = """                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),"""

start_idx = content.find(start_str)
if start_idx == -1:
    print("Could not find start_str")
    sys.exit(1)
    
end_idx = content.find(end_str, start_idx) + len(end_str)

new_header = """                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? 0.0 : 1.0,
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8.0, left: 24.0, right: 24.0),
                        child: SharedTopHeader(
                          leading: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(navProvider.notifier).setIndex(0);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withValues(alpha: 0.6),
                                      border: Border.all(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.book_rounded,
                                        size: 24,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          centerContent: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (isImmersive) {
                                      ref.read(immersiveModeProvider.notifier).set(false);
                                    } else {
                                      _showSelectorBottomSheet(allBooks);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withValues(alpha: 0.6),
                                      border: Border.all(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 180),
                                              child: MediaQuery(
                                                data: MediaQuery.of(context).copyWith(
                                                  textScaler: const TextScaler.linear(1.0),
                                                ),
                                                child: Text(
                                                  '$currentBookName $currentChapter',
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14).clamp(12.0, 18.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.keyboard_arrow_down_rounded, 
                                          size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          trailing: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                child: GestureDetector(
                                  onTap: _showTypographyBottomSheet,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withValues(alpha: 0.6),
                                      border: Border.all(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'aA',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),"""

content = content[:start_idx] + new_header + content[end_idx:]

with open('lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)
