import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../state/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/commentary_view.dart';

class CommentaryHubScreen extends ConsumerWidget {
  final String book;
  final int chapter;
  final int? verse;
  final String? verseText;

  const CommentaryHubScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
    this.verseText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final tokens = Theme.of(context).extension<ReadingTokens>()!;

    return Scaffold(
      backgroundColor: tokens.readingPaper,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: CommentaryView(
              book: book,
              chapter: chapter,
              verse: verse,
              verseText: verseText,
              isCompact: false,
            ),
          ),
        ],
      ),
    );
  }
}
