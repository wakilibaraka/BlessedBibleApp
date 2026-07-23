with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

# Fix the method signature
target_sig = "Widget _buildEndOfChapterBlock(FlatChapter fc, int pageIndex, ThemeData theme) {"
replacement_sig = "Widget _buildEndOfChapterBlock(FlatChapter fc, int pageIndex, ThemeData theme, bool hasChapterCommentary) {"
content = content.replace(target_sig, replacement_sig)

# Fix the call
target_call = "return _buildEndOfChapterBlock(fc, pageIndex, theme);"
replacement_call = "return _buildEndOfChapterBlock(fc, pageIndex, theme, hasChapterCommentary);"
content = content.replace(target_call, replacement_call)

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)

print("Fixed end chapter block")
