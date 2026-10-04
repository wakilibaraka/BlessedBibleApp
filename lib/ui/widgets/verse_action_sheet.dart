import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/read_location_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/read_settings_provider.dart';
import '../screens/read_screen.dart' show VerseActionLogic;
import 'textured_glass_container.dart';

/// Compact Apple-style action sheet for a verse selection.
///
/// Replaces the old 420pt in-dock stack: the dock keeps its 64pt height
/// and this short sheet floats above it.
///
/// Height contract: the sheet never exceeds [kVerseSheetMaxHeight]
/// (a fraction of the screen) so it stays visually at the bottom rather
/// than climbing up the page, and it clears the nav dock by
/// [kDockClearance] so the dock and FAB are never covered.
const double kVerseSheetMaxHeightFactor = 0.26;
const double kDockClearance = 84.0;

/// One action in the sheet row.
class _SheetAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
}

/// Shows the compact sheet for the current selection.
/// Returns false when there is nothing selected (caller may fall back).
Future<bool> showVerseActionSheet(BuildContext context, WidgetRef ref) async {
  final selected = ref.read(readSelectionProvider);
  if (selected.isEmpty) return false;

  final readLoc = ref.read(readLocationProvider);
  final theme = Theme.of(context);
  final verses = selected.toList()..sort();
  final bookmarks = ref.read(bookmarksProvider);
  final bookAbbrev = _bookAbbrev(ref, readLoc.bookName);
  final allBookmarked = verses.every((v) =>
      bookmarks.contains(generateVerseKey(bookAbbrev, readLoc.chapter, v)));

  HapticFeedback.lightImpact();
  final keepOpen = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (ctx) => _VerseActionSheet(
      contextLabel: _contextLabel(readLoc.bookName, readLoc.chapter, verses),
      actionCount: verses.length,
      actions: [
        _SheetAction(
          icon: allBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          label: allBookmarked ? 'Saved' : 'Save',
          active: allBookmarked,
          onTap: () {
            VerseActionLogic.handleBookmark(ctx, theme, ref,
                readLoc.bookName, readLoc.chapter, verses);
          },
        ),
        _SheetAction(
          icon: Icons.color_lens_rounded,
          label: 'Highlight',
          onTap: () =>
              ref.read(readSettingsProvider.notifier).cycleHighlightColor(),
        ),
        _SheetAction(
          icon: Icons.note_add_outlined,
          label: 'Note',
          onTap: () => VerseActionLogic.handleNote(
              ctx, ref, theme, readLoc.bookName, readLoc.chapter, verses),
        ),
        _SheetAction(
          icon: Icons.menu_book_rounded,
          label: 'Study',
          onTap: () => VerseActionLogic.handleCommentary(
              ctx, ref, readLoc.bookName, readLoc.chapter, verses.first,
              verses),
        ),
        _SheetAction(
          icon: Icons.ios_share_rounded,
          label: 'Share',
          onTap: () async {
            await VerseActionLogic.handleShareOptions(
                ctx, ref, readLoc.bookName, readLoc.chapter, verses);
          },
        ),
      ],
    ),
  );

  // Any action that didn't itself clear the selection does it here.
  if (keepOpen != true) {
    ref.read(readSelectionProvider.notifier).clear();
  }
  return true;
}

String _contextLabel(String book, int chapter, List<int> verses) {
  final count = verses.length;
  final noun = count == 1 ? 'verse' : 'verses';
  final range = count == 1
      ? '$book $chapter:${verses.first}'
      : (verses.length == 2 && verses[1] == verses[0] + 1
          ? '$book $chapter:${verses.first}-${verses.last}'
          : '$book $chapter');
  return '$count $noun selected · $range';
}

String _bookAbbrev(WidgetRef ref, String bookName) {
  final books = ref.read(bibleProvider).books;
  if (books.isNotEmpty) {
    for (final b in books) {
      if (b.name == bookName) return b.abbreviation;
    }
  }
  return bookName.length >= 3 ? bookName.substring(0, 3) : bookName;
}

class _VerseActionSheet extends StatelessWidget {
  final String contextLabel;
  final int actionCount;
  final List<_SheetAction> actions;

  const _VerseActionSheet({
    required this.contextLabel,
    required this.actionCount,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height *
        kVerseSheetMaxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        // Clears the nav dock + FAB so neither is ever covered.
        bottom: kDockClearance + MediaQuery.paddingOf(context).bottom,
      ),
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                contextLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Apple-standard proportions: 56pt targets, 20pt icons,
            // 11pt labels, even spacing.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final a in actions)
                    _SheetActionButton(action: a),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final _SheetAction action;
  const _SheetActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.active
        ? theme.primaryColor
        : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      label: action.label,
      child: ExcludeSemantics(
        child: CupertinoButton(
          // 56pt square target, zero chrome: a bare tap surface.
          padding: EdgeInsets.zero,
          minimumSize: const Size(56, 56),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop(true); // keep the sheet open (no clear)
            action.onTap();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 20, color: color),
              const SizedBox(height: 3),
              Text(
                action.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
