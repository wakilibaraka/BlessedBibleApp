import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../state/theme_provider.dart';
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

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.pop:
          return const Color(0xFFF4F5F7);
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return tokens.readingPaper;
      }
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
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
