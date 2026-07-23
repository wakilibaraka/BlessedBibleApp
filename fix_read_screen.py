with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

target = """                                      onNotification: (notification) {
                                        if (notification.direction == ScrollDirection.reverse) {"""

replacement = """                                      onNotification: (notification) {
                                        final alwaysShow = ref.read(bibleNavSettingsProvider).alwaysShowNav;
                                        if (alwaysShow) return false;
                                        
                                        if (notification.direction == ScrollDirection.reverse) {"""

content = content.replace(target, replacement)

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)

print("Fixed read_screen.dart")
