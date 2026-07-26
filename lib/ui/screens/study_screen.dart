import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/study_provider.dart';
import '../widgets/verse_link_text.dart';
import '../../state/theme_provider.dart';
import '../widgets/textured_glass_container.dart';
import 'commentary_list_screen.dart';
import '../widgets/bouncy_entrance.dart';
import 'your_space_screen.dart' as your_space;

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  final List<String> _commentaryAuthors = [
    'Uriah Smith',
  ];
  int _currentAuthorIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentAuthorIndex = (_currentAuthorIndex + 1) % _commentaryAuthors.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    
    String subGreeting;
    switch (appThemeMode.resolve(context)) {
      case AppThemeMode.light:
        subGreeting = "Embrace the light of His word.";
        break;
      case AppThemeMode.dark:
      case AppThemeMode.automatic:
        subGreeting = "Rest in the peace of His promises.";
        break;
      case AppThemeMode.sepia:
        subGreeting = "Reflect on the ancient wisdom.";
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peace be with you,',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subGreeting,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Reading streaks coming soon!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 24),
                            const SizedBox(width: 4),
                            const Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notifications coming soon!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 28, color: theme.colorScheme.onSurface),
                            Container(
                              margin: const EdgeInsets.only(top: 2, right: 2),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // ── HERO CARD: Your Space ────────────────────────────
              _buildYourSpaceHero(context, theme),

              const SizedBox(height: 16),

              // ── MIDDLE 1: Active Reading Plan ─────────────────────
              _buildReadingPlanBanner(context, theme),

              const SizedBox(height: 16),

              // ── MIDDLE 2: Commentary ──────────────────────────────
              _buildCommentaryBanner(context, theme),

              const SizedBox(height: 16),

              // ── BOTTOM: Saved Verses ──────────────────────────────
              _buildSavedVersesCompact(context, theme),
              
              const SizedBox(height: 180), // Increased clearance for bottom nav so commentary isn't hidden
            ],
          ),
        ),
          ),
        ),
      ),
      
      // Removed local floatingActionButton as it is handled by main_nav_screen.dart
    );
  }

// Removed unused static popover functions

// Removed _showNotesPopover from here, moved to top level


  Widget _buildSavedVersesCompact(BuildContext context, ThemeData theme) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Saved Verses coming soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.surface.withValues(alpha: 0.3),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Icon(Icons.bookmark_rounded, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Verses',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your collected reflections',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildReadingPlanBanner(BuildContext context, ThemeData theme) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reading plans coming soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Reading Plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chronological Bible in a Year',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Day 203 • 4 Chapters',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: theme.primaryColor, size: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYourSpaceHero(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const your_space.YourSpaceScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.8),
              theme.primaryColor.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Space',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'View all your color-coded highlighted verses.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentaryBanner(BuildContext context, ThemeData theme) {
    final activeVerse = ref.watch(activeStudyVerseProvider);
    final commentaryAsync = ref.watch(combinedCommentaryProvider);

    String displayAuthor = 'Commentary';
    String displayReference = activeVerse ?? 'Genesis 1:1';
    String displaySnippet = 'Local EGW module not found. Place EGW JSON files in your local directory to enable this commentary.';

    if (activeVerse != null && commentaryAsync is AsyncData<CombinedCommentaryState>) {
      final state = commentaryAsync.value;
      
      // Parse activeVerse e.g. "Genesis 1:1"
      final parts = activeVerse.split(' ');
      if (parts.length >= 2) {
        final bookName = parts[0];
        final refParts = parts[1].split(':');
        if (refParts.length >= 2) {
          final chapter = refParts[0];
          final verse = refParts[1];
          
          final entries = state.data[bookName]?[chapter]?[verse];
          if (entries != null && entries.isNotEmpty) {
            final entry = entries.first;
            displayAuthor = 'Commentary';
            displaySnippet = '"${entry.text.split('. ').take(2).join('. ')}..."';
          } else if (!state.isEgwMissing) {
            displaySnippet = 'No commentary available for this verse.';
          }
        }
      }
    }

    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(28),
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.1),
              Colors.transparent,
              theme.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              String navBook = 'Revelation';
              String navChapter = '14';
              if (activeVerse != null) {
                final parts = activeVerse.split(' ');
                if (parts.length >= 2) {
                  navBook = parts[0];
                  final refParts = parts[1].split(':');
                  if (refParts.isNotEmpty) {
                    navChapter = refParts[0];
                  }
                }
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => CommentaryListScreen(bookName: navBook, chapterNumber: navChapter)));
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Commentary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.library_books_rounded, color: theme.primaryColor, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$displayAuthor • $displayReference',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VerseLinkText(
                    text: displaySnippet,
                    defaultStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    referenceStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    numberStyle: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'EXPLORE FULL COMMENTARY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showNotesPopover(BuildContext context, ThemeData theme) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return BouncyEntrance(
        delay: const Duration(milliseconds: 50),
        child: TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
          padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My Notes',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Icon(Icons.edit_note_rounded, size: 48, color: theme.primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No notes yet.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
        ),
      );
    },
  );
}
