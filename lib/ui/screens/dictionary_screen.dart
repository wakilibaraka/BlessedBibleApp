import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../state/dictionary_search_provider.dart';
import '../widgets/dictionary_entry_sheet.dart';
import '../../state/dictionary_provider.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  String _searchQuery = '';
  Timer? _debounce;
  String? _currentDragLetter;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  void _jumpToLetter(String letter, Map<String, int> letterIndices) {
    if (letterIndices.containsKey(letter)) {
      final index = letterIndices[letter]!;
      _itemScrollController.jumpTo(index: index);
      if (_currentDragLetter != letter) {
        HapticFeedback.selectionClick();
        setState(() => _currentDragLetter = letter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(dictionarySearchProvider(_searchQuery));
    final bookmarkedWords = ref.watch(bookmarkedWordsProvider).asData?.value ?? {};

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Bible Dictionary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                placeholder: 'Search for Words',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2),
                  child: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
                ),
                suffixIcon: const Icon(Icons.cancel, size: 18),
                style: theme.textTheme.bodyMedium,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          // ── Results List ─────────────────────────────────────────
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }

                // Compute letter indices for the slider
                final Map<String, int> letterIndices = {};
                for (int i = 0; i < results.length; i++) {
                  final firstChar = results[i].displayHeadword[0].toUpperCase();
                  if (RegExp(r'[A-Z]').hasMatch(firstChar) && !letterIndices.containsKey(firstChar)) {
                    letterIndices[firstChar] = i;
                  }
                }
                final availableLetters = letterIndices.keys.toList()..sort();
                final showSlider = _searchQuery.isEmpty && availableLetters.length > 5;
                
                return Stack(
                  children: [
                    ScrollablePositionedList.separated(
                      itemScrollController: _itemScrollController,
                      padding: EdgeInsets.fromLTRB(16, 16, showSlider ? 36 : 16, 100),
                      itemCount: results.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        final isBookmarked = bookmarkedWords.contains(item.normalizedWord);
                        
                        return _DictionaryCard(
                          word: item.displayHeadword,
                          snippet: item.snippet,
                          isBookmarked: isBookmarked,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DictionaryEntrySheet(
                                normalizedWord: item.normalizedWord,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // A-Z Slider
                    if (showSlider)
                      Positioned(
                        right: 4,
                        top: 16,
                        bottom: 32,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double letterHeight = constraints.maxHeight / availableLetters.length;
                            return GestureDetector(
                              onVerticalDragStart: (details) {
                                final index = (details.localPosition.dy / letterHeight).floor().clamp(0, availableLetters.length - 1);
                                _jumpToLetter(availableLetters[index], letterIndices);
                              },
                              onVerticalDragUpdate: (details) {
                                final index = (details.localPosition.dy / letterHeight).floor().clamp(0, availableLetters.length - 1);
                                _jumpToLetter(availableLetters[index], letterIndices);
                              },
                              onVerticalDragEnd: (_) => setState(() => _currentDragLetter = null),
                              onTapUp: (_) => setState(() => _currentDragLetter = null),
                              child: Container(
                                width: 28,
                                color: Colors.transparent, // catch touches
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: availableLetters.map((letter) {
                                    final isActive = letter == _currentDragLetter;
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          letter,
                                          style: TextStyle(
                                            fontSize: isActive ? 14 : 11,
                                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                            color: isActive 
                                                ? theme.primaryColor 
                                                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  final String word;
  final String snippet;
  final bool isBookmarked;
  final VoidCallback onTap;

  const _DictionaryCard({
    required this.word,
    required this.snippet,
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.03),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (snippet.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isBookmarked)
              Icon(
                Icons.bookmark_rounded,
                size: 20,
                color: theme.primaryColor.withValues(alpha: 0.8),
              )
            else
              Icon(
                Icons.bookmark_border_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}
