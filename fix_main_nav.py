with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("iconData = navSettings.manualMinimizeNav ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded;", "iconData = ref.watch(immersiveModeProvider) ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded;")
content = content.replace("key: ValueKey<int>(currentIndex * 10 + (navSettings.manualMinimizeNav ? 1 : 0)),", "key: ValueKey<int>(currentIndex * 10 + (ref.watch(immersiveModeProvider) ? 1 : 0)),")
content = content.replace("ref.read(navSettingsProvider.notifier).toggleManualMinimize();", "ref.read(immersiveModeProvider.notifier).toggle();")

# We also need to add 'WidgetRef ref' to _buildFabIcon if it doesn't have it.
content = content.replace("Widget _buildFabIcon(int currentIndex, NavSettingsState navSettings)", "Widget _buildFabIcon(int currentIndex, NavSettingsState navSettings, WidgetRef ref)")
content = content.replace("_buildFabIcon(currentIndex, navSettings)", "_buildFabIcon(currentIndex, navSettings, ref)")

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

print("Fixed main_nav_screen.dart")
