import re

with open('lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

# 1. Change the root SizedBox height
content = content.replace(
    'final double height = (currentIndex == 1 && selectedVerses.isNotEmpty) ? 300.0 : 72.0;\n\n            return SizedBox(\n              height: height + 32.0,',
    'final double height = (currentIndex == 1 && selectedVerses.isNotEmpty) ? 420.0 : 72.0;\n\n            return SizedBox(\n              height: height + 32.0,'
)

# 2. Extract the Top Pill code from inside the TweenAnimationBuilder
top_pill_start = content.find('// ── Top Pill (Verse + Colors) ──')
top_pill_end = content.find('// ── Morphing FAB / Bottom Pill ──')

top_pill_code = content[top_pill_start:top_pill_end]

# 3. Remove the Top Pill from its current location
content = content[:top_pill_start] + content[top_pill_end:]

# 4. Insert the Top Pill into the root Stack, right after the Row
row_end = content.find('                            ),\n                          ),\n                        ),\n                        AnimatedContainer(')
if row_end == -1:
    print("Could not find Row end")
    exit(1)

# Find the end of the Positioned that contains the Row
# The Positioned starts at `Positioned(\n                    right: rightOffset,\n                    bottom: 16.0,`
pos_end = content.find('                    ),\n                  ),\n                ],\n              ),\n            );')

top_pill_modified = top_pill_code.replace(
    'Positioned(\n                                  bottom: height + 12.0,\n                                  right: 0,',
    'Padding(\n                                  padding: EdgeInsets.only(bottom: animHeight + 12.0),'
)
# Fix the isAction reference
top_pill_modified = top_pill_modified.replace('!isAction', '!(currentIndex == 1 && selectedVerses.isNotEmpty)')
top_pill_modified = top_pill_modified.replace('isVisible: isAction', 'isVisible: currentIndex == 1 && selectedVerses.isNotEmpty')


new_positioned = """
                  // Top Pill
                  Positioned(
                    right: rightOffset,
                    bottom: 16.0,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 56.0,
                        end: (currentIndex == 1 && selectedVerses.isNotEmpty) ? 380.0 : 56.0,
                      ),
                      builder: (context, animHeight, child) {
                        return """ + top_pill_modified.strip() + """;
                      }
                    ),
                  ),
"""

# Insert new_positioned before the end of the root Stack
content = content[:pos_end + 22] + new_positioned + content[pos_end + 22:]

with open('lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

