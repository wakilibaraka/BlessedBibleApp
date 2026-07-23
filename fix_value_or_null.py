with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

target = """                                              bool hasChapterCommentary = false;
                                              final state = commentaryDataAsync.valueOrNull;
                                              if (state != null) {
                                                final bookCommentary = state[fc.book.name];
                                                if (bookCommentary != null) {
                                                  final chapterCommentary = bookCommentary[fc.chapter.number.toString()];
                                                  if (chapterCommentary != null && chapterCommentary.isNotEmpty) {
                                                    hasChapterCommentary = true;
                                                  }
                                                }
                                              }"""

replacement = """                                              bool hasChapterCommentary = false;
                                              commentaryDataAsync.whenData((state) {
                                                final bookCommentary = state[fc.book.name];
                                                if (bookCommentary != null) {
                                                  final chapterCommentary = bookCommentary[fc.chapter.number.toString()];
                                                  if (chapterCommentary != null && chapterCommentary.isNotEmpty) {
                                                    hasChapterCommentary = true;
                                                  }
                                                }
                                              });"""

content = content.replace(target, replacement)

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)

print("Fixed valueOrNull")
