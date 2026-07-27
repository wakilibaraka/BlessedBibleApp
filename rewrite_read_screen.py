import sys

with open('lib/ui/screens/read_screen.dart', 'r') as f:
    lines = f.readlines()

# Replace fullScreenNavigationVersePicker on lines 1592-1594
# Actually let's just find those lines and replace them.
for i, line in enumerate(lines):
    if "height: settings.fullScreenNavigationVersePicker" in line:
        lines[i] = "          height: MediaQuery.of(context).size.height * 0.85,\n"
        lines[i+1] = ""
        lines[i+2] = ""
        break

# Lines for the switch block are 1781 to 1988 (0-indexed 1780 to 1987)
# But wait, my line numbers above were modified by the view_file tool.
# Let's find exactly `switch (settings.layout) {`
switch_start = -1
switch_end = -1
for i, line in enumerate(lines):
    if "switch (settings.layout) {" in line:
        switch_start = i
    if "Widget _buildChapterSelection(" in line:
        switch_end = i - 1
        break

if switch_start != -1 and switch_end != -1:
    # We extract the `case TestamentLayout.sideBySide:`
    side_by_side_start = -1
    side_by_side_end = -1
    for i in range(switch_start, switch_end):
        if "case TestamentLayout.sideBySide:" in lines[i]:
            side_by_side_start = i + 1
        if "case TestamentLayout.stickySections:" in lines[i]:
            side_by_side_end = i
            break
            
    if side_by_side_start != -1 and side_by_side_end != -1:
        side_by_side_lines = lines[side_by_side_start:side_by_side_end]
        # Replace the whole switch block with side_by_side_lines
        # (remove leading 4 spaces because it's indented one level too deep inside the switch)
        dedented_lines = [line[4:] if line.startswith('    ') else line for line in side_by_side_lines]
        new_lines = lines[:switch_start] + dedented_lines + lines[switch_end:]
        with open('lib/ui/screens/read_screen.dart', 'w') as f:
            f.writelines(new_lines)
        print("Switch replaced.")
    else:
        print("sideBySide not found")
else:
    print("switch not found")

