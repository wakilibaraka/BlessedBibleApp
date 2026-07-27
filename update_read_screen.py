import sys

f = 'lib/ui/screens/read_screen.dart'
with open(f, 'r') as file:
    content = file.read()

# 1. 'aA' to 'Aa'
content = content.replace("'aA',", "'Aa',")

# 2. Typography line height
content = content.replace('height: 1.6,', 'height: typography.lineHeight,')

# 3. Import wakelock_plus
if 'wakelock_plus.dart' not in content:
    content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:wakelock_plus/wakelock_plus.dart';")

# 4. showVerseNumbers
if 'if (readSettings.showVerseNumbers)' not in content:
    old_verse_num = '''          TextSpan(
            text: '${verse.number}  ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: typography.fontSize * 0.75, // Scale number down
            ),
          ),'''
    new_verse_num = '''          if (ref.watch(readSettingsProvider).showVerseNumbers)
          TextSpan(
            text: '${verse.number}  ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: typography.fontSize * 0.75, // Scale number down
            ),
          ),'''
    content = content.replace(old_verse_num, new_verse_num)

# 5. Add wakelock logic to build
wakelock_code = '''
    final readSettings = ref.watch(readSettingsProvider);
    if (readSettings.keepScreenAwake) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
'''
if 'WakelockPlus.enable' not in content:
    content = content.replace('final chapterTitles = ref.watch(chapterTitlesProvider);\n    final readSettings = ref.watch(readSettingsProvider);', 'final chapterTitles = ref.watch(chapterTitlesProvider);\n    final readSettings = ref.watch(readSettingsProvider);\n' + wakelock_code)

# 6. Add wakelock disable to dispose
if 'WakelockPlus.disable();' not in content.split('super.dispose();')[0]:
    content = content.replace('super.dispose();', 'WakelockPlus.disable();\n    super.dispose();')

# 7. Add line spacing control to bottom sheet
line_spacing_control = '''
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LINE SPACING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    typography.lineHeight <= 1.4 ? 'Compact' : (typography.lineHeight >= 1.8 ? 'Relaxed' : 'Normal'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: PillSegmentedControl(
                  segments: const ['Compact', 'Normal', 'Relaxed'],
                  selectedIndex: typography.lineHeight <= 1.4 ? 0 : (typography.lineHeight >= 1.8 ? 2 : 1),
                  onSegmentSelected: (index) {
                    HapticFeedback.selectionClick();
                    final heights = [1.3, 1.6, 1.9];
                    typographyNotifier.setLineHeight(heights[index]);
                  },
                ),
              ),
'''
if 'LINE SPACING' not in content:
    content = content.replace("              const SizedBox(height: 24),\n              Text(\n                'FONT FAMILY',", line_spacing_control + "              const SizedBox(height: 24),\n              Text(\n                'FONT FAMILY',")

# 8. All Settings Link
all_settings_link = '''
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    ref.read(navProvider.notifier).setTab(3); // Go to Settings tab
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  child: const Text('All Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
'''
if 'All Settings' not in content:
    content = content.replace('            ],\n          ),\n        ),\n        ),\n      ),\n    );\n  }\n}\n\nclass CommentaryBottomSheetContent', all_settings_link + '            ],\n          ),\n        ),\n        ),\n      ),\n    );\n  }\n}\n\nclass CommentaryBottomSheetContent')


with open(f, 'w') as file:
    file.write(content)
print('read_screen.dart processed')
