import sys
import re

with open('lib/ui/screens/settings_screen.dart', 'r') as f:
    content = f.read()

# Helper to find a block starting at a specific substring
def extract_consumer_block(text, identifier):
    idx = text.find(identifier)
    if idx == -1: return None, text
    
    start_idx = text.rfind('Consumer(builder: (context, ref, _) {', 0, idx)
    if start_idx == -1: return None, text
    
    brace_count = 0
    in_block = False
    for i in range(start_idx, len(text)):
        if text[i] == '{':
            brace_count += 1
            in_block = True
        elif text[i] == '}':
            brace_count -= 1
        
        if in_block and brace_count == 0:
            end_idx = text.find('}),', i)
            if end_idx != -1 and end_idx - i <= 2:
                block = text[start_idx:end_idx+3]
                last_nl = text.rfind('\n', 0, start_idx)
                actual_start = last_nl + 1 if last_nl != -1 else start_idx
                # keep track of commas if they trail
                comma_check = text.find(',', end_idx+3)
                if comma_check != -1 and not text[end_idx+3:comma_check].strip():
                   end_offset = comma_check + 1
                else:
                   end_offset = end_idx + 4
                return block, text[:actual_start] + text[end_offset:]
    return None, text

_, content = extract_consumer_block(content, "TestamentLayout")
_, content = extract_consumer_block(content, "fullScreenNavigationVersePicker")
_, content = extract_consumer_block(content, "useClassicSearch")

glow_block, content = extract_consumer_block(content, "BackgroundGlowStyle")
nav_depth_block, content = extract_consumer_block(content, "NavigationDepth")
swipe_down_block, content = extract_consumer_block(content, "Swipe Down to Open Navigation")
auto_close_block, content = extract_consumer_block(content, "autoCloseOnFinalSelection")
auto_open_block, content = extract_consumer_block(content, "autoOpenSingleSearchResult")

advanced_group = f"""
          _buildSection(context, 'Advanced', [
            {nav_depth_block},
            {auto_open_block},
            {auto_close_block},
            {swipe_down_block},
            {glow_block},
          ]),
"""

data_backup_idx = content.find("_buildSection(context, 'Data & Backup', [")
if data_backup_idx != -1:
    content = content[:data_backup_idx] + advanced_group + content[data_backup_idx:]

# Remove setFullScreenPicker from Reset to Default
reset_line = "await ref.read(bibleNavSettingsProvider.notifier).setFullScreenPicker(false);"
content = content.replace(reset_line, "")

with open('lib/ui/screens/settings_screen.dart', 'w') as f:
    f.write(content)
print('Settings screen refactored.')
