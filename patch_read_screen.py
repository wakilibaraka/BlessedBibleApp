import sys

with open('lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

# 1. Update the scroll logic
old_scroll_logic = """                                      if (notification is UserScrollNotification) {
                                        if (notification.direction == ScrollDirection.reverse) {
                                          if (!isImmersive) {
                                            Future.microtask(() => ref.read(immersiveModeProvider.notifier).set(true));
                                          }
                                        } else if (notification.direction == ScrollDirection.forward) {
                                          if (isImmersive) {
                                            Future.microtask(() => ref.read(immersiveModeProvider.notifier).set(false));
                                          }
                                        }
                                      }
                                      return false;"""

new_scroll_logic = """                                      if (notification is UserScrollNotification) {
                                        if (notification.direction == ScrollDirection.reverse) {
                                          if (!isImmersive) {
                                            Future.microtask(() => ref.read(immersiveModeProvider.notifier).set(true));
                                          }
                                        }
                                      }
                                      return false;"""
content = content.replace(old_scroll_logic, new_scroll_logic)

# 2. Update the Positioned block
old_positioned = """                Positioned(
                  top: 0, left: 0, right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    offset: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? const Offset(0, -1) : Offset.zero,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? 0.0 : 1.0,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isScrolling,
                        builder: (context, isScrolling, _) {
                          final isGlassy = ref.watch(glassUiProvider) && !isScrolling;
                          final double nonGlassAlpha = 0.85;
                          return Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8.0, left: 24.0, right: 24.0),
                            child: SharedTopHeader(
                              leading: RepaintBoundary(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(navProvider.notifier).setIndex(0);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                              centerContent: RepaintBoundary(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      if (isGlassy)
                                        Positioned.fill(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                            child: const SizedBox.shrink(),
                                          ),
                                        ),
                                      GestureDetector(
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
                                            color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                                    ],
                                  ),
                                ),
                              ),
                              trailing: RepaintBoundary(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: GestureDetector(
                                    onTap: _showTypographyBottomSheet,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                          );
                        },
                      ),
                    ),
                  ),
                ),"""

new_positioned = """                Positioned(
                  top: 0, left: 0, right: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isScrolling,
                    builder: (context, isScrolling, _) {
                      final isGlassy = ref.watch(glassUiProvider) && !isScrolling;
                      final double nonGlassAlpha = 0.85;
                      
                      final hideSides = isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive;
                      final slideOffset = hideSides ? const Offset(0, -1) : Offset.zero;
                      final sideOpacity = hideSides ? 0.0 : 1.0;

                      return Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8.0, left: 24.0, right: 24.0),
                        child: SharedTopHeader(
                          leading: AnimatedSlide(
                            duration: const Duration(milliseconds: 350),
                            offset: slideOffset,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 350),
                              opacity: sideOpacity,
                              child: RepaintBoundary(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(navProvider.notifier).setIndex(0);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                          ),
                          centerContent: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  if (isGlassy)
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                        child: const SizedBox.shrink(),
                                      ),
                                    ),
                                  GestureDetector(
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
                                        color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                                ],
                              ),
                            ),
                          ),
                          trailing: AnimatedSlide(
                            duration: const Duration(milliseconds: 350),
                            offset: slideOffset,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 350),
                              opacity: sideOpacity,
                              child: RepaintBoundary(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: GestureDetector(
                                    onTap: _showTypographyBottomSheet,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(alpha: isGlassy ? 0.6 : nonGlassAlpha),
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
                      );
                    },
                  ),
                ),"""

content = content.replace(old_positioned, new_positioned)

with open('lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)
