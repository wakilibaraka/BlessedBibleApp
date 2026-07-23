with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

import_statement = "import '../../state/immersive_mode_provider.dart';\n"
if import_statement not in content:
    # insert after the last import
    idx = content.rfind("import ")
    end_of_line = content.find("\n", idx)
    content = content[:end_of_line+1] + import_statement + content[end_of_line+1:]

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

print("Added import")
