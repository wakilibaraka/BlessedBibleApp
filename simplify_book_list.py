import sys

with open('lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

start_str = "    switch (settings.layout) {"
end_str = "  Widget _buildChapterSelection(ThemeData theme, BibleNavSettingsState settings) {"

start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx != -1 and end_idx != -1:
    switch_block = content[start_idx:end_idx]
    
    # We want to extract just the `sideBySide` block
    side_idx = switch_block.find("case TestamentLayout.sideBySide:")
    sticky_idx = switch_block.find("case TestamentLayout.stickySections:")
    
    side_by_side_code = switch_block[side_idx + len("case TestamentLayout.sideBySide:"):sticky_idx].strip()
    
    # Let's replace the whole switch with side_by_side_code
    new_content = content[:start_idx] + "    return " + side_by_side_code[6:] + "\n\n" + content[end_idx:]
    # side_by_side_code starts with `return Row(` so `side_by_side_code[6:]` might not be necessary, we can just dump the code verbatim.
    new_content = content[:start_idx] + "    " + side_by_side_code + "\n\n" + content[end_idx:]
    
    with open('lib/ui/screens/read_screen.dart', 'w') as f:
        f.write(new_content)
    print("Simplified book list.")
else:
    print("Could not find start/end.")
