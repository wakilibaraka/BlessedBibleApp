with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'r') as f:
    content = f.read()

import_statement = "import 'commentary_list_screen.dart';\n"
if import_statement not in content:
    idx = content.rfind("import ")
    end_of_line = content.find("\n", idx)
    content = content[:end_of_line+1] + import_statement + content[end_of_line+1:]

with open('/Users/baraka/the_blessed_bible/lib/ui/screens/read_screen.dart', 'w') as f:
    f.write(content)

print("Added import to read_screen")
