import sys
f = 'lib/ui/screens/settings_screen.dart'
with open(f, 'r') as file:
    content = file.read()

# 1. Imports
if 'package_info_plus.dart' not in content:
    content = content.replace("import '../widgets/shared_app_bar.dart';", "import '../widgets/shared_app_bar.dart';\nimport 'package:package_info_plus/package_info_plus.dart';\nimport 'package:url_launcher/url_launcher.dart';\nimport 'privacy_policy_screen.dart';")

# 2. PackageInfo provider
if 'packageInfoProvider' not in content:
    content = content.replace('class SettingsScreen extends StatelessWidget {', 'final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {\n  return await PackageInfo.fromPlatform();\n});\n\nclass SettingsScreen extends StatelessWidget {')

# 3. Add to READING group
new_reading_toggles = """            Consumer(builder: (context, ref, _) {
              final isRedLetter = ref.watch(readSettingsProvider.select((s) => s.isRedLetterEnabled));
              return SwitchListTile(
                title: const Text('Words of Jesus in Red'),
                subtitle: const Text('Render words spoken by Jesus in red'),
                value: isRedLetter,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setRedLetterEnabled(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final showNumbers = ref.watch(readSettingsProvider.select((s) => s.showVerseNumbers));
              return SwitchListTile(
                title: const Text('Show Verse Numbers'),
                subtitle: const Text('Display verse numbers in the text'),
                value: showNumbers,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setShowVerseNumbers(val);
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final keepAwake = ref.watch(readSettingsProvider.select((s) => s.keepScreenAwake));
              return SwitchListTile(
                title: const Text('Keep Screen Awake'),
                subtitle: const Text('Prevent device from sleeping while reading'),
                value: keepAwake,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ref.read(readSettingsProvider.notifier).setKeepScreenAwake(val);
                },
              );
            }),
"""

if 'Show Verse Numbers' not in content:
    target = """ref.read(readSettingsProvider.notifier).setVerseActionStyle(val);\n                },\n              );\n            }),"""
    if target in content:
        content = content.replace(target, target + '\n' + new_reading_toggles)
    else:
        print("Could not find the insertion point for READING group")

# 4. Add ABOUT section
about_section = """
          const SizedBox(height: 16),
          _buildSection(context, theme, 'ABOUT', [
            Consumer(builder: (context, ref, _) {
              final packageInfoAsync = ref.watch(packageInfoProvider);
              return ListTile(
                title: const Text('Version'),
                trailing: packageInfoAsync.when(
                  data: (info) => Text(info.version, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const Text('Unknown'),
                ),
              );
            }),
            ListTile(
              title: const Text('Send Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () async {
                HapticFeedback.selectionClick();
                final uri = Uri.parse('mailto:[Your Contact Email]?subject=The Blessed Bible Feedback');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
              },
            ),
          ]),
"""
if 'ABOUT' not in content:
    content = content.replace("          // Bottom padding to clear", about_section + "          // Bottom padding to clear")

with open(f, 'w') as file:
    file.write(content)
print('settings_screen.dart processed')
