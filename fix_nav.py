import re

with open('lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

# 1. Fix Tween end
content = re.sub(
    r'end: \(currentIndex == 1 && selectedVerses.isNotEmpty && \n\s*\(style == VerseActionStyle\.classic \|\| style == VerseActionStyle\.raindrop\)\) \n\s*\? 400\.0 \n\s*: kBottomDockHeight,',
    'end: (currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.classic) ? 400.0 : kBottomDockHeight,',
    content,
    flags=re.MULTILINE
)

# 2. Fix hit-test bounds for Raindrop Vertical Pill
content = re.sub(
    r'// Expand bounds to catch Raindrop Vertical Pill hits\n\s*if \(isRaindropAction\)\n\s*SizedBox\(width: kBottomDockHeight, height: height\),',
    '// Expand bounds to catch Raindrop Vertical Pill hits\n                                if (isRaindropAction)\n                                  SizedBox(width: kBottomDockHeight, height: 260),',
    content
)

# 3. Fix _buildActionMenuIcons spacing and padding
# Replace vertical padding
content = re.sub(
    r"padding: const EdgeInsets\.symmetric\(vertical: 16\.0\),",
    r"padding: const EdgeInsets.symmetric(vertical: 12.0),",
    content
)

# Replace spacing between icons
content = re.sub(
    r"const SizedBox\(height: 8\),",
    r"const SizedBox(height: 2),",
    content
)

with open('lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

print("Done")
